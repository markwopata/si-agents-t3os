view: DIM_WORK_ORDER {
  sql_table_name: "BRANCH_EARNINGS"."DIM_WORK_ORDER"
    ;;

  dimension: PK_WORK_ORDER {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK_WORK_ORDER" ;;
  }

  dimension: WORK_ORDER_ID {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: WORK_ORDER_DESCRIPTION {
    type: string
    sql: ${TABLE}."WORK_ORDER_DESCRIPTION" ;;
  }

  dimension: WORK_ORDER_STATUS {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS" ;;
  }

  dimension: WORK_ORDER_TYPE_NAME {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }

  dimension: URGENCY_LEVEL_NAME {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL_NAME" ;;
  }

  dimension: SEVERITY_LEVEL_NAME {
    type: string
    sql: ${TABLE}."SEVERITY_LEVEL_NAME" ;;
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
    label: "NUMBER OF WORK ORDERS"
    drill_fields: [WORK_ORDER_ID, WORK_ORDER_TYPE_NAME, WORK_ORDER_STATUS, WORK_ORDER_DESCRIPTION, URGENCY_LEVEL_NAME, SEVERITY_LEVEL_NAME]
  }
}
