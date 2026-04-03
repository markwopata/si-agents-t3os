view: vic_sandbox__dimensions {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__DIMENSIONS" ;;

  dimension: fk_dbt_dimension_id {
    type: string
    sql: ${TABLE}."FK_DBT_DIMENSION_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: name_dim {
    type: string
    sql: ${TABLE}."NAME_DIM" ;;
  }
  dimension: name_dim_display {
    type: string
    sql: ${TABLE}."NAME_DIM_DISPLAY" ;;
  }
  dimension: name_dim_short {
    type: string
    sql: ${TABLE}."NAME_DIM_SHORT" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: pk_vic_dimension_id {
    type: string
    sql: ${TABLE}."PK_VIC_DIMENSION_ID" ;;
    primary_key: yes
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: type_dim {
    type: string
    sql: ${TABLE}."TYPE_DIM" ;;
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
