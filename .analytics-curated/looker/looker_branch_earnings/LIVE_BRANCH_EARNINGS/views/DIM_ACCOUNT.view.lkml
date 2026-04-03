view: DIM_ACCOUNT {
  sql_table_name: "BRANCH_EARNINGS"."DIM_ACCOUNT"
    ;;

  dimension: ACCOUNT_CODE {
    type: string
    sql: ${TABLE}."ACCOUNT_CODE" ;;
  }

  dimension: ACCOUNT_NUMBER {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: ACCOUNT_REV_EXP {
    type: string
    sql: ${TABLE}."ACCOUNT_REV_EXP" ;;
  }

  dimension: ACCOUNT_SORT_GROUP {
    type: number
    hidden: yes
    sql: ${TABLE}."ACCOUNT_SORT_GROUP" ;;
  }

  dimension: ACCOUNT_TYPE {
    type: string
    order_by_field: ACCOUNT_SORT_GROUP
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: DEPARTMENT {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: GL_ACCOUNT {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: KPI_GROUP_CODE {
    type: string
    sql: ${TABLE}."KPI_GROUP_CODE" ;;
  }

  dimension: PK_ACCOUNT {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_ACCOUNT" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF ACCOUNTS"
    drill_fields: [ACCOUNT_TYPE, ACCOUNT_CODE, ACCOUNT_NUMBER, ACCOUNT_SORT_GROUP, GL_ACCOUNT, DEPARTMENT, ACCOUNT_REV_EXP]
  }
}
