SELECT
    bbe.booking_uuid,
    bbe.index,
    bbe._fivetran_deleted,
    bbe._fivetran_synced,
    bbe.billable_entity
FROM {{ source('analytics_navan', 'booking_billable_entity') }} as bbe
