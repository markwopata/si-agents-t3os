SELECT
    bd.booking_uuid,
    bd.index,
    bd._fivetran_deleted,
    bd._fivetran_synced,
    bd.department
FROM {{ source('analytics_navan', 'booking_department') }} as bd
