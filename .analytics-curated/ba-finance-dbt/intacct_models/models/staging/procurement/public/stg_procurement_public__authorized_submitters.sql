SELECT
    asu._es_load_timestamp,
    asu.authorized_submitter_id,
    asu.created_at,
    asu.authorized_user_id,
    asu.modified_at,
    asu.user_id,
    asu._es_update_timestamp
FROM {{ source('procurement_public', 'authorized_submitters') }} as asu
