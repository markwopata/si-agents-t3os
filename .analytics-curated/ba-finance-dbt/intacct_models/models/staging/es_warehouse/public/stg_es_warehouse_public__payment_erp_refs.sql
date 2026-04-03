SELECT
    per.payment_erp_ref_id,
    per.erp_instance_id,
    per.payment_id,
    per.intacct_record_no,
    per.intacct_active_date,
    per.is_reversed,
    per._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_erp_refs') }} as per
