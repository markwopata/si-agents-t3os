
view: company_tags {

  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."COMPANY_TAGS"
    ;;
  drill_fields: [company_tag_id]

  dimension: company_tag_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
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


  dimension: color {
    type: string
    sql: ${TABLE}."COLOR" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_tag_id, name, work_order_company_tags.count]
  }
}
