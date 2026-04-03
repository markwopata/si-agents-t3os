view: districts {
  sql_table_name: "PUBLIC"."DISTRICTS"
    ;;
  drill_fields: [district_id]

  dimension: district_name {
    primary_key: yes
    type: string
    sql: ${TABLE}."DISTRICT_ID" ;;
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

  dimension: district_manager {
    type: string
    sql: ${TABLE}."DISTRICT_MANAGER" ;;
  }

  dimension: district_manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: comment {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }

  dimension: district_sales_manager {
    type: string
    sql: ${TABLE}."DISTRICT_SALES_MANAGER" ;;
  }

  dimension: sales_manager_email {
    type: string
    sql: ${TABLE}."SALES_MANAGER_EMAIL" ;;
  }


  dimension: district_service_manager {
    type: string
    sql: ${TABLE}."DISTRICT_SERVICE_MANAGER" ;;
  }

  dimension: service_manager_email {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER_EMAIL" ;;
  }

  dimension: district_id {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: manager_email {
    type: string
    sql: LOWER(TRIM(${TABLE}."MANAGER_EMAIL")) ;;
  }



  dimension: region_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."REGION_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [district_id, comment, regions.region_name, regions.region_id]
  }
}
