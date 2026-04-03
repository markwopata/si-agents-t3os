select 
    rate_tier_id, 
    name, 
    commission_percentage, 
    category
from {{ source('analytics_rate_achievement', 'commission_rate_tiers') }}
