with source as (
      select * from {{ source('analytics_retool', 'fuel_cards_cc_driver_adjustments') }}
),
renamed as (
    select
        -- ids
        transaction_id
        , driver_id
        , employee_id
        
        --strings
        , first_name
        , last_name
        , concat(first_name, ' ', last_name) as full_name
        , account_number
        , work_email
        
        -- timestamps
        , es_update_timestamp

    from source
)
select * from renamed 
