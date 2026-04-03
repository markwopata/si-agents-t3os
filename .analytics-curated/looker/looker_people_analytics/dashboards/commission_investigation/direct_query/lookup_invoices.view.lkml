view: lookup_invoices {

    label: "Invoices Lookup"

    derived_table: {
      sql:
        select i.BILLING_APPROVED_DATE,
               i.PAID_DATE,
               i.ORDER_ID,
               i.INVOICE_NO,
               i.INVOICE_ID,
               li.LINE_ITEM_ID,
               li.LINE_ITEM_TYPE_ID,
               lit.name                               as LINE_ITEM_TYPE_NAME,
               c.COMPANY_ID,
               concat_ws(' - ', c.COMPANY_ID, c.NAME) as customer,
        from ES_WAREHOUSE.PUBLIC.INVOICES i
                 left join ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS ais on i.INVOICE_ID = ais.INVOICE_ID
                 left join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
                 left join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit on li.LINE_ITEM_TYPE_ID = lit.LINE_ITEM_TYPE_ID
                 left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
        where i.BILLING_APPROVED_DATE is not null
        ORDER BY i.BILLING_APPROVED_DATE DESC, li.LINE_ITEM_TYPE_ID asc
        ;;
    }

  dimension: COMPANY_ID {
    label: "Customer ID"
    type: string
    sql:  ${TABLE}.COMPANY_ID ;;
    }

  dimension: customer {
    label: "Customer ID & Name"
    type: string
    sql: CAST(${TABLE}.customer AS STRING) ;;

    link: {
      label: "Admin App"
      url: "https://admin.equipmentshare.com/#/home/companies/{{ value }}"
    }

  }



    dimension_group: billing_approved_date {
      label: "Billing Approved Date"
      type: time
      timeframes: [raw, time, date, week, month, year]
      sql: ${TABLE}.BILLING_APPROVED_DATE ;;
    }

  dimension_group: PAID_DATE {
    label: "Invoice Payment Applied Date"
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.PAID_DATE ;;
  }

  dimension: ORDER_ID {
    type: string
    sql: ${TABLE}.ORDER_ID ;;

    link: {
      label: "Admin App"
      url: "https://admin.equipmentshare.com/#/home/orders/{{ value }}"
    }

    link: {
      label: "Order History Looker"
      url: "https://equipmentshare.looker.com/dashboards/2463?Order+Details={{ value }}"
    }

  }


  dimension: INVOICE_NO {
    type: string
    sql: ${TABLE}.INVOICE_NO ;;

    link: {
      label: "Admin App"
      url: "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ lookup_invoices.INVOICE_ID }}"
    }
  }

  dimension: INVOICE_ID {
    type: number
    sql: ${TABLE}.INVOICE_ID ;;
    link: {
      label: "Admin App"
      url: "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ lookup_invoices.INVOICE_ID }}"
    }
  }




  dimension: LINE_ITEM_TYPE_ID {
    type: number
    sql: ${TABLE}.LINE_ITEM_TYPE_ID ;;
  }

  dimension: LINE_ITEM_TYPE_NAME {
    type: string
    sql: ${TABLE}.LINE_ITEM_TYPE_NAME ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}.LINE_ITEM_ID ;;
  }


  dimension: line_item_rate_comparison {
    type: string
    label: "Rate Comparison"
    sql: ${TABLE}.LINE_ITEM_ID ;;

    link: {
      label: "Rate Comparison Looker"
      url: "https://equipmentshare.looker.com/dashboards/2464?Line+Item+ID={{ value }}"
    }

  }



  }
