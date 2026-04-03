SELECT
    br.booking_uuid,
    br.index,
    br._fivetran_deleted,
    br._fivetran_synced,
    br.reshopping_is_rebooked,
    br.reshopping_new_price,
    br.reshopping_original_price
FROM {{ source('analytics_navan', 'booking_reshopping') }} as br
