view: dim_customers {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_CUSTOMERS" ;;

  dimension: company_contact_id {
    type: number
    sql: ${TABLE}."COMPANY_CONTACT_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }
  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_is_company {
    type: yesno
    sql: ${TABLE}."CUSTOMER_IS_COMPANY" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [contact_name, customer_name]
  }
}
