select
    pta._es_load_timestamp,
    pta.purchase_transaction_adjustment_id,
    pta.is_credit,
    pta.acquirer_reference_number,
    pta.metadata,
    pta.adjusted_transaction_id,
    pta.adjustment_description,
    pta.posting_date,
    pta.external_transaction_id,
    pta.adjustment_code,
    pta.amount,
    pta.purchase_date,
    pta.date_created,
    pta._es_update_timestamp
from {{ source('procurement_public', 'purchase_transaction_adjustments') }} as pta
