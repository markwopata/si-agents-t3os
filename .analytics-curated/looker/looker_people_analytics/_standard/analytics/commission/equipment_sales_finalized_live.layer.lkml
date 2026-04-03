include: "/_base/analytics/commission/equipment_sales_finalized_live.view.lkml"

view: +equipment_sales_finalized_live {
  label: "Equipment Sales Finalized Live"


  dimension_group: invoice_created_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${invoice_created_date} ;;
    description: "invoice created date"
  }

  dimension_group: order_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${order_date} ;;
    description: "order date"
  }

  dimension_group: transaction_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${transaction_date} ;;
    description: "transaction date"
  }

  dimension_group: billing_approved_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${billing_approved_date} ;;
    description: "billing approved date"
  }

  dimension_group: commission_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${commission_month} ;;
    description: "commission month"
  }

  dimension_group: paycheck_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${paycheck_date} ;;
    description: "paycheck date"
  }

  dimension: invoice_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.estrack.com/#/billing/{{ invoice_id | url_encode }}" target="_blank">{{invoice_no}}</a></font></u>;;
    sql: 'Link' ;;
  }

  dimension: request_manual_adjustment {
    label: "Request for Manual Adjustment"
    type: string
    sql: ${commission_id} ;;
    html:
    <a href="https://equipmentshare.retool-hosted.com/app/manual-adjustment-request-submit/request?commission_id={{ value | url_encode }}"
       target="_blank"
       style="color:#0063f3; font-weight:600; text-decoration:none;">
      Link
    </a>;;
    description: "HTML link that opens the Retool app with commission_id and user email."
  }

### formatting changes to already existing dimensions from the base view ###
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }

  dimension: amount {
    label: "Revenue"
    type: number
    sql: ${TABLE}."AMOUNT" ;;
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
