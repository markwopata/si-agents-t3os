SELECT
    assets."ASSET_ID"  AS asset_id,
    assets.driver_name as driver,
    assets.model as model,
    assets.serial_number as serial_number,
    assets.asset_class as class,
    assets.COMPANY_ID,
    c.name as category_name,
    assets.asset_type_id,
    at.name as asset_type,
    o.name as organization_group,
    askv.asset_status_key_value_id,
    askv.value as asset_status_value,
    asvt.name as asset_status_value_type,
    al.geofences as asset_last_location_geofences,
    al.address as asset_last_location_address,
    al.location as asset_last_location,
    ao.ownership,
    assets.custom_name,
    mgi.name as maintenance_group_interval_name,
    (assets."CUSTOM_NAME") AS asset_linked_to_track_details,

    asset_service_intervals.date_created as date_created,
    asset_service_intervals.until_next_service_usage as until_next_service_usage,
    asset_service_intervals.maintenance_group_interval_id as maintenance_group_interval_id,
    case
        when UPPER(mgi.name) LIKE '%ANSI%' then 'ANSI'
        when UPPER(mgi.name) LIKE '%DOT %' 
            OR UPPER(mgi.name) LIKE '%90 DAY%' then 'DOT'
        when UPPER(mgi.name) LIKE '%ANNUAL%' then 'ANNUAL'
        else 'PM' 
    end as inspection_type,
    askv.value as inventory_status,
    CASE
        WHEN current_time_value IS NULL OR next_service_time_value IS NULL THEN -1.0
        ELSE (next_service_time_value::NUMBER - current_time_value::NUMBER)
        / (604800.0 * IFF(LENGTH(TO_VARCHAR(ABS(current_time_value::NUMBER))) >= 13, 1000.0, 1.0))
    END::NUMBER(18,2) AS service_time_remaining_in_weeks,
    IFF( service_time_remaining_in_weeks <= 0 OR service_time_remaining_in_weeks = -1 OR (until_next_service_usage < 0 AND until_next_service_usage IS NOT NULL),TRUE, FALSE) AS overdue,
    CASE WHEN (assets."ASSET_TYPE_ID") = 2 --vehicle asset type
         THEN COALESCE((assets."DRIVER_NAME"),'')
         ELSE ''
         END AS driver_vehicle_type,
    concat((assets."MAKE"),' ',(assets."MODEL"))  AS make_and_model,
    case when (asset_service_intervals."SERVICE_INTERVAL_NAME") is null then
    (mgi.name)
    else
    concat((mgi.name),'-> ',coalesce((asset_service_intervals."SERVICE_INTERVAL_NAME"),' '))
    end AS service_interval,
    companies."NAME"  AS company_name,

      ((coalesce((asset_last_location."GEOFENCES"),(asset_last_location."ADDRESS"),(asset_last_location."LOCATION"))))
      AS dynamic_last_location,
    case when (asset_service_intervals."UNTIL_NEXT_SERVICE_TIME") is not null then concat(round((asset_service_intervals."UNTIL_NEXT_SERVICE_TIME"),2),' days') end  AS time_remaining,
    concat(round((asset_service_intervals."UNTIL_NEXT_SERVICE_USAGE"),2),' ',(case when (asset_service_intervals."USAGE_UNIT_ID") = 15 then 'hours' when (asset_service_intervals."USAGE_UNIT_ID") = 17 then 'miles' else ' ' end))  AS utilization_remaining,
    assets."YEAR"  AS year,
    CASE WHEN (assets."ASSET_TYPE_ID") = 2 --vehicle asset type
         THEN (assets."VIN")
         ELSE (assets."SERIAL_NUMBER")
         END AS vehicle_vin_serial_number,
    markets_service."NAME"  AS markets_service_name,
    markets_service."NAME"  AS branch,
    asset_service_intervals."WORK_ORDER_ID"  AS work_order_id,
    (asset_service_intervals."WORK_ORDER_ID")  AS link_to_work_order,
    case 
        when (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) >= 21 then '21-100%'
        when (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) >= 11 and (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) < 20 then '11-20%'
        when (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) > 0 and (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) <= 10 then '0-10%'
        when (coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))) <= 0 then 'Overdue'
        else 'Unknown'
    end AS percentage_remaining_buckets,
    coalesce(truncate(((ROUND(asset_service_intervals."USAGE_PERCENTAGE_REMAINING",2))*100)),truncate(((ROUND(asset_service_intervals."TIME_PERCENTAGE_REMAINING",2))*100)))  AS percentage_remaining
