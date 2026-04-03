SELECT
    b.bill_id,
    b.bill_no,
    b.company_id,
    b.xero_id,
    b.date_created,
    b._es_update_timestamp
FROM {{ source('es_warehouse_public', 'bills') }} as b
