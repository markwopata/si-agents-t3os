view: national_accounts_collections {
  sql_table_name: "ANALYTICS"."TREASURY"."NATIONAL_ACCOUNTS_COLLECTIONS" ;;

######## DIMENSIONS ########

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ national_accounts_collections.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: past_due {
    type: string
    sql: ${TABLE}."PAST_DUE" ;;
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  ######## MEASURES ########
  measure: balance {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."BALANCE" ;;
  }

  measure: collections {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."COLLECTIONS" ;;
  }

  measure: ttm_revenue {
    label: "TTM Revenue"
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: dso  {
    label: "DSO"
    value_format_name: decimal_1
    type: number
    drill_fields: [trx_details*]
    sql: iff(${ttm_revenue}=0,0,(${past_due_balance}/${ttm_revenue})*365) ;;
  }

  measure: current_balance {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."CURRENT_BALANCE" ;;
  }

  measure: past_due_balance {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."PAST_DUE_BALANCE" ;;
  }


  measure: percent_current {
    label: "% Current"
    type: number
    value_format_name: percent_1
    sql: iff(${balance}=0,0,${current_balance}/${balance}) ;;
  }

  measure: percent_past_due {
    label: "% Past Due"
    type: number
    value_format_name: percent_1
    sql: iff(${balance}=0,0,${past_due_balance}/${balance}) ;;
  }

  ######## DRILL FIELDS ########
  set: trx_details {
    fields: [invoice_no,customer_id,customer_name,net_terms,final_collector,direct_manager_name,invoice_no,billing_approved_date,due_date,
      balance,ttm_revenue,collections
    ]
  }


}
