select
    cpot.company_purchase_order_type_id,
    cpot.asset_type_id,
    cpot.prefix,
    cpot.name,
    cpot.logo_url,
    cpot.help_text,
    cpot.company_id,
    cpot.sort_index,
    cpot.footer_text,
    cpot._es_update_timestamp
from {{ source('es_warehouse_public', 'company_purchase_order_types') }} as cpot
