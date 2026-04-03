view: compensation_details {
  sql_table_name: "LOOKER"."COMPENSATION_DETAILS" ;;

  dimension: credit {
    type: number
    sql: CASE WHEN ${TABLE}."CREDIT" IS NULL THEN 0 ELSE ${TABLE}."CREDIT"END;;
  }
  dimension: debit {
    type: number
    sql: CASE WHEN ${TABLE}."DEBIT" IS NULL THEN 0 ELSE ${TABLE}."DEBIT"END;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: gl_account_no {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: pay_component_category {
    type: string
    sql: ${TABLE}."PAY_COMPONENT_CATEGORY" ;;
  }
  dimension: pay_period_start {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_START" ;;
    hidden:  yes
  }
  dimension: pay_period_end{
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_END" ;;
    hidden:  yes
  }
  dimension: pay_date {
    type: date_raw
    sql: ${TABLE}."PAY_DATE" ;;
    hidden:  yes
  }

  dimension: position_effective_date {
    type: date_raw
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
    hidden:  yes
  }

  dimension: calc_primary_key {
    primary_key: yes
    sql:  concat(${employee_id},'',${pay_date},'',${gl_account_no},'',${pay_component_category},'',${intaact_code},'',${default_cost_centers_full_path},'',${employee_title},'',${debit},'',${pay_period_end},'',${first_name},'',${last_name},${pay_period_start},'',${credit}) ;;
  }

  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
