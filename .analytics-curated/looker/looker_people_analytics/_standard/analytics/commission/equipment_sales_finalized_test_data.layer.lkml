include: "/_base/analytics/commission/equipment_sales_finalized_test_data.view.lkml"

view: +equipment_sales_finalized_test_data {
  label: "Equipment Sales Finalized Test Data"

  dimension_group: commission_month {
    label: "Commission"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${commission_month} ;;
    description: "commission month"
  }

  dimension_group: paycheck_date {
    label: "Paycheck"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${paycheck_date} ;;
    description: "paycheck date"
  }

  dimension_group: invoice_pay_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${paycheck_date} ;;
    description: "invoice pay date"
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${paycheck_date} ;;
    description: "date created"
  }

  dimension: invoice_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.estrack.com/#/billing/{{ invoice_id | url_encode }}" target="_blank">{{invoice_no}}</a></font></u>;;
    sql: 'Link' ;;
  }

  ### formatting changes to already existing dimensions from the base view ###
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }

  dimension: line_item_amount {
    label: "Revenue"
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
    value_format: "$#,##0.00"
  }

  dimension: profit {
    label: "Profit"
    type: number
    sql: ${TABLE}."PROFIT" ;;
    value_format: "$#,##0.00"
  }

  dimension: profit_margin {
    type: number
    sql: ${TABLE}."PROFIT_MARGIN" ;;
    value_format: "0.0%"
  }

  dimension: commission_rate {
    type: number
    sql: ${TABLE}."COMMISSION_RATE" ;;
    value_format: "0.0%"
  }

  dimension: commission_amount {
    type: number
    sql: ${TABLE}."COMMISSION_AMOUNT" ;;
    value_format: "$#,##0.00"
  }

  dimension: nbv {
    label: "Net Book Value"
    type:  string
    sql: ${TABLE}."NBV" ;;
    value_format: "$#,##0.00"
  }

  dimension: company_name {
    label: "Customer"
  }

  ### measures ###
  measure: total_commission {
    type: sum
    sql: ${commission_amount} ;;
    value_format_name: usd
    value_format: "$#,##0"
  }

  measure: total_revenue {
    type: sum
    sql: ${line_item_amount} ;;
    value_format_name: usd
    value_format: "$#,##0"
  }




}
