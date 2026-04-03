view: integrations_vic_t3__dimensions {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__DIMENSIONS" ;;

  dimension: pk_dimension_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_DIMENSION_ID" ;;
  }

  dimension: name_dim {
    type: string
    sql: ${TABLE}."NAME_DIM" ;;
  }

  dimension: name_dim_alt {
    type: string
    sql: ${TABLE}."NAME_DIM_ALT" ;;
  }

  dimension: type_dim {
    type: string
    sql: ${TABLE}."TYPE_DIM" ;;
  }

  dimension: type_dim_external_id {
    type: string
    sql: ${TABLE}."TYPE_DIM_EXTERNAL_ID" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  measure: count {
    type: count
  }
}
