select
    ba.id,
    ba.connected_account_id,
    ba.account,
    ba.account_holder_name,
    ba.account_holder_type,
    ba.bank_name,
    ba.country,
    ba.currency,
    ba.fingerprint,
    ba.last_4,
    ba.routing_number,
    ba.status,
    ba.metadata,
    ba.is_deleted,
    ba.customer_id,
    ba._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'bank_account') }} as ba
