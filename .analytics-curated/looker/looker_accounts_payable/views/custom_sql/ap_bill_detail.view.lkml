view: ap_bill_detail {
  derived_table: {
    sql: SELECT
    APBH.VENDORID          AS VENDOR_ID,
    VEND.NAME              AS VENDOR_NAME,
    APBH.RECORDID          AS BILL_NUMBER,
    APBH.WHENCREATED       AS BILL_DATE,
    APBH.WHENPOSTED        AS GL_POSTING_DATE,
    APBH.WHENDUE           AS DUE_DATE,
    APBH.WHENPAID          AS PAID_DATE,
    APBH.TERMNAME          AS TERMS,
    APBH.DESCRIPTION       AS BILL_MEMO,
    URL.RECORD_URL         AS URL,
    APBH.DOCNUMBER         AS PO_NUMBER,
    APBD.LINE_NO           AS LINE_NO,
    APBD.ACCOUNTNO         AS ACCOUNT,
    GLA.TITLE              AS ACCOUNT_NAME,
    GLA.ACCOUNTTYPE        AS ACCOUNT_TYPE,
    GLA.CATEGORY           AS ACCOUNT_CATEGORY,
    GLA.CLOSINGTYPE        AS ACCOUNT_CLOSE_TYPE,
    GLA.NORMALBALANCE      AS ACCOUNT_NORMAL_BALANCE,
    APBD.DEPARTMENTID      AS BRANCH_ID,
    APBD.LOCATIONID        AS ENTITY,
    APBD.GLDIMEXPENSE_LINE AS EXP_LINE_ID,
    EL.NAME                AS EXP_LINE_NAME,
    APBD.ASSET_ID          AS ASSET_ID,
    APBD.AMOUNT            AS AMOUNT,
    APBD.ENTRYDESCRIPTION  AS LINE_MEMO,
    CASE
        WHEN APBH.SYSTEMGENERATED = 'T'
            THEN
            'Manual'
        ELSE
            CASE
                WHEN APBH.DESCRIPTION2 IS NOT NULL
                    THEN
                    CASE
                        WHEN APBH.YOOZ_DOCID IS NOT NULL
                            THEN 'Purchase Conversion by Yooz'
                        ELSE 'Purchase Conversion by Intacct'
                        END
                ELSE
                    CASE
                        WHEN APBH.YOOZ_DOCID IS NOT NULL
                            THEN 'Yooz AP Bill'
                        ELSE 'Direct AP Bill'
                        END
                END
        END                AS PROCESSING_METHOD
FROM
    ANALYTICS.INTACCT.APRECORD APBH
        LEFT JOIN ANALYTICS.INTACCT.APDETAIL APBD ON APBH.RECORDNO = APBD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APBH.VENDORID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON APBD.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN
        (SELECT
             RECORDNO,
             RECORD_URL
         FROM
             ANALYTICS.PUBLIC.RECORD_URL
         WHERE
             INTACCT_OBJECT = 'APBILL') URL ON APBH.RECORDNO = URL.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON APBD.GLDIMEXPENSE_LINE = EL.ID
WHERE
    APBH.RECORDTYPE = 'apbill'
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

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: gl_posting_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."GL_POSTING_DATE" ;;
  }

  dimension: due_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: paid_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: bill_memo {
    type: string
    sql: ${TABLE}."BILL_MEMO" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: line_no {
    type: string
    sql: ${TABLE}."LINE_NO" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  dimension: account_close_type {
    type: string
    sql: ${TABLE}."ACCOUNT_CLOSE_TYPE" ;;
  }

  dimension: account_normal_balance {
    type: string
    sql: ${TABLE}."ACCOUNT_NORMAL_BALANCE" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: processing_method {
    type: string
    sql: ${TABLE}."PROCESSING_METHOD" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: exp_line_id {
    type: string
    sql: ${TABLE}."EXP_LINE_ID" ;;
  }

  dimension: exp_line_name {
    type: string
    sql: ${TABLE}."EXP_LINE_NAME" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      bill_number,
      bill_date,
      gl_posting_date,
      due_date,
      paid_date,
      terms,
      bill_memo,
      url,
      po_number,
      line_no,
      account,
      account_name,
      account_type,
      account_category,
      account_close_type,
      account_normal_balance,
      branch_id,
      asset_id,
      entity,
      exp_line_id,
      exp_line_name,
      amount,
      line_memo,
      processing_method
    ]
  }
}
