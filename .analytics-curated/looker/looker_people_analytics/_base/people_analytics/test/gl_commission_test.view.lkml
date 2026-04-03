
view: gl_commission_test {
  sql_table_name: "PEOPLE_ANALYTICS"."TEST"."GL_COMMISSION_TEST" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    hidden: yes
  }
  dimension: _gl_commission_report_pk {
    type: number
    sql: ${TABLE}."_GL_COMMISSION_REPORT_PK" ;;
  }
  dimension: cost_centers_full_path {
    type: string
    sql: ${TABLE}."COST_CENTERS_FULL_PATH" ;;
  }
  dimension: credit {
    type: number
    sql: ${TABLE}."CREDIT" ;;
  }
  dimension: debit {
    type: number
    sql: ${TABLE}."DEBIT" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: gl_account_no {
    type: number
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: gl_account_no_description {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  }
  dimension: intaact_code {
    type: number
    sql: ${TABLE}."INTAACT_CODE" ;;
  }
  dimension: pay_date {
    type: date_raw
    sql: ${TABLE}."PAY_DATE" ;;
    hidden: yes
  }
  measure: count {
    type: count
  }
}
