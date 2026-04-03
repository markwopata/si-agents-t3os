select
    rr.market_id,
    dr.equipment_class_id,
    dr.price_per_month,
    dr.date_created,
    dr.date_voided,
    dr.created_by,
    dr.voided_by,
    dr.active
from {{ ref('stg_analytics_rate_achievement__discount_rates') }} dr
inner join {{ ref('stg_analytics_rate_achievement__rate_regions') }} rr 
    on dr.district = rr.district
order by dr.discount_rate_id