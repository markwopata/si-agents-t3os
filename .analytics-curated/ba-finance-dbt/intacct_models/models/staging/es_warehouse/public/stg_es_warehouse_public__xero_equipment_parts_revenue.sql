SELECT
    xepr.service_invoice_id,
    xepr.invoice_date,
    xepr.description,
    xepr.reference,
    xepr.credit,
    xepr.net,
    xepr.account,
    xepr.region,
    xepr.asset_id,
    xepr._es_update_timestamp
FROM {{ source('es_warehouse_public', 'xero_equipment_parts_revenue') }} as xepr
