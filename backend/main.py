from fastapi import FastAPI, Depends, HTTPException, status, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, File, UploadFile, Form
import base64
import shutil
import uuid
import os
from PIL import Image
import io
from pydantic import BaseModel, Base64Str
from typing import List, Optional
import psycopg2.extras
import bcrypt
from jwt import encode, decode, ExpiredSignatureError, InvalidTokenError
from datetime import datetime, timedelta
from database import get_db_connection

app = FastAPI()
# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SECRET_KEY = os.getenv("JWT_SECRET", "your_default_secret")
ALGORITHM = "HS256"

def create_token(user_id: int):
    expiration = datetime.utcnow() + timedelta(hours=1)
    return encode({"user_id": user_id, "exp": expiration}, SECRET_KEY, algorithm=ALGORITHM)

# Middleware to extract user from Bearer token
def get_current_user(authorization: str = Header(...)):
    print(f"🔍 Authorization header: {authorization}")  # Debugging

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token format")
    
    token = authorization.split("Bearer ")[1]
    
    try:
        decoded = decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        print(f"✅ Decoded Token: {decoded}")  # Debugging
        return decoded["user_id"]
    except ExpiredSignatureError:
        print("⏳ Token expired")  # Debugging
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except InvalidTokenError:
        print("❌ Invalid Token")  # Debugging
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

# ------------------
# Models
# ------------------
class LoginRequest(BaseModel):
    email: str
    password: str

class SignupRequest(BaseModel):
    name: str
    username: str
    email: str
    password: str
    gender: str
    current_location: str = "(0,0)"
    college: str
    interests: List[str]
    image: Optional[Base64Str] = None # using Base64 for simplicity

# For multipart/form-data approach (alternative, more robust):
class SignupRequestMultipart(BaseModel):  # separate model
    name: str
    username: str
    email: str
    password: str
    gender: str
    current_location: str = "(0,0)"
    college: str
    interests: List[str]

class PostCreate(BaseModel):
    title: str
    content: str
    community_id: int

class CommunityCreate(BaseModel):
    name: str
    description: Optional[str] = None
    # created_by: int
    primary_location: str  # Representing POINT as a string "(lat,lon)"

class VoteCreate(BaseModel):
    post_id: Optional[int] = None
    reply_id: Optional[int] = None
    vote_type: bool

class ReplyCreate(BaseModel):
    post_id: int
    content: str
    parent_reply_id: int | None = None

# ------------------
# Auth Endpoints
# ------------------
# --- Helper Functions ---

def save_image_from_base64(base64_string: str, username: str) -> str:
    """Decodes a Base64 string, saves it as an image, and returns the file path."""
    try:
        image_data = base64.b64decode(base64_string)
        image = Image.open(io.BytesIO(image_data))

        # Create the directory if it doesn't exist
        os.makedirs("user_images", exist_ok=True)

        # Create a unique filename. Use username and a UUID
        file_extension = image.format.lower()  # Get file extension (e.g., "jpeg")
        filename = f"{username}_{uuid.uuid4()}.{file_extension}"  # e.g., "johndoe_123e4567-e89b-12d3-a456-426614174000.jpeg"
        file_path = os.path.join("user_images", filename)  # e.g., "user_images/johndoe_123e4567-e89b-12d3-a456-426614174000.jpeg"
        image.save(file_path)
        return file_path
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving image: {e}")


async def save_image_multipart(image: UploadFile, username: str) -> str:
    """Saves an uploaded image and returns the file path."""
    try:
        # Create a unique filename. Use username and a UUID
        file_extension = image.filename.split(".")[-1].lower()  # Get file extension from original filename
        filename = f"{username}_{uuid.uuid4()}.{file_extension}" # e.g., "johndoe_123e4567-e89b-12d3-a456-426614174000.jpeg"
        file_path = os.path.join("user_images", filename)

        # Create the 'user_images' directory if it doesn't exist
        os.makedirs("user_images", exist_ok=True)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)  # Use shutil for efficient saving

        return file_path
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saving image: {e}")
    finally:
        await image.close()

