SELECT
    be.booking_uuid,
    be.index,
    be._fivetran_deleted,
    be._fivetran_synced,
    be.eticket
FROM {{ source('analytics_navan', 'booking_eticket') }} as be
