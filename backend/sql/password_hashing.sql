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
SET password_hash = crypt('X@0135691215@z', gen_salt('bf'))
WHERE email = 'divanshthebest@gmail.com';

UPDATE users
SET password_hash = crypt('kanishk30', gen_salt('bf'))
WHERE email = 'kanishk.0030@gmail.com';