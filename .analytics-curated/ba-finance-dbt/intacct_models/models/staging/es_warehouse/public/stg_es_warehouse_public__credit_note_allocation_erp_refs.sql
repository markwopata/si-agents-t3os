SELECT
    cnaer.credit_note_allocation_erp_ref_id,
    cnaer.erp_instance_id,
    cnaer.credit_note_allocation_id,
    cnaer.intacct_synced_date,
    cnaer.reversal_date,
    cnaer._es_update_timestamp
FROM {{ source('es_warehouse_public', 'credit_note_allocation_erp_refs') }} as cnaer
