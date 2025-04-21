CREATE TABLE IF NOT EXISTS public.addresses
(
    address_id bigint NOT NULL DEFAULT nextval('addresses_address_id_seq'::regclass),
    street_line1 text COLLATE pg_catalog."default" NOT NULL,
    street_line2 text COLLATE pg_catalog."default",
    city text COLLATE pg_catalog."default" NOT NULL,
    state_code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    postal_code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    county text COLLATE pg_catalog."default",
    country_code character varying(3) COLLATE pg_catalog."default" NOT NULL DEFAULT 'USA'::character varying,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT addresses_pkey PRIMARY KEY (address_id)
);

CREATE TABLE IF NOT EXISTS public.borrowers
(
    borrower_internal_id bigint NOT NULL DEFAULT nextval('borrowers_borrower_internal_id_seq'::regclass),
    borrower_id text COLLATE pg_catalog."default" NOT NULL,
    application_id text COLLATE pg_catalog."default" NOT NULL,
    role text COLLATE pg_catalog."default" NOT NULL,
    first_name text COLLATE pg_catalog."default" NOT NULL,
    middle_name text COLLATE pg_catalog."default",
    last_name text COLLATE pg_catalog."default" NOT NULL,
    suffix text COLLATE pg_catalog."default",
    date_of_birth date NOT NULL,
    ssn text COLLATE pg_catalog."default",
    citizenship_status text COLLATE pg_catalog."default" NOT NULL,
    marital_status text COLLATE pg_catalog."default" NOT NULL,
    dependents_count integer NOT NULL DEFAULT 0,
    dependents_ages integer[],
    contact_email text COLLATE pg_catalog."default",
    contact_phone_mobile text COLLATE pg_catalog."default",
    contact_phone_home text COLLATE pg_catalog."default",
    current_address_id bigint NOT NULL,
    previous_address_id bigint,
    mailing_address_id bigint,
    years_at_current_address numeric(4,2) NOT NULL,
    residency_type text COLLATE pg_catalog."default" NOT NULL,
    monthly_housing_expense numeric(10,2) NOT NULL,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT borrowers_pkey PRIMARY KEY (borrower_internal_id),
    CONSTRAINT borrowers_application_id_borrower_id_key UNIQUE (application_id, borrower_id),
    CONSTRAINT borrowers_application_id_fkey FOREIGN KEY (application_id)
        REFERENCES public.applications (application_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT borrowers_current_address_id_fkey FOREIGN KEY (current_address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT borrowers_mailing_address_id_fkey FOREIGN KEY (mailing_address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT borrowers_previous_address_id_fkey FOREIGN KEY (previous_address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.applications
(
    application_id text COLLATE pg_catalog."default" NOT NULL,
    application_date date NOT NULL,
    loan_purpose text COLLATE pg_catalog."default" NOT NULL,
    application_status text COLLATE pg_catalog."default" NOT NULL,
    source_channel text COLLATE pg_catalog."default",
    property_id text COLLATE pg_catalog."default",
    loan_id text COLLATE pg_catalog."default",
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT applications_pkey PRIMARY KEY (application_id),
    CONSTRAINT fk_applications_loan FOREIGN KEY (loan_id)
        REFERENCES public.loans (loan_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT fk_applications_property FOREIGN KEY (property_id)
        REFERENCES public.properties (property_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
);


