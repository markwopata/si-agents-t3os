view: invoices {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."INVOICES"
  ;;

  # derived_table: {
  #   sql: SELECT i.*,
  #   si.name as rep,
  #   si.home_market_dated AS sp_home_market,
  #   si.first_date_as_TAM
  #   FROM es_warehouse.public.invoices i
  #   LEFT JOIN (SELECT * FROM analytics.bi_ops.salesperson_info WHERE record_ineffective_date IS NULL) si WHERE si.user_id = i.salesperson_user_id;;
  # }
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
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

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  # dimension: rep {
  #   type: string
  #   sql: ${TABLE}."REP" ;;
  # }

  # dimension: sp_home_market {
  #   type: string
  #   sql: ${TABLE}."SP_HOME_MARKET" ;;
  # }

  # dimension: rep_market {
  #   label: "Rep - Home Market"
  #   type: string
  #   sql:  concat(${rep}, ' - ', ${sp_home_market})  ;;
  # }

  # dimension: first_date_as_tam {
  #   type: string
  #   sql:  ${TABLE}."FIRST_DATE_AS_TAM"  ;;
  # }



  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }


  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
    label: "Invoice Created"
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }} ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }} ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_no_with_link {
    label: "Invoice Number With Link"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_no}}" target="_blank">{{ invoice_no._value }} ➔ </a></font></u> ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }

  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: reference {
    label: "PO/Reference"
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }

  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }

  dimension: track_link {
    label: "Track Link"
    type: string
    html: <font color="#0063f3 "><u><a href="https://app.estrack.com/#/home/dashboard/invoices/{{invoice_id}}?status=outstanding" target="_blank">Track</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: admin_link_to_invoice {
    label: "Admin Link to Invoice"
    type: string
    html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  measure: Total_Outstanding {
    type: sum
    value_format_name: usd
    sql: ${owed_amount} ;;
    drill_fields: [date_created_date, companies.name, track_link, due_date, invoice_no_with_link, owed_amount]
    filters: [paid: "No",
      billing_approved: "Yes"]
  }

  measure: Total_Revenue {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    filters: [billing_approved: "Yes"]
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,billed_amount]
  }

  measure: dso {
    type: number
    sql: (${Total_Outstanding}/case when ${Total_Revenue} = 0 then null else ${Total_Revenue} end)*180 ;;
    value_format_name: decimal_0
    drill_fields: [dso_detail*]
  }

  measure: dso_companies_drill {
    type: number
    sql: (${Total_Outstanding}/case when ${Total_Revenue} = 0 then null else ${Total_Revenue} end)*180 ;;
    value_format_name: decimal_0
    drill_fields: [dso_companies_detail*]
  }

  measure: Invoice_Total_Amount{
    type: sum
    sql:
        CASE
          WHEN ${owed_amount} is not null and ${owed_amount} > 0.0 then ${owed_amount}
          ELSE ${billed_amount}
        END ;;
    ##html: <u><a href="https://equipmentshare.looker.com/dashboards/12?Market=&Sales+Rep=&Company+Name+with+Net+Terms=&Collector=&Net+Terms=&Region=District=&Customer+Flag=&Do+Not+Rent="target="_blank">{{rendered_value}}</a></u> ;;
    value_format_name: usd_0
    drill_fields: [detail*]
    filters: [paid: "No",
      billing_approved: "Yes"]
  }

  dimension: invoice_1_to_30 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) <= 30 ;;
  }

  measure: Outstanding_1_to_30{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_1_to_30: "Yes" , owed_amount: "> 0"]
    filters: [outstanding: "= 1" , owed_amount: "> 0", billing_approved: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: invoice_31_to_60 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 30 AND datediff(day,${invoice_date},current_date()) <= 60 ;;
  }

  measure: Outstanding_31_to_60{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_31_to_60: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 31", owed_amount: "> 0", billing_approved: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: invoice_61_to_90 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 60 AND datediff(day,${invoice_date},current_date()) <= 90 ;;
  }

  measure: Outstanding_61_to_90{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_61_to_90: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 61", owed_amount: "> 0", billing_approved: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: invoice_91_to_120 {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 90 AND datediff(day,${invoice_date},current_date()) <= 120 ;;
  }

  measure: Outstanding_91_to_120{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_91_to_120: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 91", owed_amount: "> 0", billing_approved: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: invoice_120_plus {
    type: yesno
    sql: datediff(day,${invoice_date},current_date()) > 120 ;;
  }

  measure: Outstanding_120_plus{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_120_plus: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 121", owed_amount: "> 0", billing_approved: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: Outstanding_total{
    type: sum
    sql: ${owed_amount} ;;
    filters: [owed_amount: "> 0"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: Outstanding_120_plus_clawback{
    type: sum
    sql: ${owed_amount} ;;
    # filters: [invoice_120_plus: "Yes", clawback_eligible: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 121", clawback_eligible: "Yes", owed_amount: "> 0"]
    value_format: "$#,##0"
    drill_fields: [detail*]
  }

  measure: Outstanding_120_plus_clawback_4{
    type: sum
    sql: ${owed_amount}*.04 ;;
    # filters: [invoice_120_plus: "Yes", clawback_eligible: "Yes", owed_amount: "> 0"]
    filters: [outstanding: "= 121", clawback_eligible: "Yes", owed_amount: "> 0"]
    value_format: "$#,##0"
    drill_fields: [detail*]
  }

  measure: count {
    type: count
    drill_fields: [invoice_id, orders.purchase_order_id]
  }

  dimension: clawback_eligible {
    type: yesno
    sql: ${invoice_date} >= '2019-11-01' ;;
  }

  measure: Invoices_before_sept{
    type: sum
    sql: ${owed_amount} ;;
    filters: [clawback_eligible: "No"]
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      invoice_date,
      companies.name,
      companies.do_not_rent,
      users.Full_Name,
      invoice_no,
      purchase_orders.name,
      Invoice_Total_Amount
    ]
  }

  set: dso_detail {
    fields: [
      market_region_xwalk.market_name,
      invoice_date,
      invoice_no,
      Total_Outstanding,
      Total_Revenue
    ]
  }

  set: dso_companies_detail {
    fields: [
      companies.name,
      Total_Outstanding,
      Total_Revenue,
      dso
    ]
  }
}
