with central_bank_cc_transactions as (
    select * from {{ ref('base_analytics_public__central_bank_cc_transactions')}}
)

, company_directory as (
    select 
        employee_id
        , employee_title
    from {{ ref('stg_analytics_payroll__company_directory') }}
)

, corporate_card_accounts as (
    select
        corporate_account_number,
        corporate_account_name,
        card_type
    from {{ ref('stg_analytics_credit_card__corporate_card_accounts') }}
)

select
    -- ids
    cd.employee_id
    , cc.transaction_id

    -- strings
    , cc.first_name
    , cc.last_name
    , cc.full_name
    , cc.mcc
    , cc.card_type
    , cc.status
    , cc.merchant_name
    , cc.card_number
    , cd.employee_title
    , cca.corporate_account_number::varchar as corporate_account_number
    , cca.corporate_account_name

    -- numerics
    , cc.transaction_amount
    , cc.mcc_code::varchar as mcc_code

    -- booleans
    , cc.is_bypass_verification

    -- dates
    , cc.transaction_date
    
from central_bank_cc_transactions cc
left join company_directory cd
    on cc.employee_id = cd.employee_id
left join corporate_card_accounts cca
    on cc.card_type::varchar = cca.card_type::varchar