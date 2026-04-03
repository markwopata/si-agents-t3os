SELECT
    pie.generateddate,
    pie.eventdate,
    pie.asset_id,
    pie.make,
    pie.class,
    pie.asset_inventory_status,
    pie.market_id,
    pie.unavailablecount,
    pie.unavailableoec,
    pie.totalcount,
    pie.totaloec
FROM {{ source('es_warehouse_scd', 'pulling_inventory_events') }} as pie
