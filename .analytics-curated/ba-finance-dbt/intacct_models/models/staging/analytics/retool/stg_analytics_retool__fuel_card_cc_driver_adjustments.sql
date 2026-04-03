with source as (
    select * from {{ ref('base_analytics_retool__fuel_cards_cc_driver_adjustments') }}
)

select
    -- ids
    transaction_id,
    driver_id,
    employee_id,

    --strings
    first_name,
    last_name,
    full_name,
    account_number,
    work_email,

    -- timestamps
    es_update_timestamp

from source
qualify row_number() over (partition by transaction_id order by es_update_timestamp desc) = 1
