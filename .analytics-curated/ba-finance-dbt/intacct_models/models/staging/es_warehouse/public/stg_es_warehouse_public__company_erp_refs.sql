SELECT
    cer.company_erp_ref_id,
    cer.company_id,
    cer.erp_instance_id,
    cer.intacct_customer_id,
    cer._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_erp_refs') }} as cer
