SELECT
    br.booking_uuid,
    br.index,
    br._fivetran_deleted,
    br._fivetran_synced,
    br.region
FROM {{ source('analytics_navan', 'booking_region') }} as br
