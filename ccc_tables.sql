CREATE TABLE IF NOT EXISTS auto_insurance_horizon.agent
(
    agent_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.agent_agent_id_seq'::regclass),
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    phone_number character varying(15) COLLATE pg_catalog."default",
    email character varying(100) COLLATE pg_catalog."default",
    agency_name character varying(100) COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.claim
(
    claim_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.claim_claim_id_seq'::regclass),
    policy_id integer NOT NULL,
    customer_id integer NOT NULL,
    agent_id integer,
    claim_adjuster_id integer NOT NULL,
    incident_id integer NOT NULL,
    repair_shop_id integer,
    claim_date date NOT NULL,
    claim_amount numeric(10,2) NOT NULL,
    status character varying(20) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.claim_adjuster
(
    adjuster_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.claim_adjuster_adjuster_id_seq'::regclass),
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    phone_number character varying(15) COLLATE pg_catalog."default",
    email character varying(100) COLLATE pg_catalog."default",
    agency_name character varying(100) COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.claim_notes
(
    note_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.claim_notes_note_id_seq'::regclass),
    claim_id integer NOT NULL,
    note_text text COLLATE pg_catalog."default" NOT NULL,
    note_date timestamp without time zone NOT NULL,
    note_type character varying(20) COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.customer
(
    customer_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.customer_customer_id_seq'::regclass),
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    date_of_birth date NOT NULL,
    address character varying(200) COLLATE pg_catalog."default",
    phone_number character varying(15) COLLATE pg_catalog."default",
    email character varying(100) COLLATE pg_catalog."default",
    license_number character varying(20) COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.incident
(
    incident_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.incident_incident_id_seq'::regclass),
    incident_date date NOT NULL,
    location character varying(200) COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    police_report_number character varying(20) COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.payment
(
    payment_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.payment_payment_id_seq'::regclass),
    policy_id integer NOT NULL,
    customer_id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(50) COLLATE pg_catalog."default" NOT NULL,
    status character varying(20) COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.policy
(
    policy_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.policy_policy_id_seq'::regclass),
    customer_id integer NOT NULL,
    agent_id integer,
    policy_number character varying(20) COLLATE pg_catalog."default" NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    premium_amount numeric(10,2) NOT NULL,
    coverage_type character varying(50) COLLATE pg_catalog."default" NOT NULL,
    status character varying(20) COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.repair_shop
(
    shop_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.repair_shop_shop_id_seq'::regclass),
    shop_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    address character varying(200) COLLATE pg_catalog."default" NOT NULL,
    phone_number character varying(15) COLLATE pg_catalog."default" NOT NULL,
    email character varying(100) COLLATE pg_catalog."default",
    contact_name character varying(100) COLLATE pg_catalog."default",
    agency_name character varying(100) COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS auto_insurance_horizon.vehicle
(
    vehicle_id integer NOT NULL DEFAULT nextval('auto_insurance_horizon.vehicle_vehicle_id_seq'::regclass),
    policy_id integer NOT NULL,
    vin character varying(17) COLLATE pg_catalog."default" NOT NULL,
    make character varying(50) COLLATE pg_catalog."default" NOT NULL,
    model character varying(50) COLLATE pg_catalog."default" NOT NULL,
    year integer NOT NULL,
    license_plate character varying(10) COLLATE pg_catalog."default" NOT NULL,
    vehicle_value numeric(10,2) NOT NULL
);
