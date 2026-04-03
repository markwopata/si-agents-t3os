SELECT
    djc.dds_job_number,
    djc.object,
    djc.dds_job_status,
    djc.ingest_status,
    djc.ingest_claimed_by,
    djc.ingest_last_claimed_timestamp,
    djc.landed_status,
    djc.merge_status,
    djc._es_update_timestamp
FROM {{ source('analytics_intacct__etl', 'dds_job_control') }} as djc
