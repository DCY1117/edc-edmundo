--
-- PostgreSQL database dump
--

\restrict tYUXgXy5uxwe6Z8te3dNkzgGOOQMbDITX5QUyAItSZwcggGyHOcEnlko1vVxvWD

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.upload_chunks DROP CONSTRAINT IF EXISTS upload_chunks_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ml_metadata DROP CONSTRAINT IF EXISTS ml_metadata_asset_id_fkey1;
ALTER TABLE IF EXISTS ONLY public.ml_metadata DROP CONSTRAINT IF EXISTS ml_metadata_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.model_executions DROP CONSTRAINT IF EXISTS fk_execution_asset;
ALTER TABLE IF EXISTS ONLY public.data_addresses DROP CONSTRAINT IF EXISTS data_addresses_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_offers DROP CONSTRAINT IF EXISTS contract_offers_negotiation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_offers DROP CONSTRAINT IF EXISTS contract_offers_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_negotiations DROP CONSTRAINT IF EXISTS contract_negotiations_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_definitions DROP CONSTRAINT IF EXISTS contract_definitions_contract_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_definitions DROP CONSTRAINT IF EXISTS contract_definitions_access_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_definition_assets DROP CONSTRAINT IF EXISTS contract_definition_assets_contract_definition_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_definition_assets DROP CONSTRAINT IF EXISTS contract_definition_assets_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_agreements DROP CONSTRAINT IF EXISTS contract_agreements_negotiation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.contract_agreements DROP CONSTRAINT IF EXISTS contract_agreements_asset_id_fkey;
DROP TRIGGER IF EXISTS update_upload_sessions_updated_at ON public.upload_sessions;
DROP TRIGGER IF EXISTS update_policy_definitions_updated_at ON public.policy_definitions;
DROP TRIGGER IF EXISTS update_contract_definitions_updated_at ON public.contract_definitions;
DROP TRIGGER IF EXISTS update_assets_updated_at ON public.assets;
DROP TRIGGER IF EXISTS trigger_update_offer_timestamp ON public.contract_offers;
DROP TRIGGER IF EXISTS trigger_update_negotiation_timestamp ON public.contract_negotiations;
DROP TRIGGER IF EXISTS trigger_update_agreement_timestamp ON public.contract_agreements;
DROP INDEX IF EXISTS public.idx_upload_sessions_status;
DROP INDEX IF EXISTS public.idx_upload_sessions_owner;
DROP INDEX IF EXISTS public.idx_upload_sessions_asset_id;
DROP INDEX IF EXISTS public.idx_policy_definitions_created_at;
DROP INDEX IF EXISTS public.idx_offers_state;
DROP INDEX IF EXISTS public.idx_offers_negotiation;
DROP INDEX IF EXISTS public.idx_offers_asset;
DROP INDEX IF EXISTS public.idx_negotiations_state;
DROP INDEX IF EXISTS public.idx_negotiations_provider;
DROP INDEX IF EXISTS public.idx_negotiations_created;
DROP INDEX IF EXISTS public.idx_negotiations_counterparty;
DROP INDEX IF EXISTS public.idx_negotiations_asset;
DROP INDEX IF EXISTS public.idx_model_executions_user_id;
DROP INDEX IF EXISTS public.idx_model_executions_status;
DROP INDEX IF EXISTS public.idx_model_executions_created_at;
DROP INDEX IF EXISTS public.idx_model_executions_asset_id;
DROP INDEX IF EXISTS public.idx_ml_metadata_task;
DROP INDEX IF EXISTS public.idx_ml_metadata_input_features;
DROP INDEX IF EXISTS public.idx_ml_metadata_algorithm;
DROP INDEX IF EXISTS public.idx_data_addresses_type;
DROP INDEX IF EXISTS public.idx_data_addresses_is_executable;
DROP INDEX IF EXISTS public.idx_data_addresses_asset_id;
DROP INDEX IF EXISTS public.idx_contract_definitions_created_at;
DROP INDEX IF EXISTS public.idx_contract_definitions_contract_policy;
DROP INDEX IF EXISTS public.idx_contract_definitions_access_policy;
DROP INDEX IF EXISTS public.idx_contract_definition_assets_asset_id;
DROP INDEX IF EXISTS public.idx_assets_type;
DROP INDEX IF EXISTS public.idx_assets_owner;
DROP INDEX IF EXISTS public.idx_assets_created_at;
DROP INDEX IF EXISTS public.idx_agreements_state;
DROP INDEX IF EXISTS public.idx_agreements_provider;
DROP INDEX IF EXISTS public.idx_agreements_consumer_asset;
DROP INDEX IF EXISTS public.idx_agreements_consumer;
DROP INDEX IF EXISTS public.idx_agreements_asset;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_connector_id_key;
ALTER TABLE IF EXISTS ONLY public.upload_sessions DROP CONSTRAINT IF EXISTS upload_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.upload_chunks DROP CONSTRAINT IF EXISTS upload_chunks_session_id_chunk_index_key;
ALTER TABLE IF EXISTS ONLY public.upload_chunks DROP CONSTRAINT IF EXISTS upload_chunks_pkey;
ALTER TABLE IF EXISTS ONLY public.policy_definitions DROP CONSTRAINT IF EXISTS policy_definitions_pkey;
ALTER TABLE IF EXISTS ONLY public.model_executions DROP CONSTRAINT IF EXISTS model_executions_pkey;
ALTER TABLE IF EXISTS ONLY public.ml_metadata DROP CONSTRAINT IF EXISTS ml_metadata_pkey;
ALTER TABLE IF EXISTS ONLY public.data_addresses DROP CONSTRAINT IF EXISTS data_addresses_pkey;
ALTER TABLE IF EXISTS ONLY public.contract_offers DROP CONSTRAINT IF EXISTS contract_offers_pkey;
ALTER TABLE IF EXISTS ONLY public.contract_negotiations DROP CONSTRAINT IF EXISTS contract_negotiations_pkey;
ALTER TABLE IF EXISTS ONLY public.contract_definitions DROP CONSTRAINT IF EXISTS contract_definitions_pkey;
ALTER TABLE IF EXISTS ONLY public.contract_definition_assets DROP CONSTRAINT IF EXISTS contract_definition_assets_pkey;
ALTER TABLE IF EXISTS ONLY public.contract_agreements DROP CONSTRAINT IF EXISTS contract_agreements_pkey;
ALTER TABLE IF EXISTS ONLY public.assets DROP CONSTRAINT IF EXISTS assets_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.upload_sessions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.upload_chunks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.data_addresses ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP SEQUENCE IF EXISTS public.upload_sessions_id_seq;
DROP TABLE IF EXISTS public.upload_sessions;
DROP SEQUENCE IF EXISTS public.upload_chunks_id_seq;
DROP TABLE IF EXISTS public.upload_chunks;
DROP TABLE IF EXISTS public.policy_definitions;
DROP VIEW IF EXISTS public.pending_negotiations;
DROP TABLE IF EXISTS public.model_executions;
DROP VIEW IF EXISTS public.executable_assets;
DROP SEQUENCE IF EXISTS public.data_addresses_id_seq;
DROP TABLE IF EXISTS public.contract_offers;
DROP TABLE IF EXISTS public.contract_negotiations;
DROP TABLE IF EXISTS public.contract_definitions;
DROP TABLE IF EXISTS public.contract_definition_assets;
DROP VIEW IF EXISTS public.assets_with_owner;
DROP TABLE IF EXISTS public.users;
DROP VIEW IF EXISTS public.assets_complete;
DROP TABLE IF EXISTS public.ml_metadata;
DROP TABLE IF EXISTS public.data_addresses;
DROP VIEW IF EXISTS public.active_agreements;
DROP TABLE IF EXISTS public.contract_agreements;
DROP TABLE IF EXISTS public.assets;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP FUNCTION IF EXISTS public.update_negotiation_timestamp();
DROP FUNCTION IF EXISTS public.has_valid_agreement(p_consumer_id character varying, p_asset_id character varying);
--
-- Name: has_valid_agreement(character varying, character varying); Type: FUNCTION; Schema: public; Owner: ml_assets_user
--

