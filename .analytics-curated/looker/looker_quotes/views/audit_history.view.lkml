view: audit_history {
  sql_table_name: "QUOTES"."AUDIT_HISTORY"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: _es_load_timestamp {
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
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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

  dimension: audit_event_type_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."AUDIT_EVENT_TYPE_ID" ;;
  }

  dimension: quote_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: quote_json {
    type: string
    sql: ${TABLE}."QUOTE_JSON" ;;
  }

  dimension_group: time_stamp {
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
    sql: ${TABLE}."TIME_STAMP" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      audit_event_type.id,
      audit_event_type.name,
      quote.company_name,
      quote.new_company_name,
      quote.delivery_type_name,
      quote.po_name,
      quote.id,
      quote.rpp_name,
      quote.contact_name
    ]
  }
}
