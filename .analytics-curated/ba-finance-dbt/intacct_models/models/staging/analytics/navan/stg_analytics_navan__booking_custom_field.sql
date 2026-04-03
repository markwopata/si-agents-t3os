SELECT
    bcf.booking_uuid,
    bcf.index,
    bcf._fivetran_deleted,
    bcf._fivetran_synced,
    bcf.name,
    bcf.value
FROM {{ source('analytics_navan', 'booking_custom_field') }} as bcf
