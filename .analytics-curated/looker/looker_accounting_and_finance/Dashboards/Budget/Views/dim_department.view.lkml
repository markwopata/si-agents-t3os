view: dim_department {
  sql_table_name: "CORPORATE_BUDGET"."DIM_DEPARTMENT"
    ;;

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: department_name {
    suggest_persist_for: "0 minutes"
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension_group: department_updated_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.CAST(${TABLE}."DEPARTMENT_UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: department_year {
    type: number
    sql: ${TABLE}."DEPARTMENT_YEAR" ;;
  }

  dimension: pk_department {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_DEPARTMENT" ;;
  }

  dimension: sub_department_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: sub_department_name {
    suggest_persist_for: "0 minutes"
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;
  }

  dimension: department_heads {
    type: string
    sql: ${TABLE}."DEPARTMENT_HEADS" ;;
  }

  dimension: sub_department_managers {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_MANAGERS" ;;
  }

  dimension_group: sub_department_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.CAST(${TABLE}."SUB_DEPARTMENT_UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: sub_department_year {
    type: number
    sql: ${TABLE}."SUB_DEPARTMENT_YEAR" ;;
  }

  dimension: ukg_cost_center {
    type: string
    sql: ${TABLE}."UKG_COST_CENTER" ;;
  }

  dimension: allowed_emails {
    type: string
    sql: ${TABLE}."ALLOWED_EMAILS" ;;
  }

  measure: count {
    type: count
    drill_fields: [sub_department_name, department_name]
  }
}
