with 

source as (

    select * from {{ source('retool', 'credit_app_master_retool') }}

),

renamed as (

    select
        camr_id,
        date_created as date_created_utc, -- keep as UTC for incremental needs
        CAST(CONVERT_TIMEZONE('UTC', 'America/Chicago', date_created) AS TIMESTAMP_NTZ) as date_created_ct,
        created_by_email,
        source,
        company_id,
        company as company_name,
        market_id,
        market as market_name,
        duns,
        fein,
        sic,
        naics_1 as naics_primary,
        naics_2 as naics_secondary,
        date_received as date_received_ct,
        date_completed as date_completed_ct,
        app_status,
        NULLIF(TRIM(notes), '') as notes,
        NULLIF(sp_user_id, 0) as salesperson_user_id,
        salesperson,
        IFF(
            CONTAINS(salesperson, ' - '),
            NULLIF(TRIM(SPLIT_PART(salesperson, ' - ', 1)), ''),
            NULLIF(TRIM(salesperson), '')
        ) AS salesperson_name,
        TRY_TO_NUMBER(IFF(
            CONTAINS(salesperson, ' - '),
            NULLIF(TRIM(SPLIT_PART(salesperson, ' - ', 2)), ''),
            NULL
        )) AS salesperson_employee_id,
        cs_user_id as credit_specialist_user_id,
        credit_specialist,
        IFF(
            CONTAINS(credit_specialist, ' - '),
            NULLIF(TRIM(SPLIT_PART(credit_specialist, ' - ', 1)), ''),
            NULLIF(TRIM(credit_specialist), '')
        ) AS credit_specialist_name,
        TRY_TO_NUMBER(IFF(
            CONTAINS(credit_specialist, ' - '),
            NULLIF(TRIM(SPLIT_PART(credit_specialist, ' - ', 2)), ''),
            NULL
        )) AS credit_specialist_employee_id,

        insurance_info as has_insurance_info,
        coi_received,
        insurance_company,
        insurance_email,
        insurance_phone,

        NULLIF(TRIM(credit_safe_no), '') as credit_safe_no,
        COALESCE(government_entity, FALSE) as is_government_entity,
        COALESCE(online_app_status, FALSE) as has_online_app_status,
        COALESCE(deleted, FALSE) as is_deleted,
        COALESCE(salesperson_override, FALSE) as is_salesperson_override,
        COALESCE(initial_web_self_signup, FALSE) as is_initial_web_self_signup,
        COALESCE(initial_web_unauthenticated, FALSE) as is_initial_web_unauthenticated,
        unauthenticated_dot_com_app_id,

    from source

)

select * from renamed