view: regions {
  sql_table_name: "PUBLIC"."REGIONS"
    ;;
  drill_fields: [region_id]

  dimension: region_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: regional_fleet_manager {
    type: string
    sql: ${TABLE}."REGIONAL_FLEET_MANAGER" ;;
  }

  dimension: regional_fleet_manager_email {
    type: string
    sql: ${TABLE}."REGIONAL_FLEET_MANAGER_EMAIL" ;;
  }

  dimension: regional_manager {
    type: string
    sql: ${TABLE}."REGIONAL_MANAGER" ;;
  }

  dimension: regional_sales_manager {
    type: string
    sql: ${TABLE}."REGIONAL_SALES_MANAGER" ;;
  }

  dimension: regional_service_manager {
    type: string
    sql: ${TABLE}."REGIONAL_SERVICE_MANAGER" ;;
  }

  dimension: sales_manager_email {
    type: string
    sql: ${TABLE}."SALES_MANAGER_EMAIL" ;;
  }

  dimension: service_manager_email {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER_EMAIL" ;;
  }

  measure: count {
    type: count
    drill_fields: [region_id, region_name, districts.count]
  }
}
