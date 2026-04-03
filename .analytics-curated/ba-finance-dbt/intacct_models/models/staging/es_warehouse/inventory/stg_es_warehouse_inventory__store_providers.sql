SELECT
    sp.store_provider_id,
    sp.provider_id,
    sp.store_id,
    sp.phone,
    sp.email,
    sp.address,
    sp.date_created,
    sp.date_updated,
    sp._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'store_providers') }} as sp
