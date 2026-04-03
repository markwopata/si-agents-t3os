select
    cpo.company_purchase_order_id,
    -- concat(cpot.prefix, 'PO', cpo.company_purchase_order_id) as purchase_order_number, -- Keeping here for future use
    cpo.pdf as pdf_hash,
    cpo.note,
    cpo.created_at,
    cpo.submitted_at,
    cpo.approved_at,
    cpo.modified_at,
    cpo.vendor_id,
    cpo.company_purchase_order_type_id,
    cpo.market_id,
    cpo.created_by_user_id,
    cpo.submitted_by_user_id,
    cpo.approved_by_user_id,
    cpo.net_terms_id,
    cpo.deleted_at,
    cpo.deleted_by_user_id,
    cpo.deleted_at is not null as is_deleted,
    'https://purchasing.equipmentshare.com/documents/' || cpo.pdf || '.pdf' as url_po_pdf,
    'https://purchasing.equipmentshare.com/company-purchase-orders/' || cpo.company_purchase_order_id as url_admin,
    cpo._es_update_timestamp
from {{ source('es_warehouse_public', 'company_purchase_orders') }} as cpo
