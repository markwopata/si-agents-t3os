SELECT
    tcal.tracker_company_assignment_log_id,
    tcal.tracker_account_id,
    tcal.user_id,
    tcal.tracker_id,
    tcal.company_id,
    tcal.date_created,
    tcal._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracker_company_assignment_logs') }} as tcal
