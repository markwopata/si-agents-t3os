select
    sa.setup_intent_id,
    sa.id,
    sa.on_behalf_of,
    sa.default_payment_method_id,
    sa.application,
    sa.created,
    sa.livemode,
    sa.status,
    sa.usage,
    sa.setup_error_code,
    sa.setup_error_decline_code,
    sa.setup_error_doc_url,
    sa.setup_error_message,
    sa.setup_error_type,
    sa._fivetran_synced
from {{ source('analytics_stripe_vehicle_solutions', 'setup_attempt') }} as sa
