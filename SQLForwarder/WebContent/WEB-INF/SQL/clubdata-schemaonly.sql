CREATE SCHEMA IF NOT EXISTS cd;
GRANT USAGE ON SCHEMA cd TO pgexercises;
GRANT USAGE ON SCHEMA cd TO pgeadmin;


SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = cd, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;

--
-- TOC entry 171 (class 1259 OID 32818)
-- Name: bookings; Type: TABLE; Schema: cd; Owner: -; Tablespace:
--

CREATE UNLOGGED TABLE bookings (
    bookid integer NOT NULL,
    facid integer NOT NULL,
    memid integer NOT NULL,
    starttime timestamp without time zone NOT NULL,
    slots integer NOT NULL
);


--
-- TOC entry 169 (class 1259 OID 32770)
-- Name: facilities; Type: TABLE; Schema: cd; Owner: -; Tablespace:
--

CREATE UNLOGGED TABLE facilities (
    facid integer NOT NULL,
    name character varying(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL
);


--
-- TOC entry 170 (class 1259 OID 32800)
-- Name: members; Type: TABLE; Schema: cd; Owner: -; Tablespace:
--

CREATE UNLOGGED TABLE members (
    memid integer NOT NULL,
    surname character varying(200) NOT NULL,
    firstname character varying(200) NOT NULL,
    address character varying(300) NOT NULL,
    zipcode integer NOT NULL,
    telephone character varying(20) NOT NULL,
    recommendedby integer,
    joindate timestamp without time zone NOT NULL
);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cd TO pgexercises;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cd TO pgeadmin;