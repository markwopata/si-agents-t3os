SELECT
    bs.booking_uuid,
    bs.index,
    bs._fivetran_deleted,
    bs._fivetran_synced,
    bs.seat
FROM {{ source('analytics_navan', 'booking_seat') }} as bs
