
view: v_parent_company_relationships {
  sql_table_name:analytics.bi_ops.v_parent_company_relationships ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: update_timestamp {
    type: time
    sql: ${TABLE}."UPDATE_TIMESTAMP" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_owner_user_id {
    type: string
    sql: ${TABLE}."COMPANY_OWNER_USER_ID" ;;
  }

  dimension: parent_company_id {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  }

  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }

  dimension: parent_company_owner_user_id {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_OWNER_USER_ID" ;;
  }

  dimension: test_parent_company_owner_user_id {
    type: string
    sql: ${TABLE}."TEST_PARENT_COMPANY_OWNER_USER_ID" ;;
  }

  dimension: allowed_users {
    type: string
    sql: ${TABLE}."ALLOWED_USERS" ;;
  }

  dimension: national_account {
    type: yesno
    sql: ${TABLE}."NATIONAL_ACCOUNT" ;;
  }

  set: detail {
    fields: [
        update_timestamp_time,
  company_id,
  company_name,
  company_owner_user_id,
  parent_company_id,
  parent_company_name,
  parent_company_owner_user_id,
  test_parent_company_owner_user_id,
  allowed_users,
  national_account
    ]
  }
}
