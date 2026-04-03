SELECT
    bb.booking_uuid,
    bb.index,
    bb._fivetran_deleted,
    bb.uuid,
    bb._fivetran_synced,
    bb.subsidiary,
    bb.cost_center,
    bb.name,
    bb.region,
    bb.manager_uuid,
    bb.email,
    bb.employeed_id,
    bb.department
FROM {{ source('analytics_navan', 'booking_booker') }} as bb
