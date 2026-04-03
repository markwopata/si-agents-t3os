select
    mpt.matched_purchase_transaction_id,
    mpt.purchase_id,
    mpt.purchase_transaction_id,
    mpt.matched_by_user_id,
    mpt.was_auto_matched,
    mpt._es_update_timestamp,
    mpt._es_load_timestamp,
    mpt.date_matched,
    mpt.date_updated,
    mpt.date_created
from {{ source('procurement_public', 'matched_purchase_transactions') }} as mpt
