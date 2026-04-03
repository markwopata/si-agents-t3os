view: admin_credits {
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
SELECT c.COMPANY_ID,
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
       c.CREDIT_NOTE_NUMBER,
       c.CREDIT_NOTE_ID,
       c.REFERENCE,
       c.MEMO,
       CAST(c.DATE_CREATED AS DATE)                                                                          AS DATE_CREATED,
       c.TOTAL_CREDIT_AMOUNT,
       c.REMAINING_CREDIT_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.CREDIT_NOTES c
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES co ON c.COMPANY_ID = co.COMPANY_ID
         LEFT JOIN billing_prefs ON co.COMPANY_ID = billing_prefs.COMPANY_ID
         LEFT JOIN max_pmt_date ON co.COMPANY_ID = max_pmt_date.COMPANY_ID
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
                   ON TRY_TO_NUMBER(c.COMPANY_ID) = col.CUSTOMER_ID
WHERE 1 = 1
--   AND c.COMPANY_ID = 95817
  AND c.REMAINING_CREDIT_AMOUNT > 0
  AND c.CREDIT_NOTE_STATUS_ID = 2;;
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

  dimension: credit_note_number {
    type: string
    label: "Credit Note Number"
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
    html: <a href="{{ credit_note_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

    dimension: credit_note_url {
      type: string
      sql: CONCAT('https://admin.equipmentshare.com/#/home/transactions/credit-notes/',${TABLE}."CREDIT_NOTE_ID") ;;
    }

    dimension: credit_note_id {
      type: string
      primary_key: yes
      sql: ${TABLE}."CREDIT_NOTE_ID" ;;
    }

    dimension: memo {
      type: string
      label: "Memo"
      sql: ${TABLE}."MEMO" ;;
    }

    dimension: date_created {
      type: date
      label: "Date Created"
      sql: ${TABLE}."DATE_CREATED" ;;
    }

    dimension_group: date_created_group {
      type: time
      label: "Date Created Group"
      timeframes: [date, month, year]
      sql: ${TABLE}."DATE_CREATED" ;;
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

    dimension: reference {
      type: string
      label: "Reference"
      sql: ${TABLE}."REFERENCE" ;;
    }

    dimension: credit_amount {
      type: number
      label: "Credit Amount"
      sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
    }

    measure: total_credit_amount {
      type: sum
      label: "Total Credit Amount"
      sql: ${credit_amount} ;;
    }

    dimension: amount_remaining {
      type: number
      label: "Amount Remaining"
      sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
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
      credit_note_number,
      date_created,
      reference,
      memo,
      credit_amount,
      amount_remaining
    ]
  }
