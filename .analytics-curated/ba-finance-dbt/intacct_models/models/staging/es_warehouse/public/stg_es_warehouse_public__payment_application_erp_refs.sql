SELECT
    paer.payment_application_erp_ref_id,
    paer.erp_instance_id,
    paer.payment_application_id,
    paer.intacct_record_no,
    paer.intacct_active_date,
    paer.is_reversed,
    paer._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_application_erp_refs') }} as paer
