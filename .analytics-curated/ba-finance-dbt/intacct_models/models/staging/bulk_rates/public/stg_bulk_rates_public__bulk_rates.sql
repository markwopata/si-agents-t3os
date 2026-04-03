{{
  config(
    tags=['commissions']
  )
}}

with source as (
      select * from {{ source('bulk_rates_public', 'bulk_rates') }}
),
renamed as (
    select

    -- ids
    id,
    rate_type_id,
    branch_id,
    file_id,


    -- timestamps
    _es_update_timestamp,
    _es_load_timestamp,
    created_at,
    updated_at,


    -- numerics
    price_per_month,
    price_per_day,
    price_per_week,
    price_per_hour,


    -- bools
    call_for_pricing,

    -- strings
    cat_class


    from source
)
select * from renamed