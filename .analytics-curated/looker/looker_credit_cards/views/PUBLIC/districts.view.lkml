view: districts {
  sql_table_name: "PUBLIC"."DISTRICTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: district_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: district_manager {
    type: string
    sql: ${TABLE}."DISTRICT_MANAGER" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }

  dimension: district_sales_manager {
    type: string
    sql: ${TABLE}."DISTRICT_SALES_MANAGER" ;;
  }

  dimension: district_service_manager {
    type: string
    sql: ${TABLE}."DISTRICT_SERVICE_MANAGER" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: region_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."REGION_ID" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      district_name,
      regions.region_name,
      regions.region_id,
      districts.district_name,
      districts.id,
      districts.count
    ]
  }
}
