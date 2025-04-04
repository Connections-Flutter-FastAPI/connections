# backend/utils.py
import os
import shutil
import uuid
import base64
import io
from PIL import Image
from fastapi import UploadFile
from typing import Optional, Dict

IMAGE_DIR = "user_images" # Define image directory constant

def save_image_from_base64(base64_string: str, username: str) -> Optional[str]:
    """Decodes a Base64 string, saves it as an image, and returns the relative file path."""
    if not base64_string:
        return None
    try:
        # Ensure the string is pure Base64 data without prefixes like "data:image/jpeg;base64,"
        if ',' in base64_string:
             base64_string = base64_string.split(',')[1]

        image_data = base64.b64decode(base64_string)
        image = Image.open(io.BytesIO(image_data))

        # Create the directory if it doesn't exist
        os.makedirs(IMAGE_DIR, exist_ok=True)

        file_extension = image.format.lower() if image.format else 'jpeg' # Default extension
        filename = f"{username}_{uuid.uuid4()}.{file_extension}"
        # Save relative path for database storage
        relative_path = os.path.join(IMAGE_DIR, filename)
        image.save(relative_path) # Save using the relative path
        print(f"Image saved via base64: {relative_path}")
        return relative_path
    except Exception as e:
        print(f"Error saving base64 image for {username}: {e}")
        return None


async def save_image_multipart(image: UploadFile, username: str) -> Optional[str]:
    """Saves an uploaded image and returns the relative file path."""
    if not image or not image.filename:
        return None
    try:
        # Create the directory if it doesn't exist
        os.makedirs(IMAGE_DIR, exist_ok=True)

        # Sanitize filename and create unique name
        file_extension = image.filename.split(".")[-1].lower()
        if not file_extension: file_extension = 'jpeg' # Default
        filename = f"{username}_{uuid.uuid4()}.{file_extension}"
        relative_path = os.path.join(IMAGE_DIR, filename)

        # Use shutil for efficient saving
        with open(relative_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        print(f"Image saved via multipart: {relative_path}")
        return relative_path
    except Exception as e:
        print(f"Error saving multipart image for {username}: {e}")
        return None
    finally:
        await image.close() # Ensure file is closed

def parse_point_string(point_str: str) -> Optional[Dict[str, float]]:
    """Parses POINT '(lon,lat)' string to dict."""
    try:
        # Remove parentheses and split
        coords = point_str.strip('()').split(',')
        if len(coords) == 2:
            lon = float(coords[0].strip())
            lat = float(coords[1].strip())
            return {'longitude': lon, 'latitude': lat}
    except Exception as e:
        print(f"Warning: Could not parse point string '{point_str}': {e}")
    return None

def format_location_for_db(location_str: str) -> str:
    """ Ensures the location string is in the format POINT(lon lat) for DB insertion.
        Assumes input is like '(lon,lat)' """
    try:
        coords = location_str.strip('()').split(',')
        if len(coords) == 2:
            lon = float(coords[0].strip())
            lat = float(coords[1].strip())
            # PostgreSQL POINT format is typically 'lon,lat' or '(lon,lat)' when casting ::point
            # Let's stick to the '(lon,lat)' format which seems to work with ::point cast
            return f'({lon},{lat})'
        else:
             print(f"Warning: Invalid location string format '{location_str}'. Using default.")
             return '(0,0)' # Default point
    except Exception as e:
         print(f"Warning: Error parsing location string '{location_str}': {e}. Using default.")
         return '(0,0)' # Default point
