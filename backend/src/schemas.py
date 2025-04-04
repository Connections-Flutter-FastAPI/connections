# backend/schemas.py
from pydantic import BaseModel, Field, Base64Str, validator
from typing import List, Optional, Dict
from datetime import datetime

# --- Auth Schemas ---
class LoginRequest(BaseModel):
    email: str
    password: str

class SignupRequest(BaseModel): # Used for internal representation if needed, Form data is now preferred
    name: str
    username: str
    email: str
    password: str
    gender: str
    current_location: str = "(0,0)" # Keep for potential base64 variant or internal use
    college: str
    interests: List[str] = []
    image_path: Optional[str] = None # Store path now

class TokenData(BaseModel): # For decoding token payload
    user_id: Optional[int] = None

class UserBase(BaseModel):
    name: str
    username: str
    email: str
    gender: str
    college: Optional[str] = None
    interest: Optional[str] = None # Comma-separated string in DB
    image_path: Optional[str] = None
    current_location: Optional[Dict[str, float]] = None # Frontend expects dict

class UserDisplay(UserBase):
    id: int
    created_at: datetime
    last_seen: Optional[datetime] = None
    interests: List[str] = [] # Processed list for frontend

    class Config:
        orm_mode = True # Useful if you switch to ORM later

# --- Post Schemas ---
class PostBase(BaseModel):
    title: str
    content: str

class PostCreate(PostBase):
    community_id: Optional[int] = None

class PostDisplay(PostBase):
    id: int
    user_id: int
    created_at: datetime
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    upvotes: int = 0
    downvotes: int = 0
    reply_count: int = 0
    community_id: Optional[int] = None
    community_name: Optional[str] = None

    class Config:
        orm_mode = True

# --- Reply Schemas ---
class ReplyBase(BaseModel):
    content: str

class ReplyCreate(ReplyBase):
    post_id: int
    parent_reply_id: Optional[int] = None

class ReplyDisplay(ReplyBase):
    id: int
    post_id: int
    user_id: int
    parent_reply_id: Optional[int] = None
    created_at: datetime
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    upvotes: int = 0
    downvotes: int = 0

    class Config:
        orm_mode = True


# --- Community Schemas ---
class CommunityBase(BaseModel):
    name: str
    description: Optional[str] = None
    primary_location: str # Keep as string "(lon,lat)" for input
    interest: Optional[str] = None

class CommunityCreate(CommunityBase):
    pass

class CommunityDisplay(CommunityBase):
    id: int
    created_by: int
    created_at: datetime
    member_count: int = 0
    online_count: int = 0

    class Config:
        orm_mode = True

# --- Vote Schemas ---
class VoteCreate(BaseModel):
    post_id: Optional[int] = None
    reply_id: Optional[int] = None
    vote_type: bool # True for upvote, False for downvote

    @validator('post_id', 'reply_id', always=True)
    def check_one_target(cls, v, values):
        if values.get('post_id') is not None and values.get('reply_id') is not None:
            raise ValueError('Cannot vote on both post and reply simultaneously')
        if values.get('post_id') is None and values.get('reply_id') is None:
            raise ValueError('Either post_id or reply_id must be provided')
        return v

class VoteDisplay(BaseModel):
    id: int
    user_id: int
    post_id: Optional[int]
    reply_id: Optional[int]
    vote_type: bool
    created_at: datetime

    class Config:
        orm_mode = True

# --- Event Schemas ---
class EventBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=255)
    description: Optional[str] = None
    location: str = Field(..., min_length=3)
    event_timestamp: datetime # Expect ISO 8601 format string from frontend
    max_participants: int = Field(gt=0, default=100) # Must be > 0
    image_url: Optional[str] = None

class EventCreate(EventBase):
    pass # Inherits all fields from EventBase

class EventUpdate(BaseModel): # Allow partial updates
    title: Optional[str] = Field(None, min_length=3, max_length=255)
    description: Optional[str] = None
    location: Optional[str] = Field(None, min_length=3)
    event_timestamp: Optional[datetime] = None
    max_participants: Optional[int] = Field(None, gt=0)
    image_url: Optional[str] = None

class EventDisplay(EventBase):
    id: int
    community_id: int
    creator_id: int
    created_at: datetime
    participant_count: int = 0 # Add participant count

    class Config:
        orm_mode = True


# --- Chat Schemas ---
class ChatMessageCreate(BaseModel):
    content: str

class ChatMessageData(BaseModel): # Matches backend structure for WS/HTTP response
    message_id: int
    community_id: Optional[int] = None
    event_id: Optional[int] = None
    user_id: int
    username: str # Include username for display
    content: str
    timestamp: datetime

    class Config:
        orm_mode = True
