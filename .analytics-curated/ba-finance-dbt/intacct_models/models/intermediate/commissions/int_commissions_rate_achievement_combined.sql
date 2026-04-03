with unioned_data as (
    select
        line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        itl_rep_rate_tier_id,
        business_segment_id,
        equipment_class_name,
        equipment_class_id,
        deal_floor,
        floor_rate,
        benchmark_rate,
        book_rate,
        source_model
    from {{ ref("int_commissions_rate_achievement_rental") }}

    union all

    select
        line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        null as itl_rep_rate_tier_id,
        business_segment_id,
        null as equipment_class_name,
        null as equipment_class_id,
        deal_floor,
        floor_rate,
        null as benchmark_rate,
        book_rate,
        source_model
    from {{ ref("int_commissions_rate_achievement_fuel") }}

    union all

    select
        line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        null as itl_rep_rate_tier_id,
        business_segment_id,
        null as equipment_class_name,
        null as equipment_class_id,
        deal_floor,
        floor_rate,
        benchmark_rate,
        book_rate,
        source_model
    from {{ ref("int_commissions_rate_achievement_bulk") }}

    union all

    select
        line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        null as itl_rep_rate_tier_id,
        business_segment_id,
        null as equipment_class_name,
        null as equipment_class_id,
        deal_floor,
        floor_rate,
        benchmark_rate,
        book_rate,
        source_model
    from {{ ref("int_commissions_rate_achievement_pickup_and_delivery") }}
)

select
    ud.line_item_id,
    ud.rate_tier_id,
    itl_rep_rate_tier_id,
    ud.business_segment_id,
    ud.grace_period_flag,
    ud.deal_floor_flag,
    ud.book_rate,
    ud.benchmark_rate,
    ud.floor_rate,
    ud.deal_floor,
    crt.name as rate_tier_name,
    crt_itl.name as itl_rate_tier_name,
    crt.commission_percentage,
    crt_itl.commission_percentage as itl_commission_percentage,
    crt.category,
    ud.equipment_class_name,
    ud.equipment_class_id,
    ud.source_model,
from unioned_data as ud
    left join
        {{ ref("stg_analytics_rate_achievement__commission_rate_tiers") }} as crt
        on ud.rate_tier_id = crt.rate_tier_id
    left join
        {{ ref("stg_analytics_rate_achievement__commission_rate_tiers") }} as crt_itl
        on ud.itl_rep_rate_tier_id = crt_itl.rate_tier_id
