view: gold_collector_payment_history {
  sql_table_name: "ANALYTICS"."PL_DBT"."GOLD_COLLECTOR_PAYMENT_HISTORY" ;;

###### DIMENSIONS ######

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ gold_collector_payment_history.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: market_id {
    value_format_name: id
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_id {
    value_format_name: id
    type: number
    html: <a href= "https://admin.equipmentshare.com/#/home/payments/{{ value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: is_manager  {
    type: yesno
    sql:
         ('{{ _user_attributes['email'] }}' in (
        'lewis.hornsby@equipmentshare.com',
        'ashley.dominguez@equipmentshare.com',
        'tiffany.brown@equipmentshare.com',
        'greg.stegeman@equipmentshare.com',
        'rhiannon.mitchell@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'regina.stuart@equipmentshare.com',
        'erica.parsons@equipmentshare.com',
        'cassondra.simon@equipmentshare.com',
        'roxanne.price@equipmentshare.com'
        )) ;;
  }


###### MEASURES ######

  measure: outstanding_balance {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."OUTSTANDING_BALANCE" ;;
  }

  measure: payment_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

}
