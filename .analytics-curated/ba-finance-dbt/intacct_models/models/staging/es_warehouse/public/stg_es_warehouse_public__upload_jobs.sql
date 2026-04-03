SELECT
    uj._es_load_timestamp,
    uj.upload_job_id,
    uj.upload_job_status_id,
    uj.start_date,
    uj.upload_job_type_id,
    uj.user_id,
    uj.completed_date,
    uj.file_name,
    uj.upload_job_metadata,
    uj._es_update_timestamp,
    uj.upload_job_metadata:"total_rows" AS upload_job_metadata__total_rows,
    uj.upload_job_metadata:"rows_processed" AS upload_job_metadata__rows_processed,
    uj.upload_job_metadata:"error_message" AS upload_job_metadata__error_message
FROM {{ source('es_warehouse_public', 'upload_jobs') }} as uj
