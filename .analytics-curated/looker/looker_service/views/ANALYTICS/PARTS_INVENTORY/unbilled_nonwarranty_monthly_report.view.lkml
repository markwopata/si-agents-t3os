view: unbilled_nonwarranty_monthly_report {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."UNBILLED_NONWARRANTY_MONTHLY_REPORT" ;;

  dimension: ad_max_prem {
    type: yesno
    sql: ${TABLE}."AD_MAX_PREM" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: billed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLED_DATE" ;;
  }
  dimension: billing_type {
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }
  dimension: crockett_partners_ii {
    type: yesno
    sql: ${TABLE}."CROCKETT_PARTNERS_II" ;;
  }
  dimension: current_asset_owner {
    type: string
    sql: ${TABLE}."CURRENT_ASSET_OWNER" ;;
  }
  dimension: current_asset_owner_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CURRENT_ASSET_OWNER_ID" ;;
  }
  dimension: es_owned {
    type: yesno
    sql: ${TABLE}."ES_OWNED" ;;
  }
  dimension: es_owned_or_maintained_at_completion {
    type: yesno
    sql: ${TABLE}."ES_OWNED_OR_MAINTAINED_AT_COMPLETION" ;;
  }
  dimension: estimated_labor_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ESTIMATED_LABOR_RATE" ;;
  }
  dimension: flex_50 {
    type: yesno
    sql: ${TABLE}."FLEX_50" ;;
  }
  dimension: flex_55 {
    type: yesno
    sql: ${TABLE}."FLEX_55" ;;
  }
  dimension: labor_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."HOURS_EXPENSE" ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: ot_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."OT_HOURS" ;;
  }
  dimension: own_equipment_fund_i {
    type: yesno
    sql: ${TABLE}."OWN_EQUIPMENT_FUND_I" ;;
  }
  dimension: own_sale_pending_payment {
    type: yesno
    sql: ${TABLE}."OWN_SALE_PENDING_PAYMENT" ;;
  }
  dimension: parts_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PARTS_COST" ;;
  }
  dimension: reg_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."REG_HOURS" ;;
  }
  dimension: total_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_COST" ;;
  }
  dimension_group: wo_completed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WO_COMPLETED" ;;
  }
  dimension_group: wo_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WO_CREATED" ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  measure: count {
    type: count
  }
}
