view: t3_subscription_revenue {
    derived_table: {
      sql: SELECT
                I.BILLING_APPROVED_DATE::DATE AS BILLING_APPROVED_DATE
                , LIT.NAME AS LINE_ITEM_TYPE
                , LIT.LINE_ITEM_TYPE_ID
                , U.COMPANY_ID
                , C.NAME AS CUSTOMER_NAME
                , I.INVOICE_ID
                , I.INVOICE_NO
                , PO.NAME AS REFERENCE
                , I.PAID
                , I.PAID_DATE
                , SUM(LI.AMOUNT) AS REVENUE
              FROM ES_WAREHOUSE.PUBLIC.INVOICES AS I
              LEFT JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS AS PO
                ON I.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI
                ON I.INVOICE_ID = LI.INVOICE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
                ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS AS O
                ON I.ORDER_ID = O.ORDER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
                ON O.USER_ID = U.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C
                ON U.COMPANY_ID = C.COMPANY_ID
              WHERE LI.LINE_ITEM_TYPE_ID IN (30,31,32,33,34)
                AND I.BILLING_APPROVED_DATE BETWEEN '2020-01-01'::TIMESTAMP_NTZ AND CURRENT_DATE::TIMESTAMP_NTZ
                AND I.BILLING_APPROVED_DATE IS NOT NULL
                AND U.COMPANY_ID <> 1854
                AND O.DELETED = FALSE
              GROUP BY I.BILLING_APPROVED_DATE::DATE, LIT.NAME, LIT.LINE_ITEM_TYPE_ID, U.COMPANY_ID, C.NAME, I.INVOICE_ID, I.INVOICE_NO, I.PAID_DATE, PO.NAME, I.PAID
              HAVING SUM(LI.AMOUNT) > 0
              ORDER BY I.BILLING_APPROVED_DATE::DATE, LIT.LINE_ITEM_TYPE_ID, U.COMPANY_ID, I.INVOICE_ID, I.INVOICE_NO ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: billing_approved_date {
      label: "Billing Approved Date"
      type: time
      sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
    }

    dimension: line_item_type {
      label: "Line Item Type"
      type: string
      sql: ${TABLE}."LINE_ITEM_TYPE" ;;
    }

    dimension: line_item_type_id {
      type: string
      sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    }

    dimension: company_id {
      label: "Company ID"
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: customer_name {
      label: "Company Name"
      type: string
      sql: ${TABLE}."CUSTOMER_NAME" ;;
    }

    dimension: invoice_id {
      label: "Invoice ID"
      type: string
      sql: ${TABLE}."INVOICE_ID" ;;
    }

    dimension: invoice_no {
      label: "Invoice No."
      type: string
      sql: ${TABLE}."INVOICE_NO" ;;
    }


    dimension: reference {
      label: "Reference"
      type: string
      sql: ${TABLE}."REFERENCE" ;;
    }

    dimension: paid {
      label: "Paid (y/n)"
      type: yesno
      sql: ${TABLE}."PAID" ;;
    }

  dimension_group: paid_date {
    label: "Invoice Paid Date"
    type: time
    sql: ${TABLE}."PAID_DATE" ;;
  }

    dimension: revenue {
      type: number
      sql: ${TABLE}."REVENUE" ;;
    }

    measure: t3_revenue {
      label: "T3 Revenue"
      type: sum
      sql: ${revenue} ;;
    }

    set: detail {
      fields: [
        billing_approved_date_date,
        line_item_type,
        line_item_type_id,
        company_id,
        customer_name,
        invoice_id,
        invoice_no,
        reference,
        paid,
        paid_date_date,
        t3_revenue
      ]
    }
  }
