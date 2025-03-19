CREATE TABLE "users" (
    "id"  serial PRIMARY KEY,
    "name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "gender" BOOLEAN NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password_hash" TEXT NOT NULL,
    "current_location" POINT NOT NULL,
    "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "communities" (
    "id" serial PRIMARY KEY,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_by" serial NOT NULL,
    "created_at" TIMESTAMP DEFAULT now(),
    "primary_location" POINT NOT NULL,
    FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE
);

CREATE TABLE "community_members" (
    "id" serial PRIMARY KEY,
    "user_id" INT NOT NULL,
    "community_id" INT NOT NULL,
    "joined_at" TIMESTAMP DEFAULT now(),
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE CASCADE,
    UNIQUE ("user_id", "community_id")  -- Ensures a user can't join the same community twice
);

CREATE TABLE "posts" (
    "id" serial PRIMARY KEY,
    "user_id" serial NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT now(),
    "title" VARCHAR NOT NULL,
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
);

CREATE TABLE post_favorites (
    id serial PRIMARY KEY,
    user_id int NOT NULL,
    post_id int NOT NULL,
    favorited_at TIMESTAMP DEFAULT now(),
    UNIQUE (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE community_posts (
    id serial PRIMARY KEY,
    community_id int NOT NULL,
    post_id int NOT NULL,
    added_at TIMESTAMP DEFAULT now(),
    UNIQUE (community_id, post_id),
    FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE "replies" (
    "id" serial PRIMARY KEY,
    "post_id" serial NOT NULL,
    "user_id" serial NOT NULL,
    "content" TEXT NOT NULL,
    "parent_reply_id" serial,
    "created_at" TIMESTAMP DEFAULT now(),
    FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY ("parent_reply_id") REFERENCES "replies"("id") ON DELETE CASCADE
);

CREATE TABLE reply_favorites (
    id serial PRIMARY KEY,
    user_id int NOT NULL,
    reply_id int NOT NULL,
    favorited_at TIMESTAMP DEFAULT now(),
    UNIQUE (user_id, reply_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_id) REFERENCES replies(id) ON DELETE CASCADE
);

CREATE TABLE "votes" (
    "id" serial PRIMARY KEY,
    "user_id" serial NOT NULL,
    "post_id" serial,
    "reply_id" serial,
    "vote_type" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP DEFAULT now(),
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
    FOREIGN KEY ("reply_id") REFERENCES "replies"("id") ON DELETE CASCADE
);
