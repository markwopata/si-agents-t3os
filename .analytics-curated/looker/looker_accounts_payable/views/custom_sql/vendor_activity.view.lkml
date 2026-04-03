view: vendor_activity {
  derived_table: {
    sql: SELECT
          V.VENDORID                                                                                                       AS VENDOR_ID,
          V.NAME                                                                                                           AS VENDOR_NAME,
          V.COMPANY_LEGAL_NAME                                                                                             AS LEGAL_NAME,
          CONTACT.MAILADDRESS_ADDRESS1                                                                                     AS ADDRESS_LINE_1,
          CONTACT.MAILADDRESS_ADDRESS2                                                                                     AS ADDRESS_LINE_2,
          CONTACT.MAILADDRESS_ZIP                                                                                          AS ZIP,
          CONTACT.MAILADDRESS_COUNTRY                                                                                      AS COUNTRY,
          V.VENDTYPE                                                                                                       AS VENDOR_TYPE,
          V.FORM1099TYPE AS FORM_1099_TYPE,
          V.FORM1099BOX AS FORM_1099_BOX,
          V.VENDOR_CATEGORY                                                                                                AS VENDOR_CATEGORY,
          V.DIVERSITY_CLASSIFICATION                                                                                       AS DIVERSITY_CLASS,
          V.REPORTING_CATEGORY                                                                                             AS REPORTING_CATEGORY,
          CASE WHEN V.REQUIRES_COI THEN 'Yes' ELSE 'No' END                                                                AS REQUIRES_COI,
          V.TERMNAME                                                                                                       AS TERMS,
    CASE
        WHEN V.ALT_PAY_METHOD = 'FifthThird Epay' THEN 'FifthThird Epay'
        ELSE
            CASE
                WHEN V.PAYMETHODREC = 1 THEN 'Printed Check'
                ELSE CASE
                         WHEN V.PAYMETHODREC = 12 THEN 'ACH/Bank File'
                         ELSE CASE
                                  WHEN V.PAYMETHODREC = 3 THEN 'Credit Card'
                                  ELSE CASE WHEN V.PAYMETHODREC = 6 THEN 'Cash' ELSE '-' END END END END END AS PAY_METHOD,
          DUE.TOTAL_DUE                                                                                                    AS TOTAL_DUE,
          V.STATUS                                                                                                         AS VENDOR_STATUS,
          V.APPROVED_ENTITIES                                                                                              AS
            APPROVED_ENTITIES,
          CASE WHEN CAST(V.ONETIME AS BOOLEAN) THEN 'Yes' ELSE 'No' END                                                    AS ONE_TIME,
          COALESCE(CONTACT.MAILADDRESS_CITY, PAY_TO_CONT.MAILADDRESS_CITY)                                                 AS CITY,
          COALESCE(CONTACT.MAILADDRESS_STATE, PAY_TO_CONT.MAILADDRESS_STATE)                                               AS STATE,
          CAST(CONVERT_TIMEZONE('America/Chicago', V.WHENCREATED) AS DATE)                                                 AS VENDOR_CREATED,
          CAST(LAST_BILL.LAST_BILLED AS DATE)                                                                              AS LAST_BILLED,
          CAST(LAST_PO.LAST_PO_DATE AS DATE)                                                                               AS LAST_PO,
          CAST(APP.LASTPAID AS DATE)                                                                                       AS LAST_PAYMENT,
          GREATEST(CAST(CONVERT_TIMEZONE('America/Chicago', V.WHENCREATED) AS DATE),
                   COALESCE(CAST(LAST_BILL.LAST_BILLED AS DATE),
                            CAST(CONVERT_TIMEZONE('America/Chicago', V.WHENCREATED) AS DATE)),
                   COALESCE(CAST(LAST_PO.LAST_PO_DATE AS DATE),
                            CAST(CONVERT_TIMEZONE('America/Chicago', V.WHENCREATED) AS DATE)),
                   COALESCE(CAST(APP.LASTPAID AS DATE),
                            CAST(CONVERT_TIMEZONE('America/Chicago', V.WHENCREATED) AS DATE)))                             AS LAST_ACTIVITY
      FROM
          ANALYTICS.INTACCT.VENDOR V
              LEFT JOIN(SELECT
                            APR.VENDORID,
                            MAX(APR.WHENCREATED) AS LAST_BILLED
                        FROM
                            ANALYTICS.INTACCT.APRECORD APR
                        WHERE
                            APR.RECORDTYPE = 'apbill'
                        GROUP BY
                            APR.VENDORID) LAST_BILL ON V.VENDORID = LAST_BILL.VENDORID
              LEFT JOIN(SELECT
                            LAST_PO.VENDOR_ID,
                            MAX(LAST_PO.LAST_PO_DATE) LAST_PO_DATE
                        FROM
                            (SELECT
                                 VEND.EXTERNAL_ERP_VENDOR_REF                                              AS VENDOR_ID,
                                 CAST(CONVERT_TIMEZONE('America/Chicago', MAX(CCPO.DATE_CREATED)) AS DATE) AS LAST_PO_DATE
                             FROM
                                 PROCUREMENT.PUBLIC.PURCHASE_ORDERS CCPO
                                     LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS VEND
                                               ON CCPO.VENDOR_ID = VEND.ENTITY_ID
                             GROUP BY
                                 VEND.EXTERNAL_ERP_VENDOR_REF

      UNION

      SELECT
      INTPO.CUSTVENDID AS VENDOR_ID,
      MAX(WHENCREATED) AS LAST_PO_DATE
      FROM
      ANALYTICS.INTACCT.PODOCUMENT INTPO
      WHERE
      INTPO.DOCPARID IN ('Purchase Order', 'Purchase Order Entry')
      AND INTPO.T3_PR_CREATED_BY IS NULL
      GROUP BY
      INTPO.CUSTVENDID) LAST_PO
      GROUP BY
      LAST_PO.VENDOR_ID) LAST_PO ON V.VENDORID = LAST_PO.VENDOR_ID
      LEFT JOIN (SELECT
      APR.VENDORID,
      SUM(APR.TOTALDUE) AS TOTAL_DUE
      FROM
      ANALYTICS.INTACCT.APRECORD APR
      GROUP BY
      APR.VENDORID) DUE ON V.VENDORID = DUE.VENDORID
      LEFT JOIN ANALYTICS.INTACCT.CONTACT CONTACT ON V.DISPLAYCONTACTKEY = CONTACT.RECORDNO
      LEFT JOIN ANALYTICS.INTACCT.CONTACT PAY_TO_CONT ON V.PAYTOKEY = PAY_TO_CONT.RECORDNO
      LEFT JOIN (SELECT
      APPAY.VENDORID,
      MAX(APPAY.WHENCREATED) AS LASTPAID
      FROM
      ANALYTICS.INTACCT.APRECORD APPAY
      WHERE
      APPAY.RECORDTYPE = 'appayment'
      GROUP BY
      APPAY.VENDORID) AS APP
      ON V.VENDORID = APP.VENDORID
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: legal_name {
    type: string
    sql: ${TABLE}."LEGAL_NAME" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }

  dimension: form_1099_box {
    type: number
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: diversity_class {
    type: string
    sql: ${TABLE}."DIVERSITY_CLASS" ;;
  }

  dimension: reporting_category {
    type: string
    sql: ${TABLE}."REPORTING_CATEGORY" ;;
  }

  dimension: requires_coi {
    type: string
    sql: ${TABLE}."REQUIRES_COI" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: pay_method {
    type: string
    sql: ${TABLE}."PAY_METHOD" ;;
  }

  dimension: total_due {
    type: number
    sql: ${TABLE}."TOTAL_DUE" ;;
  }

  dimension: vendor_status {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension: approved_entities {
    type: string
    sql: ${TABLE}."APPROVED_ENTITIES" ;;
  }

  dimension: one_time {
    type: string
    sql: ${TABLE}."ONE_TIME" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: vendor_created {
    convert_tz:  no
    type: date
    sql: ${TABLE}."VENDOR_CREATED" ;;
  }

  dimension: last_billed {
    convert_tz:  no
    type: date
    sql: ${TABLE}."LAST_BILLED" ;;
  }

  dimension: last_po {
    convert_tz:  no
    type: date
    sql: ${TABLE}."LAST_PO" ;;
  }

  dimension: last_payment {
    convert_tz:  no
    type: date
    sql: ${TABLE}."LAST_PAYMENT" ;;
  }

  dimension: last_activity {
    convert_tz:  no
    type: date
    sql: ${TABLE}."LAST_ACTIVITY" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      legal_name,
      address_line_1,
      address_line_2,
      zip,
      country,
      vendor_type,
      form_1099_type,
      form_1099_box,
      vendor_category,
      diversity_class,
      reporting_category,
      requires_coi,
      terms,
      pay_method,
      total_due,
      vendor_status,
      approved_entities,
      one_time,
      city,
      state,
      vendor_created,
      last_billed,
      last_po,
      last_payment,
      last_activity
    ]
  }
}
