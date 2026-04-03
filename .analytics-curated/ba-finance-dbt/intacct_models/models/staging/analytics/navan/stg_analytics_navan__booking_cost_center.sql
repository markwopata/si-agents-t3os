SELECT
    bcc.booking_uuid,
    bcc.index,
    bcc._fivetran_deleted,
    bcc._fivetran_synced,
    bcc.cost_center
FROM {{ source('analytics_navan', 'booking_cost_center') }} as bcc
