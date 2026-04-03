view: duplicate_accounts_vendors {
  sql_table_name: "ANALYTICS"."TREASURY"."DUPLICATE_ACCOUNTS_VENDORS" ;;

########## DIMENSIONS ##########

  dimension: ach_account_key_count {
    label: "ACH Account Number Count"
    type: number
    sql: ${TABLE}."ACH_ACCOUNT_KEY_COUNT" ;;
  }

  dimension: achaccountnumber {
    type: string
    sql: ${TABLE}."ACHACCOUNTNUMBER" ;;
  }

  dimension: achbankroutingnumber {
    type: string
    sql: ${TABLE}."ACHBANKROUTINGNUMBER" ;;
  }

  dimension: noa {
    label: "NOA"
    type: yesno
    sql: ${TABLE}."NOA" ;;
  }

  dimension: pay_to_city {
    type: string
    sql: ${TABLE}."PAY_TO_CITY" ;;
  }

  dimension: pay_to_country {
    type: string
    sql: ${TABLE}."PAY_TO_COUNTRY" ;;
  }

  dimension: pay_to_email_1 {
    type: string
    sql: ${TABLE}."PAY_TO_EMAIL_1" ;;
  }

  dimension: pay_to_email_2 {
    type: string
    sql: ${TABLE}."PAY_TO_EMAIL_2" ;;
  }

  dimension: pay_to_mail_address_1 {
    type: string
    sql: ${TABLE}."PAY_TO_MAIL_ADDRESS_1" ;;
  }

  dimension: pay_to_mail_address_2 {
    type: string
    sql: ${TABLE}."PAY_TO_MAIL_ADDRESS_2" ;;
  }

  dimension: pay_to_name {
    type: string
    sql: ${TABLE}."PAY_TO_NAME" ;;
  }

  dimension: pay_to_phone_1 {
    type: string
    sql: ${TABLE}."PAY_TO_PHONE_1" ;;
  }

  dimension: pay_to_phone_2 {
    type: string
    sql: ${TABLE}."PAY_TO_PHONE_2" ;;
  }

  dimension: pay_to_state {
    type: string
    sql: ${TABLE}."PAY_TO_STATE" ;;
  }

  dimension: pay_to_zip {
    type: string
    sql: ${TABLE}."PAY_TO_ZIP" ;;
  }

  dimension: pref_pay_method {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD" ;;
  }

  dimension: pref_pay_method_2 {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD_2" ;;
  }

  dimension: prim_city {
    type: string
    sql: ${TABLE}."PRIM_CITY" ;;
  }

  dimension: prim_country {
    type: string
    sql: ${TABLE}."PRIM_COUNTRY" ;;
  }

  dimension: prim_email_1 {
    type: string
    sql: ${TABLE}."PRIM_EMAIL_1" ;;
  }

  dimension: prim_email_2 {
    type: string
    sql: ${TABLE}."PRIM_EMAIL_2" ;;
  }

  dimension: prim_mail_address_1 {
    type: string
    sql: ${TABLE}."PRIM_MAIL_ADDRESS_1" ;;
  }

  dimension: prim_mail_address_2 {
    type: string
    sql: ${TABLE}."PRIM_MAIL_ADDRESS_2" ;;
  }

  dimension: prim_name {
    type: string
    sql: ${TABLE}."PRIM_NAME" ;;
  }

  dimension: prim_phone_1 {
    type: string
    sql: ${TABLE}."PRIM_PHONE_1" ;;
  }

  dimension: prim_phone_2 {
    type: string
    sql: ${TABLE}."PRIM_PHONE_2" ;;
  }

  dimension: prim_state {
    type: string
    sql: ${TABLE}."PRIM_STATE" ;;
  }

  dimension: prim_zip {
    type: string
    sql: ${TABLE}."PRIM_ZIP" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: tax_id {
    label: "Last 4 Tax ID"
    type: string
    sql: ${TABLE}."TAX_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: ach_account_number {
    label: "Last 4 ACH Routing  - Account Number"
    type:  string
    sql: ${TABLE}."ACH_ACCOUNT_NUMBER" ;;
  }

  ########## MEASURES ##########

  measure: ytd_payment_amount {
    label: "YTD Payment Amount"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."YTD_PAYMENT_AMOUNT" ;;
  }

  ########## DRILL FIELDS ##########

  #set: drill_details {
  #  fields: [vendor_id,vendor_name,pref_pay_method_2,noa,tax_id,ach_account_number,
  #    pay_to_mail_address_1,pay_to_mail_address_2,pay_to_city,pay_to_state,pay_to_zip,pay_to_country,ach_account_key_count,ytd_payment_amount]
  #}

}
