import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
import datetime # Add this import

# Load environment variables
load_dotenv()

# Database connection settings
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT", 5432)

# Connect to PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        cursor_factory=RealDictCursor  # Returns results as dictionaries
    )
    return conn

# Helper to update last_seen timestamp
def update_last_seen(user_id: int):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE users SET last_seen = NOW() WHERE id = %s",
            (user_id,)
        )
        conn.commit()
        print(f"Updated last_seen for user {user_id}")
    except Exception as e:
        print(f"Error updating last_seen for user {user_id}: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()