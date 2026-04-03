view: v_dim_stage {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_STAGE" ;;

  dimension: stage_active {
    type: yesno
    sql: ${TABLE}."STAGE_ACTIVE" ;;
  }
  dimension: stage_id {
    type: number
    sql: ${TABLE}."STAGE_ID" ;;
  }
  dimension: stage_job_id {
    type: number
    sql: ${TABLE}."STAGE_JOB_ID" ;;
  }
  dimension: stage_key {
    type: number
    sql: ${TABLE}."STAGE_KEY" ;;
  }
  dimension: stage_name {
    type: string
    sql: ${TABLE}."STAGE_NAME" ;;
  }
  dimension: stage_priority {
    type: number
    sql: ${TABLE}."STAGE_PRIORITY" ;;
  }
  measure: count {
    type: count
    drill_fields: [stage_name]
  }
}
