with source as (

    select * from {{ source('lease_accelerator', 'leasing_summary_api_download') }}

),

renamed as (

    select

        -- strings
        schedule_number
        , asset_type
        , funder
        , status
        , cost_center

        -- numerics
        , equipment_value_reporting_currency
        , equipment_value_transactional_currency as equipment_value_local
        , lrf as lease_rate_factor
        , equipment_value_transactional_currency as equipment_value
        , total_rent_reporting_currency
        , rental_transactional_currency as total_rent_local
        , term
        , ledger_code
        
        -- timestamps
        , booking_ledger_date
        , rental_start
        , rental_end
        , _es_update_timestamp

    from source
    where 
        status!='Defunct (Rolled Back)'
    -- excluding defunct leases to include only valid ones
        and schedule_number!='nan'

)

select * from renamed
