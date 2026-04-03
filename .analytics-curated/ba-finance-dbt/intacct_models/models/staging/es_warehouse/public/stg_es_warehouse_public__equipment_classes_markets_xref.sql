SELECT
    ecmx.equipment_classes_markets_xref_id,
    ecmx.market_id,
    ecmx.equipment_class_id,
    ecmx.price_per_day,
    ecmx.price_per_week,
    ecmx.price_per_month,
    ecmx.market_price_per_day,
    ecmx.market_price_per_week,
    ecmx.market_price_per_month,
    ecmx.call_for_pricing,
    ecmx.price_per_hour,
    ecmx.date_created,
    ecmx.date_updated,
    ecmx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'equipment_classes_markets_xref') }} as ecmx
