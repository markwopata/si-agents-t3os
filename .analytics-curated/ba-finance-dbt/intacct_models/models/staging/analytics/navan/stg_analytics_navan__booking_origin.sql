SELECT
    bo.booking_uuid,
    bo.index,
    bo._fivetran_deleted,
    bo._fivetran_synced,
    bo.country,
    bo.city,
    bo.airport_code,
    bo.state
FROM {{ source('analytics_navan', 'booking_origin') }} as bo
