view: inventory_locations {
sql_table_name: "ES_WAREHOUSE"."INVENTORY"."INVENTORY_LOCATIONS";;
  drill_fields: [inventory_location_id]

  dimension: inventory_location_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: default_location {
    type: string
    sql: ${TABLE}."DEFAULT_LOCATION" ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: inventory_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_archived {
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
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension_group: date_updated {
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  measure: count {
    type: count
    drill_fields: [inventory_location_id, name]
  }
}