# Base64 approach (simpler)
@app.post("/signup_base64")
async def signup_base64(request: SignupRequest):
    print(f"🔹 Signup Request (Base64): {request}")

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    hashed_password = bcrypt.hashpw(request.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    try:
        cursor.execute(
            """
            INSERT INTO users (name, username, email, password_hash, gender, current_location, college)
            VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;
            """,
            (request.name, request.username, request.email, hashed_password, request.gender, request.current_location, request.college)
        )
        user_id = cursor.fetchone()["id"]

        # --- Handle Image (Base64) ---
        image_path = None # Initialize to None.  Only set if there's an image.
        if request.image:
            image_path = save_image_from_base64(request.image, request.username)
            # Store the image_path in the database
            cursor.execute("UPDATE users SET image_path = %s WHERE id = %s;", (image_path, user_id))


        conn.commit()
        print(f"✅ User created with ID: {user_id} and image path: {image_path}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Signup Error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {
      "message": "User signed up successfully",
      "user_id": user_id,
      "image_path": image_path  # Include image path in the response
    }



# Multipart/form-data approach (more robust)
@app.post("/signup")  # More robust approach.
async def signup(
    name: str = Form(...),
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    gender: str = Form(...),
    current_location: str = Form("(0,0)"),
    college: str = Form(...),
    interests: List[str] = Form(...),  # Assuming you can handle list of strings in form data
    image: UploadFile = File(...)  # Image is required now
):

    # Create the Pydantic model instance from form data
    request = SignupRequestMultipart(name=name, username=username, email=email, password=password, gender=gender, current_location=current_location, college=college, interests=interests)


    print(f"🔹 Signup Request (Multipart): {request}")

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    try:
        cursor.execute(
            """
            INSERT INTO users (name, username, email, password_hash, gender, current_location, college)
            VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;
            """,
            (name, username, email, hashed_password, gender, current_location, college)
        )
        user_id = cursor.fetchone()["id"]

        # --- Handle Image (Multipart) ---
        image_path = await save_image_multipart(image, username)

        # Store the image_path (or URL if using cloud storage) in the database
        cursor.execute("UPDATE users SET image_path = %s WHERE id = %s;", (image_path, user_id))


        conn.commit()
        print(f"✅ User created with ID: {user_id} and image path: {image_path}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Signup Error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {
      "message": "User signed up successfully",
      "user_id": user_id,
      "image_path": image_path  # Include image path in response
    }

@app.post("/login")
def login(request: LoginRequest):
    print(f"🔹 Login Request: {request.email}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cursor.execute("SELECT id, password_hash FROM users WHERE email = %s", (request.email,))
    user = cursor.fetchone()
    conn.close()
    
    if not user:
        print("⚠️ User not found")  # Debugging
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    if not bcrypt.checkpw(request.password.encode('utf-8'), user["password_hash"].encode('utf-8')):
        print("⚠️ Incorrect password")  # Debugging
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    token = create_token(str(user["id"]))
    print(f"✅ Token generated for user {user['id']}")  # Debugging
    return {"token": token, "user_id": user["id"]}

@app.get("/me")
async def get_me(user_id: int = Depends(get_current_user)):
    print(f"🔹 Fetching user data for: {user_id}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cursor.execute(
        "SELECT id, name, username, email, gender,image_path, current_location, college, interests, created_at FROM users WHERE id = %s;",
        (user_id,)
    )
    user = cursor.fetchone()
    conn.close()
    if user:
        print(f"✅ User found: {user}")  # Debugging
        return user
    else:
        print("❌ User not found")  # Debugging
        raise HTTPException(status_code=404, detail="User not found")

# ------------------------
# Post Endpoints
# ------------------------

@app.post("/posts")
def create_post(post: PostCreate, user_id: int = Depends(get_current_user)):
    print(f"🔹 Creating post by user: {user_id}, Data: {post}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)  # ✅ Ensures dictionary-style rows

    try:
        user_id = int(user_id)  # Ensure integer

        print("SQL Query:", "INSERT INTO posts (user_id, content, title) VALUES (%s, %s, %s) RETURNING id;")
        print("Values:", (user_id, post.content, post.title))

        cursor.execute(
            "INSERT INTO posts (user_id, content, title) VALUES (%s, %s, %s) RETURNING id;",
            (user_id, post.content, post.title),
        )

        result = cursor.fetchone()
        print(f"🔍 Cursor Fetch Result: {result}")  # Debugging

        if not result:
            raise HTTPException(status_code=400, detail="Post creation failed: No ID returned")

        post_id = result["id"]  # ✅ Access by dictionary key
        conn.commit()
        print(f"✅ Post created with ID: {post_id}")  # Debugging

    except psycopg2.Error as e:
        conn.rollback()
        print(f"❌ SQL Error: {e.pgcode} - {e.pgerror}")  # Debugging
        raise HTTPException(status_code=400, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Unexpected Error: {repr(e)}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {"message": "Post created successfully", "post_id": post_id}


@app.get("/posts")
def get_posts():
    print("🔹 Fetching all posts")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, user_id, content, title, created_at FROM posts ORDER BY created_at DESC;")
    posts = cursor.fetchall()
    conn.close()
    print(f"✅ Fetched {len(posts)} posts")  # Debugging
    return {"posts": posts}

@app.delete("/posts/{post_id}")
def delete_post(post_id: int, user_id: int = Depends(get_current_user)):
    print(f"🔹 Deleting post ID: {post_id} by user: {user_id}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Check if the post exists and belongs to the current user
        cursor.execute("SELECT user_id FROM posts WHERE id = %s;", (post_id,))
        post = cursor.fetchone()
        
        if not post:
            raise HTTPException(status_code=404, detail="Post not found")
        
        if post[0] != user_id:
            raise HTTPException(status_code=403, detail="Unauthorized: You can only delete your own posts")
        
        # Delete the post
        cursor.execute("DELETE FROM posts WHERE id = %s;", (post_id,))
        conn.commit()
        print(f"✅ Post {post_id} deleted successfully")  # Debugging
    
    except psycopg2.Error as e:
        conn.rollback()
        print(f"❌ SQL Error: {e.pgcode} - {e.pgerror}")  # Debugging
        raise HTTPException(status_code=400, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Unexpected Error: {repr(e)}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    
    return {"message": "Post deleted successfully", "post_id": post_id}

# ------------------------
# Community Endpoints
# ------------------------

@app.post("/communities")
def create_community(community: CommunityCreate, user_id: int = Depends(get_current_user)):
    print(f"🔹 Creating community by user: {user_id}, Data: {community}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)  # ✅ Ensures dictionary-style rows

    try:
        user_id = int(user_id)  # Ensure integer
        primary_location = community.primary_location  # Assuming format "(lat,lon)"

        print("SQL Query:", "INSERT INTO communities (name, description, created_by, primary_location) VALUES (%s, %s, %s, %s) RETURNING id;")
        print("Values:", (community.name, community.description, user_id, primary_location))

        cursor.execute(
            "INSERT INTO communities (name, description, created_by, primary_location) VALUES (%s, %s, %s, %s) RETURNING id;",
            (community.name, community.description, user_id, primary_location),
        )

        result = cursor.fetchone()
        print(f"🔍 Cursor Fetch Result: {result}")  # Debugging

        if not result:
            raise HTTPException(status_code=400, detail="Community creation failed: No ID returned")

        community_id = result["id"]  # ✅ Access by dictionary key
        conn.commit()
        print(f"✅ Community created with ID: {community_id}")  # Debugging

    except psycopg2.Error as e:
        conn.rollback()
        print(f"❌ SQL Error: {e.pgcode} - {e.pgerror}")  # Debugging
        raise HTTPException(status_code=400, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Unexpected Error: {repr(e)}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {"message": "Community created successfully", "community_id": community_id}


@app.get("/communities")
def get_communities():
    print("🔹 Fetching all communities")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, description, created_by, created_at, primary_location FROM communities ORDER BY created_at DESC;")
    communities = cursor.fetchall()
    conn.close()
    print(f"✅ Fetched {len(communities)} communities")  # Debugging
    return {"communities": communities}

@app.delete("/communities/{community_id}")
def delete_community(community_id: int, user_id: int = Depends(get_current_user)):
    print(f"🔹 Deleting community ID: {community_id} by user: {user_id}")  # Debugging
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    try:
        cursor.execute("SELECT created_by FROM communities WHERE id = %s;", (community_id,))
        result = cursor.fetchone()

        if not result:
            raise HTTPException(status_code=404, detail="Community not found")

        if result["created_by"] != user_id:
            raise HTTPException(status_code=403, detail="Unauthorized to delete this community")

        cursor.execute("DELETE FROM communities WHERE id = %s;", (community_id,))
        conn.commit()
        print(f"✅ Community {community_id} deleted successfully")
    
    except psycopg2.Error as e:
        conn.rollback()
        print(f"❌ SQL Error: {e.pgcode} - {e.pgerror}")  # Debugging
        raise HTTPException(status_code=400, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Unexpected Error: {repr(e)}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {"message": "Community deleted successfully"}

# ------------------------
# Vote Endpoints
# ------------------------

@app.post("/votes")
def create_vote(vote: VoteCreate, user_id: int = Depends(get_current_user)):
    print(f"🔹 Vote received: post_id={vote.post_id} reply_id={vote.reply_id} vote_type={vote.vote_type}, User: {user_id}")

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Check if the user has already voted on this post
        cursor.execute(
            "SELECT id FROM votes WHERE user_id = %s AND post_id = %s;",
            (user_id, vote.post_id)
        )
        existing_vote = cursor.fetchone()

        if existing_vote:
            raise HTTPException(status_code=400, detail="User has already voted on this post.")

        # Insert new vote
        cursor.execute(
            "INSERT INTO votes (user_id, post_id, reply_id, vote_type) VALUES (%s, %s, %s, %s) RETURNING id;",
            (user_id, vote.post_id, vote.reply_id, vote.vote_type)
        )
        result = cursor.fetchone()

        if not result:
            raise HTTPException(status_code=500, detail="Vote insertion failed.")

        vote_id = result['id']
        conn.commit()
        print(f"✅ Vote recorded with ID: {vote_id}")
    except Exception as e:
        conn.rollback()
        print(f"❌ Vote error [{e.__class__.__name__}]: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        conn.close()

    return {"message": "Vote recorded", "vote_id": vote_id}

@app.get("/votes")
def get_votes(post_id: Optional[int] = None, reply_id: Optional[int] = None):
    if not post_id and not reply_id:
        raise HTTPException(status_code=400, detail="Either post_id or reply_id must be provided.")

    print(f"🔹 Fetching votes for post_id={post_id}, reply_id={reply_id}")

    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    try:
        query = "SELECT id, user_id, post_id, reply_id, vote_type FROM votes WHERE "
        params = []

        if post_id:
            query += "post_id = %s "
            params.append(post_id)
        elif reply_id:
            query += "reply_id = %s "
            params.append(reply_id)

        query += "ORDER BY id DESC;"
        
        print("SQL Query:", query, "Params:", params)

        cursor.execute(query, params)
        votes = cursor.fetchall()

        print(f"✅ Fetched {len(votes)} votes")
    except Exception as e:
        print(f"❌ Error fetching votes: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        conn.close()

    return {"votes": votes}

# ------------------------
# Reply Endpoints
# ------------------------

@app.post("/replies")
def create_reply(reply: ReplyCreate, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()

    print(f"🔹 User ID: {user_id}")  # Debugging
    print(f"🔹 Reply Data: {reply}")  # Debugging

    # Validate parent_reply_id if provided
    if reply.parent_reply_id:
        cursor.execute("SELECT id FROM replies WHERE id = %s", (reply.parent_reply_id,))
        parent_exists = cursor.fetchone()
        if not parent_exists:
            raise HTTPException(status_code=400, detail="Parent reply ID does not exist.")

    try:
        cursor.execute(
            "INSERT INTO replies (post_id, user_id, content, parent_reply_id) VALUES (%s, %s, %s, %s) RETURNING id;",
            (reply.post_id, user_id, reply.content, reply.parent_reply_id)
        )
        result = cursor.fetchone()
        if not result or not result.get("id"):
            raise HTTPException(status_code=500, detail="Reply insertion failed.")

        reply_id = result["id"]
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"❌ Database Error: {e}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

    return {"message": "Reply created successfully", "reply_id": reply_id}


@app.get("/replies/{post_id}")
def get_replies(post_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    print(f"🔹 Fetching replies for post ID: {post_id}")  # Debugging

    cursor.execute(
        "SELECT id, post_id, user_id, content, parent_reply_id, created_at FROM replies WHERE post_id = %s ORDER BY created_at ASC;",
        (post_id,)
    )
    replies = cursor.fetchall()
    
    print(f"🔹 Replies Fetched: {replies}")  # Debugging
    
    conn.close()
    return {"replies": replies}

@app.delete("/replies/{reply_id}")
def delete_reply(reply_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()

    print(f"🔹 Deleting reply ID: {reply_id} by user ID: {user_id}")  # Debugging

    try:
        # Check if the reply exists and belongs to the current user
        cursor.execute("SELECT id FROM replies WHERE id = %s AND user_id = %s;", (reply_id, user_id))
        reply = cursor.fetchone()

        if not reply:
            raise HTTPException(status_code=403, detail="Reply not found or permission denied.")

        # Delete the reply
        cursor.execute("DELETE FROM replies WHERE id = %s;", (reply_id,))
        conn.commit()

        print(f"✅ Reply ID {reply_id} deleted successfully")  # Debugging
    except Exception as e:
        conn.rollback()
        print(f"❌ Error deleting reply: {e}")  # Debugging
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
        conn.close()

    return {"message": "Reply deleted successfully"}

# ------------------------
# Community Membership Endpoints
# ------------------------
@app.post("/communities/{community_id}/join")
def join_community(community_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO community_members (user_id, community_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (user_id, community_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Joined community successfully"}

@app.delete("/communities/{community_id}/leave")
def leave_community(community_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM community_members WHERE user_id = %s AND community_id = %s;", (user_id, community_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Left community successfully"}

# ------------------------
# Post Favorites Endpoints
# ------------------------
@app.post("/posts/{post_id}/favorite")
def favorite_post(post_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO post_favorites (user_id, post_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (user_id, post_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Post favorited successfully"}

@app.delete("/posts/{post_id}/unfavorite")
def unfavorite_post(post_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM post_favorites WHERE user_id = %s AND post_id = %s;", (user_id, post_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Post unfavorited successfully"}

# ------------------------
# Community Post Management
# ------------------------
@app.post("/communities/{community_id}/add_post/{post_id}")
def add_post_to_community(community_id: int, post_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO community_posts (community_id, post_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (community_id, post_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Post added to community successfully"}

@app.delete("/communities/{community_id}/remove_post/{post_id}")
def remove_post_from_community(community_id: int, post_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM community_posts WHERE community_id = %s AND post_id = %s;", (community_id, post_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Post removed from community successfully"}

# ------------------------
# Reply Favorites Endpoints
# ------------------------
@app.post("/replies/{reply_id}/favorite")
def favorite_reply(reply_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO reply_favorites (user_id, reply_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (user_id, reply_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Reply favorited successfully"}

@app.delete("/replies/{reply_id}/unfavorite")
def unfavorite_reply(reply_id: int, user_id: int = Depends(get_current_user)):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM reply_favorites WHERE user_id = %s AND reply_id = %s;", (user_id, reply_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()
    return {"message": "Reply unfavorited successfully"}
