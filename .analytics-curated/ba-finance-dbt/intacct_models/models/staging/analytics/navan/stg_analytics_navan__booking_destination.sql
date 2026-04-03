SELECT
    bd.booking_uuid,
    bd.index,
    bd._fivetran_deleted,
    bd._fivetran_synced,
    bd.country,
    bd.city,
    bd.airport_code,
    bd.state
FROM {{ source('analytics_navan', 'booking_destination') }} as bd
