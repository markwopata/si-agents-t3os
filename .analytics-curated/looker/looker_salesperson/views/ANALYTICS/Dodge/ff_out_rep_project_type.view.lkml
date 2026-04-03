view: ff_out_rep_project_type {
  sql_table_name: "DODGE"."FF_OUT_REP_PROJECT_TYPE"
    ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
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
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}."DR_NBR" ;;
  }

  dimension: dr_ver {
    type: number
    sql: ${TABLE}."DR_VER" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  dimension: proj_type {
    type: string
    sql: ${TABLE}."PROJ_TYPE" ;;
  }

  dimension: proj_type_code {
    type: number
    sql: ${TABLE}."PROJ_TYPE_CODE" ;;
  }

  dimension: proj_type_pi {
    type: string
    sql: ${TABLE}."PROJ_TYPE_PI" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