CREATE FUNCTION public.has_valid_agreement(p_consumer_id character varying, p_asset_id character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM contract_agreements
    WHERE consumer_id = p_consumer_id
    AND asset_id = p_asset_id
    AND state = 'FINALIZED'
    AND (end_date IS NULL OR end_date > CURRENT_TIMESTAMP);
    
    RETURN v_count > 0;
END;
$$;


ALTER FUNCTION public.has_valid_agreement(p_consumer_id character varying, p_asset_id character varying) OWNER TO ml_assets_user;

--
-- Name: update_negotiation_timestamp(); Type: FUNCTION; Schema: public; Owner: ml_assets_user
--

CREATE FUNCTION public.update_negotiation_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_negotiation_timestamp() OWNER TO ml_assets_user;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: ml_assets_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO ml_assets_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assets; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.assets (
    id character varying(255) NOT NULL,
    name character varying(500) NOT NULL,
    version character varying(50) DEFAULT '1.0'::character varying,
    content_type character varying(100) DEFAULT 'application/octet-stream'::character varying,
    description text,
    short_description character varying(1000),
    keywords text,
    byte_size bigint,
    format character varying(100),
    asset_type character varying(100) DEFAULT 'MLModel'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    owner character varying(100) DEFAULT 'conn-user1-demo'::character varying
);


ALTER TABLE public.assets OWNER TO ml_assets_user;

--
-- Name: TABLE assets; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.assets IS 'Main table for IA assets metadata';


--
-- Name: COLUMN assets.owner; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.assets.owner IS 'Connector ID of the user who owns this asset (e.g., conn-user1-demo)';


--
-- Name: contract_agreements; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.contract_agreements (
    id character varying(255) NOT NULL,
    consumer_id character varying(255) NOT NULL,
    provider_id character varying(255) NOT NULL,
    asset_id character varying(255) NOT NULL,
    policy_id character varying(255),
    contract_definition_id character varying(255),
    negotiation_id character varying(255),
    state character varying(50) DEFAULT 'FINALIZED'::character varying,
    signing_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    start_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    end_date timestamp without time zone,
    terms jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.contract_agreements OWNER TO ml_assets_user;

--
-- Name: TABLE contract_agreements; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.contract_agreements IS 'EDC Contract Agreements - Finalized contracts that grant access rights to assets';


--
-- Name: active_agreements; Type: VIEW; Schema: public; Owner: ml_assets_user
--

CREATE VIEW public.active_agreements AS
 SELECT ca.id,
    ca.consumer_id,
    ca.provider_id,
    ca.asset_id,
    ca.policy_id,
    ca.contract_definition_id,
    ca.negotiation_id,
    ca.state,
    ca.signing_date,
    ca.start_date,
    ca.end_date,
    ca.terms,
    ca.created_at,
    ca.updated_at,
    a.name AS asset_name,
    a.owner AS provider_owner
   FROM (public.contract_agreements ca
     JOIN public.assets a ON (((ca.asset_id)::text = (a.id)::text)))
  WHERE (((ca.state)::text = 'FINALIZED'::text) AND ((ca.end_date IS NULL) OR (ca.end_date > CURRENT_TIMESTAMP)));


ALTER VIEW public.active_agreements OWNER TO ml_assets_user;

--
-- Name: data_addresses; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.data_addresses (
    id integer NOT NULL,
    asset_id character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(500),
    base_url text,
    path text,
    auth_key character varying(255),
    auth_code character varying(255),
    secret_name character varying(255),
    proxy_body character varying(50),
    proxy_path character varying(50),
    proxy_query_params character varying(50),
    proxy_method character varying(50),
    region character varying(100),
    bucket_name character varying(255),
    access_key_id character varying(255),
    secret_access_key character varying(500),
    endpoint_override text,
    key_prefix character varying(500),
    folder_name character varying(500),
    folder character varying(500),
    file_name character varying(500),
    s3_key character varying(1000),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    execution_endpoint text,
    execution_method character varying(10) DEFAULT 'POST'::character varying,
    execution_timeout integer DEFAULT 30000,
    is_executable boolean DEFAULT false
);


ALTER TABLE public.data_addresses OWNER TO ml_assets_user;

--
-- Name: TABLE data_addresses; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.data_addresses IS 'Storage configuration for assets (HTTP, S3, InesDataStore)';


--
-- Name: COLUMN data_addresses.execution_endpoint; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.data_addresses.execution_endpoint IS 'HTTP endpoint URL for model execution (e.g., https://model-api.example.com/predict)';


--
-- Name: COLUMN data_addresses.execution_method; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.data_addresses.execution_method IS 'HTTP method for execution (POST, GET, etc.)';


--
-- Name: COLUMN data_addresses.execution_timeout; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.data_addresses.execution_timeout IS 'Timeout in milliseconds for model execution';


--
-- Name: COLUMN data_addresses.is_executable; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.data_addresses.is_executable IS 'Flag indicating if this asset can be executed via API';


--
-- Name: ml_metadata; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.ml_metadata (
    asset_id character varying(255) NOT NULL,
    task character varying(200),
    subtask character varying(200),
    algorithm character varying(200),
    library character varying(200),
    framework character varying(200),
    software character varying(200),
    programming_language character varying(100),
    license character varying(200),
    version character varying(50),
    input_features jsonb
);


ALTER TABLE public.ml_metadata OWNER TO ml_assets_user;

--
-- Name: TABLE ml_metadata; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.ml_metadata IS 'ML-specific metadata from JS_Pionera_Ontology';


--
-- Name: assets_complete; Type: VIEW; Schema: public; Owner: ml_assets_user
--

CREATE VIEW public.assets_complete AS
 SELECT a.id,
    a.name,
    a.version,
    a.content_type,
    a.description,
    a.short_description,
    a.keywords,
    a.byte_size,
    a.format,
    a.asset_type,
    a.created_at,
    a.updated_at,
    m.task,
    m.subtask,
    m.algorithm,
    m.library,
    m.framework,
    m.software,
    m.programming_language,
    m.license AS ml_license,
    da.type AS storage_type,
    da.bucket_name,
    da.s3_key,
    da.base_url
   FROM ((public.assets a
     LEFT JOIN public.ml_metadata m ON (((a.id)::text = (m.asset_id)::text)))
     LEFT JOIN public.data_addresses da ON (((a.id)::text = (da.asset_id)::text)));


ALTER VIEW public.assets_complete OWNER TO ml_assets_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    connector_id character varying(100) NOT NULL,
    display_name character varying(200),
    email character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO ml_assets_user;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.users IS 'User authentication table for multi-tenant connector system';


--
-- Name: assets_with_owner; Type: VIEW; Schema: public; Owner: ml_assets_user
--

CREATE VIEW public.assets_with_owner AS
 SELECT a.id,
    a.name,
    a.version,
    a.content_type,
    a.description,
    a.short_description,
    a.keywords,
    a.byte_size,
    a.format,
    a.asset_type,
    a.created_at,
    a.updated_at,
    a.owner,
    u.display_name AS owner_display_name,
    u.connector_id AS owner_connector_id
   FROM (public.assets a
     LEFT JOIN public.users u ON (((a.owner)::text = (u.connector_id)::text)));


ALTER VIEW public.assets_with_owner OWNER TO ml_assets_user;

--
-- Name: contract_definition_assets; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.contract_definition_assets (
    contract_definition_id character varying(255) NOT NULL,
    asset_id character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.contract_definition_assets OWNER TO ml_assets_user;

--
-- Name: TABLE contract_definition_assets; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.contract_definition_assets IS 'Junction table for assets in contract definitions';


--
-- Name: contract_definitions; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.contract_definitions (
    id character varying(255) NOT NULL,
    access_policy_id character varying(255) NOT NULL,
    contract_policy_id character varying(255) NOT NULL,
    assets_selector jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255)
);


ALTER TABLE public.contract_definitions OWNER TO ml_assets_user;

--
-- Name: TABLE contract_definitions; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.contract_definitions IS 'EDC Contract Definitions linking policies to assets';


--
-- Name: contract_negotiations; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.contract_negotiations (
    id character varying(255) NOT NULL,
    correlation_id character varying(255),
    counterparty_id character varying(255) NOT NULL,
    counterparty_address character varying(500),
    protocol character varying(50) DEFAULT 'dataspace-protocol-http'::character varying,
    state character varying(50) DEFAULT 'REQUESTED'::character varying NOT NULL,
    contract_offer_id character varying(255),
    contract_agreement_id character varying(255),
    asset_id character varying(255) NOT NULL,
    policy_id character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    finalized_at timestamp without time zone,
    provider_id character varying(255) NOT NULL,
    error_detail text
);


ALTER TABLE public.contract_negotiations OWNER TO ml_assets_user;

--
-- Name: TABLE contract_negotiations; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.contract_negotiations IS 'EDC Contract Negotiation Protocol - Tracks negotiation state machine between consumer and provider';


--
-- Name: contract_offers; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.contract_offers (
    id character varying(255) NOT NULL,
    negotiation_id character varying(255) NOT NULL,
    asset_id character varying(255) NOT NULL,
    policy_id character varying(255),
    state character varying(50) DEFAULT 'PENDING'::character varying,
    provider_id character varying(255) NOT NULL,
    terms jsonb,
    valid_until timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.contract_offers OWNER TO ml_assets_user;

--
-- Name: TABLE contract_offers; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.contract_offers IS 'EDC Contract Offers - Offers made during the negotiation process';


--
-- Name: data_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: ml_assets_user
--

CREATE SEQUENCE public.data_addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_addresses_id_seq OWNER TO ml_assets_user;

--
-- Name: data_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ml_assets_user
--

ALTER SEQUENCE public.data_addresses_id_seq OWNED BY public.data_addresses.id;


--
-- Name: executable_assets; Type: VIEW; Schema: public; Owner: ml_assets_user
--

CREATE VIEW public.executable_assets AS
 SELECT a.id,
    a.name,
    a.version,
    a.asset_type,
    a.owner,
    da.execution_endpoint,
    da.execution_method,
    da.execution_timeout,
    da.type AS data_address_type,
    m.task,
    m.algorithm,
    m.framework
   FROM ((public.assets a
     JOIN public.data_addresses da ON (((a.id)::text = (da.asset_id)::text)))
     LEFT JOIN public.ml_metadata m ON (((a.id)::text = (m.asset_id)::text)))
  WHERE ((da.is_executable = true) AND (da.execution_endpoint IS NOT NULL));


ALTER VIEW public.executable_assets OWNER TO ml_assets_user;

--
-- Name: VIEW executable_assets; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON VIEW public.executable_assets IS 'View of all assets that can be executed via API';


--
-- Name: model_executions; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.model_executions (
    id character varying(255) NOT NULL,
    asset_id character varying(255) NOT NULL,
    user_id character varying(255),
    connector_id character varying(255),
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    input_payload jsonb,
    output_payload jsonb,
    error_message text,
    error_code character varying(50),
    http_status_code integer,
    execution_time_ms integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    execution_metadata jsonb
);


ALTER TABLE public.model_executions OWNER TO ml_assets_user;

--
-- Name: TABLE model_executions; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.model_executions IS 'History and status tracking for AI model executions';


--
-- Name: COLUMN model_executions.status; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.model_executions.status IS 'Execution status: pending, running, success, error, timeout';


--
-- Name: COLUMN model_executions.input_payload; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.model_executions.input_payload IS 'JSON payload sent to the model endpoint';


--
-- Name: COLUMN model_executions.output_payload; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.model_executions.output_payload IS 'JSON response received from the model';


--
-- Name: COLUMN model_executions.execution_time_ms; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.model_executions.execution_time_ms IS 'Total execution time in milliseconds';


--
-- Name: pending_negotiations; Type: VIEW; Schema: public; Owner: ml_assets_user
--

CREATE VIEW public.pending_negotiations AS
 SELECT cn.id,
    cn.correlation_id,
    cn.counterparty_id,
    cn.counterparty_address,
    cn.protocol,
    cn.state,
    cn.contract_offer_id,
    cn.contract_agreement_id,
    cn.asset_id,
    cn.policy_id,
    cn.created_at,
    cn.updated_at,
    cn.finalized_at,
    cn.provider_id,
    cn.error_detail,
    a.name AS asset_name,
    a.owner AS asset_owner
   FROM (public.contract_negotiations cn
     JOIN public.assets a ON (((cn.asset_id)::text = (a.id)::text)))
  WHERE ((cn.state)::text = ANY (ARRAY[('REQUESTED'::character varying)::text, ('OFFERED'::character varying)::text, ('ACCEPTED'::character varying)::text, ('AGREED'::character varying)::text, ('VERIFIED'::character varying)::text]));


ALTER VIEW public.pending_negotiations OWNER TO ml_assets_user;

--
-- Name: policy_definitions; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.policy_definitions (
    id character varying(255) NOT NULL,
    policy jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255)
);


ALTER TABLE public.policy_definitions OWNER TO ml_assets_user;

--
-- Name: TABLE policy_definitions; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.policy_definitions IS 'EDC Policy Definitions (ODRL format)';


--
-- Name: upload_chunks; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.upload_chunks (
    id integer NOT NULL,
    session_id integer NOT NULL,
    chunk_index integer NOT NULL,
    etag character varying(255),
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.upload_chunks OWNER TO ml_assets_user;

--
-- Name: TABLE upload_chunks; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.upload_chunks IS 'Individual chunks for multipart uploads';


--
-- Name: upload_chunks_id_seq; Type: SEQUENCE; Schema: public; Owner: ml_assets_user
--

CREATE SEQUENCE public.upload_chunks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_chunks_id_seq OWNER TO ml_assets_user;

--
-- Name: upload_chunks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ml_assets_user
--

ALTER SEQUENCE public.upload_chunks_id_seq OWNED BY public.upload_chunks.id;


--
-- Name: upload_sessions; Type: TABLE; Schema: public; Owner: ml_assets_user
--

CREATE TABLE public.upload_sessions (
    id integer NOT NULL,
    asset_id character varying(255) NOT NULL,
    file_name character varying(500) NOT NULL,
    total_chunks integer NOT NULL,
    uploaded_chunks integer DEFAULT 0,
    s3_upload_id character varying(500),
    status character varying(50) DEFAULT 'in_progress'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    owner character varying(100) DEFAULT 'conn-user1-demo'::character varying
);


ALTER TABLE public.upload_sessions OWNER TO ml_assets_user;

--
-- Name: TABLE upload_sessions; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON TABLE public.upload_sessions IS 'Tracking chunked file uploads to MinIO';


--
-- Name: COLUMN upload_sessions.owner; Type: COMMENT; Schema: public; Owner: ml_assets_user
--

COMMENT ON COLUMN public.upload_sessions.owner IS 'Connector ID of the user who owns this upload session';


--
-- Name: upload_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: ml_assets_user
--

CREATE SEQUENCE public.upload_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_sessions_id_seq OWNER TO ml_assets_user;

--
-- Name: upload_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ml_assets_user
--

ALTER SEQUENCE public.upload_sessions_id_seq OWNED BY public.upload_sessions.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ml_assets_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO ml_assets_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ml_assets_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: data_addresses id; Type: DEFAULT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.data_addresses ALTER COLUMN id SET DEFAULT nextval('public.data_addresses_id_seq'::regclass);


--
-- Name: upload_chunks id; Type: DEFAULT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_chunks ALTER COLUMN id SET DEFAULT nextval('public.upload_chunks_id_seq'::regclass);


--
-- Name: upload_sessions id; Type: DEFAULT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_sessions ALTER COLUMN id SET DEFAULT nextval('public.upload_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: assets; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.assets (id, name, version, content_type, description, short_description, keywords, byte_size, format, asset_type, created_at, updated_at, owner) FROM stdin;
asset-user2-image-api	Chest X-Ray Classifier API	3.1.0	application/json	Computer vision model for medical imaging. Classifies chest X-rays into 5 pathology categories using ResNet architecture.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user2-equipment-model	Industrial Equipment Failure Predictor	1.8.5	application/x-pickle	Tabular classification model for predictive maintenance. Trained on 50K sensor records with XGBoost. AUC: 0.94, Recall: 0.89.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user2-pricing-model	Dynamic Pricing Optimization Model	2.1.2	application/x-pickle	Tabular regression model for revenue optimization. Predicts optimal price point using LightGBM ensemble. MSE: 12.3, R2: 0.87.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user2-detection-model	Warehouse Safety Object Detector	4.2.1	application/x-pickle	Computer vision model for object detection in industrial environments. Detects 15 safety hazard categories using YOLO architecture.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user2-sentiment-model	Customer Review Sentiment Analyzer	1.6.0	application/x-pickle	Natural Language Processing model for multi-class sentiment classification. Trained on 200K reviews with scikit-learn TF-IDF + SVM.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user2-churn-model	Customer Churn Prediction System	3.0.4	application/x-pickle	Tabular classification model for customer retention. Ensemble model combining XGBoost + LightGBM. Trained on 1M customer records. GINI: 0.82.	\N	\N	\N	\N	machineLearning	2026-01-23 12:19:16.600397	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user1-sentiment-api	E-commerce Review Sentiment API	1.4.2	application/json	Natural Language Processing model for sentiment classification. Analyzes customer reviews in Spanish/English with scikit-learn TF-IDF pipeline.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user1-fraud-api	Real-Time Transaction Fraud Detector	2.3.1	application/json	Tabular classification model for financial fraud detection. Trained on 500K transactions with LightGBM. Recall: 0.92, AUC: 0.96.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user1-segmentation-model	Agricultural Crop Segmentation Model	2.0.5	application/x-pickle	Computer vision model for image segmentation. Identifies crop types and disease areas in drone imagery using U-Net architecture.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user1-sales-model	Weekly Sales Forecasting Model	1.7.3	application/x-pickle	Tabular regression model for retail sales prediction. Trained with XGBoost on 2 years of historical data. MAE: 8.5, R2: 0.91.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user1-credit-model	Consumer Credit Risk Classifier	3.1.0	application/x-pickle	Tabular classification model for credit approval decisions. Ensemble of LightGBM models trained on 300K loan applications. GINI: 0.79.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user2-iris-classifier	Iris Species Classifier API	1.2.0	application/json	Machine learning model for classifying iris flowers into three species (setosa, versicolor, virginica) based on sepal and petal measurements. Built using scikit-learn with 95% accuracy on test dataset. Real-time HTTP API endpoint.	Iris flower species classification via HTTP API	iris, classification, flowers, botany, scikit-learn, machine-learning, http-api	0	REST API	machineLearning	2025-12-12 15:41:21.765	2026-01-23 17:06:06.912155	user-conn-user2-demo
asset-user1-recommendation-model	Personalized Product Recommender	2.5.0	application/x-pickle	Tabular classification model for product recommendations. Matrix factorization with XGBoost trained on 5M user interactions.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
asset-user1-vqa-model	Industrial Visual Inspection Assistant	1.2.0	application/x-pickle	Multimodal model for visual question answering. Combines computer vision + NLP for quality control inspection. Built with TensorFlow multi-input architecture.	\N	\N	\N	\N	machineLearning	2026-01-23 12:20:02.848712	2026-01-23 17:06:06.912155	user-conn-user1-demo
\.


--
-- Data for Name: contract_agreements; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.contract_agreements (id, consumer_id, provider_id, asset_id, policy_id, contract_definition_id, negotiation_id, state, signing_date, start_date, end_date, terms, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: contract_definition_assets; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.contract_definition_assets (contract_definition_id, asset_id, created_at) FROM stdin;
contract-user1-sentiment-api	asset-user1-sentiment-api	2026-01-23 12:27:35.869081
contract-user1-fraud-api	asset-user1-fraud-api	2026-01-23 12:27:35.869081
contract-user1-segmentation-model	asset-user1-segmentation-model	2026-01-23 12:27:35.869081
contract-user1-credit-model	asset-user1-credit-model	2026-01-23 12:27:35.869081
contract-user2-image-api	asset-user2-image-api	2026-01-23 12:27:38.331905
contract-user2-equipment-model	asset-user2-equipment-model	2026-01-23 12:27:38.331905
contract-user2-detection-model	asset-user2-detection-model	2026-01-23 12:27:38.331905
contract-user2-iris-classifier	asset-user2-iris-classifier	2026-01-23 13:09:46.327327
\.


--
-- Data for Name: contract_definitions; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.contract_definitions (id, access_policy_id, contract_policy_id, assets_selector, created_at, updated_at, created_by) FROM stdin;
contract-user1-sentiment-api	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:35.869081	2026-01-23 17:17:53.802377	user-conn-user1-demo
contract-user1-fraud-api	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:35.869081	2026-01-23 17:17:53.802377	user-conn-user1-demo
contract-user1-segmentation-model	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:35.869081	2026-01-23 17:17:53.802377	user-conn-user1-demo
contract-user1-credit-model	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:35.869081	2026-01-23 17:17:53.802377	user-conn-user1-demo
contract-user2-image-api	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:38.331905	2026-01-23 17:17:53.802377	user-conn-user2-demo
contract-user2-speech-api	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:38.331905	2026-01-23 17:17:53.802377	user-conn-user2-demo
contract-user2-equipment-model	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:38.331905	2026-01-23 17:17:53.802377	user-conn-user2-demo
contract-user2-detection-model	unrestricted-policy	unrestricted-policy	{}	2026-01-23 12:27:38.331905	2026-01-23 17:17:53.802377	user-conn-user2-demo
contract-user2-iris-classifier	unrestricted-policy	unrestricted-policy	{"asset_ids": ["asset-user2-iris-classifier"]}	2026-01-23 13:09:46.321864	2026-01-23 17:17:53.802377	user-conn-user2-demo
\.


--
-- Data for Name: contract_negotiations; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.contract_negotiations (id, correlation_id, counterparty_id, counterparty_address, protocol, state, contract_offer_id, contract_agreement_id, asset_id, policy_id, created_at, updated_at, finalized_at, provider_id, error_detail) FROM stdin;
\.


--
-- Data for Name: contract_offers; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.contract_offers (id, negotiation_id, asset_id, policy_id, state, provider_id, terms, valid_until, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: data_addresses; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.data_addresses (id, asset_id, type, name, base_url, path, auth_key, auth_code, secret_name, proxy_body, proxy_path, proxy_query_params, proxy_method, region, bucket_name, access_key_id, secret_access_key, endpoint_override, key_prefix, folder_name, folder, file_name, s3_key, created_at, execution_endpoint, execution_method, execution_timeout, is_executable) FROM stdin;
23	asset-user2-pricing-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user2/pricing_optimization_lgbm.pkl	2026-01-23 12:19:16.600397	\N	POST	30000	t
25	asset-user2-sentiment-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user2/sentiment_sklearn_svm.pkl	2026-01-23 12:19:16.600397	\N	POST	30000	t
26	asset-user2-churn-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user2/churn_ensemble_model.pkl	2026-01-23 12:19:16.600397	\N	POST	30000	t
29	asset-user1-segmentation-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user1/crop_segmentation_unet.pkl	2026-01-23 12:20:02.848712	\N	POST	30000	t
30	asset-user1-sales-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user1/sales_forecast_xgb.pkl	2026-01-23 12:20:02.848712	\N	POST	30000	t
31	asset-user1-credit-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user1/credit_risk_lgbm.pkl	2026-01-23 12:20:02.848712	\N	POST	30000	t
32	asset-user1-recommendation-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user1/product_recommender_xgb.pkl	2026-01-23 12:20:02.848712	\N	POST	30000	t
33	asset-user1-vqa-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user1/vqa_multimodal_tf.pkl	2026-01-23 12:20:02.848712	\N	POST	30000	t
28	asset-user1-fraud-api	HttpData	/api/v1/detect-fraud	http://localhost:8080	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-23 12:20:02.848712	http://localhost:8080/api/v1/detect-fraud	POST	8000	t
34	asset-user2-iris-classifier	HttpData	/api/v1/predict	http://localhost:8080	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-23 13:09:46.318022	http://localhost:8080/api/v1/predict	POST	30000	t
27	asset-user1-sentiment-api	HttpData	/api/v1/sentiment	http://localhost:8080	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-23 12:20:02.848712	http://localhost:8080/api/v1/sentiment	POST	12000	t
20	asset-user2-image-api	HttpData	/api/v1/classify-image	http://localhost:8080	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-23 12:19:16.600397	http://localhost:8080/api/v1/classify-image	POST	18000	t
22	asset-user2-equipment-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user2/equipment_failure_xgb.pkl	2026-01-23 12:19:16.600397	http://localhost:8080/api/v1/predict-equipment-failure	POST	30000	f
24	asset-user2-detection-model	S3	\N	http://localhost:9000	\N	\N	\N	\N	\N	\N	\N	\N	\N	ml-assets	\N	\N	\N	\N	\N	\N	\N	models/user2/warehouse_detection_yolo.pkl	2026-01-23 12:19:16.600397	http://localhost:8080/api/v1/detect-objects	POST	30000	f
\.


--
-- Data for Name: ml_metadata; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.ml_metadata (asset_id, task, subtask, algorithm, library, framework, software, programming_language, license, version, input_features) FROM stdin;
asset-user2-image-api	Computer vision	Image Classification	Classification Algorithm	PyTorch	PyTorch	Python	Python 3.11	apache-2.0	3.1.0	{"task": "image_classification", "features": [{"name": "image", "type": "string", "required": true, "description": "Base64 encoded image or image URL"}], "keywords": ["medical", "radiology", "pathology"], "languages": ["English"], "image_format": "224x224x3 RGB tensor", "normalization": "ImageNet", "evaluation_metrics": [{"value": 0.93, "metric": "AUC"}]}
asset-user2-equipment-model	Tabular	Image Classification	Classification Algorithm	XGBoost	XGBoost	Python	Python 3.10	apache-2.0	1.8.5	{"pressure_psi": "float", "vibration_hz": "float", "runtime_hours": "int", "maintenance_days": "int", "evaluation_metrics": [{"value": 0.94, "metric": "AUC"}, {"value": 0.89, "metric": "Recall"}], "temperature_celsius": "float"}
asset-user2-pricing-model	Tabular	Image Classification	Regression Algorithm	LightGBM	LightGBM	Python	Python 3.10	mit	2.1.2	{"inventory_level": "int", "competitor_price": "float", "demand_elasticity": "float", "seasonality_index": "float", "evaluation_metrics": [{"value": 12.3, "metric": "MSE"}, {"value": 0.87, "metric": "R2"}]}
asset-user2-detection-model	Computer vision	Object detection	Multi label Classification Algorithm	PyTorch	PyTorch	Python	Python 3.11	apache-2.0	4.2.1	{"keywords": ["safety", "warehouse", "hazard"], "image_size": [640, 640], "nms_threshold": 0.45, "evaluation_metrics": [{"value": 0.78, "metric": "GINI"}], "confidence_threshold": 0.5}
asset-user2-sentiment-model	Natural Language Processing	Image Classification	Multi label Classification Algorithm	scikit-learn	scikit-learn	Python	Python 3.10	apache-2.0	1.6.0	{"text": "string", "keywords": ["sentiment", "reviews", "NLP"], "languages": ["Spanish", "English"], "max_length": 512, "evaluation_metrics": [{"value": 0.91, "metric": "AUC"}]}
asset-user2-churn-model	Tabular	Image Classification	Classification Algorithm	XGBoost	XGBoost	Python	Python 3.10	mit	3.0.4	{"contract_type": "categorical", "tenure_months": "int", "monthly_charges": "float", "support_tickets": "int", "evaluation_metrics": [{"value": 0.82, "metric": "GINI"}, {"value": 0.91, "metric": "AUC"}], "customer_lifetime_value": "float"}
asset-user1-sentiment-api	Natural Language Processing	Image Classification	Multi label Classification Algorithm	scikit-learn	scikit-learn	Python	Python 3.10	apache-2.0	1.4.2	{"task": "sentiment_analysis", "features": [{"name": "text", "type": "string", "required": true, "description": "Text to analyze for sentiment (reviews, comments, etc.)"}], "languages": ["Spanish", "English"], "max_tokens": 512}
asset-user1-fraud-api	Tabular	Image Classification	Classification Algorithm	LightGBM	LightGBM	Python	Python 3.10	mit	2.3.1	{"task": "fraud_detection", "features": [{"min": 0, "name": "transaction_amount", "type": "float", "required": true, "description": "Transaction amount in currency units"}, {"min": 0, "name": "time_since_last", "type": "int", "required": true, "description": "Time since last transaction in minutes"}, {"min": 0, "name": "location_distance", "type": "float", "required": true, "description": "Distance from usual location in km"}, {"name": "merchant_category", "type": "string", "required": true, "description": "Merchant category (e.g., retail, restaurant, online)"}], "evaluation_metrics": [{"value": 0.92, "metric": "Recall"}, {"value": 0.96, "metric": "AUC"}]}
asset-user1-segmentation-model	Computer vision	Image Segmentation	Multi label Classification Algorithm	TensorFlow	TensorFlow	Python	Python 3.11	apache-2.0	2.0.5	{"classes": 8, "channels": 3, "keywords": ["agriculture", "drone", "crop"], "image_size": [512, 512], "evaluation_metrics": [{"value": 0.75, "metric": "GINI"}]}
asset-user1-sales-model	Tabular	Image Classification	Regression Algorithm	XGBoost	XGBoost	Python	Python 3.10	apache-2.0	1.7.3	{"holiday": "boolean", "promotions": "boolean", "temperature": "float", "week_of_year": "int", "evaluation_metrics": [{"value": 8.5, "metric": "MAE"}, {"value": 0.91, "metric": "R2"}]}
asset-user1-credit-model	Tabular	Image Classification	Classification Algorithm	LightGBM	LightGBM	Python	Python 3.10	mit	3.1.0	{"loan_amount": "float", "annual_income": "float", "debt_to_income": "float", "evaluation_metrics": [{"value": 0.79, "metric": "GINI"}, {"value": 0.895, "metric": "AUC"}], "credit_history_months": "int"}
asset-user1-recommendation-model	Tabular	Image Classification	Multi label Classification Algorithm	XGBoost	XGBoost	Python	Python 3.10	apache-2.0	2.5.0	{"user_id": "string", "keywords": ["recommendation", "personalization"], "demographics": "object", "browsing_history": "array", "purchase_history": "array", "evaluation_metrics": [{"value": 0.87, "metric": "AUC"}]}
asset-user1-vqa-model	Multimodal	Visual question answering	Multi label Classification Algorithm	TensorFlow	TensorFlow	Python	Python 3.11	mit	1.2.0	{"keywords": ["VQA", "quality-control", "inspection"], "languages": ["English", "Spanish"], "max_length": 128, "image_tensor": "array[224,224,3]", "question_text": "string", "evaluation_metrics": [{"value": 0.83, "metric": "AUC"}]}
asset-user2-iris-classifier	Tabular	Classification	Classification Algorithm	scikit-learn	scikit-learn	Python	Python	MIT	1.2.0	{"output": {"confidence": "float", "prediction": "string", "probabilities": "object"}, "classes": ["setosa", "versicolor", "virginica"], "dataset": "Iris Dataset", "samples": 150, "features": [{"name": "sepal_length", "type": "float", "required": true, "description": "Sepal length in cm (4.0-8.0)"}, {"name": "sepal_width", "type": "float", "required": true, "description": "Sepal width in cm (2.0-4.5)"}, {"name": "petal_length", "type": "float", "required": true, "description": "Petal length in cm (1.0-7.0)"}, {"name": "petal_width", "type": "float", "required": true, "description": "Petal width in cm (0.1-2.5)"}], "evaluation_metrics": {"recall": 0.95, "accuracy": 0.95, "f1_score": 0.94, "precision": 0.94}}
\.


--
-- Data for Name: model_executions; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.model_executions (id, asset_id, user_id, connector_id, status, input_payload, output_payload, error_message, error_code, http_status_code, execution_time_ms, created_at, started_at, completed_at, execution_metadata) FROM stdin;
a24f8633-ca0d-4eb0-9412-6a536af5e11b	asset-user1-sentiment-api	3	user-conn-user1-demo	error	{"input": "i am very happy about my advances"}	\N	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n<title>404 Not Found</title>\n<h1>Not Found</h1>\n<p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>\n	HTTP_404	404	\N	2026-01-23 18:41:06.642314	2026-01-23 18:41:06.65	2026-01-23 18:41:06.9	\N
986e7c41-3a23-4352-b3a4-12e5e65c7508	asset-user1-fraud-api	3	user-conn-user1-demo	success	{"text": "I love this amazing product"}	{"model": "Fraud Detector", "is_fraud": false, "risk_level": "low", "risk_factors": {"high_amount": false, "unusual_time": false, "risky_merchant": false, "card_not_present": false, "unusual_location": false}, "fraud_probability": 0.021, "transaction_details": {"hour": 12, "amount": 100, "location": "domestic", "merchant": "retail"}}	\N	\N	200	1020	2026-01-23 18:44:53.153553	2026-01-23 18:44:53.16	2026-01-23 18:44:54.166	\N
fa13f19d-54b0-4680-a79c-95090927a48b	asset-user1-sentiment-api	3	user-conn-user1-demo	error	{"text": "I love this amazing product"}	\N	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n<title>404 Not Found</title>\n<h1>Not Found</h1>\n<p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>\n	HTTP_404	404	\N	2026-01-23 18:46:17.94942	2026-01-23 18:46:17.953	2026-01-23 18:46:17.969	\N
\.


--
-- Data for Name: policy_definitions; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.policy_definitions (id, policy, created_at, updated_at, created_by) FROM stdin;
use-eu-policy	{"@id": "use-eu-policy", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "EQ", "odrl:leftOperand": "BusinessPartnerNumber", "odrl:rightOperand": "EU"}]}]}	2025-12-11 14:46:48.491759	2025-12-11 14:46:48.491759	\N
connector-restricted-policy	{"@id": "connector-restricted-policy", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "EQ", "odrl:leftOperand": "DataspaceIdentifier", "odrl:rightOperand": "INESDATA"}]}]}	2025-12-11 14:46:48.491759	2025-12-11 14:46:48.491759	\N
unrestricted-policy	{"@id": "unrestricted-policy", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE"}]}	2025-12-11 14:46:48.491759	2025-12-11 14:46:48.491759	\N
ID_POLICY_001	{"@id": "ID_POLICY_001", "policy": {"@id": "ID_POLICY_001", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE"}]}, "@context": {"odrl": "http://www.w3.org/ns/odrl/2/", "@vocab": "https://w3id.org/edc/v0.0.1/ns/"}}	2025-12-11 15:02:43.571703	2025-12-11 15:02:43.571703	user-conn-user1-demo
TIME_RESTRICTED_POLICY	{"@id": "TIME_RESTRICTED_POLICY", "policy": {"@id": "TIME_RESTRICTED_POLICY", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "GEQ", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2025-01-01T00:00:00.000Z"}, {"odrl:operator": "LEQ", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2025-12-31T23:59:59.999Z"}]}]}, "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"}}	2025-12-11 15:35:31.274558	2025-12-11 15:35:31.274558	user-conn-user1-demo
ID_POLICY_WITH_CONSTRAINTS	{"@id": "ID_POLICY_WITH_CONSTRAINTS", "policy": {"@id": "ID_POLICY_WITH_CONSTRAINTS", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "EQ", "odrl:leftOperand": "DataspaceIdentifier", "odrl:rightOperand": "DataSpacePrototype"}, {"odrl:operator": "EQ", "odrl:leftOperand": "PURPOSE", "odrl:rightOperand": "Research"}]}]}, "@context": {"edc": "https://w3id.org/edc/v0.0.1/ns/"}}	2025-12-11 15:30:28.260211	2025-12-11 15:44:46.887529	user-conn-user1-demo
test-policy-001	{"@type": "odrl:Set", "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": []}]}	2025-12-12 00:23:48.464927	2025-12-12 00:23:48.464927	user-conn-user1-demo
test-policy-002	{"@type": "odrl:Set", "odrl:permission": [{"odrl:action": "USE"}]}	2025-12-12 00:23:58.419871	2025-12-12 00:23:58.419871	user-conn-user1-demo
time_policy	{"@id": "time_policy", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "GT", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2025-12-15T23:00:00.000Z"}, {"odrl:operator": "LEQ", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2026-03-24T23:00:00.000Z"}]}]}	2025-12-12 00:31:17.142866	2025-12-12 00:31:17.142866	user-conn-user1-demo
policy-iris-http-1765535248	{"@type": "odrl:Set", "odrl:permission": [{"odrl:action": "USE"}]}	2025-12-12 10:27:28.476492	2025-12-12 10:27:28.476492	user-conn-user1-demo
policy-iris-http-1765537190	{"@type": "odrl:Set", "odrl:permission": [{"odrl:action": "USE"}]}	2025-12-12 10:59:50.779035	2025-12-12 10:59:50.779035	user-conn-user1-demo
policy_002_ld	{"@id": "policy_002_ld", "@type": "PolicyDefinition", "@context": ["https://www.w3.org/ns/odrl.jsonld", {"edc": "https://w3id.org/edc/v0.0.1/ns/"}], "odrl:permission": [{"odrl:action": "USE", "odrl:constraint": [{"odrl:operator": "GEQ", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2025-12-15T23:00:00.000Z"}, {"odrl:operator": "LEQ", "odrl:leftOperand": "POLICY_EVALUATION_TIME", "odrl:rightOperand": "2026-05-30T22:00:00.000Z"}]}]}	2025-12-12 13:02:09.067957	2025-12-12 13:02:09.067957	user-conn-user1-demo
policy-alpha-standard	{"@type": "PolicyDefinition", "policy": {"@type": "Set", "permission": [{"action": "use", "constraint": {"operator": "eq", "leftOperand": "purpose", "rightOperand": "research"}}]}}	2026-01-23 01:23:50.018452	2026-01-23 01:23:50.018452	\N
policy-beta-premium	{"@type": "PolicyDefinition", "policy": {"@type": "Set", "permission": [{"action": "use", "constraint": {"operator": "lteq", "leftOperand": "usage", "rightOperand": "1000"}}]}}	2026-01-23 01:23:50.018452	2026-01-23 01:23:50.018452	\N
policy-slow-basic	{"@type": "PolicyDefinition", "policy": {"@type": "Set", "permission": [{"action": "use"}]}}	2026-01-23 01:23:50.018452	2026-01-23 01:23:50.018452	\N
\.


--
-- Data for Name: upload_chunks; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.upload_chunks (id, session_id, chunk_index, etag, uploaded_at) FROM stdin;
1	1	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 12:58:04.353553
2	2	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 13:06:55.455912
3	3	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 13:07:56.546862
4	4	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 17:31:14.555175
5	5	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 17:44:08.275506
6	6	0	"af38fa28cece05b54fe88e44977de512"	2025-12-11 17:53:42.974704
\.


--
-- Data for Name: upload_sessions; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.upload_sessions (id, asset_id, file_name, total_chunks, uploaded_chunks, s3_upload_id, status, created_at, updated_at, owner) FROM stdin;
1	ML_Model_001	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLmNiODY5MTVmLTUzNjktNGM4YS1hMTExLTg3YjVjYTI1ZDViOXgxNzY1NDU3ODg0Mjc1OTYwNTU3	completed	2025-12-11 12:58:04.306624	2025-12-11 12:58:04.495868	conn-user1-demo
2	ML_Model_001	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLmExNWRhYjQ4LTJhZjEtNGFiMy04ZGU1LWMzYzUwYjRhZDJjY3gxNzY1NDU4NDE1MzkzOTkxNDgy	in_progress	2025-12-11 13:06:55.408128	2025-12-11 13:06:55.462571	conn-user1-demo
3	ML_Model_002	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLjJmMTAzZjdhLWVlYmEtNGU3NS1iYjVlLWIzYjI0YjY1NjRiNngxNzY1NDU4NDc2NDc3MTU4NDE2	completed	2025-12-11 13:07:56.492198	2025-12-11 13:07:56.696001	conn-user1-demo
4	ML_Model_003	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLmI1MjZlZjlhLTI0MDEtNDkzMS1hMjhhLWQyMWIwM2U0ODE4YXgxNzY1NDc0Mjc0NDYwOTExODA4	completed	2025-12-11 17:31:14.495391	2025-12-11 17:31:14.772751	conn-user1-demo
5	ML_model_004	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLjdiYjk0YjhkLTJkMmYtNDIzYi04Mjk3LTQyYzMxYzY2NWE5MHgxNzY1NDc1MDQ4MTg4MDI4Mjcw	completed	2025-12-11 17:44:08.222285	2025-12-11 17:44:08.454517	conn-user1-demo
6	ML_model_005	LGBM_Classifier_1.pkl	1	1	OGFhMWExNWEtMmJmMS00ZDU4LTkzMjQtYTk3MjNmZjRlYWMzLjAxMTE1Y2ExLWRlNDYtNDA5Yy05OWQ3LTJiOWM4NDVhNGU3ZngxNzY1NDc1NjIyODgxNzE3NTk1	completed	2025-12-11 17:53:42.917684	2025-12-11 17:53:43.153938	conn-user1-demo
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ml_assets_user
--

COPY public.users (id, username, password_hash, connector_id, display_name, email, is_active, created_at, updated_at) FROM stdin;
3	user-conn-user1-demo	$2a$10$I/m17k0PieyAy2M71CT9De3uVqv0mNft/yz.DmvGYrEZKAYc5qA1C	user-conn-user1-demo	User1 Demo User	demo@oeg.fi.upm.es	t	2025-12-12 16:41:21.765511	2025-12-12 16:41:21.765511
4	user-conn-user2-demo	$2a$10$4V9w.aXdEAcxU/ln6M7MHue25m6yjTeeJM1E3bkvEPj2XaSOa8M5.	user-conn-user2-demo	User2 Demo User	edmundo@demo.com	t	2025-12-12 16:41:21.765511	2025-12-12 16:41:21.765511
\.


--
-- Name: data_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ml_assets_user
--

SELECT pg_catalog.setval('public.data_addresses_id_seq', 34, true);


--
-- Name: upload_chunks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ml_assets_user
--

SELECT pg_catalog.setval('public.upload_chunks_id_seq', 6, true);


--
-- Name: upload_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ml_assets_user
--

SELECT pg_catalog.setval('public.upload_sessions_id_seq', 6, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ml_assets_user
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: contract_agreements contract_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_agreements
    ADD CONSTRAINT contract_agreements_pkey PRIMARY KEY (id);


--
-- Name: contract_definition_assets contract_definition_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definition_assets
    ADD CONSTRAINT contract_definition_assets_pkey PRIMARY KEY (contract_definition_id, asset_id);


--
-- Name: contract_definitions contract_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definitions
    ADD CONSTRAINT contract_definitions_pkey PRIMARY KEY (id);


--
-- Name: contract_negotiations contract_negotiations_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_negotiations
    ADD CONSTRAINT contract_negotiations_pkey PRIMARY KEY (id);


--
-- Name: contract_offers contract_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_offers
    ADD CONSTRAINT contract_offers_pkey PRIMARY KEY (id);


--
-- Name: data_addresses data_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.data_addresses
    ADD CONSTRAINT data_addresses_pkey PRIMARY KEY (id);


--
-- Name: ml_metadata ml_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.ml_metadata
    ADD CONSTRAINT ml_metadata_pkey PRIMARY KEY (asset_id);


--
-- Name: model_executions model_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.model_executions
    ADD CONSTRAINT model_executions_pkey PRIMARY KEY (id);


--
-- Name: policy_definitions policy_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.policy_definitions
    ADD CONSTRAINT policy_definitions_pkey PRIMARY KEY (id);


--
-- Name: upload_chunks upload_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_chunks
    ADD CONSTRAINT upload_chunks_pkey PRIMARY KEY (id);


--
-- Name: upload_chunks upload_chunks_session_id_chunk_index_key; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_chunks
    ADD CONSTRAINT upload_chunks_session_id_chunk_index_key UNIQUE (session_id, chunk_index);


--
-- Name: upload_sessions upload_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_sessions
    ADD CONSTRAINT upload_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_connector_id_key; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_connector_id_key UNIQUE (connector_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_agreements_asset; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_agreements_asset ON public.contract_agreements USING btree (asset_id);


--
-- Name: idx_agreements_consumer; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_agreements_consumer ON public.contract_agreements USING btree (consumer_id);


--
-- Name: idx_agreements_consumer_asset; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_agreements_consumer_asset ON public.contract_agreements USING btree (consumer_id, asset_id);


--
-- Name: idx_agreements_provider; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_agreements_provider ON public.contract_agreements USING btree (provider_id);


--
-- Name: idx_agreements_state; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_agreements_state ON public.contract_agreements USING btree (state);


--
-- Name: idx_assets_created_at; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_assets_created_at ON public.assets USING btree (created_at DESC);


--
-- Name: idx_assets_owner; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_assets_owner ON public.assets USING btree (owner);


--
-- Name: idx_assets_type; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_assets_type ON public.assets USING btree (asset_type);


--
-- Name: idx_contract_definition_assets_asset_id; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_contract_definition_assets_asset_id ON public.contract_definition_assets USING btree (asset_id);


--
-- Name: idx_contract_definitions_access_policy; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_contract_definitions_access_policy ON public.contract_definitions USING btree (access_policy_id);


--
-- Name: idx_contract_definitions_contract_policy; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_contract_definitions_contract_policy ON public.contract_definitions USING btree (contract_policy_id);


--
-- Name: idx_contract_definitions_created_at; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_contract_definitions_created_at ON public.contract_definitions USING btree (created_at DESC);


--
-- Name: idx_data_addresses_asset_id; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_data_addresses_asset_id ON public.data_addresses USING btree (asset_id);


--
-- Name: idx_data_addresses_is_executable; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_data_addresses_is_executable ON public.data_addresses USING btree (is_executable) WHERE (is_executable = true);


--
-- Name: idx_data_addresses_type; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_data_addresses_type ON public.data_addresses USING btree (type);


--
-- Name: idx_ml_metadata_algorithm; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_ml_metadata_algorithm ON public.ml_metadata USING btree (algorithm);


--
-- Name: idx_ml_metadata_input_features; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_ml_metadata_input_features ON public.ml_metadata USING gin (input_features);


--
-- Name: idx_ml_metadata_task; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_ml_metadata_task ON public.ml_metadata USING btree (task);


--
-- Name: idx_model_executions_asset_id; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_model_executions_asset_id ON public.model_executions USING btree (asset_id);


--
-- Name: idx_model_executions_created_at; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_model_executions_created_at ON public.model_executions USING btree (created_at DESC);


--
-- Name: idx_model_executions_status; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_model_executions_status ON public.model_executions USING btree (status);


--
-- Name: idx_model_executions_user_id; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_model_executions_user_id ON public.model_executions USING btree (user_id);


--
-- Name: idx_negotiations_asset; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_negotiations_asset ON public.contract_negotiations USING btree (asset_id);


--
-- Name: idx_negotiations_counterparty; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_negotiations_counterparty ON public.contract_negotiations USING btree (counterparty_id);


--
-- Name: idx_negotiations_created; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_negotiations_created ON public.contract_negotiations USING btree (created_at);


--
-- Name: idx_negotiations_provider; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_negotiations_provider ON public.contract_negotiations USING btree (provider_id);


--
-- Name: idx_negotiations_state; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_negotiations_state ON public.contract_negotiations USING btree (state);


--
-- Name: idx_offers_asset; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_offers_asset ON public.contract_offers USING btree (asset_id);


--
-- Name: idx_offers_negotiation; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_offers_negotiation ON public.contract_offers USING btree (negotiation_id);


--
-- Name: idx_offers_state; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_offers_state ON public.contract_offers USING btree (state);


--
-- Name: idx_policy_definitions_created_at; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_policy_definitions_created_at ON public.policy_definitions USING btree (created_at DESC);


--
-- Name: idx_upload_sessions_asset_id; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_upload_sessions_asset_id ON public.upload_sessions USING btree (asset_id);


--
-- Name: idx_upload_sessions_owner; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_upload_sessions_owner ON public.upload_sessions USING btree (owner);


--
-- Name: idx_upload_sessions_status; Type: INDEX; Schema: public; Owner: ml_assets_user
--

CREATE INDEX idx_upload_sessions_status ON public.upload_sessions USING btree (status);


--
-- Name: contract_agreements trigger_update_agreement_timestamp; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER trigger_update_agreement_timestamp BEFORE UPDATE ON public.contract_agreements FOR EACH ROW EXECUTE FUNCTION public.update_negotiation_timestamp();


--
-- Name: contract_negotiations trigger_update_negotiation_timestamp; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER trigger_update_negotiation_timestamp BEFORE UPDATE ON public.contract_negotiations FOR EACH ROW EXECUTE FUNCTION public.update_negotiation_timestamp();


--
-- Name: contract_offers trigger_update_offer_timestamp; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER trigger_update_offer_timestamp BEFORE UPDATE ON public.contract_offers FOR EACH ROW EXECUTE FUNCTION public.update_negotiation_timestamp();


--
-- Name: assets update_assets_updated_at; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON public.assets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: contract_definitions update_contract_definitions_updated_at; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER update_contract_definitions_updated_at BEFORE UPDATE ON public.contract_definitions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: policy_definitions update_policy_definitions_updated_at; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER update_policy_definitions_updated_at BEFORE UPDATE ON public.policy_definitions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: upload_sessions update_upload_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: ml_assets_user
--

CREATE TRIGGER update_upload_sessions_updated_at BEFORE UPDATE ON public.upload_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: contract_agreements contract_agreements_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_agreements
    ADD CONSTRAINT contract_agreements_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: contract_agreements contract_agreements_negotiation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_agreements
    ADD CONSTRAINT contract_agreements_negotiation_id_fkey FOREIGN KEY (negotiation_id) REFERENCES public.contract_negotiations(id) ON DELETE SET NULL;


--
-- Name: contract_definition_assets contract_definition_assets_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definition_assets
    ADD CONSTRAINT contract_definition_assets_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: contract_definition_assets contract_definition_assets_contract_definition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definition_assets
    ADD CONSTRAINT contract_definition_assets_contract_definition_id_fkey FOREIGN KEY (contract_definition_id) REFERENCES public.contract_definitions(id) ON DELETE CASCADE;


--
-- Name: contract_definitions contract_definitions_access_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definitions
    ADD CONSTRAINT contract_definitions_access_policy_id_fkey FOREIGN KEY (access_policy_id) REFERENCES public.policy_definitions(id) ON DELETE RESTRICT;


--
-- Name: contract_definitions contract_definitions_contract_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_definitions
    ADD CONSTRAINT contract_definitions_contract_policy_id_fkey FOREIGN KEY (contract_policy_id) REFERENCES public.policy_definitions(id) ON DELETE RESTRICT;


--
-- Name: contract_negotiations contract_negotiations_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_negotiations
    ADD CONSTRAINT contract_negotiations_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: contract_offers contract_offers_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_offers
    ADD CONSTRAINT contract_offers_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: contract_offers contract_offers_negotiation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.contract_offers
    ADD CONSTRAINT contract_offers_negotiation_id_fkey FOREIGN KEY (negotiation_id) REFERENCES public.contract_negotiations(id) ON DELETE CASCADE;


--
-- Name: data_addresses data_addresses_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.data_addresses
    ADD CONSTRAINT data_addresses_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: model_executions fk_execution_asset; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.model_executions
    ADD CONSTRAINT fk_execution_asset FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: ml_metadata ml_metadata_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.ml_metadata
    ADD CONSTRAINT ml_metadata_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: ml_metadata ml_metadata_asset_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.ml_metadata
    ADD CONSTRAINT ml_metadata_asset_id_fkey1 FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: upload_chunks upload_chunks_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ml_assets_user
--

ALTER TABLE ONLY public.upload_chunks
    ADD CONSTRAINT upload_chunks_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.upload_sessions(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict tYUXgXy5uxwe6Z8te3dNkzgGOOQMbDITX5QUyAItSZwcggGyHOcEnlko1vVxvWD

