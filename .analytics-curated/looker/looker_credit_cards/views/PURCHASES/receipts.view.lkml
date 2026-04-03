view: receipts {
  sql_table_name: "PURCHASES"."RECEIPTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
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

  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }

  dimension: purchase_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PURCHASE_ID" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      filename,
      purchases.market_name,
      purchases.id,
      purchases.vendor_name,
      purchases.user_name
    ]
  }
}
