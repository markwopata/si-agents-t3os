view: ar_legal_report_customers {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_LEGAL_REPORT_CUSTOMERS" ;;

  ############# DIMENSIONS #############

  dimension: billing_contact_type {
    type: string
    sql: ${TABLE}."BILLING_CONTACT_TYPE" ;;
  }

  dimension: customer_contact_email_address {
    type: string
    sql: ${TABLE}."CUSTOMER_CONTACT_EMAIL_ADDRESS" ;;
  }

  dimension: customer_contact_name {
    type: string
    sql: ${TABLE}."CUSTOMER_CONTACT_NAME" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }


}
