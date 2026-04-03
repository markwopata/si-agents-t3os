view: looker_commission_clawback_history {
  sql_table_name: "COMMISSION_CLAWBACKS"."LOOKER_COMMISSION_CLAWBACK_HISTORY"
    ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension_group: date {
    label: "Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: eligible {
    type: yesno
    sql: ${TABLE}."ELIGIBLE" ;;
  }

  dimension: exception {
    type: yesno
    sql: ${TABLE}."EXCEPTION" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: month {
    label: "Month"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  measure: count {
    type: count
    filters: [eligible: "Yes"]
    drill_fields: [month_date, branch_id, companies.name, invoices.invoice_no, type, amount]
  }

  measure: total {
    type: sum
    sql: ${amount};;
    filters: [eligible: "Yes"]
    value_format_name: usd_0
    drill_fields: [month_date, branch_id, companies.name, invoices.invoice_no, type, amount]
  }
}
