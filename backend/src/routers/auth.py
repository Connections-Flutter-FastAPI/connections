# backend/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status, Form, UploadFile, File
from fastapi.security import OAuth2PasswordRequestForm # If using standard form login
from typing import List, Optional
import psycopg2
import bcrypt

from .. import schemas, crud, utils, auth # Relative imports
from ..database import get_db_connection

router = APIRouter(
    prefix="/auth", # Changed prefix to /auth
    tags=["Authentication"],
)

# Use standard OAuth2 form for login if preferred
# @router.post("/token", response_model=schemas.Token)
# async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
#     conn = get_db_connection()
#     cursor = conn.cursor()
#     user = crud.get_user_by_email(cursor, form_data.username) # email is username here
#     conn.close()
#     if not user or not bcrypt.checkpw(form_data.password.encode('utf-8'), user["password_hash"].encode('utf-8')):
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Incorrect username or password",
#             headers={"WWW-Authenticate": "Bearer"},
#         )
#     access_token = auth.create_access_token(data={"user_id": user["id"]})
#     return {"access_token": access_token, "token_type": "bearer"}


# Alternative: JSON body login
@router.post("/login", response_model=schemas.TokenData) # Return user_id along with token
async def login(request: schemas.LoginRequest):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        user = crud.get_user_by_email(cursor, request.email)

        if not user or not bcrypt.checkpw(request.password.encode('utf-8'), user["password_hash"].encode('utf-8')):
             raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials",
             )

        user_id = user["id"]
        access_token = auth.create_access_token(data={"user_id": user_id})

        # Update last seen on login
        crud.update_user_last_seen(cursor, user_id)
        conn.commit()
        print(f"✅ Token generated for user {user_id}")
        return {"token": access_token, "user_id": user_id} # Changed response model

    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except Exception as e:
         if conn: conn.rollback()
         print(f"❌ Login Error: {e}")
         raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Login failed")
    finally:
        if conn: conn.close()


@router.post("/signup", status_code=status.HTTP_201_CREATED, response_model=schemas.TokenData) # Return token+userid on signup
async def signup(
    name: str = Form(...),
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    gender: str = Form(...),
    # Expect frontend to send POINT string e.g., '(lon,lat)'
    current_location: str = Form("(0,0)"),
    college: str = Form(...),
    interests: List[str] = Form(...), # Use Form for lists from multipart
    image: Optional[UploadFile] = File(None)
):
    conn = None
    image_path = None
    try:
        # Handle Image Upload
        if image:
            image_path = await utils.save_image_multipart(image, username)
            if image_path is None:
                 print(f"⚠️ Warning: Image saving failed for {username}")
                 # Decide if signup should fail or continue without image

        # Prepare data for DB
        interests_str = ",".join(interests) if interests else None
        # Ensure location format is correct for DB insertion if needed
        # db_location_str = utils.format_location_for_db(current_location) # Use helper if needed

        conn = get_db_connection()
        cursor = conn.cursor()

        # Create user using CRUD function
        user_id = crud.create_user(
            cursor, name, username, email, password, gender,
            current_location, # Pass raw string, assuming ::point cast handles it
            college, interests_str, image_path
        )

        if user_id is None:
             raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="User creation failed")

        conn.commit()
        print(f"✅ User created with ID: {user_id}, Image: {image_path}")

        # Create token for the new user
        access_token = auth.create_access_token(data={"user_id": user_id})
        return {
            "message": "User signed up successfully", # Can customize response schema if needed
            "user_id": user_id,
            "image_path": image_path,
            "token": access_token
        }

    except psycopg2.IntegrityError as e:
        if conn: conn.rollback()
        print(f"❌ Signup Error (Integrity): {e}")
        detail = "Username or email already exists."
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detail)
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Signup Error: {e}")
        # Clean up saved image if user creation failed after saving image
        if image_path and os.path.exists(image_path):
             try:
                  os.remove(image_path)
                  print(f"🧹 Cleaned up image {image_path} after signup failure.")
             except OSError as rm_err:
                  print(f"⚠️ Error cleaning up image {image_path}: {rm_err}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    finally:
        if conn: conn.close()


@router.get("/me", response_model=schemas.UserDisplay)
async def read_users_me(current_user_id: int = Depends(auth.get_current_user)):
    """Fetches details for the currently authenticated user."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        user_db = crud.get_user_by_id(cursor, current_user_id)
        if user_db is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

        # Process data for display model
        user_display_data = dict(user_db) # Convert RealDictRow to dict

        # Parse location point string
        location_str = user_db.get('current_location')
        if location_str:
             user_display_data['current_location'] = utils.parse_point_string(str(location_str))
        else:
             user_display_data['current_location'] = None # Explicitly set to None if DB value is NULL

        # Split interests string
        interests_db = user_db.get('interest')
        user_display_data['interests'] = interests_db.split(',') if interests_db else []

        # Construct full image path URL if needed (adjust based on how you serve static files)
        img_path = user_db.get('image_path')
        if img_path:
            # Assuming 'user_images' is served statically at the root
            # This might need adjustment based on your static file setup in server.py
            user_display_data['image_path'] = f"/{img_path}" # Prepend '/' if served from root
            # Or use full base URL if needed:
            # from .. import app_constants
            # user_display_data['image_path'] = f"{app_constants.baseUrl}/{img_path}"

        # Validate and return using the Pydantic model
        return schemas.UserDisplay(**user_display_data)

    except Exception as e:
         print(f"❌ Error fetching /me: {e}")
         raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to fetch user details")
    finally:
        if conn: conn.close()
