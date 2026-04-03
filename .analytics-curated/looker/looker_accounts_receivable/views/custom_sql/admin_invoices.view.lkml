view: admin_invoices {
  derived_table: {
    sql: SELECT i.COMPANY_ID,
       co.NAME,
       u.EMAIL_ADDRESS,
       u.PHONE_NUMBER,
       CASE
           WHEN l.ZIP_CODE IS NULL THEN CONCAT(l.CITY, ', ', s.ABBREVIATION)
           WHEN l.STREET_2 IS NULL THEN CONCAT(l.STREET_1, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE)
           ELSE CONCAT(l.STREET_1, ' ', l.STREET_2, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE) END AS ADDRESS,
       COALESCE(col.COLLECTOR, '(No Collector Assigned)')                                                    AS COLLECTOR,
       i.INVOICE_NO,
       CAST(i.INVOICE_DATE AS DATE)                                                                          AS INVOICE_DATE,
       i.BILLED_AMOUNT,
       CAST(i.DUE_DATE AS DATE)                                                                              AS DUE_DATE,
       i.OWED_AMOUNT,
       i.INVOICE_ID
FROM ES_WAREHOUSE.PUBLIC.INVOICES i
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES co ON i.COMPANY_ID = co.COMPANY_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l ON co.BILLING_LOCATION_ID = l.LOCATION_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES s ON l.STATE_ID = s.STATE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u on u.user_id = co.owner_user_id
         LEFT JOIN (SELECT DISTINCT CCA.COMPANY_ID                                AS CUSTOMER_ID,
                                    CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS MARKET,
                                    CASE
                                        WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL'
                                        ELSE CCA.FINAL_COLLECTOR END              AS COLLECTOR
                    FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                             LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                       ON CCA.COMPANY_ID = COGL.CUSTOMER_ID) col
                   ON TRY_TO_NUMBER(i.COMPANY_ID) = col.CUSTOMER_ID
WHERE 1 = 1
--   AND i.COMPANY_ID = 109728
  AND i.OWED_AMOUNT != 0
  AND i.BILLING_APPROVED = true ;;
  }

  dimension: company_id {
    type: string
    label: "Company ID"
    sql: ${TABLE}."COMPANY_ID" ;;
    html: <a href="{{ company_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: company_name {
    type: string
    label: "Company Name"
    sql: ${TABLE}."NAME" ;;
  }

  dimension: email_address {
    type: string
    label: "Email Address"
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: phone_number {
    type: string
    label: "Phone Number"
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: address {
    type: string
    label: "Company Address"
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: company_url {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/companies/',${TABLE}."COMPANY_ID") ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: invoice_no {
    type: string
    label: "Invoice Number"
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <a href="{{ invoice_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: invoice_url {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/transactions/invoices/',${TABLE}."INVOICE_ID") ;;
  }

  dimension: invoice_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_date {
    type: date
    label: "Invoice Date"
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension_group: invoice_date_group {
    type: time
    label: "Invoice Date Group"
    timeframes: [date, month, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: billed_amount {
    type: number
    label: "Billed Amount"
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: total_billed_amount {
    type: sum
    label: "Total Billed Amount"
    sql: ${billed_amount} ;;
  }

  dimension: due_date {
    type: date
    label: "Due Date"
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: due_date_group {
    type: time
    label: "Due Date Group"
    timeframes: [date, month, year]
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: owed_amount {
    type: number
    label: "Owed Amount"
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  measure: total_outstanding_amount {
    type: sum
    label: "Total Outstanding Amount"
    sql: ${owed_amount} ;;
  }

  drill_fields: [
    company_id,
    company_name,
    address,
    collector,
    invoice_no,
    invoice_date,
    billed_amount,
    due_date,
    owed_amount
  ]
}
