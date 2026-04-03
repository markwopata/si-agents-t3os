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
from {{ source('analytics_stripe_vsg_charge_key', 'file') }} as f
