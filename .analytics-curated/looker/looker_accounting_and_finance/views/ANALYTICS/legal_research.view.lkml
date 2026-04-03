view: legal_research {
  sql_table_name: "TREASURY"."LEGAL_RESEARCH" ;;

  dimension: admin_legal {
    type: string
    sql: ${TABLE}."ADMIN_LEGAL" ;;
  }
  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ legal_research.customer_id }}/settings" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }
  measure: count {
    type: count
    drill_fields: [customer_name]
  }
}
