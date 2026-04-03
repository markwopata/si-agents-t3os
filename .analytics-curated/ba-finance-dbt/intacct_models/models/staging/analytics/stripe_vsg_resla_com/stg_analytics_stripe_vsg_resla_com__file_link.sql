select
    fl.id,
    fl.created,
    fl.expired,
    fl.expires_at,
    fl.livemode,
    fl.metadata,
    fl.url,
    fl.file_id,
    fl._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'file_link') }} as fl
