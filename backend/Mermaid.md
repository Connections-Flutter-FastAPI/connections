erDiagram
	posts }o--|| users : references
	communities }o--|| users : references
	replies }o--|| posts : references
	replies ||--|| replies : references
	replies }o--|| users : references
	votes }o--|| users : references
	votes }o--|| posts : references
	votes }o--|| replies : references
	posts }o--|| communities : references

	users {
		SERIAL id
		TEXT(65535) name
		TEXT(65535) username
		BOOLEAN gender
		TEXT(65535) email
		TEXT(65535) password_hash
		POINT current_location
		TIMESTAMP created_at
	}

	posts {
		SERIAL id
		INTEGER user_id
		INTEGER community_id
		TEXT(65535) content
		TIMESTAMP created_at
		VARCHAR(50) title
	}

	communities {
		SERIAL id
		TEXT(65535) name
		TEXT(65535) description
		INTEGER created_by
		TIMESTAMP created_at
		POINT primary_location
	}

	replies {
		INTEGER id
		INTEGER post_id
		INTEGER user_id
		TEXT(65535) content
		INTEGER parent_reply_id
		TIMESTAMP created_at
	}

	votes {
		SERIAL id
		INTEGER user_id
		INTEGER post_id
		INTEGER reply_id
		BOOLEAN vote_type
		TIMESTAMP created_at
	}