SELECT
    pa.provider_alias_id,
    pa.observing_provider_id,
    pa.alias,
    pa.observed_provider_id,
    pa.date_created,
    pa.date_updated,
    pa._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'provider_aliases') }} as pa
