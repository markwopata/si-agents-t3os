view: existing_companies_mapping {
  sql_table_name: "ANALYTICS"."PROSPECTS"."EXISTING_COMPANIES_MAPPING"
    ;;

  dimension: company_folder {
    type: string
    sql: ${TABLE}."COMPANY_FOLDER" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: folder_id {
    type: string
    sql: ${TABLE}."FOLDER_ID" ;;
  }

  dimension: folder_name {
    type: string
    sql: ${TABLE}."FOLDER_NAME" ;;
  }

  dimension: folder_url {
    type: string
    sql: ${TABLE}."FOLDER_URL" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, folder_name]
  }
}
