with source as (

    select * from {{ source('es_warehouse_public', 'markets') }}

),

renamed as (

    select

        -- ids
        market_id,
        company_id,
        state_id,
        location_id,

        -- strings
        name as market_name,
        abbreviation,
        left(phone_number, 3) as area_code,
        sales_email,
        service_email,

        -- booleans
        active as is_active,
        is_public_msp,
        is_public_rsp,

        -- timestamps
        date_created,
        date_updated,
        _es_update_timestamp

    from source

)

select * from renamed
