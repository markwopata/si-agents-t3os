{{
  config(
    tags=['commissions']
  )
}}

with source as (
      select * from {{ source('es_warehouse_public', 'branch_rental_rates') }}
),
renamed as (
    select

        -- ids
        branch_rental_rate_id,
        rate_type_id,
        equipment_class_id,
        created_by_user_id,
        voided_by_user_id,
        branch_id,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_voided,

        -- numerics
        price_per_hour,
        price_per_day,
        price_per_week,
        price_per_month,

        -- bools
        call_for_pricing,
        active

    from source
)
select * from renamed
  
