with source as (
    select * from {{ source('analytics_commission', 'retail_manual_adjustments') }}
),

renamed as (
    select
        *,
        split_part(reverse(commission_id), '-', 1)::int as commission_type_id
    from source
)

select * from renamed
