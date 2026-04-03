view: potentially_duplicate_customers {
  sql_table_name: "ANALYTICS"."TREASURY"."POTENTIALLY_DUPLICATE_CUSTOMERS" ;;

  ##### DIMENSIONS #####

  dimension: billing_address {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS" ;;
  }

  dimension: dnr_customer_id {
    label: "DNR Customer ID"
    value_format_name: id
    type: number
    sql: ${TABLE}."DNR_CUSTOMER_ID" ;;
  }

  dimension: dnr_customer_name {
    label: "DNR Customer Name"
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ potentially_duplicate_customers.dnr_customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."DNR_CUSTOMER_NAME" ;;
  }

  dimension: match_type {
    type: string
    sql: ${TABLE}."MATCH_TYPE" ;;
  }

  dimension: non_dnr_customer_id {
    label: "Non DNR Customer ID"
    value_format_name: id
    type: number
    sql: ${TABLE}."NON_DNR_CUSTOMER_ID" ;;
  }

  dimension: non_dnr_customer_name {
    label: "Non DNR Customer Name"
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ potentially_duplicate_customers.non_dnr_customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."NON_DNR_CUSTOMER_NAME" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

}
