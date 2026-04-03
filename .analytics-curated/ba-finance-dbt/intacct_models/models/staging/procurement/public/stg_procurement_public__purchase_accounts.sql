select
    pa.purchase_account_id,
    pa.user_id,
    pa.account_type,
    pa.company_id,
    pa.last_four,
    pa.enrollment_date,
    pa.closed_date,
    pa.metadata,
    pa.date_created,
    pa.date_updated,
    pa._es_update_timestamp,
    pa._es_load_timestamp
from {{ source('procurement_public', 'purchase_accounts') }} as pa
