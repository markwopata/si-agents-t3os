
view: customer_region {
  sql_table_name: "ANALYTICS"."PUBLIC"."CUSTOMER_REGION"
    ;;


  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  measure: total_region {
    type: sum
    sql: ${region} ;;
  }

  measure: average_region {
    type: average
    sql: ${region} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
