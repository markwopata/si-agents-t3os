view: purchases {
  derived_table: {
    sql: SELECT
  p.*
  ,replace(replace(replace(c.value::string,'[',''),']',''),'"','') as image_urls_parsed
  FROM ES_WAREHOUSE.PURCHASES.PURCHASES p,
  lateral flatten(input=>split(IMAGE_URLS::STRING, ',')) c
    ;;
    }

  dimension: purchase_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PURCHASE_ID" ;;
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

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: receipt_amount {
    type: number
    sql: ${TABLE}."GRAND_TOTAL" ;;
  }

  dimension: image_urls {
    type: string
    sql: ${TABLE}."IMAGE_URLS" ;;
  }

  dimension: image_urls_parsed {
    type: string
    sql: ${TABLE}."IMAGE_URLS_PARSED" ;;
  }

  dimension: link_to_receipt {
    type: string
    html: <font color="blue "><u><a href ="{{image_urls_parsed._value}}"target="_blank">Link to CC Receipt</a></font></u> ;;
    sql: ${image_urls_parsed} ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: modified {
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
    sql: CAST(${TABLE}."MODIFIED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension_group: transaction_date {
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
    sql: CAST(${TABLE}."PURCHASED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: submitted {
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
    sql: CAST(${TABLE}."SUBMITTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: submitted_by_user_id {
    type: string
    sql: ${TABLE}."SUBMITTED_BY_USER_ID" ;;
  }

  dimension: vendor_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      purchase_id,
      vendor_name,
      user_id,
      vendors.term_name,
      vendors.vendor_id,
      vendors.name,
      receipts.count
    ]
  }
}
