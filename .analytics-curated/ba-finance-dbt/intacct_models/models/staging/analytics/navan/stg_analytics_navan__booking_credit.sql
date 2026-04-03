SELECT
    bc.booking_uuid,
    bc.index,
    bc._fivetran_deleted,
    bc._fivetran_synced,
    bc.credit_used_usd,
    bc.residual_credit,
    bc.credit_available_usd,
    bc.credit_available,
    bc.credit_used,
    bc.credit_from_original_booking,
    bc.credit_exchange_fee_usd
FROM {{ source('analytics_navan', 'booking_credit') }} as bc
