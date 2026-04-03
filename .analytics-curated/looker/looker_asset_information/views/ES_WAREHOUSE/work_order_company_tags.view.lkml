view: work_order_company_tags {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
    ;;

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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_tag_id {
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