FROM saasy.public.asset_maintenance_status AS asset_service_intervals
INNER JOIN {{ref('platform', 'es_warehouse__public__assets')}} AS assets ON (assets."ASSET_ID") = (asset_service_intervals."ASSET_ID")
LEFT JOIN {{ref('platform', 'es_warehouse__public__companies')}} AS companies ON (companies."COMPANY_ID") = (assets."COMPANY_ID")
LEFT JOIN  {{ref('platform', 'es_warehouse__public__asset_last_location')}} AS asset_last_location ON (assets."ASSET_ID") = (asset_last_location."ASSET_ID")
LEFT JOIN {{ref('platform', 'es_warehouse__public__markets')}} AS markets_service ON (markets_service."MARKET_ID") = (assets."SERVICE_BRANCH_ID")
LEFT JOIN {{ref('platform', 'es_warehouse__public__categories')}} c on c.category_id = assets.category_id
LEFT JOIN {{ref('platform', 'es_warehouse__public__asset_types')}} at on at.asset_type_id = assets.asset_type_id
LEFT JOIN {{ref('platform', 'es_warehouse__public__organization_asset_xref')}} oax on oax.asset_id = assets.asset_id
LEFT JOIN {{ref('platform', 'es_warehouse__public__organizations')}} o on oax.organization_id = o.organization_id
LEFT JOIN {{ref('platform', 'es_warehouse__public__asset_last_location')}} al on al.asset_id = assets.asset_id
LEFT JOIN {{ref('platform', 'es_warehouse__public__asset_status_key_values')}} askv on askv.asset_id = assets.asset_id and  askv.name = 'asset_inventory_status' 
LEFT JOIN {{ref('platform', 'es_warehouse__public__asset_status_value_types')}} asvt on askv.asset_status_value_type_id = asvt.asset_status_value_type_id
LEFT JOIN {{ref('platform','analytics__bi_ops__asset_ownership')}} as ao on ao.asset_id  = assets.ASSET_ID
LEFT JOIN es_warehouse.public.maintenance_group_intervals mgi on mgi.maintenance_group_interval_id = asset_service_intervals.maintenance_group_interval_id

WHERE (assets."DELETED") = 'No'
AND (asset_service_intervals."IS_DELETED") = FALSE

GROUP BY
    assets.COMPANY_ID,
    assets.ASSET_ID,
    assets.CUSTOM_NAME,
    assets.ASSET_TYPE_ID,
    assets.DRIVER_NAME,
    assets.MAKE,
    assets.MODEL,
    asset_service_intervals.SERVICE_INTERVAL_NAME,
    mgi.name,
    companies.NAME,
    asset_last_location.GEOFENCES,
    asset_last_location.ADDRESS,
    asset_last_location.LOCATION,
    asset_service_intervals.UNTIL_NEXT_SERVICE_TIME,
    asset_service_intervals.UNTIL_NEXT_SERVICE_USAGE,
    asset_service_intervals.USAGE_UNIT_ID,
    assets.YEAR,
    assets.VIN,
    assets.SERIAL_NUMBER,
    markets_service.NAME,
    asset_service_intervals.WORK_ORDER_ID,
    asset_service_intervals.USAGE_PERCENTAGE_REMAINING,
    asset_service_intervals.TIME_PERCENTAGE_REMAINING, 
    assets.driver_name ,
    assets.model,
    assets.serial_number,
    assets.asset_class,
    c.name,
    at.name,
    o.name,
    askv.asset_status_key_value_id,
    askv.value,
    asvt.name,
    al.geofences,
    al.address,
    al.location,
    assets.asset_type_id,
    ao.ownership,
    assets.custom_name,
    service_time_remaining_in_weeks,
    overdue,
    asset_service_intervals.date_created,
    asset_service_intervals.maintenance_group_interval_id