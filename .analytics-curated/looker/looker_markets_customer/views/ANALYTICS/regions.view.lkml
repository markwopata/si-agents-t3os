view: regions {
  sql_table_name: "PUBLIC"."REGIONS"
    ;;
  drill_fields: [region_id]

  dimension: region_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: regional_manager {
    label: "Regional Director of Operations"
    type: string
    sql: ${TABLE}."REGIONAL_MANAGER" ;;
  }

  dimension: manager_email {
    label: "Regional Director of Operations Email"
    type: string
    sql: LOWER(TRIM(${TABLE}."MANAGER_EMAIL")) ;;
  }

  dimension: regional_service_manager {
    type: string
    sql: ${TABLE}."REGIONAL_SERVICE_MANAGER" ;;
  }

  dimension: service_manager_email {
    type: string
    sql: LOWER(TRIM(${TABLE}."SERVICE_MANAGER_EMAIL")) ;;
  }

  dimension: regional_sales_manager {
    label: "Regional Director of Sales"
    type: string
    sql: ${TABLE}."REGIONAL_SALES_MANAGER" ;;
  }

  dimension: sales_manager_email {
    label: "Regional Director of Sales Email"
    type: string
    sql: ${TABLE}."SALES_MANAGER_EMAIL" ;;
  }

  dimension: regional_fleet_manager {
    type: string
    sql: ${TABLE}."REGIONAL_FLEET_MANAGER" ;;
  }

  dimension: regional_fleet_manager_email {
    type: string
    sql: ${TABLE}."REGIONAL_FLEET_MANAGER_EMAIL" ;;
  }

  dimension: director_of_advanced_solutions {
    label: "Regional Director of Adv. Solutions"
    type: string
    sql: ${TABLE}."DIRECTOR_OF_ADVANCED_SOLUTIONS" ;;
  }

  dimension: director_of_advanced_solutions_email {
    label: "Regional Director of Adv. Solutions Email"
    type: string
    sql: ${TABLE}."DIRECTOR_OF_ADVANCED_SOLUTIONS_EMAIL" ;;
  }



  measure: count {
    type: count
    drill_fields: [region_id, region_name, districts.count]
  }
}
