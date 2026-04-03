view: integrations_vic_fleet_sandbox__dimensions {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_FLEET_SANDBOX__DIMENSIONS" ;;

  dimension: name_dim {
    type: string
    sql: ${TABLE}."NAME_DIM" ;;
  }
  dimension: name_dim_short {
    type: string
    sql: ${TABLE}."NAME_DIM_SHORT" ;;
  }
  dimension: pk_dimension_id {
    type: string
    sql: ${TABLE}."PK_DIMENSION_ID" ;;
    primary_key: yes
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: type_dim_display {
    type: string
    sql: ${TABLE}."TYPE_DIM_DISPLAY" ;;
  }
  dimension: type_dim_name {
    type: string
    sql: ${TABLE}."TYPE_DIM_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [type_dim_name]
  }
}
