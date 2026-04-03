select
    efw.id,
    efw.actionable,
    efw.created,
    efw.fraud_type,
    efw.livemode,
    efw.charge_id,
    efw._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'early_fraud_warning') }} as efw
