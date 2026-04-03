view: fleet_sandbox__vic_write_back {
  sql_table_name: "FLEET_SANDBOX_GOLD"."FLEET_SANDBOX__VIC_WRITE_BACK" ;;

  dimension: invoice_number {
    type:  string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: reconciliation_status {
    type:  string
    sql:  ${TABLE}."STATUS_RECONCILIATION" ;;
  }

  dimension: order_status {
    type:  string
    sql:  ${TABLE}."STATUS_ORDER" ;;
  }

    dimension: amount_total {
      type:  number
      sql:  ${TABLE}."AMOUNT_TOTAL" ;;
  }

  dimension: amount_freight {
    type:  number
    sql:  ${TABLE}."AMOUNT_FREIGHT" ;;
  }

  dimension: amount_sales_tax {
    type:  number
    sql:  ${TABLE}."AMOUNT_SALES_TAX" ;;
  }

  dimension: date_gl {
    type:  date
    sql:  ${TABLE}."DATE_GL" ;;
  }

  dimension: date_invoice_due {
    type:  date
    sql:  ${TABLE}."DATE_INVOICE_DUE" ;;
  }

  dimension: date_invoice_issued {
    type:  date
    sql:  ${TABLE}."DATE_INVOICE_ISSUED" ;;
  }

  }
