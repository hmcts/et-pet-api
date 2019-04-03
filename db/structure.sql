SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
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

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
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

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
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

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
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

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: admin_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_permissions (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_permissions_id_seq OWNED BY public.admin_permissions.id;


--
-- Name: admin_role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_role_permissions (
    id bigint NOT NULL,
    role_id bigint,
    permission_id bigint
);


--
-- Name: admin_role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_role_permissions_id_seq OWNED BY public.admin_role_permissions.id;


--
-- Name: admin_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_roles (
    id bigint NOT NULL,
    name character varying NOT NULL,
    is_admin boolean DEFAULT false,
    permission_names character varying[]
);


--
-- Name: admin_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_roles_id_seq OWNED BY public.admin_roles.id;


--
-- Name: admin_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_user_roles (
    id bigint NOT NULL,
    user_id bigint,
    role_id bigint
);


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_user_roles_id_seq OWNED BY public.admin_user_roles.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
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
    updated_at timestamp without time zone NOT NULL,
    username character varying,
    name character varying,
    department character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_claimants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claim_claimants (
    id bigint NOT NULL,
    claim_id bigint,
    claimant_id bigint
);


--
-- Name: claim_claimants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claim_claimants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_claimants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claim_claimants_id_seq OWNED BY public.claim_claimants.id;


--
-- Name: claim_representatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claim_representatives (
    id bigint NOT NULL,
    claim_id bigint,
    representative_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_representatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claim_representatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claim_representatives_id_seq OWNED BY public.claim_representatives.id;


--
-- Name: claim_respondents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claim_respondents (
    id bigint NOT NULL,
    claim_id bigint,
    respondent_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_respondents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claim_respondents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_respondents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claim_respondents_id_seq OWNED BY public.claim_respondents.id;


--
-- Name: claim_uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claim_uploaded_files (
    id bigint NOT NULL,
    claim_id bigint,
    uploaded_file_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: claim_uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claim_uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claim_uploaded_files_id_seq OWNED BY public.claim_uploaded_files.id;


--
-- Name: claimants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claimants (
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
    updated_at timestamp without time zone NOT NULL,
    fax_number character varying,
    special_needs text
);


--
-- Name: claimants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claimants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claimants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claimants_id_seq OWNED BY public.claimants.id;


--
-- Name: claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claims (
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
    updated_at timestamp without time zone NOT NULL,
    primary_claimant_id bigint NOT NULL,
    other_known_claimant_names character varying,
    discrimination_claims character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    pay_claims character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    desired_outcomes character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    other_claim_details text,
    claim_details text,
    other_outcome character varying,
    send_claim_to_whistleblowing_entity boolean,
    miscellaneous_information text,
    employment_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_unfair_dismissal boolean,
    primary_respondent_id bigint,
    primary_representative_id bigint,
    pdf_template_reference character varying NOT NULL
);


--
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claims_id_seq OWNED BY public.claims.id;


--
-- Name: commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commands (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    request_body text NOT NULL,
    request_headers jsonb NOT NULL,
    response_body text NOT NULL,
    response_headers jsonb,
    response_status integer,
    root_object_type character varying,
    root_object_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: diversity_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diversity_responses (
    id bigint NOT NULL,
    claim_type character varying,
    sex character varying,
    sexual_identity character varying,
    age_group character varying,
    ethnicity character varying,
    ethnicity_subgroup character varying,
    disability character varying,
    caring_responsibility character varying,
    gender character varying,
    gender_at_birth character varying,
    pregnancy character varying,
    relationship character varying,
    religion character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: diversity_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diversity_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diversity_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diversity_responses_id_seq OWNED BY public.diversity_responses.id;


--
-- Name: et_acas_api_download_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.et_acas_api_download_logs (
    id bigint NOT NULL,
    user_id character varying,
    certificate_number character varying,
    method_of_issue character varying,
    message character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: et_acas_api_download_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.et_acas_api_download_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: et_acas_api_download_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.et_acas_api_download_logs_id_seq OWNED BY public.et_acas_api_download_logs.id;


--
-- Name: exported_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exported_files (
    id bigint NOT NULL,
    filename character varying,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_system_id bigint NOT NULL
);


--
-- Name: exported_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exported_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exported_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exported_files_id_seq OWNED BY public.exported_files.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exports (
    id bigint NOT NULL,
    resource_id bigint,
    pdf_file_id bigint,
    in_progress boolean,
    messages character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    resource_type character varying,
    external_system_id bigint NOT NULL
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: external_system_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_system_configurations (
    id bigint NOT NULL,
    external_system_id bigint NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL,
    can_read boolean DEFAULT true NOT NULL,
    can_write boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_system_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_system_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_system_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_system_configurations_id_seq OWNED BY public.external_system_configurations.id;


--
-- Name: external_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_systems (
    id bigint NOT NULL,
    name character varying NOT NULL,
    reference character varying NOT NULL,
    office_codes integer[] DEFAULT '{}'::integer[],
    enabled boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_systems_id_seq OWNED BY public.external_systems.id;


--
-- Name: office_post_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_post_codes (
    id bigint NOT NULL,
    postcode character varying,
    office_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: office_post_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.office_post_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: office_post_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.office_post_codes_id_seq OWNED BY public.office_post_codes.id;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices (
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

CREATE SEQUENCE public.offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.offices_id_seq OWNED BY public.offices.id;


--
-- Name: pre_allocated_file_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pre_allocated_file_keys (
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

CREATE SEQUENCE public.pre_allocated_file_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_allocated_file_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pre_allocated_file_keys_id_seq OWNED BY public.pre_allocated_file_keys.id;


--
-- Name: representatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representatives (
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
    fax_number character varying
);


--
-- Name: representatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.representatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.representatives_id_seq OWNED BY public.representatives.id;


--
-- Name: respondents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.respondents (
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
    employment_at_site_number integer,
    disability boolean,
    disability_information character varying,
    acas_certificate_number character varying,
    acas_exemption_code character varying
);


--
-- Name: respondents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.respondents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: respondents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.respondents_id_seq OWNED BY public.respondents.id;


--
-- Name: response_uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_uploaded_files (
    id bigint NOT NULL,
    response_id bigint,
    uploaded_file_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: response_uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.response_uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_uploaded_files_id_seq OWNED BY public.response_uploaded_files.id;


--
-- Name: responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.responses (
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
    updated_at timestamp without time zone NOT NULL,
    pdf_template_reference character varying NOT NULL,
    email_template_reference character varying NOT NULL
);


--
-- Name: responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.responses_id_seq OWNED BY public.responses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: unique_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unique_references (
    id bigint NOT NULL,
    number integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: unique_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unique_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unique_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unique_references_id_seq OWNED BY public.unique_references.id;


--
-- Name: uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploaded_files (
    id bigint NOT NULL,
    filename character varying,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    import_file_url character varying,
    import_from_key character varying
);


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploaded_files_id_seq OWNED BY public.uploaded_files.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: admin_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_permissions ALTER COLUMN id SET DEFAULT nextval('public.admin_permissions_id_seq'::regclass);


--
-- Name: admin_role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions ALTER COLUMN id SET DEFAULT nextval('public.admin_role_permissions_id_seq'::regclass);


--
-- Name: admin_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_roles ALTER COLUMN id SET DEFAULT nextval('public.admin_roles_id_seq'::regclass);


--
-- Name: admin_user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles ALTER COLUMN id SET DEFAULT nextval('public.admin_user_roles_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: claim_claimants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_claimants ALTER COLUMN id SET DEFAULT nextval('public.claim_claimants_id_seq'::regclass);


--
-- Name: claim_representatives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_representatives ALTER COLUMN id SET DEFAULT nextval('public.claim_representatives_id_seq'::regclass);


--
-- Name: claim_respondents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_respondents ALTER COLUMN id SET DEFAULT nextval('public.claim_respondents_id_seq'::regclass);


--
-- Name: claim_uploaded_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.claim_uploaded_files_id_seq'::regclass);


--
-- Name: claimants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claimants ALTER COLUMN id SET DEFAULT nextval('public.claimants_id_seq'::regclass);


--
-- Name: claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims ALTER COLUMN id SET DEFAULT nextval('public.claims_id_seq'::regclass);


--
-- Name: diversity_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diversity_responses ALTER COLUMN id SET DEFAULT nextval('public.diversity_responses_id_seq'::regclass);


--
-- Name: et_acas_api_download_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.et_acas_api_download_logs ALTER COLUMN id SET DEFAULT nextval('public.et_acas_api_download_logs_id_seq'::regclass);


--
-- Name: exported_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exported_files ALTER COLUMN id SET DEFAULT nextval('public.exported_files_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: external_system_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_system_configurations ALTER COLUMN id SET DEFAULT nextval('public.external_system_configurations_id_seq'::regclass);


--
-- Name: external_systems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_systems ALTER COLUMN id SET DEFAULT nextval('public.external_systems_id_seq'::regclass);


--
-- Name: office_post_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_post_codes ALTER COLUMN id SET DEFAULT nextval('public.office_post_codes_id_seq'::regclass);


--
-- Name: offices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices ALTER COLUMN id SET DEFAULT nextval('public.offices_id_seq'::regclass);


--
-- Name: pre_allocated_file_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_allocated_file_keys ALTER COLUMN id SET DEFAULT nextval('public.pre_allocated_file_keys_id_seq'::regclass);


--
-- Name: representatives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representatives ALTER COLUMN id SET DEFAULT nextval('public.representatives_id_seq'::regclass);


--
-- Name: respondents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.respondents ALTER COLUMN id SET DEFAULT nextval('public.respondents_id_seq'::regclass);


--
-- Name: response_uploaded_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.response_uploaded_files_id_seq'::regclass);


--
-- Name: responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses ALTER COLUMN id SET DEFAULT nextval('public.responses_id_seq'::regclass);


--
-- Name: unique_references id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unique_references ALTER COLUMN id SET DEFAULT nextval('public.unique_references_id_seq'::regclass);


--
-- Name: uploaded_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.uploaded_files_id_seq'::regclass);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admin_permissions admin_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_role_permissions admin_role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_role_permissions
    ADD CONSTRAINT admin_role_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_roles admin_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_roles
    ADD CONSTRAINT admin_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_user_roles admin_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT admin_user_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: claim_claimants claim_claimants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_claimants
    ADD CONSTRAINT claim_claimants_pkey PRIMARY KEY (id);


--
-- Name: claim_representatives claim_representatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_representatives
    ADD CONSTRAINT claim_representatives_pkey PRIMARY KEY (id);


--
-- Name: claim_respondents claim_respondents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_respondents
    ADD CONSTRAINT claim_respondents_pkey PRIMARY KEY (id);


--
-- Name: claim_uploaded_files claim_uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_uploaded_files
    ADD CONSTRAINT claim_uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: claimants claimants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claimants
    ADD CONSTRAINT claimants_pkey PRIMARY KEY (id);


--
-- Name: claims claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: commands commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- Name: diversity_responses diversity_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diversity_responses
    ADD CONSTRAINT diversity_responses_pkey PRIMARY KEY (id);


--
-- Name: et_acas_api_download_logs et_acas_api_download_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.et_acas_api_download_logs
    ADD CONSTRAINT et_acas_api_download_logs_pkey PRIMARY KEY (id);


--
-- Name: exported_files exported_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exported_files
    ADD CONSTRAINT exported_files_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: external_system_configurations external_system_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_system_configurations
    ADD CONSTRAINT external_system_configurations_pkey PRIMARY KEY (id);


--
-- Name: external_systems external_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_systems
    ADD CONSTRAINT external_systems_pkey PRIMARY KEY (id);


--
-- Name: office_post_codes office_post_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_post_codes
    ADD CONSTRAINT office_post_codes_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: pre_allocated_file_keys pre_allocated_file_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_allocated_file_keys
    ADD CONSTRAINT pre_allocated_file_keys_pkey PRIMARY KEY (id);


--
-- Name: representatives representatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representatives
    ADD CONSTRAINT representatives_pkey PRIMARY KEY (id);


--
-- Name: respondents respondents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.respondents
    ADD CONSTRAINT respondents_pkey PRIMARY KEY (id);


--
-- Name: response_uploaded_files response_uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_uploaded_files
    ADD CONSTRAINT response_uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: responses responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT responses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: unique_references unique_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unique_references
    ADD CONSTRAINT unique_references_pkey PRIMARY KEY (id);


--
-- Name: uploaded_files uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files
    ADD CONSTRAINT uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_admin_role_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_role_permissions_on_permission_id ON public.admin_role_permissions USING btree (permission_id);


--
-- Name: index_admin_role_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_role_permissions_on_role_id ON public.admin_role_permissions USING btree (role_id);


--
-- Name: index_admin_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_role_id ON public.admin_user_roles USING btree (role_id);


--
-- Name: index_admin_user_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_user_id ON public.admin_user_roles USING btree (user_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_admin_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_unlock_token ON public.admin_users USING btree (unlock_token);


--
-- Name: index_admin_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_username ON public.admin_users USING btree (username);


--
-- Name: index_claim_claimants_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_claimants_on_claim_id ON public.claim_claimants USING btree (claim_id);


--
-- Name: index_claim_claimants_on_claimant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_claimants_on_claimant_id ON public.claim_claimants USING btree (claimant_id);


--
-- Name: index_claim_representatives_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_representatives_on_claim_id ON public.claim_representatives USING btree (claim_id);


--
-- Name: index_claim_representatives_on_representative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_representatives_on_representative_id ON public.claim_representatives USING btree (representative_id);


--
-- Name: index_claim_respondents_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_respondents_on_claim_id ON public.claim_respondents USING btree (claim_id);


--
-- Name: index_claim_respondents_on_respondent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_respondents_on_respondent_id ON public.claim_respondents USING btree (respondent_id);


--
-- Name: index_claim_uploaded_files_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_uploaded_files_on_claim_id ON public.claim_uploaded_files USING btree (claim_id);


--
-- Name: index_claim_uploaded_files_on_uploaded_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claim_uploaded_files_on_uploaded_file_id ON public.claim_uploaded_files USING btree (uploaded_file_id);


--
-- Name: index_claimants_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claimants_on_address_id ON public.claimants USING btree (address_id);


--
-- Name: index_claims_on_primary_claimant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_primary_claimant_id ON public.claims USING btree (primary_claimant_id);


--
-- Name: index_claims_on_primary_representative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_primary_representative_id ON public.claims USING btree (primary_representative_id);


--
-- Name: index_claims_on_primary_respondent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_primary_respondent_id ON public.claims USING btree (primary_respondent_id);


--
-- Name: index_commands_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commands_on_id ON public.commands USING btree (id);


--
-- Name: index_commands_on_root_object_type_and_root_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commands_on_root_object_type_and_root_object_id ON public.commands USING btree (root_object_type, root_object_id);


--
-- Name: index_exported_files_on_external_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exported_files_on_external_system_id ON public.exported_files USING btree (external_system_id);


--
-- Name: index_exports_on_external_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_external_system_id ON public.exports USING btree (external_system_id);


--
-- Name: index_exports_on_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_resource_id ON public.exports USING btree (resource_id);


--
-- Name: index_external_system_configurations_on_external_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_system_configurations_on_external_system_id ON public.external_system_configurations USING btree (external_system_id);


--
-- Name: index_external_systems_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_external_systems_on_reference ON public.external_systems USING btree (reference);


--
-- Name: index_office_post_codes_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_post_codes_on_office_id ON public.office_post_codes USING btree (office_id);


--
-- Name: index_office_post_codes_on_postcode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_office_post_codes_on_postcode ON public.office_post_codes USING btree (postcode);


--
-- Name: index_pre_allocated_file_keys_to_allocated_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pre_allocated_file_keys_to_allocated_id_and_type ON public.pre_allocated_file_keys USING btree (allocated_to_type, allocated_to_id);


--
-- Name: index_representatives_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representatives_on_address_id ON public.representatives USING btree (address_id);


--
-- Name: index_respondents_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_respondents_on_address_id ON public.respondents USING btree (address_id);


--
-- Name: index_respondents_on_work_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_respondents_on_work_address_id ON public.respondents USING btree (work_address_id);


--
-- Name: index_response_uploaded_files_on_response_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_uploaded_files_on_response_id ON public.response_uploaded_files USING btree (response_id);


--
-- Name: index_response_uploaded_files_on_uploaded_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_uploaded_files_on_uploaded_file_id ON public.response_uploaded_files USING btree (uploaded_file_id);


--
-- Name: index_responses_on_representative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responses_on_representative_id ON public.responses USING btree (representative_id);


--
-- Name: index_responses_on_respondent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responses_on_respondent_id ON public.responses USING btree (respondent_id);


--
-- Name: exported_files fk_rails_14a7c09d3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exported_files
    ADD CONSTRAINT fk_rails_14a7c09d3f FOREIGN KEY (external_system_id) REFERENCES public.external_systems(id);


--
-- Name: exports fk_rails_201815efe4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT fk_rails_201815efe4 FOREIGN KEY (external_system_id) REFERENCES public.external_systems(id);


--
-- Name: claim_representatives fk_rails_303e8e36aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_representatives
    ADD CONSTRAINT fk_rails_303e8e36aa FOREIGN KEY (representative_id) REFERENCES public.representatives(id);


--
-- Name: claim_claimants fk_rails_3b2aad2c6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_claimants
    ADD CONSTRAINT fk_rails_3b2aad2c6b FOREIGN KEY (claim_id) REFERENCES public.claims(id);


--
-- Name: claimants fk_rails_5b676c7564; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claimants
    ADD CONSTRAINT fk_rails_5b676c7564 FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: claim_representatives fk_rails_6b02086897; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_representatives
    ADD CONSTRAINT fk_rails_6b02086897 FOREIGN KEY (claim_id) REFERENCES public.claims(id);


--
-- Name: representatives fk_rails_6e31f27150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representatives
    ADD CONSTRAINT fk_rails_6e31f27150 FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: claim_respondents fk_rails_6f891eb8c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_respondents
    ADD CONSTRAINT fk_rails_6f891eb8c6 FOREIGN KEY (respondent_id) REFERENCES public.respondents(id);


--
-- Name: claim_uploaded_files fk_rails_aef838d57f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_uploaded_files
    ADD CONSTRAINT fk_rails_aef838d57f FOREIGN KEY (uploaded_file_id) REFERENCES public.uploaded_files(id);


--
-- Name: respondents fk_rails_b2834e6387; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.respondents
    ADD CONSTRAINT fk_rails_b2834e6387 FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: claim_respondents fk_rails_c38ecd1031; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_respondents
    ADD CONSTRAINT fk_rails_c38ecd1031 FOREIGN KEY (claim_id) REFERENCES public.claims(id);


--
-- Name: claim_uploaded_files fk_rails_c95be0dd75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_uploaded_files
    ADD CONSTRAINT fk_rails_c95be0dd75 FOREIGN KEY (claim_id) REFERENCES public.claims(id);


--
-- Name: response_uploaded_files fk_rails_caf1d8fe35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_uploaded_files
    ADD CONSTRAINT fk_rails_caf1d8fe35 FOREIGN KEY (response_id) REFERENCES public.responses(id);


--
-- Name: office_post_codes fk_rails_d276fbe15b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_post_codes
    ADD CONSTRAINT fk_rails_d276fbe15b FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: respondents fk_rails_d2d3e755fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.respondents
    ADD CONSTRAINT fk_rails_d2d3e755fa FOREIGN KEY (work_address_id) REFERENCES public.addresses(id);


--
-- Name: response_uploaded_files fk_rails_e34b7bdec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_uploaded_files
    ADD CONSTRAINT fk_rails_e34b7bdec4 FOREIGN KEY (uploaded_file_id) REFERENCES public.uploaded_files(id);


--
-- Name: claim_claimants fk_rails_fc3432143b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claim_claimants
    ADD CONSTRAINT fk_rails_fc3432143b FOREIGN KEY (claimant_id) REFERENCES public.claimants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

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
('20180628143738'),
('20180718155326'),
('20180719065824'),
('20180719102805'),
('20180719142155'),
('20180719143301'),
('20180720100511'),
('20180721164447'),
('20180722080012'),
('20180731090130'),
('20180809050755'),
('20180809060935'),
('20180824103139'),
('20180828120205'),
('20180828162908'),
('20180829121912'),
('20180829143635'),
('20180903102740'),
('20180903102828'),
('20180903104122'),
('20180919102125'),
('20180919110439'),
('20180925162336'),
('20180925165653'),
('20181031123357'),
('20181031123747'),
('20181126122143'),
('20181126123456'),
('20181126123517'),
('20181126133409'),
('20181126133537'),
('20181128123705'),
('20181128124306'),
('20181128175719'),
('20181128175720'),
('20181214120957'),
('20181214121017'),
('20181214121108'),
('20181214121203'),
('20190104181613'),
('20190104181652'),
('20190107093812'),
('20190108161050'),
('20190108161126'),
('20190108161211'),
('20190116150702'),
('20190225185919'),
('20190225190111'),
('20190225190207'),
('20190312113307'),
('20190401204615'),
('20190401204745');


