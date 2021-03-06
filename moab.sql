--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attendance (
    session_id integer NOT NULL,
    user_id character varying(16) NOT NULL,
    learning_week smallint NOT NULL,
    confirmed character(1)
);


--
-- Name: blogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE blogs (
    user_id character varying(16) NOT NULL,
    learning_week smallint NOT NULL,
    term smallint NOT NULL,
    title text NOT NULL,
    contents text NOT NULL,
    approved boolean DEFAULT false NOT NULL
);


--
-- Name: eliom__persistent_refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE eliom__persistent_refs (
    key text NOT NULL,
    value bytea
);


--
-- Name: log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log (
    "time" timestamp without time zone NOT NULL,
    user_id character varying(8) NOT NULL,
    ip_address text NOT NULL,
    action character(1) NOT NULL
);


--
-- Name: optional_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE optional_sessions (
    timetable_id smallint NOT NULL,
    week smallint NOT NULL
);


--
-- Name: presentation_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE presentation_criteria (
    term smallint NOT NULL,
    id integer NOT NULL,
    criterion text NOT NULL,
    description text
);


--
-- Name: presentation_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE presentation_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: presentation_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE presentation_criteria_id_seq OWNED BY presentation_criteria.id;


--
-- Name: presentation_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE presentation_scores (
    presenter_id character varying(16) NOT NULL,
    scorer_id character varying(16) NOT NULL,
    term smallint NOT NULL,
    criterion_id integer NOT NULL,
    score smallint NOT NULL,
    comment text
);


--
-- Name: presentation_tutor_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE presentation_tutor_feedback (
    presenter_id character varying(16) NOT NULL,
    scorer_id character varying(16) NOT NULL,
    term smallint NOT NULL,
    comments text NOT NULL,
    duration smallint NOT NULL,
    topic text NOT NULL,
    grade character varying(16) NOT NULL
);


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schedule (
    user_id character varying(16) NOT NULL,
    first boolean NOT NULL,
    learning_week smallint NOT NULL,
    timetable_id integer NOT NULL,
    self_set boolean NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    year smallint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    id integer NOT NULL,
    timetable_id integer NOT NULL
);


--
-- Name: sessions_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_session_id_seq OWNED BY sessions.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE students (
    user_id character varying(16) NOT NULL,
    group_number smallint NOT NULL,
    student_id character(9) NOT NULL,
    joined_week smallint NOT NULL,
    left_week smallint,
    visa boolean DEFAULT false NOT NULL,
    term smallint NOT NULL
);


--
-- Name: timetable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE timetable (
    weekday smallint NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    term smallint NOT NULL,
    id integer NOT NULL,
    type character(1) NOT NULL,
    group_number smallint,
    locked boolean,
    CONSTRAINT timetable_check CHECK ((((type = 'S'::bpchar) AND (group_number IS NOT NULL) AND (locked IS NOT NULL)) OR ((group_number IS NULL) AND (locked IS NULL))))
);


--
-- Name: timetable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timetable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timetable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timetable_id_seq OWNED BY timetable.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id character varying(16) NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    password text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL
);


--
-- Name: presentation_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_criteria ALTER COLUMN id SET DEFAULT nextval('presentation_criteria_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_session_id_seq'::regclass);


--
-- Name: timetable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable ALTER COLUMN id SET DEFAULT nextval('timetable_id_seq'::regclass);


--
-- Name: attendance attendance_session_id_user_id_week_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attendance
    ADD CONSTRAINT attendance_session_id_user_id_week_key UNIQUE (session_id, user_id, learning_week);


--
-- Name: blogs blogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blogs
    ADD CONSTRAINT blogs_pkey PRIMARY KEY (user_id, learning_week, term);


--
-- Name: eliom__persistent_refs eliom__persistent_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eliom__persistent_refs
    ADD CONSTRAINT eliom__persistent_refs_pkey PRIMARY KEY (key);


--
-- Name: optional_sessions optional_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY optional_sessions
    ADD CONSTRAINT optional_sessions_pkey PRIMARY KEY (timetable_id, week);


--
-- Name: presentation_criteria presentation_criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_criteria
    ADD CONSTRAINT presentation_criteria_pkey PRIMARY KEY (term, id);


--
-- Name: presentation_scores presentation_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_scores
    ADD CONSTRAINT presentation_scores_pkey PRIMARY KEY (presenter_id, scorer_id, term, criterion_id);


--
-- Name: presentation_tutor_feedback presentation_tutor_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_tutor_feedback
    ADD CONSTRAINT presentation_tutor_feedback_pkey PRIMARY KEY (presenter_id, scorer_id, term);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (user_id, timetable_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_pkey PRIMARY KEY (user_id, term);


--
-- Name: timetable timetable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable
    ADD CONSTRAINT timetable_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attendance
    ADD CONSTRAINT attendance_session_id_fkey FOREIGN KEY (session_id) REFERENCES sessions(id);


--
-- Name: attendance attendance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attendance
    ADD CONSTRAINT attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: optional_sessions optional_sessions_timetable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY optional_sessions
    ADD CONSTRAINT optional_sessions_timetable_id_fkey FOREIGN KEY (timetable_id) REFERENCES timetable(id);


--
-- Name: presentation_scores presentation_scores_presenter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_scores
    ADD CONSTRAINT presentation_scores_presenter_id_fkey FOREIGN KEY (presenter_id) REFERENCES users(id);


--
-- Name: presentation_scores presentation_scores_presenter_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_scores
    ADD CONSTRAINT presentation_scores_presenter_id_fkey1 FOREIGN KEY (presenter_id, term) REFERENCES students(user_id, term);


--
-- Name: presentation_scores presentation_scores_scorer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_scores
    ADD CONSTRAINT presentation_scores_scorer_id_fkey FOREIGN KEY (scorer_id) REFERENCES users(id);


--
-- Name: presentation_scores presentation_scores_term_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_scores
    ADD CONSTRAINT presentation_scores_term_fkey FOREIGN KEY (term, criterion_id) REFERENCES presentation_criteria(term, id);


--
-- Name: presentation_tutor_feedback presentation_tutor_feedback_presenter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_tutor_feedback
    ADD CONSTRAINT presentation_tutor_feedback_presenter_id_fkey FOREIGN KEY (presenter_id, term) REFERENCES students(user_id, term);


--
-- Name: presentation_tutor_feedback presentation_tutor_feedback_scorer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY presentation_tutor_feedback
    ADD CONSTRAINT presentation_tutor_feedback_scorer_id_fkey FOREIGN KEY (scorer_id) REFERENCES users(id);


--
-- Name: schedule schedule_timetable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_timetable_id_fkey FOREIGN KEY (timetable_id) REFERENCES timetable(id);


--
-- Name: sessions sessions_timetable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_timetable_id_fkey FOREIGN KEY (timetable_id) REFERENCES timetable(id);


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

