SELECT
    bp._es_update_timestamp,
    bp._es_load_timestamp,
    bp.billing_provider_id,
    bp.name,
    bp.remit_location_id
FROM {{ source('es_warehouse_public', 'billing_providers') }} as bp
