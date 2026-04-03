{{
  config(
    tags=['commissions']
  )
}}

with source as (
      select * from {{ source('es_warehouse_inventory', 'product_classes') }}
),
renamed as (
    select
        -- ids
        product_class_id,
        company_id,

        -- timestamps
        _es_update_timestamp,
        _es_load_timestamp,
        date_created,
        date_updated,

        -- strings
        classification,
        category_name,
        cat_class

    from source
)
select * from renamed
  
