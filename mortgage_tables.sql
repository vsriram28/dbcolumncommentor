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

CREATE TABLE IF NOT EXISTS public.assets
(
    asset_id bigint NOT NULL DEFAULT nextval('assets_asset_id_seq'::regclass),
    borrower_internal_id bigint NOT NULL,
    asset_type text COLLATE pg_catalog."default" NOT NULL,
    financial_institution text COLLATE pg_catalog."default" NOT NULL,
    account_number text COLLATE pg_catalog."default",
    current_balance numeric(15,2) NOT NULL,
    description text COLLATE pg_catalog."default",
    is_liquid boolean,
    real_estate_address_id bigint,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT assets_pkey PRIMARY KEY (asset_id),
    CONSTRAINT assets_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT assets_real_estate_address_id_fkey FOREIGN KEY (real_estate_address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.credit_reports
(
    credit_report_internal_id bigint NOT NULL DEFAULT nextval('credit_reports_credit_report_internal_id_seq'::regclass),
    credit_report_id text COLLATE pg_catalog."default" NOT NULL,
    borrower_internal_id bigint NOT NULL,
    report_provider_name text COLLATE pg_catalog."default" NOT NULL,
    report_date date NOT NULL,
    credit_score integer NOT NULL,
    credit_score_model text COLLATE pg_catalog."default" NOT NULL,
    report_url_or_reference text COLLATE pg_catalog."default",
    public_records_count integer,
    collections_count integer,
    total_credit_limit numeric(15,2),
    total_credit_balance numeric(15,2),
    credit_utilization_ratio numeric(5,2),
    derogatory_marks_count integer,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb NOT NULL,
    additional_data jsonb,
    CONSTRAINT credit_reports_pkey PRIMARY KEY (credit_report_internal_id),
    CONSTRAINT credit_reports_borrower_internal_id_report_provider_name_re_key UNIQUE (borrower_internal_id, report_provider_name, report_date),
    CONSTRAINT credit_reports_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.declarations
(
    declaration_id bigint NOT NULL DEFAULT nextval('declarations_declaration_id_seq'::regclass),
    borrower_internal_id bigint NOT NULL,
    has_outstanding_judgments boolean NOT NULL,
    is_delinquent_on_federal_debt boolean NOT NULL,
    is_party_to_lawsuit boolean NOT NULL,
    has_foreclosure_in_past_7_years boolean NOT NULL,
    has_bankruptcy_in_past_7_years boolean NOT NULL,
    bankruptcy_type text COLLATE pg_catalog."default",
    is_obligated_to_pay_alimony_etc boolean NOT NULL,
    is_down_payment_borrowed boolean NOT NULL,
    is_co_maker_or_endorser_on_note boolean NOT NULL,
    will_occupy_as_primary_residence boolean NOT NULL,
    has_ownership_interest_in_property boolean NOT NULL,
    prior_property_title_type text COLLATE pg_catalog."default",
    prior_property_usage_type text COLLATE pg_catalog."default",
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT declarations_pkey PRIMARY KEY (declaration_id),
    CONSTRAINT declarations_borrower_internal_id_key UNIQUE (borrower_internal_id),
    CONSTRAINT declarations_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.employments
(
    employment_id bigint NOT NULL DEFAULT nextval('employments_employment_id_seq'::regclass),
    borrower_internal_id bigint NOT NULL,
    is_current_employment boolean NOT NULL,
    employment_type text COLLATE pg_catalog."default" NOT NULL,
    employer_name text COLLATE pg_catalog."default" NOT NULL,
    job_title text COLLATE pg_catalog."default" NOT NULL,
    start_date date NOT NULL,
    end_date date,
    years_in_profession numeric(4,2),
    is_salaried boolean NOT NULL,
    hours_per_week numeric(5,2),
    phone_number text COLLATE pg_catalog."default",
    address_id bigint NOT NULL,
    monthly_income_amount numeric(10,2) NOT NULL,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT employments_pkey PRIMARY KEY (employment_id),
    CONSTRAINT employments_address_id_fkey FOREIGN KEY (address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT employments_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.incomes
(
    income_id bigint NOT NULL DEFAULT nextval('incomes_income_id_seq'::regclass),
    borrower_internal_id bigint NOT NULL,
    income_type text COLLATE pg_catalog."default" NOT NULL,
    payment_frequency text COLLATE pg_catalog."default" NOT NULL,
    monthly_amount numeric(10,2) NOT NULL,
    description text COLLATE pg_catalog."default",
    start_date date,
    end_date date,
    is_verified boolean DEFAULT false,
    verification_source text COLLATE pg_catalog."default",
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT incomes_pkey PRIMARY KEY (income_id),
    CONSTRAINT incomes_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.liabilities
(
    liability_id bigint NOT NULL DEFAULT nextval('liabilities_liability_id_seq'::regclass),
    borrower_internal_id bigint NOT NULL,
    liability_type text COLLATE pg_catalog."default" NOT NULL,
    creditor_name text COLLATE pg_catalog."default" NOT NULL,
    account_number text COLLATE pg_catalog."default",
    monthly_payment numeric(10,2) NOT NULL,
    unpaid_balance numeric(15,2) NOT NULL,
    months_remaining integer,
    is_to_be_paid_off boolean DEFAULT false,
    real_estate_address_id bigint,
    creation_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    provider_metadata jsonb,
    additional_data jsonb,
    CONSTRAINT liabilities_pkey PRIMARY KEY (liability_id),
    CONSTRAINT liabilities_borrower_internal_id_fkey FOREIGN KEY (borrower_internal_id)
        REFERENCES public.borrowers (borrower_internal_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT liabilities_real_estate_address_id_fkey FOREIGN KEY (real_estate_address_id)
        REFERENCES public.addresses (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
);

