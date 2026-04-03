view: invoice_balance {
  derived_table: {
    sql:
    WITH CREDITS AS (
    -- LIST OF CREDIT AMOUNTS
        select INVOICE_ID,
               listagg(distinct concat('CR-', CREDIT_NOTE_ID), ', ')
                       within group (order by concat('CR-', CREDIT_NOTE_ID)) as list_of_CR,
               sum(AMOUNT)                                                   as CREDIT_AMOUNT_APPLIED
        from ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_ALLOCATIONS
        where REVERSAL_DATE is null
        group by INVOICE_ID),
         PAYMENTS AS (
             -- payment amounts
             select pa.INVOICE_ID,
                    listagg(distinct pa.PAYMENT_ID, ' | ')   as payment_id,
                    listagg(distinct pt.NAME, ' | ')         as payment_type,
                    listagg(distinct py.REFERENCE, ' | ')    as reference,
                    listagg(distinct py.CHECK_NUMBER, ' | ') as check_number,
                    listagg(distinct DATE(pa.DATE), ' | ')   as date_paid,
                    sum(pa.AMOUNT)                           as paid_amount
             from ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS pa
                      left join ES_WAREHOUSE.PUBLIC.PAYMENTS py on pa.PAYMENT_ID = py.PAYMENT_ID
                      join ES_WAREHOUSE.PUBLIC.PAYMENT_METHOD_TYPES pt
                           on py.PAYMENT_METHOD_TYPE_ID = pt.PAYMENT_METHOD_TYPE_ID
             where pa.REVERSED_DATE is null
             group by pa.INVOICE_ID)

      select ar.CUSTOMER_NAME                                                                   as CUSTOMER_NAME,
      REPLACE(i.SHIP_TO:"nickname"::STRING, '"', '')                                     AS DELIVERY_LOCATION,
      REPLACE(
      CONCAT(
      i.SHIP_TO:"address":"street_1"::STRING, ', ',
      i.SHIP_TO:"address":"city"::STRING, ', ',
      i.SHIP_TO:"address":"state_abbreviation"::STRING, ', ',
      i.SHIP_TO:"address":"zip_code"::STRING
      ), '"', ''
      )                                                                                  AS JOBSITE_ADDRESS,
      de.EMPLOYEE_NAME                                                                   AS SALESPERSON,
      ar.INVOICE_NUMBER,
      ar.invoice_id,
      ar.INVOICE_STATE                                                                   AS INVOICE_STATUS,
      po.NAME                                                                            AS PO,
      ar.INVOICE_DATE,
      ar.DUE_DATE,
      ar.BILLING_APPROVED_DATE,
      ar.DEPARTMENT_ID                                                                   AS MARKET_ID,
      ar.DEPARTMENT_NAME                                                                 AS MARKET_NAME,
      sum(ar.AMOUNT)                                                                     AS INVOICE_AMOUNT,
      c.list_of_CR                                                                       AS CREDITS_APPLIED,
      coalesce(c.CREDIT_AMOUNT_APPLIED, 0)                                               AS CREDIT_AMOUNT_APPLIED,
      coalesce(p.paid_amount, 0)                                                         AS AMOUNT_PAID,
      p.date_paid                                                                        AS DATE_PAID,
      p.PAYMENT_ID                                                                       AS PAYMENT_ID,
      UPPER(p.payment_type)                                                              AS PAYMENT_METHOD,
      p.CHECK_NUMBER                                                                     AS CHECK_NUMBER,
      sum(ar.AMOUNT) - coalesce(p.paid_amount, 0) - coalesce(c.CREDIT_AMOUNT_APPLIED, 0) AS OUTSTANDING_BALANCE,
      CASE
      WHEN ar.DUE_DATE < CURRENT_DATE()
      AND SUM(ar.AMOUNT) - COALESCE(p.paid_amount, 0) - COALESCE(c.CREDIT_AMOUNT_APPLIED, 0) > 0
      THEN DATEDIFF(day, ar.DUE_DATE, CURRENT_DATE()) -- Calculate days overdue
      ELSE NULL
      END                                                                            AS OVERDUE_BY,
      ar.URL_ADMIN                                                                       AS URL_ADMIN
      from ANALYTICS.INTACCT_MODELS.AR_DETAIL ar
      left join CREDITS AS c
      on ar.INVOICE_ID = c.INVOICE_ID
      left join PAYMENTS as p
      on ar.INVOICE_ID = p.INVOICE_ID
      left join ES_WAREHOUSE.PUBLIC.INVOICES i
      on ar.INVOICE_ID = i.INVOICE_ID
      left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po
      on i.PURCHASE_ORDER_ID = po.PURCHASE_ORDER_ID
      left join ANALYTICS.BRANCH_EARNINGS.DIM_EMPLOYEE de
      on i.SALESPERSON_USER_ID = de.USER_ID
      where ar.AR_LINE_TYPE != 'aradjustmententry'
      group by all
      having INVOICE_AMOUNT != 0
      and INVOICE_NUMBER is not null


      ;;
  }
  dimension: CUSTOMER_NAME {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: DELIVERY_LOCATION {
    type: string
    sql: ${TABLE}."DELIVERY_LOCATION" ;;
  }

  dimension: JOBSITE_ADDRESS {
    type: string
    sql: ${TABLE}."JOBSITE_ADDRESS" ;;
  }

  dimension: SALESPERSON {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: INVOICE_NUMBER {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: INVOICE_ID {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: DUE_DATE {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: BILLING_APPROVED_DATE {
    type: time
    timeframes: [date, week, month, year]
    datatype: timestamp
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }


  dimension: INVOICE_STATUS {
    type: string
    sql: ${TABLE}."INVOICE_STATUS" ;;
  }

  dimension: PO {
    type: string
    sql: ${TABLE}."PO" ;;
  }

  dimension: MARKET_ID {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: MARKET_NAME {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: INVOICE_AMOUNT {
    label: "INVOICE AMOUNT"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
  }

  measure: AMOUNT_PAID {
    label: "Amount Paid"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."AMOUNT_PAID" ;;
  }

  measure: CREDIT_AMOUNT {
    label: "CREDIT AMOUNT"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."CREDIT_AMOUNT_APPLIED" ;;
  }

  dimension: CREDITS_APPLIED {
    type:  string
    sql: ${TABLE}."CREDITS_APPLIED" ;;
  }

  dimension: DATE_PAID {
    type:  string
    sql: ${TABLE}."DATE_PAID" ;;
  }

  dimension: PAYMENT_ID {
    type: string
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: PAYMENT_METHOD {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD" ;;
  }

  dimension: CHECK_NUMBER {
    type: string
    sql: ${TABLE}."CHECK_NUMBER" ;;
  }

  measure: OUTSTANDING_BALANCE {
    label: "Outsanding Amount"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."OUTSTANDING_BALANCE" ;;
  }

  dimension: url_admin {
    label: "URL Admin"
    type: string
    # hidden: yes
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Admin Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_ADMIN" ;;
  }


  dimension: OVERDUE_BY {
    type: number
    sql: ${TABLE}."OVERDUE_BY" ;;
  }

}
