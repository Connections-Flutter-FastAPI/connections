ALTER TABLE users
ADD COLUMN image bytea;

ALTER TABLE users
ADD COLUMN interest TEXT;

ALTER TABLE communities
ADD COLUMN interest TEXT;

ALTER TABLE users
ADD COLUMN college_email TEXT;

ALTER TABLE users
ALTER COLUMN gender TYPE TEXT
USING CASE WHEN gender THEN 'Male' ELSE 'Female' END;

ALTER TABLE users
ADD CONSTRAINT gender_check CHECK (gender IN ('Male', 'Female', 'Others'));

ALTER TABLE votes ADD CONSTRAINT unique_user_post_vote UNIQUE (user_id, post_id);
