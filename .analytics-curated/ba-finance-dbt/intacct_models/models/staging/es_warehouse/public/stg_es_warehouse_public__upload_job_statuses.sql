SELECT
    ujs._es_load_timestamp,
    ujs.upload_job_status_id,
    ujs.name,
    ujs._es_update_timestamp
FROM {{ source('es_warehouse_public', 'upload_job_statuses') }} as ujs
