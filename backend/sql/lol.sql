CREATE TABLE "communities" (
  "id" integer PRIMARY KEY NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "created_by" integer NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "primary_location" point NOT NULL,
  "interest" text
);

CREATE TABLE "community_members" (
  "id" integer PRIMARY KEY NOT NULL,
  "user_id" integer NOT NULL,
  "community_id" integer NOT NULL,
  "joined_at" timestamp DEFAULT (now())
);

CREATE TABLE "community_posts" (
  "id" integer PRIMARY KEY NOT NULL,
  "community_id" integer NOT NULL,
  "post_id" integer NOT NULL,
  "added_at" timestamp DEFAULT (now())
);

CREATE TABLE "post_favorites" (
  "id" integer PRIMARY KEY NOT NULL,
  "user_id" integer NOT NULL,
  "post_id" integer NOT NULL,
  "favorited_at" timestamp DEFAULT (now())
);

CREATE TABLE "posts" (
  "id" integer PRIMARY KEY NOT NULL,
  "user_id" integer NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "title" text  NOT NULL
);

CREATE TABLE "replies" (
  "id" integer PRIMARY KEY NOT NULL,
  "post_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "content" text NOT NULL,
  "parent_reply_id" integer,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "reply_favorites" (
  "id" integer PRIMARY KEY NOT NULL,
  "user_id" integer NOT NULL,
  "reply_id" integer NOT NULL,
  "favorited_at" timestamp DEFAULT (now())
);

CREATE TABLE "users" (
  "id" integer PRIMARY KEY NOT NULL,
  "name" text NOT NULL,
  "username" text UNIQUE NOT NULL,
  "gender" text NOT NULL,
  "email" text UNIQUE NOT NULL,
  "password_hash" text NOT NULL,
  "current_location" point NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "image" bytea,
  "interest" text,
  "college_email" text
);

CREATE TABLE "votes" (
  "id" integer PRIMARY KEY NOT NULL,
  "user_id" integer NOT NULL,
  "post_id" integer,
  "reply_id" integer,
  "vote_type" boolean NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE UNIQUE INDEX "community_members_user_id_community_id_key" ON "community_members" ("user_id", "community_id");

CREATE UNIQUE INDEX "community_posts_community_id_post_id_key" ON "community_posts" ("community_id", "post_id");

CREATE UNIQUE INDEX "post_favorites_user_id_post_id_key" ON "post_favorites" ("user_id", "post_id");

CREATE UNIQUE INDEX "reply_favorites_user_id_reply_id_key" ON "reply_favorites" ("user_id", "reply_id");

CREATE UNIQUE INDEX "unique_user_post_vote" ON "votes" ("user_id", "post_id");

ALTER TABLE "communities" ADD CONSTRAINT "communities_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "community_members" ADD CONSTRAINT "community_members_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities" ("id") ON DELETE CASCADE;

ALTER TABLE "community_members" ADD CONSTRAINT "community_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "community_posts" ADD CONSTRAINT "community_posts_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities" ("id") ON DELETE CASCADE;

ALTER TABLE "community_posts" ADD CONSTRAINT "community_posts_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE;

ALTER TABLE "post_favorites" ADD CONSTRAINT "post_favorites_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE;

ALTER TABLE "post_favorites" ADD CONSTRAINT "post_favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "posts" ADD CONSTRAINT "posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "replies" ADD CONSTRAINT "replies_parent_reply_id_fkey" FOREIGN KEY ("parent_reply_id") REFERENCES "replies" ("id") ON DELETE CASCADE;

ALTER TABLE "replies" ADD CONSTRAINT "replies_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE;

ALTER TABLE "replies" ADD CONSTRAINT "replies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "reply_favorites" ADD CONSTRAINT "reply_favorites_reply_id_fkey" FOREIGN KEY ("reply_id") REFERENCES "replies" ("id") ON DELETE CASCADE;

ALTER TABLE "reply_favorites" ADD CONSTRAINT "reply_favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "votes" ADD CONSTRAINT "votes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE;

ALTER TABLE "votes" ADD CONSTRAINT "votes_reply_id_fkey" FOREIGN KEY ("reply_id") REFERENCES "replies" ("id") ON DELETE CASCADE;

ALTER TABLE "votes" ADD CONSTRAINT "votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;
