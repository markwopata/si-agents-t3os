SELECT
    j.job_id,
    j.name,
    j.custom_id,
    j.company_id,
    j.geofence_id,
    j.create_date,
    j.update_date,
    j.created_by,
    j.updated_by,
    j.parent_job_id,
    j._es_update_timestamp
FROM {{ source('es_warehouse_public', 'jobs') }} as j
