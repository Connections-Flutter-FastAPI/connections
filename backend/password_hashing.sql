CREATE EXTENSION IF NOT EXISTS pgcrypto;

UPDATE users
SET password_hash = crypt('alice123', gen_salt('bf'))
WHERE email = 'alice@example.com';

UPDATE users
SET password_hash = crypt('bobsecure', gen_salt('bf'))
WHERE email = 'bob@example.com';

UPDATE users
SET password_hash = crypt('charliepass', gen_salt('bf'))
WHERE email = 'charlie@example.com';

UPDATE users
SET password_hash = crypt('123', gen_salt('bf'))
WHERE email = 'divanshthebest@gmail.com';

UPDATE users
SET password_hash = crypt('321', gen_salt('bf'))
WHERE email = 'kanishk.0030@gmail.com';