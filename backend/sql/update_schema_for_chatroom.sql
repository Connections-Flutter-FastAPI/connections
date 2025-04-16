-- Script to migrate the database schema for Connections App enhancements

-- Add last_seen column for online status tracking
ALTER TABLE users ADD COLUMN last_seen TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Rename 'college_email' to 'college' if it exists
-- Only run if 'college_email' exists and 'college' doesn't
DO $$
BEGIN
   IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'college_email') AND
      NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'college') THEN
      ALTER TABLE users RENAME COLUMN college_email TO college;
   END IF;
END $$;

-- Make current_location nullable (optional, for flexibility)
ALTER TABLE users ALTER COLUMN current_location DROP NOT NULL;

-- Update timestamp columns to TIMESTAMPTZ
ALTER TABLE users ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE USING created_at::timestamp with time zone;
ALTER TABLE users ALTER COLUMN created_at SET DEFAULT now();


-- ** Step 2: Modify 'communities' table **

-- Add unique constraint to name if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'communities_name_key' AND conrelid = 'communities'::regclass
    ) THEN
        ALTER TABLE communities ADD CONSTRAINT communities_name_key UNIQUE (name);
    END IF;
END $$;

-- Ensure created_by column is INT (it should be, as serial creates integer)
-- We primarily rely on the foreign key constraint ensuring it links correctly.

-- Make primary_location nullable (optional, for flexibility)
ALTER TABLE communities ALTER COLUMN primary_location DROP NOT NULL;

-- Update timestamp columns to TIMESTAMPTZ
ALTER TABLE communities ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE USING created_at::timestamp with time zone;
ALTER TABLE communities ALTER COLUMN created_at SET DEFAULT now();

-- Add interest column if it wasn't added previously (idempotent check)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'communities' AND column_name = 'interest') THEN
        ALTER TABLE communities ADD COLUMN interest TEXT;
    END IF;
END $$;


-- ** Step 3: Modify 'posts' table **

-- Ensure user_id column is INT (should already be integer)

-- Limit title length (optional but good practice)
ALTER TABLE posts ALTER COLUMN title TYPE VARCHAR(255);

-- Update timestamp columns to TIMESTAMPTZ
ALTER TABLE posts ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE USING created_at::timestamp with time zone;
ALTER TABLE posts ALTER COLUMN created_at SET DEFAULT now();


-- ** Step 4: Modify 'replies' table **

-- Ensure post_id and user_id columns are INT (should already be integer)

-- Ensure parent_reply_id is INT and nullable (serial creates INT NOT NULL by default, need to ensure nullability)
ALTER TABLE replies ALTER COLUMN parent_reply_id TYPE INT;
ALTER TABLE replies ALTER COLUMN parent_reply_id DROP NOT NULL; -- Allow NULL for top-level replies

-- Update timestamp columns to TIMESTAMPTZ
ALTER TABLE replies ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE USING created_at::timestamp with time zone;
ALTER TABLE replies ALTER COLUMN created_at SET DEFAULT now();


-- ** Step 5: Modify 'votes' table (Significant changes for voting logic) **

-- Ensure user_id is INT
-- Ensure post_id and reply_id are INT and explicitly nullable
ALTER TABLE votes ALTER COLUMN post_id TYPE INT;
ALTER TABLE votes ALTER COLUMN reply_id TYPE INT;
ALTER TABLE votes ALTER COLUMN post_id DROP NOT NULL; -- Allow NULL
ALTER TABLE votes ALTER COLUMN reply_id DROP NOT NULL; -- Allow NULL

-- Add unique constraint for user+reply votes if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'unique_user_reply_vote' AND conrelid = 'votes'::regclass
    ) THEN
        ALTER TABLE votes ADD CONSTRAINT unique_user_reply_vote UNIQUE (user_id, reply_id);
    END IF;
END $$;

-- Add check constraint to ensure vote targets EITHER post OR reply if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'check_vote_target' AND conrelid = 'votes'::regclass
    ) THEN
         ALTER TABLE votes ADD CONSTRAINT check_vote_target CHECK (("post_id" IS NOT NULL AND "reply_id" IS NULL) OR ("post_id" IS NULL AND "reply_id" IS NOT NULL));
    END IF;
END $$;

-- Update timestamp columns to TIMESTAMPTZ
ALTER TABLE votes ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE USING created_at::timestamp with time zone;
ALTER TABLE votes ALTER COLUMN created_at SET DEFAULT now();

ALTER TABLE community_members ALTER COLUMN joined_at TYPE TIMESTAMP WITH TIME ZONE USING joined_at::timestamp with time zone;
ALTER TABLE community_members ALTER COLUMN joined_at SET DEFAULT now();

