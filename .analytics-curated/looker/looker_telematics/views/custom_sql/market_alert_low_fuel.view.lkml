view: market_alert_low_fuel {

  derived_table: {
    sql:
      WITH engine_active AS (
SELECT DISTINCT asset_id FROM ES_WAREHOUSE."PUBLIC".asset_status_key_values
WHERE NAME = 'engine_active' AND lower(value) LIKE '%true%')
SELECT askv.asset_id,a.DESCRIPTION AS asset_description, askv.NAME, askv.value/100 as fuel_level, x.market_name AS serviced_by,
askv.updated AS timestamp, a.make as make, a.model as model, aa.class as equipment_class, c.company_id as company_id, c.name as company_name
FROM ES_WAREHOUSE."PUBLIC".asset_status_key_values AS askv
INNER JOIN engine_active AS ea
ON ea.asset_id = askv.asset_id
LEFT JOIN ES_WAREHOUSE."PUBLIC".assets AS a
ON askv.asset_id = a.asset_id
LEFT JOIN ANALYTICS."PUBLIC".MARKET_REGION_XWALK AS x
ON a.market_id = x.MARKET_ID
left join ES_WAREHOUSE."PUBLIC".assets_aggregate as aa
on askv.asset_id = aa.asset_id
left join ES_WAREHOUSE."PUBLIC".companies as c
on a.company_id = c.company_id
WHERE a.company_id <> 155
and askv.NAME = 'fuel_level'
and askv.value is not null
and askv.value/100 < .2
                         ;;
  }

  dimension: serviced_by {
    type: string
    sql: ${TABLE}.serviced_by ;;
  }

  dimension:asset_description {
    type: string
    sql: ${TABLE}.asset_description ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.timestamp ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.equipment_class ;;
  }

  dimension: fuel_level {
    type: number
    sql: ${TABLE}.fuel_level ;;
  }





}
