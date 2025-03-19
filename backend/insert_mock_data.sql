-- Insert Users
INSERT INTO users (name, username, gender, email, password_hash, current_location, created_at) VALUES
('Alice Johnson', 'alicej', FALSE, 'alice@example.com', 'hash123', POINT(28.7041, 77.1025), NOW()),
('Bob Smith', 'bobsmith', TRUE, 'bob@example.com', 'hash456', POINT(37.7749, -122.4194), NOW()),
('Charlie Brown', 'charlieb', TRUE, 'charlie@example.com', 'hash789', POINT(51.5074, -0.1278), NOW()),
('Divansh Prasad', 'divansh', TRUE, 'divanshthebest@gmail.com', 'xxxxxxx', POINT(28.7041, 77.1025), NOW()),
('Kanishk Prasad', 'kanishk', TRUE, 'kanishk.0030@gmail.com', 'xxxxxxx', POINT(28.7041, 77.1025), NOW());

-- Insert Communities
INSERT INTO communities (name, description, created_by, created_at, primary_location) VALUES
('Tech Enthusiasts', 'A community for tech lovers', 1, NOW(), POINT(28.7041, 77.1025)),
('Gaming Hub', 'Discuss latest games and updates', 2, NOW(), POINT(37.7749, -122.4194)),
('Book Readers', 'Share and review books', 3, NOW(), POINT(51.5074, -0.1278)),
('Fitness Freaks', 'A place to discuss workouts and nutrition', 1, NOW(), POINT(40.7128, -74.0060)),
('AI & ML Researchers', 'Community for AI and ML discussions', 2, NOW(), POINT(34.0522, -118.2437));

-- Insert Posts
INSERT INTO posts (user_id, community_id, title, content, created_at) VALUES
(1, 1, 'Latest in Tech', 'Check out the new AI advancements this year!', NOW()),
(2, 2, 'Quantum Computing', 'Exploring the future of computation.', NOW()),
(3, 3, 'Best FPS Games', 'What are your favorite first-person shooters?', NOW()),
(1, 3, 'Gaming Tournaments', 'Join our latest gaming competitions!', NOW()),
(2, 4, 'Must-Read Books', 'Here are 5 books that changed my life.', NOW()),
(3, 4, 'Fantasy vs Sci-Fi', 'Which genre do you prefer?', NOW()),
(1, 5, 'Best Home Workouts', 'No gym? No problem! Try these routines.', NOW()),
(2, 5, 'Keto vs Vegan', 'Which diet is better for muscle gain?', NOW()),
(3, 2, 'Neural Networks Explained', 'A beginner’s guide to deep learning.', NOW()),
(1, 2, 'AI Ethics', 'The challenges of bias in machine learning.', NOW());

-- Insert Replies
INSERT INTO replies (post_id, user_id, content, created_at) VALUES
-- Replies to "Latest in Tech" (post_id = 1)
(1, 2, 'AI is evolving so fast! What do you think about GPT-5?', NOW()),
(1, 3, 'I wonder how AI will impact coding jobs.', NOW()),

-- Replies to "Quantum Computing" (post_id = 2)
(2, 1, 'Quantum supremacy is still a long way off.', NOW()),
(2, 2, 'Do you think we will have commercial quantum computers soon?', NOW()),

-- Replies to "Best FPS Games" (post_id = 3)
(3, 3, 'CS:GO will always be my favorite!', NOW()),
(3, 1, 'Call of Duty has better mechanics IMO.', NOW()),

-- Replies to "Must-Read Books" (post_id = 5)
(5, 3, 'Have you read "Atomic Habits"?', NOW()),
(5, 2, 'I loved "Sapiens"! One of the best history books.', NOW()),

-- Replies to "Best Home Workouts" (post_id = 7)
(7, 1, 'Bodyweight workouts are underrated!', NOW()),
(7, 3, 'Which workout routine do you follow?', NOW()),

-- Replies to "AI Ethics" (post_id = 10)
(10, 2, 'Bias in AI is a real challenge.', NOW()),
(10, 3, 'We need better regulations for AI development.', NOW());

INSERT INTO votes (user_id, post_id, reply_id, vote_type, created_at) VALUES
-- Votes on Posts
(2, 1, NULL, TRUE, NOW()),
(3, 2, NULL, TRUE, NOW()),
(1, 3, NULL, TRUE, NOW()),
(3, 7, NULL, TRUE, NOW()),
(2, 10, NULL, TRUE, NOW()),

-- Votes on Replies
(3, NULL, 1, TRUE, NOW()),
(1, NULL, 2, TRUE, NOW()),
(2, NULL, 3, TRUE, NOW()),
(1, NULL, 4, TRUE, NOW()),
(3, NULL, 5, TRUE, NOW()),
(2, NULL, 6, TRUE, NOW()),
(1, NULL, 7, TRUE, NOW());

-- Insert Community Members
INSERT INTO community_members (user_id, community_id, joined_at) VALUES
(1, 1, NOW()),
(2, 1, NOW()),
(3, 1, NOW()),
(1, 2, NOW()),
(2, 3, NOW()),
(3, 3, NOW()),
(1, 4, NOW()),
(2, 5, NOW());

-- Insert Community Posts
INSERT INTO community_posts (community_id, post_id, added_at) VALUES
(1, 1, NOW()),
(1, 2, NOW()),
(2, 3, NOW()),
(2, 4, NOW()),
(3, 5, NOW()),
(3, 6, NOW()),
(4, 7, NOW()),
(4, 8, NOW()),
(5, 9, NOW()),
(5, 10, NOW());

-- Insert Post Favorites
INSERT INTO post_favorites (user_id, post_id, favorited_at) VALUES
(2, 1, NOW()),
(3, 2, NOW()),
(1, 3, NOW()),
(3, 7, NOW()),
(2, 10, NOW());

-- Insert Reply Favorites
INSERT INTO reply_favorites (user_id, reply_id, favorited_at) VALUES
(3, 1, NOW()),
(1, 2, NOW()),
(2, 3, NOW()),
(1, 4, NOW()),
(3, 5, NOW()),
(2, 6, NOW()),
(1, 7, NOW());