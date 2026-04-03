view: vic__dimensions {
  sql_table_name: "VIC_GOLD"."VIC__DIMENSIONS" ;;

  dimension: pk_dimension_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.pk_dimension_id ;;
    value_format_name: id
  }

  dimension: fk_source_dimension_id {
    type: number
    sql: ${TABLE}.fk_source_dimension_id ;;
    value_format_name: id
  }

  dimension: name_dim {
    type: string
    sql: ${TABLE}.name_dim ;;
  }

  dimension: name_dim_alt {
    type: string
    sql: ${TABLE}.name_dim_alt ;;
  }

  dimension: name_display {
    type: string
    sql: ${TABLE}.name_display ;;
  }

  dimension: type_dim {
    type: string
    sql: ${TABLE}.type_dim ;;
  }

  dimension: type_dim_name {
    type: string
    sql: ${TABLE}.type_dim_name ;;
  }

  dimension: type_dim_external_id {
    type: number
    sql: ${TABLE}.type_dim_external_id ;;
  }

  dimension: status_dimension {
    type: string
    sql: ${TABLE}.status_dimension ;;
  }

  dimension: name_environment {
    type: string
    sql: ${TABLE}.name_environment ;;
  }

  dimension: name_environment_alias {
    type: string
    sql: ${TABLE}.name_environment_alias ;;
  }

  dimension: fk_company_id_numeric {
    type: number
    sql: ${TABLE}.fk_company_id_numeric ;;
  }

  dimension: fk_company_id_uuid {
    type: number
    sql: ${TABLE}.fk_company_id_uuid ;;
    value_format_name: id
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_modified ;;
  }

  dimension_group: timestamp_source_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_source_modified ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_loaded ;;
  }
  measure: count {
    type: count
    drill_fields: [type_dim_name]
  }
}
