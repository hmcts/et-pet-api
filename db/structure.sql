SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_admin_comments (
    id bigint NOT NULL,
    namespace character varying,
    body text,
    resource_type character varying,
    resource_id bigint,
    author_type character varying,
    author_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_storage_attachments_id_seq OWNED BY active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_storage_blobs_id_seq OWNED BY active_storage_blobs.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id bigint NOT NULL,
    building character varying,
    street character varying,
    locality character varying,
    county character varying,
    string character varying,
    post_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: admin_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_permissions (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_permissions_id_seq OWNED BY admin_permissions.id;


--
-- Name: admin_role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_role_permissions (
    id bigint NOT NULL,
    role_id bigint,
    permission_id bigint
);


--
-- Name: admin_role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_role_permissions_id_seq OWNED BY admin_role_permissions.id;


--
-- Name: admin_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_roles (
    id bigint NOT NULL,
    name character varying NOT NULL,
    is_admin boolean DEFAULT false,
    permission_names character varying[]
);


--
-- Name: admin_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_roles_id_seq OWNED BY admin_roles.id;


--
-- Name: admin_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_user_roles (
    id bigint NOT NULL,
    user_id bigint,
    role_id bigint
);


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_user_roles_id_seq OWNED BY admin_user_roles.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    permission_names character varying[],
    is_admin boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_claimants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claim_claimants (
    id bigint NOT NULL,
    claim_id bigint,
    claimant_id bigint
);


--
-- Name: claim_claimants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claim_claimants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_claimants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claim_claimants_id_seq OWNED BY claim_claimants.id;


--
-- Name: claim_representatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claim_representatives (
    id bigint NOT NULL,
    claim_id bigint,
    representative_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_representatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claim_representatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claim_representatives_id_seq OWNED BY claim_representatives.id;


--
-- Name: claim_respondents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claim_respondents (
    id bigint NOT NULL,
    claim_id bigint,
    respondent_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_respondents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claim_respondents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_respondents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claim_respondents_id_seq OWNED BY claim_respondents.id;


--
-- Name: claim_uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claim_uploaded_files (
    id bigint NOT NULL,
    claim_id bigint,
    uploaded_file_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claim_uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claim_uploaded_files_id_seq OWNED BY claim_uploaded_files.id;


--
-- Name: claimants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claimants (
    id bigint NOT NULL,
    title character varying,
    first_name character varying,
    last_name character varying,
    address_id bigint,
    address_telephone_number character varying,
    mobile_number character varying,
    email_address character varying,
    contact_preference character varying,
    gender character varying,
    date_of_birth date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claimants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claimants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claimants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claimants_id_seq OWNED BY claimants.id;


--
-- Name: claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE claims (
    id bigint NOT NULL,
    reference character varying,
    submission_reference character varying,
    claimant_count integer DEFAULT 0 NOT NULL,
    submission_channel character varying,
    case_type character varying,
    jurisdiction integer,
    office_code integer,
    date_of_receipt timestamp without time zone,
    administrator boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claims_id_seq OWNED BY claims.id;


--
-- Name: exported_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE exported_files (
    id bigint NOT NULL,
    filename character varying,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exported_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exported_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exported_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exported_files_id_seq OWNED BY exported_files.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE exports (
    id bigint NOT NULL,
    resource_id bigint,
    pdf_file_id bigint,
    in_progress boolean,
    messages character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    resource_type character varying
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exports_id_seq OWNED BY exports.id;


--
-- Name: office_post_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE office_post_codes (
    id bigint NOT NULL,
    postcode character varying,
    office_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: office_post_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE office_post_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: office_post_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE office_post_codes_id_seq OWNED BY office_post_codes.id;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE offices (
    id bigint NOT NULL,
    code integer,
    name character varying,
    is_default boolean,
    address character varying,
    telephone character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: offices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offices_id_seq OWNED BY offices.id;


--
-- Name: pre_allocated_file_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pre_allocated_file_keys (
    id bigint NOT NULL,
    key character varying,
    allocated_to_type character varying,
    allocated_to_id bigint,
    filename character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pre_allocated_file_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pre_allocated_file_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_allocated_file_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pre_allocated_file_keys_id_seq OWNED BY pre_allocated_file_keys.id;


--
-- Name: representatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE representatives (
    id bigint NOT NULL,
    name character varying,
    organisation_name character varying,
    address_id bigint,
    address_telephone_number character varying,
    mobile_number character varying,
    email_address character varying,
    representative_type character varying,
    dx_number character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reference character varying,
    contact_preference character varying,
    fax_number character varying,
    disability boolean,
    disability_information character varying
);


--
-- Name: representatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE representatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE representatives_id_seq OWNED BY representatives.id;


--
-- Name: respondents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE respondents (
    id bigint NOT NULL,
    name character varying,
    address_id bigint,
    work_address_telephone_number character varying,
    address_telephone_number character varying,
    acas_number character varying,
    work_address_id bigint,
    alt_phone_number character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact character varying,
    dx_number character varying,
    contact_preference character varying,
    email_address character varying,
    fax_number character varying,
    organisation_employ_gb integer,
    organisation_more_than_one_site boolean,
    employment_at_site_number integer
);


--
-- Name: respondents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE respondents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: respondents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE respondents_id_seq OWNED BY respondents.id;


--
-- Name: response_uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_uploaded_files (
    id bigint NOT NULL,
    response_id bigint,
    uploaded_file_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: response_uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_uploaded_files_id_seq OWNED BY response_uploaded_files.id;


--
-- Name: responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE responses (
    id bigint NOT NULL,
    respondent_id bigint,
    representative_id bigint,
    date_of_receipt timestamp without time zone,
    reference character varying,
    case_number character varying,
    claimants_name character varying,
    agree_with_early_conciliation_details boolean,
    disagree_conciliation_reason character varying,
    agree_with_employment_dates boolean,
    employment_start date,
    employment_end date,
    disagree_employment character varying,
    continued_employment boolean,
    agree_with_claimants_description_of_job_or_title boolean,
    disagree_claimants_job_or_title character varying,
    agree_with_claimants_hours boolean,
    queried_hours numeric(4,2),
    agree_with_earnings_details boolean,
    queried_pay_before_tax numeric(8,2),
    queried_pay_before_tax_period character varying,
    queried_take_home_pay numeric(8,2),
    queried_take_home_pay_period character varying,
    agree_with_claimant_notice boolean,
    disagree_claimant_notice_reason character varying,
    agree_with_claimant_pension_benefits boolean,
    disagree_claimant_pension_benefits_reason character varying,
    defend_claim boolean,
    defend_claim_facts character varying,
    make_employer_contract_claim boolean,
    claim_information character varying,
    email_receipt character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE responses_id_seq OWNED BY responses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: unique_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unique_references (
    id bigint NOT NULL,
    number integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: unique_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unique_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unique_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unique_references_id_seq OWNED BY unique_references.id;


--
-- Name: uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE uploaded_files (
    id bigint NOT NULL,
    filename character varying,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploaded_files_id_seq OWNED BY uploaded_files.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('active_storage_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('active_storage_blobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_permissions ALTER COLUMN id SET DEFAULT nextval('admin_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_role_permissions ALTER COLUMN id SET DEFAULT nextval('admin_role_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_roles ALTER COLUMN id SET DEFAULT nextval('admin_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_user_roles ALTER COLUMN id SET DEFAULT nextval('admin_user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_claimants ALTER COLUMN id SET DEFAULT nextval('claim_claimants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_representatives ALTER COLUMN id SET DEFAULT nextval('claim_representatives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_respondents ALTER COLUMN id SET DEFAULT nextval('claim_respondents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_uploaded_files ALTER COLUMN id SET DEFAULT nextval('claim_uploaded_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claimants ALTER COLUMN id SET DEFAULT nextval('claimants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY claims ALTER COLUMN id SET DEFAULT nextval('claims_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exported_files ALTER COLUMN id SET DEFAULT nextval('exported_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exports ALTER COLUMN id SET DEFAULT nextval('exports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_post_codes ALTER COLUMN id SET DEFAULT nextval('office_post_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offices ALTER COLUMN id SET DEFAULT nextval('offices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pre_allocated_file_keys ALTER COLUMN id SET DEFAULT nextval('pre_allocated_file_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY representatives ALTER COLUMN id SET DEFAULT nextval('representatives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY respondents ALTER COLUMN id SET DEFAULT nextval('respondents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_uploaded_files ALTER COLUMN id SET DEFAULT nextval('response_uploaded_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY responses ALTER COLUMN id SET DEFAULT nextval('responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unique_references ALTER COLUMN id SET DEFAULT nextval('unique_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploaded_files ALTER COLUMN id SET DEFAULT nextval('uploaded_files_id_seq'::regclass);


--
-- Name: active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admin_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_permissions
    ADD CONSTRAINT admin_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_role_permissions
    ADD CONSTRAINT admin_role_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_roles
    ADD CONSTRAINT admin_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_user_roles
    ADD CONSTRAINT admin_user_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: claim_claimants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_claimants
    ADD CONSTRAINT claim_claimants_pkey PRIMARY KEY (id);


--
-- Name: claim_representatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_representatives
    ADD CONSTRAINT claim_representatives_pkey PRIMARY KEY (id);


--
-- Name: claim_respondents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_respondents
    ADD CONSTRAINT claim_respondents_pkey PRIMARY KEY (id);


--
-- Name: claim_uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_uploaded_files
    ADD CONSTRAINT claim_uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: claimants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claimants
    ADD CONSTRAINT claimants_pkey PRIMARY KEY (id);


--
-- Name: claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: exported_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exported_files
    ADD CONSTRAINT exported_files_pkey PRIMARY KEY (id);


--
-- Name: exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: office_post_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_post_codes
    ADD CONSTRAINT office_post_codes_pkey PRIMARY KEY (id);


--
-- Name: offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: pre_allocated_file_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pre_allocated_file_keys
    ADD CONSTRAINT pre_allocated_file_keys_pkey PRIMARY KEY (id);


--
-- Name: representatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY representatives
    ADD CONSTRAINT representatives_pkey PRIMARY KEY (id);


--
-- Name: respondents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY respondents
    ADD CONSTRAINT respondents_pkey PRIMARY KEY (id);


--
-- Name: response_uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_uploaded_files
    ADD CONSTRAINT response_uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY responses
    ADD CONSTRAINT responses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: unique_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unique_references
    ADD CONSTRAINT unique_references_pkey PRIMARY KEY (id);


--
-- Name: uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploaded_files
    ADD CONSTRAINT uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON active_storage_blobs USING btree (key);


--
-- Name: index_admin_role_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_role_permissions_on_permission_id ON admin_role_permissions USING btree (permission_id);


--
-- Name: index_admin_role_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_role_permissions_on_role_id ON admin_role_permissions USING btree (role_id);


--
-- Name: index_admin_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_role_id ON admin_user_roles USING btree (role_id);


--
-- Name: index_admin_user_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_user_id ON admin_user_roles USING btree (user_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_claim_claimants_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_claimants_on_claim_id ON claim_claimants USING btree (claim_id);


--
-- Name: index_claim_claimants_on_claimant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_claimants_on_claimant_id ON claim_claimants USING btree (claimant_id);


--
-- Name: index_claim_representatives_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_representatives_on_claim_id ON claim_representatives USING btree (claim_id);


--
-- Name: index_claim_representatives_on_representative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_representatives_on_representative_id ON claim_representatives USING btree (representative_id);


--
-- Name: index_claim_respondents_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_respondents_on_claim_id ON claim_respondents USING btree (claim_id);


--
-- Name: index_claim_respondents_on_respondent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_respondents_on_respondent_id ON claim_respondents USING btree (respondent_id);


--
-- Name: index_claim_uploaded_files_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_uploaded_files_on_claim_id ON claim_uploaded_files USING btree (claim_id);


--
-- Name: index_claim_uploaded_files_on_uploaded_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_uploaded_files_on_uploaded_file_id ON claim_uploaded_files USING btree (uploaded_file_id);


--
-- Name: index_claimants_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claimants_on_address_id ON claimants USING btree (address_id);


--
-- Name: index_exports_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_resource_id ON exports USING btree (resource_id);


--
-- Name: index_office_post_codes_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_post_codes_on_office_id ON office_post_codes USING btree (office_id);


--
-- Name: index_pre_allocated_file_keys_to_allocated_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pre_allocated_file_keys_to_allocated_id_and_type ON pre_allocated_file_keys USING btree (allocated_to_type, allocated_to_id);


--
-- Name: index_representatives_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representatives_on_address_id ON representatives USING btree (address_id);


--
-- Name: index_respondents_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_respondents_on_address_id ON respondents USING btree (address_id);


--
-- Name: index_respondents_on_work_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_respondents_on_work_address_id ON respondents USING btree (work_address_id);


--
-- Name: index_response_uploaded_files_on_response_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_uploaded_files_on_response_id ON response_uploaded_files USING btree (response_id);


--
-- Name: index_response_uploaded_files_on_uploaded_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_uploaded_files_on_uploaded_file_id ON response_uploaded_files USING btree (uploaded_file_id);


--
-- Name: index_responses_on_representative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responses_on_representative_id ON responses USING btree (representative_id);


--
-- Name: index_responses_on_respondent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responses_on_respondent_id ON responses USING btree (respondent_id);


--
-- Name: fk_rails_303e8e36aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_representatives
    ADD CONSTRAINT fk_rails_303e8e36aa FOREIGN KEY (representative_id) REFERENCES representatives(id);


--
-- Name: fk_rails_3b2aad2c6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_claimants
    ADD CONSTRAINT fk_rails_3b2aad2c6b FOREIGN KEY (claim_id) REFERENCES claims(id);


--
-- Name: fk_rails_5b676c7564; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claimants
    ADD CONSTRAINT fk_rails_5b676c7564 FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: fk_rails_6b02086897; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_representatives
    ADD CONSTRAINT fk_rails_6b02086897 FOREIGN KEY (claim_id) REFERENCES claims(id);


--
-- Name: fk_rails_6e31f27150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY representatives
    ADD CONSTRAINT fk_rails_6e31f27150 FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: fk_rails_6f891eb8c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_respondents
    ADD CONSTRAINT fk_rails_6f891eb8c6 FOREIGN KEY (respondent_id) REFERENCES respondents(id);


--
-- Name: fk_rails_aef838d57f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_uploaded_files
    ADD CONSTRAINT fk_rails_aef838d57f FOREIGN KEY (uploaded_file_id) REFERENCES uploaded_files(id);


--
-- Name: fk_rails_b2834e6387; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY respondents
    ADD CONSTRAINT fk_rails_b2834e6387 FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: fk_rails_c38ecd1031; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_respondents
    ADD CONSTRAINT fk_rails_c38ecd1031 FOREIGN KEY (claim_id) REFERENCES claims(id);


--
-- Name: fk_rails_c95be0dd75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_uploaded_files
    ADD CONSTRAINT fk_rails_c95be0dd75 FOREIGN KEY (claim_id) REFERENCES claims(id);


--
-- Name: fk_rails_caf1d8fe35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_uploaded_files
    ADD CONSTRAINT fk_rails_caf1d8fe35 FOREIGN KEY (response_id) REFERENCES responses(id);


--
-- Name: fk_rails_d276fbe15b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_post_codes
    ADD CONSTRAINT fk_rails_d276fbe15b FOREIGN KEY (office_id) REFERENCES offices(id);


--
-- Name: fk_rails_d2d3e755fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY respondents
    ADD CONSTRAINT fk_rails_d2d3e755fa FOREIGN KEY (work_address_id) REFERENCES addresses(id);


--
-- Name: fk_rails_e34b7bdec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_uploaded_files
    ADD CONSTRAINT fk_rails_e34b7bdec4 FOREIGN KEY (uploaded_file_id) REFERENCES uploaded_files(id);


--
-- Name: fk_rails_fc3432143b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY claim_claimants
    ADD CONSTRAINT fk_rails_fc3432143b FOREIGN KEY (claimant_id) REFERENCES claimants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO "schema_migrations" (version) VALUES
('20180322173653'),
('20180322173656'),
('20180323063829'),
('20180323063930'),
('20180323071607'),
('20180323072034'),
('20180324173814'),
('20180326103144'),
('20180329091655'),
('20180329092026'),
('20180403055248'),
('20180403071925'),
('20180403072137'),
('20180403072323'),
('20180403082719'),
('20180403082849'),
('20180403105143'),
('20180403105212'),
('20180403113336'),
('20180403140530'),
('20180403140552'),
('20180410052457'),
('20180410081032'),
('20180508171227'),
('20180509071735'),
('20180509080448'),
('20180509204605'),
('20180511160146'),
('20180511165627'),
('20180626154920'),
('20180628143738');


