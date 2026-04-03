SELECT
    btu.booking_uuid,
    btu.index,
    btu._fivetran_deleted,
    btu._fivetran_synced,
    btu.trip_uuid
FROM {{ source('analytics_navan', 'booking_trip_uuid') }} as btu
