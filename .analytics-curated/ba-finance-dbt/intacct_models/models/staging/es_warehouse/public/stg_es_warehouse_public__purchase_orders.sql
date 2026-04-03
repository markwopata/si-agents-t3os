with source as (

    select * from {{ source('es_warehouse_public', 'purchase_orders') }}

),

renamed as (

    select

        -- ids
        company_id,
        universal_entity_id,
        purchase_order_id,

        -- strings
        currency_type,
        name,

        -- numerics
        budget_amount,

        -- booleans
        active as is_active,

        -- timestamps
        start_date,
        end_date,
        created_by,
        date_created,
        _es_update_timestamp


    from source

)

select * from renamed
