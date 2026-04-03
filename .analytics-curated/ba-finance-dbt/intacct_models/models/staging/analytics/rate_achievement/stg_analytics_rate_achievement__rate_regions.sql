select
    -- ids
    market_id,

    -- strings
    market_name,
    district,
    region,
    region_name
from
    {{ source('analytics_rate_achievement', 'rate_regions') }} rr
