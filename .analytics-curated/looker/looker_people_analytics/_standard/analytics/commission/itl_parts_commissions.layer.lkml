include: "/_base/analytics/commission/itl_parts_commissions.view.lkml"

view: +itl_parts_commissions {
  label: "ITL Parts Commissions"

  dimension: MARKET_NAME {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: PARENT_MARKET_NAME {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }
  dimension: INVOICE_ID {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: INVOICE_NO {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: LINE_ITEM_ID {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: DESCRIPTION {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension_group: BILLING_APPROVED_DATE {
    label: "Billing Approved Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${BILLING_APPROVED_DATE} ;;
    description: "Billing Approved Date"
  }
  dimension: BILLING_YEAR_MONTH {
    type: string
    sql: ${TABLE}."BILLING_YEAR_MONTH" ;;
  }
  dimension: SALESPERSON_USER_ID {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: SALES_PERSON_TYPE {
    type: string
    sql: ${TABLE}."SALES_PERSON_TYPE" ;;
  }
  dimension: EMPLOYEE_ID {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: FULL_NAME {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: EMPLOYEE {
    type: string
    sql: ${TABLE}."EMPLOYEE" ;;
  }
  dimension: MATCH {
    type: string
    sql: ${TABLE}."MATCH" ;;
  }
  dimension: INSIDE_SALES {
    type: string
    sql: ${TABLE}."INSIDE_SALES" ;;
  }
  dimension: EMPLOYEE_TITLE {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: EMPLOYEE_COMMISSION_ELIGIBILITY {
    type: string
    sql: ${TABLE}."EMPLOYEE_COMMISSION_ELIGIBILITY" ;;
  }
  dimension: AMOUNT {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: RECORDED_PART_COST {
    type: number
    sql: ${TABLE}."RECORDED_PART_COST" ;;
  }
  dimension: MARGIN {
    type: number
    sql: ${TABLE}."MARGIN" ;;
  }
  dimension: COMMISSION_AMOUNT {
    type: number
    sql: ${TABLE}."COMMISSION_AMOUNT" ;;
  }
  dimension: INSIDE_SALES_COMMISSION {
    type: number
    sql: ${TABLE}."INSIDE_SALES_COMMISSION" ;;
  }
  dimension: MARGIN_PERC {
    type: number
    sql: ${TABLE}."MARGIN_PERC" ;;
  }
  dimension: SPLIT {
    type: number
    sql: ${TABLE}."SPLIT" ;;
  }
  dimension: COMMISSION_PERC {
    type: number
    sql: ${TABLE}."COMMISSION_PERC" ;;
  }
  dimension: COMMISSION_PERCENTAGE_TAM {
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE_TAM" ;;
  }
  dimension: COMMISSION_PERCENTAGE_COORDINATOR {
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE_COORDINATOR" ;;
  }
  dimension: STATEMENT {
    type: string
    sql: ${TABLE}."STATEMENT" ;;
  }
  dimension: PRIMARY_SALESREP {
    type: string
    sql: ${TABLE}."PRIMARY_SALESREP" ;;
  }
  dimension: SECONDARY_SALESREP_LIST {
    type: string
    sql: ${TABLE}."SECONDARY_SALESREP_LIST" ;;
  }
  dimension: NAM {
    type: string
    sql: ${TABLE}."NAM" ;;
  }
  dimension: CREATED_BY {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension: CREATED_BY_TITLE {
    type: string
    sql: ${TABLE}."CREATED_BY_TITLE" ;;
  }
  dimension: CREATED_BY_NAME {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }
  dimension: INVOICE_LINE_ITEM_IDENTIFIER {
    type: number
    sql: ${TABLE}."INVOICE_LINE_ITEM_IDENTIFIER" ;;
  }
  dimension: INVOICE_LINE_ITEM_ROLLING_COUNT {
    type: number
    sql: ${TABLE}."INVOICE_LINE_ITEM_ROLLING_COUNT" ;;
  }
  dimension: ROLLING_COUNT {
    type: number
    sql: ${TABLE}."ROLLING_COUNT" ;;
  }


  measure: total_inside_sales_commission {
    label: "Total Inside Sales Commission"
    type: sum
    sql: ${TABLE}.INSIDE_SALES_COMMISSION ;;
    value_format: "$#,##0.00"  # optional, nice formatting
  }
}
