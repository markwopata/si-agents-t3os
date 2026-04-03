with source as (

    select * from {{ ref('base_analytics_lease_accelerator__leasing_summary_api_download') }}

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
        , equipment_value_local
        , lease_rate_factor
        , equipment_value
        , total_rent_reporting_currency
        , total_rent_local
        , term
        , ledger_code

        -- timestamps
        , booking_ledger_date
        , rental_start
        , rental_end
        , _es_update_timestamp

    from source
    qualify dense_rank() over(order by _es_update_timestamp desc) = 1 -- filtering to the most recent report run

)

select * from renamed
