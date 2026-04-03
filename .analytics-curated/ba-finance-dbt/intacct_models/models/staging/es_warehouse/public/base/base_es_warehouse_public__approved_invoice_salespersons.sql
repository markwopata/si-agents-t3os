select
    -- ids
    ais.invoice_id,
    ais.primary_salesperson_id,
    ais.secondary_salesperson_ids,

    -- timestamps
    ais._es_update_timestamp

from {{ source('es_warehouse_public', 'approved_invoice_salespersons') }} as ais