ALTER TABLE community_posts ALTER COLUMN added_at TYPE TIMESTAMP WITH TIME ZONE USING added_at::timestamp with time zone;
ALTER TABLE community_posts ALTER COLUMN added_at SET DEFAULT now();

ALTER TABLE post_favorites ALTER COLUMN favorited_at TYPE TIMESTAMP WITH TIME ZONE USING favorited_at::timestamp with time zone;
ALTER TABLE post_favorites ALTER COLUMN favorited_at SET DEFAULT now();

ALTER TABLE reply_favorites ALTER COLUMN favorited_at TYPE TIMESTAMP WITH TIME ZONE USING favorited_at::timestamp with time zone;
ALTER TABLE reply_favorites ALTER COLUMN favorited_at SET DEFAULT now();


-- ** Step 7: Create 'chat_messages' table **

CREATE TABLE IF NOT EXISTS "chat_messages" (
    "id" serial PRIMARY KEY,
    "community_id" INT, -- Nullable, for general community chat
    "event_id" INT, -- Nullable, for event-specific chat
    "user_id" INT NOT NULL,
    "content" TEXT NOT NULL,
    "timestamp" TIMESTAMP WITH TIME ZONE DEFAULT now(),
    FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE CASCADE,
    -- FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE, -- Add FK if/when events table is created
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    -- Ensure message belongs to either a community OR an event (adjust if events table has diff name or structure)
    CHECK (("community_id" IS NOT NULL AND "event_id" IS NULL) OR ("community_id" IS NULL AND "event_id" IS NOT NULL) OR ("community_id" IS NOT NULL AND "event_id" IS NOT NULL)) -- Adjusted check allowing community+event OR one of them
    -- Alternative CHECK if a message MUST belong to one OR the other:
    -- CHECK (("community_id" IS NOT NULL AND "event_id" IS NULL) OR ("community_id" IS NULL AND "event_id" IS NOT NULL))
);


-- ** Step 8: Add Indexes for performance **

CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_replies_post_id ON replies(post_id);
CREATE INDEX IF NOT EXISTS idx_replies_created_at ON replies(created_at ASC);
-- Conditional indexes for votes table might be beneficial depending on queries
CREATE INDEX IF NOT EXISTS idx_votes_on_post ON votes(post_id) WHERE post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_votes_on_reply ON votes(reply_id) WHERE reply_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_community_id ON chat_messages(community_id) WHERE community_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_messages_event_id ON chat_messages(event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_last_seen ON users(last_seen DESC NULLS LAST); -- Index for online status query

-- 1. Create the 'events' table
CREATE TABLE IF NOT EXISTS "events" (
    "id" serial PRIMARY KEY,
    "community_id" INT NOT NULL,
    "creator_id" INT NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "location" TEXT NOT NULL, -- Using TEXT for simplicity, could be POINT
    "event_timestamp" TIMESTAMP WITH TIME ZONE NOT NULL, -- When the event occurs
    "max_participants" INT NOT NULL DEFAULT 100, -- Maximum attendees, added default
    "image_url" TEXT, -- Optional image/banner for the event
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT now(),
    FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE CASCADE,
    FOREIGN KEY ("creator_id") REFERENCES "users"("id") ON DELETE CASCADE -- Changed from SET NULL to CASCADE for simplicity
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_events_community_id ON events(community_id);
CREATE INDEX IF NOT EXISTS idx_events_event_timestamp ON events(event_timestamp);


-- 2. Create the 'event_participants' table (Many-to-Many)
CREATE TABLE IF NOT EXISTS "event_participants" (
    "id" serial PRIMARY KEY,
    "event_id" INT NOT NULL,
    "user_id" INT NOT NULL,
    "joined_at" TIMESTAMP WITH TIME ZONE DEFAULT now(),
    FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    UNIQUE ("event_id", "user_id") -- Prevent duplicate joins
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_event_participants_event_id ON event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_user_id ON event_participants(user_id);


-- 3. Update chat_messages table CHECK constraint (if necessary based on previous migration)
-- Ensure the check constraint allows messages linked ONLY to events
-- First, drop the old constraint if it exists and doesn't allow event-only messages
DO $$
BEGIN
   IF EXISTS (SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = 'chat_messages' AND constraint_name = 'chat_messages_check') THEN
      ALTER TABLE "chat_messages" DROP CONSTRAINT chat_messages_check;
   END IF;
END $$;

-- Add a new constraint allowing community_id OR event_id (or potentially both if needed, but usually one)
ALTER TABLE "chat_messages" ADD CONSTRAINT chat_messages_check CHECK (
    ("community_id" IS NOT NULL AND "event_id" IS NULL) -- Community message
    OR
    ("community_id" IS NULL AND "event_id" IS NOT NULL) -- Event message (Add FK to events if created)
    -- OR ("community_id" IS NOT NULL AND "event_id" IS NOT NULL) -- Uncomment if a message can belong to both
);