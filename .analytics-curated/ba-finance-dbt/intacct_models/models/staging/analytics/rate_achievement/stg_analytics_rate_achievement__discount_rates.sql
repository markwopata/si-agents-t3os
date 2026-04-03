select
    -- ids
    discount_rate_id,
    equipment_class_id,

    -- strings
    district,
    created_by,
    voided_by,
    
    -- numerics
    price_per_month,

    -- booleans
    active,

    -- timestamps
    date_created,
    coalesce(date_voided, '2099-12-31') as date_voided

from {{ source('analytics_rate_achievement', 'discount_rates') }}
