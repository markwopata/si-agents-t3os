with source as (

    select * from {{ source('analytics_claims', 'worker_comp_claims') }}

),

renamed as (

    select

        -- ids
        upper(claim_number) as claim_number,
        policy_number,
        ncci_codes,

        -- numerics
        indemnity_paid::numeric(19, 2) as indemnity_paid,
        medical_paid::numeric(19, 2) as medical_paid,
        expense_paid::numeric(19, 2) as expense_paid,
        total_paid::numeric(19, 2) as total_paid,
        indemnity_outstanding::numeric(19, 2) as indemnity_outstanding,
        medical_outstanding::numeric(19, 2) as medical_outstanding,
        expense_outstanding::numeric(19, 2) as expense_outstanding,
        total_outstanding::numeric(19, 2) as total_outstanding,
        indemnity_incurred::numeric(19, 2) as indemnity_incurred,
        medical_incurred::numeric(19, 2) as medical_incurred,
        expense_incurred::numeric(19, 2) as expense_incurred,
        total_incurred::numeric(19, 2) as total_incurred,


        -- strings
        policy_period,
        line_of_business,
        upper(claimant_insured_driver_name) as claimant_name,
        claim_status,
        accident_state,
        claim_description,
        accident_description_details,
        accident_description,
        injured_body_part,
        injury_severity_description,
        litigation_status,
        wc_claim_type,


        -- dates
        accident_date::date as accident_date,
        closed_date::date as closed_date,
        released_to_work_date::date as released_to_work_date


        -- timestamps


    from source

)

select * from renamed
