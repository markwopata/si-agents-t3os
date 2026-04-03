select
    pt.purchase_transaction_id,
    pt.external_transaction_id,
    pt.purchase_account_id,
    pt.amount,
    pt.merchant,
    pt.mcc_code,
    pt.mcc_name,
    pt.metadata,
    pt.is_purchase_verified,
    pt.is_credit,
    pt.purchase_date,
    pt.date_created,
    pt._es_update_timestamp,
    pt._es_load_timestamp,
    pt.acquirer_reference_number
from {{ source('procurement_public', 'purchase_transactions') }} as pt
