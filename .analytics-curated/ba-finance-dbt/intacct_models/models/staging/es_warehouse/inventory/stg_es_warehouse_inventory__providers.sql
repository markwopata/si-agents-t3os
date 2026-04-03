with source as (
    select * from  {{ source('es_warehouse_inventory', 'providers') }}
)

, renamed as (
    select
        -- ids
        provider_id,
        company_id,

        -- strings
        name,
        sku_field,

        -- booleans
        verified_globally,
        verified_for_company,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated,
        date_archived

    from source
)


select * from renamed
