select
    f.id,
    f.created,
    f.filename,
    f.purpose,
    f.size,
    f.title,
    f.type,
    f.url,
    f._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'file') }} as f
