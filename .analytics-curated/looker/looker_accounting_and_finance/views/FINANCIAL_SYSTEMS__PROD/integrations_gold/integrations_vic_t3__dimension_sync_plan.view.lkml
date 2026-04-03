view: integrations_vic_t3__dimension_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__DIMENSION_SYNC_PLAN" ;;

  dimension: pk_dimension_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_DIMENSION_ID" ;;
  }

  dimension: name_dim {
    type: string
    sql: ${TABLE}."NAME_DIM" ;;
  }

  dimension: name_dim_short {
    type: string
    sql: ${TABLE}."NAME_DIM_SHORT" ;;
  }

  dimension: type_dim {
    type: string
    sql: ${TABLE}."TYPE_DIM" ;;
  }

  dimension: type_dim_display {
    type: string
    sql: ${TABLE}."TYPE_DIM_DISPLAY" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }

  measure: count {
    type: count
  }
}
