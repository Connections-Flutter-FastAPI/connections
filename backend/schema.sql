--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Ubuntu 16.8-1.pgdg24.04+1)
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg24.04+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: communities; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.communities (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    created_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    primary_location point NOT NULL,
    interest text
);


ALTER TABLE public.communities OWNER TO divansh;

--
-- Name: communities_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.communities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.communities_id_seq OWNER TO divansh;

--
-- Name: communities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.communities_id_seq OWNED BY public.communities.id;


--
-- Name: community_members; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.community_members (
    id integer NOT NULL,
    user_id integer NOT NULL,
    community_id integer NOT NULL,
    joined_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.community_members OWNER TO divansh;

--
-- Name: community_members_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.community_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_members_id_seq OWNER TO divansh;

--
-- Name: community_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.community_members_id_seq OWNED BY public.community_members.id;


--
-- Name: community_posts; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.community_posts (
    id integer NOT NULL,
    community_id integer NOT NULL,
    post_id integer NOT NULL,
    added_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.community_posts OWNER TO divansh;

--
-- Name: community_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.community_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_posts_id_seq OWNER TO divansh;

--
-- Name: community_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.community_posts_id_seq OWNED BY public.community_posts.id;


--
-- Name: post_favorites; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.post_favorites (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    favorited_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.post_favorites OWNER TO divansh;

--
-- Name: post_favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.post_favorites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_favorites_id_seq OWNER TO divansh;

--
-- Name: post_favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.post_favorites_id_seq OWNED BY public.post_favorites.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    title character varying NOT NULL
);


ALTER TABLE public.posts OWNER TO divansh;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_id_seq OWNER TO divansh;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: replies; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.replies (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    content text NOT NULL,
    parent_reply_id integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.replies OWNER TO divansh;

--
-- Name: replies_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.replies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.replies_id_seq OWNER TO divansh;

--
-- Name: replies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.replies_id_seq OWNED BY public.replies.id;


--
-- Name: reply_favorites; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.reply_favorites (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reply_id integer NOT NULL,
    favorited_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.reply_favorites OWNER TO divansh;

--
-- Name: reply_favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.reply_favorites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reply_favorites_id_seq OWNER TO divansh;

--
-- Name: reply_favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.reply_favorites_id_seq OWNED BY public.reply_favorites.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    username text NOT NULL,
    gender text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    current_location point NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    image bytea,
    interest text,
    college_email text,
    CONSTRAINT gender_check CHECK ((gender = ANY (ARRAY['Male'::text, 'Female'::text, 'Others'::text])))
);


ALTER TABLE public.users OWNER TO divansh;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO divansh;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: divansh
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer,
    reply_id integer,
    vote_type boolean NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.votes OWNER TO divansh;

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: divansh
--

CREATE SEQUENCE public.votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.votes_id_seq OWNER TO divansh;

--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: divansh
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: communities id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.communities ALTER COLUMN id SET DEFAULT nextval('public.communities_id_seq'::regclass);


--
-- Name: community_members id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_members ALTER COLUMN id SET DEFAULT nextval('public.community_members_id_seq'::regclass);


--
-- Name: community_posts id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_posts ALTER COLUMN id SET DEFAULT nextval('public.community_posts_id_seq'::regclass);


--
-- Name: post_favorites id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.post_favorites ALTER COLUMN id SET DEFAULT nextval('public.post_favorites_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: replies id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.replies ALTER COLUMN id SET DEFAULT nextval('public.replies_id_seq'::regclass);


--
-- Name: reply_favorites id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.reply_favorites ALTER COLUMN id SET DEFAULT nextval('public.reply_favorites_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: communities communities_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_pkey PRIMARY KEY (id);


--
-- Name: community_members community_members_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_pkey PRIMARY KEY (id);


--
-- Name: community_members community_members_user_id_community_id_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_user_id_community_id_key UNIQUE (user_id, community_id);


--
-- Name: community_posts community_posts_community_id_post_id_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_community_id_post_id_key UNIQUE (community_id, post_id);


--
-- Name: community_posts community_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_pkey PRIMARY KEY (id);


--
-- Name: post_favorites post_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.post_favorites
    ADD CONSTRAINT post_favorites_pkey PRIMARY KEY (id);


--
-- Name: post_favorites post_favorites_user_id_post_id_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.post_favorites
    ADD CONSTRAINT post_favorites_user_id_post_id_key UNIQUE (user_id, post_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: replies replies_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.replies
    ADD CONSTRAINT replies_pkey PRIMARY KEY (id);


--
-- Name: reply_favorites reply_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.reply_favorites
    ADD CONSTRAINT reply_favorites_pkey PRIMARY KEY (id);


--
-- Name: reply_favorites reply_favorites_user_id_reply_id_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.reply_favorites
    ADD CONSTRAINT reply_favorites_user_id_reply_id_key UNIQUE (user_id, reply_id);


--
-- Name: votes unique_user_post_vote; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT unique_user_post_vote UNIQUE (user_id, post_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: communities communities_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: community_members community_members_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: community_members community_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: community_posts community_posts_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: community_posts community_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_favorites post_favorites_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.post_favorites
    ADD CONSTRAINT post_favorites_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_favorites post_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.post_favorites
    ADD CONSTRAINT post_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: replies replies_parent_reply_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.replies
    ADD CONSTRAINT replies_parent_reply_id_fkey FOREIGN KEY (parent_reply_id) REFERENCES public.replies(id) ON DELETE CASCADE;


--
-- Name: replies replies_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.replies
    ADD CONSTRAINT replies_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: replies replies_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.replies
    ADD CONSTRAINT replies_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reply_favorites reply_favorites_reply_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.reply_favorites
    ADD CONSTRAINT reply_favorites_reply_id_fkey FOREIGN KEY (reply_id) REFERENCES public.replies(id) ON DELETE CASCADE;


--
-- Name: reply_favorites reply_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.reply_favorites
    ADD CONSTRAINT reply_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: votes votes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: votes votes_reply_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_reply_id_fkey FOREIGN KEY (reply_id) REFERENCES public.replies(id) ON DELETE CASCADE;


--
-- Name: votes votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: divansh
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

