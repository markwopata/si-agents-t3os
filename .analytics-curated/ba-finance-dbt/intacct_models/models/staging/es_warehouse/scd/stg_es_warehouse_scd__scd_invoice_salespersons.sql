SELECT
    sis.invoice_id,
    sis.primary_salesperson_id,
    sis.secondary_salesperson_ids,
    sis.date_created,
    sis._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_invoice_salespersons') }} as sis
