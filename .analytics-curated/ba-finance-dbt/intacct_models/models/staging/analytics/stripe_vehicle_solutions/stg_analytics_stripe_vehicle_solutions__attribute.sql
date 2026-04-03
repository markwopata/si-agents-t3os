select
    a.id,
    a.name,
    a.value,
    a._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'attribute') }} as a
