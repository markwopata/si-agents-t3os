view: stores {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."STORES"
    ;;
  drill_fields: [store_id]

  dimension: store_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STORE_ID" ;;
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

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: parent_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PARENT_ID" ;;
  }

  dimension: store_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_TYPE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [store_id, name, store_parts.count]
  }
}
