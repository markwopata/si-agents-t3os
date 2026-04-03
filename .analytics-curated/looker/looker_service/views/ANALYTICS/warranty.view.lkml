view: warranty {
  sql_table_name: "GS"."WARRANTY"
    ;;

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

  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }

  dimension: credit_memo_number {
    type: string
    sql: ${TABLE}."CREDIT_MEMO_NUMBER" ;;
  }

  dimension: denial_code {
    type: string
    sql: ${TABLE}."DENIAL_CODE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: work_order_number {
    type: string
    sql: ${TABLE}."WORK_ORDER_NUMBER" ;;
  }

  dimension: denial_code_number {
    type: number
    sql: left(${denial_code}, 1) ;;
  }

  dimension: is_denied {
    type: yesno
    sql: ${denial_code} is not null ;;
  }

  measure: denied_count {
    type: count_distinct
    sql: ${invoice_number};;
    filters: [is_denied: "Yes"]
  }

  dimension: track_link_to_WO {
    label: "Link to WO"
    type: string
    sql: ${work_order_number} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ work_order_number._value }}" target="_blank">Track</a></font></u> ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
