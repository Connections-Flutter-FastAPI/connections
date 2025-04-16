-- Mock Data for Events, Participants, and Chat Messages

-- Insert Events (Link to existing communities and users)
-- Assuming Community 'Tech Enthusiasts' has id 1, user 'Alice' has id 1
INSERT INTO events (community_id, creator_id, title, description, location, event_timestamp, max_participants, image_url) VALUES
(1, 1, 'Tech Talk: Future of AI', 'Discussing advancements in AI and ML.', 'Online (Zoom)', NOW() + INTERVAL '3 days', 50, 'https://images.unsplash.com/photo-1593349114759-15e4b8a451a7'),
(1, 4, 'Weekly Coding Meetup', 'Casual coding session, bring your projects!', 'Community Hub Room A', NOW() + INTERVAL '1 day' + INTERVAL '10 hours', 20, NULL),
(2, 5, 'Morning Yoga Session', 'Relaxing yoga session to start the day.', 'Central Park (East Meadow)', NOW() + INTERVAL '12 hours', 15, 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b');

-- Insert Event Participants
-- User 1 (Alice), 4 (Divansh), 5 (Kanishk) joining event 1 (Tech Talk)
INSERT INTO event_participants (event_id, user_id) VALUES
(1, 1), -- Creator automatically joined by backend logic, but added here for clarity
(1, 4),
(1, 5);
-- User 4 (Divansh) joining event 2 (Coding Meetup)
INSERT INTO event_participants (event_id, user_id) VALUES
(2, 4); -- Creator automatically joined
-- User 5 (Kanishk) joining event 3 (Yoga)
INSERT INTO event_participants (event_id, user_id) VALUES
(3, 5); -- Creator automatically joined


-- Insert Chat Messages
-- Messages for Community 1 (Tech Enthusiasts) - No specific event
INSERT INTO chat_messages (community_id, event_id, user_id, content) VALUES
(1, NULL, 1, 'Hi everyone! Looking forward to the AI talk.'),
(1, NULL, 4, 'Me too! Should be interesting.'),
(1, NULL, 1, 'The coding meetup is tomorrow, right?'),
(1, NULL, 5, 'Yes, 10 AM in Room A.');

-- Messages for Event 1 (Tech Talk)
INSERT INTO chat_messages (community_id, event_id, user_id, content) VALUES
(NULL, 1, 4, 'Is the Zoom link posted yet for the AI talk?'),
(NULL, 1, 1, 'I will post it soon!'),
(NULL, 1, 5, 'I can’t wait to hear about the latest in AI!'),
(NULL, 1, 4, 'I hope they discuss the ethical implications too.'),
(NULL, 1, 1, 'Absolutely! It’s a hot topic right now.');
-- Messages for Event 2 (Weekly Coding Meetup)
INSERT INTO chat_messages (community_id, event_id, user_id, content) VALUES
(NULL, 2, 1, 'I have a project I need help with.'),
(NULL, 2, 4, 'I can help! What’s the project about?'),
(NULL, 2, 1, 'It’s a web app using React and Node.js.'),
(NULL, 2, 4, 'Sounds cool! I love React.');

-- Messages for Community 2 (Fitness Freaks)
INSERT INTO chat_messages (community_id, event_id, user_id, content) VALUES
(2, NULL, 5, 'Anyone going for a run this evening?'),
(2, NULL, 4, 'I might join! What time?'),
(2, NULL, 5, 'How about 6 PM at the park?'),
(2, NULL, 4, 'Sounds good!');