view: looker_user_permissions {
  sql_table_name: "ANALYTICS"."BI_OPS"."LOOKER_USER_PERMISSIONS" ;;

  dimension: looker_user_dccfp_department {
    type: string
    sql: ${TABLE}."LOOKER_USER_DCCFP_DEPARTMENT" ;;
  }

  dimension: looker_user_dccfp_district {
    type: string
    sql: ${TABLE}."LOOKER_USER_DCCFP_DISTRICT" ;;
  }

  dimension: looker_user_dccfp_region {
    type: string
    sql: ${TABLE}."LOOKER_USER_DCCFP_REGION" ;;
  }

  dimension: looker_user_email_address {
    type: string
    sql: ${TABLE}."LOOKER_USER_EMAIL_ADDRESS" ;;
  }

  dimension: looker_user_employee_id {
    type: number
    sql: ${TABLE}."LOOKER_USER_EMPLOYEE_ID" ;;
  }

  dimension: looker_user_employee_title {
    type: string
    sql: ${TABLE}."LOOKER_USER_EMPLOYEE_TITLE" ;;
  }

  dimension: looker_user_full_preferred_name {
    type: string
    sql: ${TABLE}."LOOKER_USER_FULL_PREFERRED_NAME" ;;
  }

  dimension: looker_user_manager_access_emails {
    type: string
    sql: ${TABLE}."LOOKER_USER_MANAGER_ACCESS_EMAILS" ;;
  }

  dimension: looker_user_manager_email {
    type: string
    sql: ${TABLE}."LOOKER_USER_MANAGER_EMAIL" ;;
  }

  dimension: looker_user_market_district {
    type: string
    sql: ${TABLE}."LOOKER_USER_MARKET_DISTRICT" ;;
  }

  dimension: looker_user_market_id {
    type: number
    sql: ${TABLE}."LOOKER_USER_MARKET_ID" ;;
  }

  dimension: looker_user_market_key {
    type: string
    sql: ${TABLE}."LOOKER_USER_MARKET_KEY" ;;
  }

  dimension: looker_user_market_region {
    type: number
    sql: ${TABLE}."LOOKER_USER_MARKET_REGION" ;;
  }

  dimension: looker_user_t3_user_id {
    type: number
    sql: ${TABLE}."LOOKER_USER_T3_USER_ID" ;;
  }

  dimension: looker_user_user_id_list_agg {
    type: string
    sql: ${TABLE}."LOOKER_USER_USER_ID_LIST_AGG" ;;
  }

  measure: count {
    type: count
    drill_fields: [looker_user_full_preferred_name]
  }

}
