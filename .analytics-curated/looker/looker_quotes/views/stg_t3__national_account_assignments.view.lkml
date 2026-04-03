view: stg_t3__national_account_assignments {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__NATIONAL_ACCOUNT_ASSIGNMENTS" ;;

  dimension: account_folder_url {
    type: string
    sql: ${TABLE}."ACCOUNT_FOLDER_URL" ;;
  }
  dimension: commissioned_nam {
    type: string
    sql: ${TABLE}."COMMISSIONED_NAM" ;;
  }
  dimension: commissioned_nam_email {
    type: string
    sql: ${TABLE}."COMMISSIONED_NAM_EMAIL" ;;
  }
  dimension: commissioned_nam_user_id {
    type: number
    sql: ${TABLE}."COMMISSIONED_NAM_USER_ID" ;;
  }
  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: coordinator_user_id {
    type: number
    sql: ${TABLE}."COORDINATOR_USER_ID" ;;
  }
  dimension: effective_nam {
    label: "National Account Manager"
    type: string
    sql: ${TABLE}."EFFECTIVE_NAM" ;;
  }
  dimension: effective_nam_email {
    type: string
    sql: ${TABLE}."EFFECTIVE_NAM_EMAIL" ;;
  }
  dimension: effective_nam_user_id {
    type: number
    sql: ${TABLE}."EFFECTIVE_NAM_USER_ID" ;;
  }
  dimension: gsa {
    type: string
    sql: ${TABLE}."GSA" ;;
  }
  dimension: managed_billing {
    type: string
    sql: ${TABLE}."MANAGED_BILLING" ;;
  }
  dimension: nac_2 {
    type: string
    sql: ${TABLE}."NAC_2" ;;
  }
  dimension: nac_2_user_id {
    type: number
    sql: ${TABLE}."NAC_2_USER_ID" ;;
  }
  dimension: nac_3 {
    type: string
    sql: ${TABLE}."NAC_3" ;;
  }
  dimension: nac_3_user_id {
    type: number
    sql: ${TABLE}."NAC_3_USER_ID" ;;
  }
  dimension: national_account_coordinator {
    type: string
    sql: ${TABLE}."NATIONAL_ACCOUNT_COORDINATOR" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  }
  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: sales_director {
    type: string
    sql: ${TABLE}."SALES_DIRECTOR" ;;
  }
  dimension: sales_director_user_id {
    type: number
    sql: ${TABLE}."SALES_DIRECTOR_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [parent_company_name]
  }
}
