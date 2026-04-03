select
    af.id,
    af.amount as amount_in_cents,
    round(af.amount / 100.0, 2) as amount,
    af.amount_refunded as amount_refunded_in_cents,
    round(af.amount_refunded / 100.0, 2) as amount_refunded,
    af.application,
    af.created,
    af.currency,
    af.livemode,
    af.originating_transaction,
    af.refunded,
    af.account_id,
    af.balance_transaction_id,
    af.charge_id,
    af._fivetran_synced
from {{ source('analytics_stripe_vsg_resla_com', 'application_fee') }} as af
