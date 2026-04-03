view: clustdoc_vendor_app_checks {
  sql_table_name: "P2P_GOLD"."CLUSTDOC_VENDOR_APP_CHECKS" ;;

  dimension: application_issue {
    type: string
    sql: ${TABLE}."APPLICATION_ISSUE" ;;
  }
  dimension: issue_value {
    type: string
    sql: ${TABLE}."ISSUE_VALUE" ;;
  }
  dimension: issue_value_description {
    type: string
    sql: ${TABLE}."ISSUE_VALUE_DESCRIPTION" ;;
  }
  dimension: pk_application_id {
    type: number
    sql: ${TABLE}."PK_APPLICATION_ID" ;;
  }
  measure: count {
    type: count
  }
}
