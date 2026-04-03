view: salesperson_invoice_changes {
  sql_table_name: "ANALYTICS"."COMMISSION_CLAWBACKS"."SALESPERSON_INVOICE_CHANGES"
    ;;

  dimension_group: change {
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
    sql: ${TABLE}."CHANGE_DATE" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: new_rep_id {
    type: number
    sql: ${TABLE}."NEW_REP_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: prev_rep_id {
    type: number
    sql: ${TABLE}."PREV_REP_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
