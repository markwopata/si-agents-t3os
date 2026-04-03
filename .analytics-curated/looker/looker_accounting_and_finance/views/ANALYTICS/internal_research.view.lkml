view: internal_research {
  sql_table_name: "ANALYTICS"."TREASURY"."INTERNAL_RESEARCH" ;;

  dimension: admin_internal_company {
    type: string
    sql: ${TABLE}."ADMIN_INTERNAL_COMPANY" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ internal_research.customer_id }}/settings" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

}
