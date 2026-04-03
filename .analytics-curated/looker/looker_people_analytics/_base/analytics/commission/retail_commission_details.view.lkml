view: retail_commission_details {
  sql_table_name: "ANALYTICS"."COMMISSION"."EQUIPMENT_SALES_FINALIZED" ;;

  # Dimensions
  dimension: equip_sales_id {
    type: number
    sql: ${TABLE}."EQUIP_SALES_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: new_calc_ind {
    type: yesno
    sql: ${TABLE}."NEW_CALC_IND" ;;
  }

  dimension: used {
    type: yesno
    sql: ${TABLE}."USED" ;;
  }

  dimension: new {
    type: yesno
    sql: ${TABLE}."NEW" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: parent_market_id {
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
  }

  dimension: net_sale_price {
    type: number
    sql: ${TABLE}."NET_SALE_PRICE" ;;
  }

  dimension: profit {
    type: number
    sql: ${TABLE}."PROFIT" ;;
  }

  dimension: profit_margin {
    type: number
    sql: ${TABLE}."PROFIT_MARGIN" ;;
  }

  dimension: rate_achievement {
    type: string
    sql: ${TABLE}."RATE_ACHIEVEMENT" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: commission_rate {
    type: number
    sql: ${TABLE}."COMMISSION_RATE" ;;
  }

  dimension: commission_amount {
    type: number
    sql: ${TABLE}."COMMISSION_AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: nbv {
    type: number
    sql: ${TABLE}."NBV" ;;
  }

  dimension: paycheck_date {
    type: date_time
    sql: ${TABLE}."PAYCHECK_DATE" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: source_category {
    type: string
    sql: ${TABLE}."SOURCE_CATEGORY" ;;
  }

  dimension: pa_notes {
    type: string
    sql: ${TABLE}."PA_NOTES" ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

}
