view: intacct_vendor_pay_method {
  derived_table: {
    sql: SELECT
          VEND.VENDORID                                                                                   AS VENDOR_ID,
          VEND.NAME                                                                                       AS VENDOR_NAME,
          CASE
              WHEN VEND.PAYMETHODREC = 1 THEN 'Check'
              ELSE CASE
                       WHEN VEND.PAYMETHODREC = 3 THEN 'Credit Card'
                       ELSE CASE
                                WHEN VEND.PAYMETHODREC = 6 THEN 'Cash'
                                ELSE CASE WHEN VEND.PAYMETHODREC = 12 THEN 'ACH' ELSE '-' END END END END AS PREF_PAY_METHOD,
          CASE
              WHEN VEND.ALT_PAY_METHOD IS NOT NULL THEN 'FifthThird Epay'
              ELSE PREF_PAY_METHOD END                                                                    AS PREF_PAY_METHOD_2,
          VEND.TERMNAME                                                                                   AS PMT_TERMS,
          VEND.ALT_PAY_METHOD                                                                             AS ALT_PAY_METHOD,
          VEND.ALT_PAY_DUE_DATE_DEDUCTION                                                                 AS ALT_PAY_DUE_DATE_DEDUCTION,
          VEND.EPAY_INTEREST                                                                              AS INTEREST_IN_EPAY,
          VEND.STATUS                                                                                     AS VENDOR_STATUS,
          VEND.WHENCREATED                                                                                AS WHEN_CREATED,
          VEND.VENDOR_CATEGORY                                                                            AS VENDOR_CATEGORY,
          UPPER(CONCAT(COALESCE(DISP_CONT.FIRSTNAME, ''), ' ',
                       COALESCE(DISP_CONT.LASTNAME, '')))                                                 AS PRIM_NAME,
          DISP_CONT.MAILADDRESS_ADDRESS1                                                                  AS PRIM_MAIL_ADDRESS_1,
          DISP_CONT.MAILADDRESS_ADDRESS2                                                                  AS PRIM_MAIL_ADDRESS_2,
          DISP_CONT.MAILADDRESS_CITY                                                                      AS PRIM_CITY,
          DISP_CONT.MAILADDRESS_STATE                                                                     AS PRIM_STATE,
          DISP_CONT.EMAIL1                                                                                AS PRIM_EMAIL_1,
          DISP_CONT.EMAIL2                                                                                AS PRIM_EMAIL_2,
          DISP_CONT.PHONE1                                                                                AS PRIM_PHONE_1,
          DISP_CONT.PHONE2                                                                                AS PRIM_PHONE_2,
          DISP_CONT.MAILADDRESS_ZIP                                                                       AS PRIM_ZIP,
          DISP_CONT.MAILADDRESS_COUNTRY                                                                   AS PRIM_COUNTRY,
          UPPER(CONCAT(COALESCE(PAY_TO_CONT.FIRSTNAME, ''), ' ',
                       COALESCE(PAY_TO_CONT.LASTNAME, '')))                                               AS PAY_TO_NAME,
          PAY_TO_CONT.MAILADDRESS_ADDRESS1                                                                AS PAY_TO_MAIL_ADDRESS_1,
          PAY_TO_CONT.MAILADDRESS_ADDRESS2                                                                AS PAY_TO_MAIL_ADDRESS_2,
          PAY_TO_CONT.MAILADDRESS_CITY                                                                    AS PAY_TO_CITY,
          PAY_TO_CONT.MAILADDRESS_STATE                                                                   AS PAY_TO_STATE,
          PAY_TO_CONT.EMAIL1                                                                              AS PAY_TO_EMAIL_1,
          PAY_TO_CONT.EMAIL2                                                                              AS PAY_TO_EMAIL_2,
          PAY_TO_CONT.PHONE1                                                                              AS PAY_TO_PHONE_1,
          PAY_TO_CONT.PHONE2                                                                              AS PAY_TO_PHONE_2,
          PAY_TO_CONT.MAILADDRESS_ZIP                                                                     AS PAY_TO_ZIP,
          PAY_TO_CONT.MAILADDRESS_COUNTRY                                                                 AS PAY_TO_COUNTRY
      FROM
          ANALYTICS.INTACCT.VENDOR VEND
              LEFT JOIN ANALYTICS.INTACCT.CONTACT DISP_CONT ON VEND.DISPLAYCONTACTKEY = DISP_CONT.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.CONTACT PAY_TO_CONT ON VEND.DISPLAYCONTACTKEY = PAY_TO_CONT.RECORDNO
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

  dimension: pref_pay_method {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD" ;;
  }

  dimension: pref_pay_method_2 {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD_2" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: pmt_terms {
    type: string
    sql: ${TABLE}."PMT_TERMS" ;;
  }

  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}."ALT_PAY_METHOD" ;;
  }

  dimension: negotiated_pay_terms_deduction {
    type: string
    sql: ${TABLE}."ALT_PAY_DUE_DATE_DEDUCTION" ;;
  }

  dimension: interest_in_epay {
    type: string
    sql: ${TABLE}."INTEREST_IN_EPAY" ;;
  }

  dimension: vendor_status {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension_group: when_created {
    type: time
    sql: ${TABLE}."WHEN_CREATED" ;;
  }

  dimension: prim_name {
    type: string
    sql: ${TABLE}."PRIM_NAME" ;;
  }

  dimension: prim_mail_address_1 {
    type: string
    sql: ${TABLE}."PRIM_MAIL_ADDRESS_1" ;;
  }

  dimension: prim_mail_address_2 {
    type: string
    sql: ${TABLE}."PRIM_MAIL_ADDRESS_2" ;;
  }

  dimension: prim_city {
    type: string
    sql: ${TABLE}."PRIM_CITY" ;;
  }

  dimension: prim_state {
    type: string
    sql: ${TABLE}."PRIM_STATE" ;;
  }

  dimension: prim_email_1 {
    type: string
    sql: ${TABLE}."PRIM_EMAIL_1" ;;
  }

  dimension: prim_email_2 {
    type: string
    sql: ${TABLE}."PRIM_EMAIL_2" ;;
  }

  dimension: prim_phone_1 {
    type: string
    sql: ${TABLE}."PRIM_PHONE_1" ;;
  }

  dimension: prim_phone_2 {
    type: string
    sql: ${TABLE}."PRIM_PHONE_2" ;;
  }

  dimension: prim_zip {
    type: string
    sql: ${TABLE}."PRIM_ZIP" ;;
  }

  dimension: prim_country {
    type: string
    sql: ${TABLE}."PRIM_COUNTRY" ;;
  }

  dimension: pay_to_name {
    type: string
    sql: ${TABLE}."PAY_TO_NAME" ;;
  }

  dimension: pay_to_mail_address_1 {
    type: string
    sql: ${TABLE}."PAY_TO_MAIL_ADDRESS_1" ;;
  }

  dimension: pay_to_mail_address_2 {
    type: string
    sql: ${TABLE}."PAY_TO_MAIL_ADDRESS_2" ;;
  }

  dimension: pay_to_city {
    type: string
    sql: ${TABLE}."PAY_TO_CITY" ;;
  }

  dimension: pay_to_state {
    type: string
    sql: ${TABLE}."PAY_TO_STATE" ;;
  }

  dimension: pay_to_email_1 {
    type: string
    sql: ${TABLE}."PAY_TO_EMAIL_1" ;;
  }

  dimension: pay_to_email_2 {
    type: string
    sql: ${TABLE}."PAY_TO_EMAIL_2" ;;
  }

  dimension: pay_to_phone_1 {
    type: string
    sql: ${TABLE}."PAY_TO_PHONE_1" ;;
  }

  dimension: pay_to_phone_2 {
    type: string
    sql: ${TABLE}."PAY_TO_PHONE_2" ;;
  }

  dimension: pay_to_zip {
    type: string
    sql: ${TABLE}."PAY_TO_ZIP" ;;
  }

  dimension: pay_to_country {
    type: string
    sql: ${TABLE}."PAY_TO_COUNTRY" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      pref_pay_method,
      pref_pay_method_2,
      interest_in_epay,
      pmt_terms,
      alt_pay_method,
      vendor_status,
      when_created_time,
      prim_name,
      prim_mail_address_1,
      prim_mail_address_2,
      prim_city,
      prim_state,
      prim_email_1,
      prim_email_2,
      prim_phone_1,
      prim_phone_2,
      prim_zip,
      prim_country,
      pay_to_name,
      pay_to_mail_address_1,
      pay_to_mail_address_2,
      pay_to_city,
      pay_to_state,
      pay_to_email_1,
      pay_to_email_2,
      pay_to_phone_1,
      pay_to_phone_2,
      pay_to_zip,
      pay_to_country
    ]
  }
}
