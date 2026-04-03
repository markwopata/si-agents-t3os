SELECT
    ujt._es_load_timestamp,
    ujt.upload_job_type_id,
    ujt.name,
    ujt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'upload_job_types') }} as ujt
