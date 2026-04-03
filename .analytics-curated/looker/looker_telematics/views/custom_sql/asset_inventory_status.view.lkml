view: asset_inventory_status {

  derived_table: {
    sql:
    SELECT asset_id AS asset_id, NAME AS name, value AS asset_inventory_status
FROM ES_WAREHOUSE."PUBLIC".asset_status_key_values
WHERE NAME = 'asset_inventory_status'
                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}.asset_inventory_status ;;
  }}
