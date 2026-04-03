with source as (
    select * from {{ source('analytics_commission', 'parts_margin') }}
),

renamed as (
    select
        line_item_id,
        part_id,
        store_part_id,
        recorded_part_cost,
        margin,
        max_margin,
        margin_perc,
        margin_perc_used,
        additional_commission,
        additional_commission_used,
        margin_used,
        margin_commission,
        _es_date_created
    from source
)

select * from renamed
