select
    efw.id,
    efw.actionable,
    efw.created,
    efw.fraud_type,
    efw.livemode,
    efw.charge_id,
    efw._fivetran_synced
from {{ source('analytics_stripe_vsg_charge_key', 'early_fraud_warning') }} as efw
