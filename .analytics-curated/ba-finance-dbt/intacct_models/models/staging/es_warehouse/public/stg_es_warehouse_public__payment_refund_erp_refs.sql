SELECT
    prer.payment_refund_erp_ref_id,
    prer.payment_history_id,
    prer.intacct_debit_memo_recordno,
    prer.intacct_apply_payment_time,
    prer.erp_instance_id,
    prer._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_refund_erp_refs') }} as prer
