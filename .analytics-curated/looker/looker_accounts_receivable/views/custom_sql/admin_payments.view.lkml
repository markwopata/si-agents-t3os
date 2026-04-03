view: admin_payments {
    derived_table: {
      sql: WITH billing_prefs AS (SELECT co.COMPANY_ID,
                              co.NAME,
                              CASE
                                  WHEN bcp.PREFS:managed_billing IS NULL THEN false
                                  ELSE bcp.PREFS:managed_billing END     AS MANAGED_BILLING_PREFERENCE,
                              CASE
                                  WHEN bcp.PREFS:specialized_billing IS NULL THEN false
                                  ELSE bcp.PREFS:specialized_billing END AS SPECIALIZED_BILLING_PREFERENCE,
                              bcp.PREFS:national_account::boolean AS NATIONAL_ACCOUNT
                       FROM ES_WAREHOUSE.PUBLIC.COMPANIES co
                                LEFT JOIN ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES bcp
                                          ON co.COMPANY_ID = bcp.COMPANY_ID),
     max_pmt_date AS (SELECT p.COMPANY_ID,
                             COALESCE(MAX(p.PAYMENT_DATE), MAX(p.DATE_CREATED)) MOST_RECENT_PMT_DATE
                      FROM ES_WAREHOUSE.PUBLIC.PAYMENTS p
                      WHERE p.payment_date IS NOT NULL OR p.date_created IS NOT NULL
                      GROUP BY p.COMPANY_ID)
SELECT p.COMPANY_ID,
       co.NAME,
       u.EMAIL_ADDRESS,
       u.PHONE_NUMBER,
       CASE
           WHEN l.ZIP_CODE IS NULL THEN CONCAT(l.CITY, ', ', s.ABBREVIATION)
           WHEN l.STREET_2 IS NULL THEN CONCAT(l.STREET_1, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE)
           ELSE CONCAT(l.STREET_1, ' ', l.STREET_2, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE) END AS ADDRESS,
       billing_prefs.MANAGED_BILLING_PREFERENCE,
       billing_prefs.SPECIALIZED_BILLING_PREFERENCE,
       billing_prefs.NATIONAL_ACCOUNT,
       co.HAS_MSA,
       max_pmt_date.MOST_RECENT_PMT_DATE,
       COALESCE(col.COLLECTOR, '(No Collector Assigned)')                                                    AS COLLECTOR,
       p.PAYMENT_ID,
       CASE
           WHEN p.STATUS = 0 THEN NULL
           WHEN p.STATUS = 1 THEN 'Reversed'
           WHEN p.STATUS = 2 THEN 'Partially Refunded'
           WHEN p.STATUS = 3 THEN 'Fully Refunded' END                                                       AS STATUS,
--     STATUS = 0;
--     STATUS = 1; Reversed
--     STATUS = 2; Partially Refunded
--     STATUS = 3; Fully Refunded
       CAST(COALESCE(p.PAYMENT_DATE, p.DATE_CREATED) AS DATE)                                                AS DATE,
       p.REFERENCE,
       COALESCE(baer.INTACCT_BANK_ACCOUNT_ID,
                CONCAT('GL# ', baer.INTACCT_UNDEPFUNDSACCT))                                                 AS DEPOSIT_TO,
       pmt.NAME                                                                                              AS PAYMENT_METHOD_TYPE,
       p.AMOUNT,
       p.AMOUNT_REMAINING
FROM ES_WAREHOUSE.PUBLIC.PAYMENTS p
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES co ON p.COMPANY_ID = co.COMPANY_ID
         LEFT JOIN billing_prefs ON co.COMPANY_ID = billing_prefs.COMPANY_ID
    LEFT JOIN max_pmt_date ON co.COMPANY_ID = max_pmt_date.COMPANY_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_METHOD_TYPES pmt ON p.PAYMENT_METHOD_TYPE_ID = pmt.PAYMENT_METHOD_TYPE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS baer ON p.BANK_ACCOUNT_ID = baer.BANK_ACCOUNT_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l ON co.BILLING_LOCATION_ID = l.LOCATION_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES s ON l.STATE_ID = s.STATE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u On u.user_id = co.owner_user_id
         LEFT JOIN (SELECT DISTINCT CCA.COMPANY_ID                                AS CUSTOMER_ID,
                                    CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS MARKET,
                                    CASE
                                        WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL'
                                        ELSE CCA.FINAL_COLLECTOR END              AS COLLECTOR
                    FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                             LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                       ON CCA.COMPANY_ID = COGL.CUSTOMER_ID) col
                   ON TRY_TO_NUMBER(p.COMPANY_ID) = col.CUSTOMER_ID
WHERE 1 = 1
--   AND p.COMPANY_ID = 22512
  AND AMOUNT_REMAINING > 0 ;;
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

  dimension: managed_billing {
    type: yesno
    label: "Managed Billing"
    sql: ${TABLE}."MANAGED_BILLING_PREFERENCE" ;;
  }

  dimension: specialized_billing {
    type: yesno
    label: "Specialized Billing"
    sql: ${TABLE}."SPECIALIZED_BILLING_PREFERENCE" ;;
  }

  dimension: last_pmt_date {
    type: date
    label: "Company Last Payment Date"
    sql: ${TABLE}."MOST_RECENT_PMT_DATE" ;;
  }

  dimension: company_url {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/companies/',${TABLE}."COMPANY_ID") ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: payment_id {
    type: string
    primary_key: yes
    label: "Payment ID"
    sql: ${TABLE}."PAYMENT_ID" ;;
    html: <a href="{{ payment_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: payment_url {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/payments/',${TABLE}."PAYMENT_ID") ;;
  }

  dimension: status {
    type: string
    label: "Status"
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: date {
    type: date
    label: "Date"
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date_group {
    type: time
    label: "Date Group"
    timeframes: [date, month, year]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: reference {
    type: string
    label: "Reference"
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: deposit_to {
    type: string
    label: "Deposit To"
    sql: ${TABLE}."DEPOSIT_TO" ;;
  }

  dimension: payment_method_type {
    type: string
    label: "Payment Method Type"
    sql: ${TABLE}."PAYMENT_METHOD_TYPE" ;;
  }

  dimension: national_account {
    label: "National Account"
    type: yesno
    sql: ${TABLE}.NATIONAL_ACCOUNT ;;
  }

  dimension: has_msa {
    label: "Has MSA"
    type: yesno
    sql: ${TABLE}.HAS_MSA ;;
  }

  dimension: amount {
    type: number
    label: "Amount"
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: total_payment_amount {
    type: sum
    label: "Total Payment Amount"
    sql: ${amount} ;;
  }

  dimension: amount_remaining {
    type: number
    label: "Amount Remaining"
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
  }

  measure: total_unapplied_amount {
    type: sum
    label: "Total Unapplied Amount"
    sql: ${amount_remaining} ;;
  }

  drill_fields: [
    company_id,
    company_name,
    address,
    managed_billing,
    specialized_billing,
    last_pmt_date,
    collector,
    payment_id,
    status,
    date,
    reference,
    deposit_to,
    payment_method_type,
    amount,
    amount_remaining
  ]
}
