SELECT
    boopvt.booking_uuid,
    boopvt.index,
    boopvt._fivetran_deleted,
    boopvt._fivetran_synced,
    boopvt.out_of_policy_violation_type
FROM {{ source('analytics_navan', 'booking_out_of_policy_violation_type') }} as boopvt
