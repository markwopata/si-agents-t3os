with source as (

    select * from {{ source('analytics_payroll', 'cost_center_to_market_id') }}

),

renamed as (

    select
        market_id,
        default_cost_centers_full_path,
        employee_status,
        _es_update_timestamp

    from source

)

select * from renamed
