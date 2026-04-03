view: ap_aging_intacct {
  derived_table: {
    sql: SELECT
          APH.VENDORID                                  AS VENDOR_ID,
          VEND.NAME                                     AS VENDOR_NAME,
          CASE WHEN VEND.REPORTING_CATEGORY = 'Related Party' THEN 'Yes' ELSE '-' END AS RELATED_PARTY,
          APH.RECORDID                                  AS BILL_NUMBER,
          APH.WHENCREATED                               AS BILL_DATE,
          APH.TERMNAME                                  AS TERMS,
          BTCONT.MAILADDRESS_COUNTRYCODE                AS COUNTRY,
          CASE
            WHEN APH.TRX_TOTALENTERED < 0 THEN CAST('1900-01-01' AS DATE)
            ELSE (APH.WHENDUE -
                  (COALESCE(
                          CASE WHEN VEND.ALT_PAY_METHOD = 'FifthThird Epay' THEN VEND.ALT_PAY_DUE_DATE_DEDUCTION ELSE 0 END,
                          0))) END                                            AS DUE_DATE,
          APD.TRX_AMOUNT                                AS TRANS_AMT,
              CASE
        WHEN APH.TRX_TOTALENTERED < 0 THEN '-'
        ELSE TO_CHAR(APH.WHENDUE -
              (COALESCE(
                      CASE WHEN VEND.ALT_PAY_METHOD = 'FifthThird Epay' THEN VEND.ALT_PAY_DUE_DATE_DEDUCTION ELSE 0 END,
                      0)),'MM/DD/YYYY') END                                            AS DUE_ON,
          COALESCE(SUBSTR(COALESCE(ITEM.NEW_ITEM_ID, APD.ITEMID), 2, 4), APD.ACCOUNTNO)                                 AS ACCOUNT_NUMBER,
          GLA.TITLE                                     AS ACCOUNT_TITLE,
          APD.DEPARTMENTID                              AS LOCATION_ID,
          DEPT.TITLE                                    AS LOCATION_NAME,
          APD.LOCATIONID                                AS ENTITY,
          APD.RECORDNO                                  AS LINE_RECORD_NUMBER,
          APD.TRX_AMOUNT - APD.TRX_TOTALPAID            AS TOTAL_DUE,
          COALESCE(VEND.ALT_PAY_METHOD, PM.DESCRIPTION) AS PREF_PAY_METHOD,
          APH.RECORDNO                                  AS RECORD_NUMBER,
          CASE
                  WHEN ((CASE
                  WHEN APH.TRX_TOTALENTERED < 0 THEN CAST('1900-01-01' AS DATE)
                  ELSE (APH.WHENDUE -
                        (COALESCE(
                                CASE WHEN VEND.ALT_PAY_METHOD = 'FifthThird Epay' THEN VEND.ALT_PAY_DUE_DATE_DEDUCTION ELSE 0 END,
                                0))) END) -
                        CURRENT_DATE) <= 0 THEN 'Due'
                  ELSE 'Not Due' END                                                AS IS_DUE,
              CASE WHEN APH.TRX_TOTALENTERED < 0 THEN 'CM' ELSE 'Bill' END AS DOCUMENT_TYPE,
              VEND_TOT_DUE.TOTAL_DUE                    AS VENDOR_DUE_SUBTOTAL

      FROM
        ANALYTICS.INTACCT.APRECORD APH
            LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
            LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
            LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON APD.DEPARTMENTID = DEPT.DEPARTMENTID
            LEFT JOIN ANALYTICS.INTACCT.NON_DDS_PAYMETHOD PM ON VEND.PAYMETHODREC = PM.PAYMETHODREC
            LEFT JOIN ANALYTICS.INTACCT.CONTACT BTCONT ON APH.BILLTOPAYTOCONTACTNAME = BTCONT.CONTACTNAME
            LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM ITEM ON APD.ITEMID = ITEM.OG_ITEM_ID
            LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA
                      ON COALESCE(SUBSTR(COALESCE(ITEM.NEW_ITEM_ID, APD.ITEMID), 2, 4), APD.ACCOUNTNO) = GLA.ACCOUNTNO
            LEFT JOIN (SELECT
                       APH.VENDORID                            AS VENDOR_ID,
                       SUM(APD.TRX_AMOUNT - APD.TRX_TOTALPAID) AS TOTAL_DUE
                   FROM
                       ANALYTICS.INTACCT.APRECORD APH
                           LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
                           LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
                   WHERE
                         APH.STATE NOT IN ('Selected', 'Complete', 'Paid', 'Reversed')
                     AND APH.ONHOLD = FALSE
                     AND VEND.ONHOLD = FALSE
                     AND APD.TRX_AMOUNT - APD.TRX_TOTALPAID - APD.TRX_TOTALSELECTED != 0
                     AND APH.RECORDID IS NOT NULL
                   GROUP BY
                       APH.VENDORID) VEND_TOT_DUE ON APH.VENDORID = VEND_TOT_DUE.VENDOR_ID
      WHERE
            APH.STATE NOT IN ('Selected', 'Complete','Paid', 'Reversed')
        AND APH.ONHOLD = FALSE
        AND VEND.ONHOLD = FALSE
                and vend.donotcutcheck = FALSE --kendall added aug 15 2024

        AND APD.TRX_AMOUNT - APD.TRX_TOTALPAID - APD.TRX_TOTALSELECTED != 0
        AND APH.RECORDID IS NOT NULL
      ORDER BY
          VEND.NAME ASC,
          APH.RECORDID ASC
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

  dimension: related_party {
    type: string
    sql: ${TABLE}."RELATED_PARTY" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: due_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  measure: trans_amt {
    type: sum
    sql: ${TABLE}."TRANS_AMT" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_title {
    type: string
    sql: ${TABLE}."ACCOUNT_TITLE" ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: line_record_number {
    type: number
    sql: ${TABLE}."LINE_RECORD_NUMBER" ;;
  }

  measure: total_due {
    type: sum
    sql: ${TABLE}."TOTAL_DUE" ;;
  }

  dimension: pref_pay_method {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD" ;;
  }

  dimension: record_number {
    type: number
    sql: ${TABLE}."RECORD_NUMBER" ;;
  }

  dimension: is_due {
    type: string
    sql: ${TABLE}."IS_DUE" ;;
  }

  dimension: document_type {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE" ;;
  }

  dimension: due_on {
    type: string
    sql: ${TABLE}."DUE_ON" ;;
  }

  dimension: vendor_due_subtotal {
    type: number
    sql: ${TABLE}."VENDOR_DUE_SUBTOTAL" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      related_party,
      bill_number,
      bill_date,
      terms,
      country,
      due_date,
      trans_amt,
      account_number,
      account_title,
      location_id,
      location_name,
      entity,
      line_record_number,
      total_due,
      pref_pay_method,
      record_number,
      is_due,
      document_type,
      due_on,
      vendor_due_subtotal
    ]
  }
}
