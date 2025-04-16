# backend/auth.py
import os
from datetime import datetime, timedelta, timezone
from typing import Optional

import jwt
from fastapi import Depends, HTTPException, status, Header
from fastapi.security import OAuth2PasswordBearer # If using OAuth2 flow later
from jwt import PyJWTError, ExpiredSignatureError, InvalidTokenError
from dotenv import load_dotenv

from .database import get_db_connection, update_last_seen # Use relative import

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET", "please_change_this_strong_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 # 1 day expiration for simplicity

# oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token") # Define if using form-based token endpoint

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(authorization: str = Header(...)) -> int:
    """
    Dependency to get the current user ID from the Authorization header (Bearer token).
    Updates the user's last_seen timestamp.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    expired_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token has expired",
        headers={"WWW-Authenticate": "Bearer"},
    )
    invalid_format_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid token format",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if not authorization or not authorization.startswith("Bearer "):
         print("❌ Invalid token format or missing header")
         raise invalid_format_exception

    token = authorization.split("Bearer ")[1]
    # print(f"🔍 Token received: {token[:10]}...") # Avoid logging full token

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id_from_payload = payload.get("user_id") # Assuming payload has 'user_id'
        if user_id_from_payload is None:
             print("❌ Token payload missing 'user_id'")
             raise credentials_exception

        user_id = int(user_id_from_payload)
        print(f"✅ Token validated for User ID: {user_id}")

        # Update last_seen timestamp (moved here from original main.py)
        # Consider making this a background task in production
        update_last_seen(user_id)

        return user_id
    except ExpiredSignatureError:
        print("⏳ Token expired")
        raise expired_exception
    except InvalidTokenError as e:
        print(f"❌ Invalid Token Error: {e}")
        raise credentials_exception
    except Exception as e: # Catch any other decoding errors
        print(f"❌ Unexpected error during token validation: {e}")
        raise credentials_exception
