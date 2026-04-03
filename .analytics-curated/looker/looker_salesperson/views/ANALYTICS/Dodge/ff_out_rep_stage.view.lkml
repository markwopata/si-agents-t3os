view: ff_out_rep_stage {
  sql_table_name: "DODGE"."FF_OUT_REP_STAGE"
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

  dimension: stage_code {
    type: string
    sql: ${TABLE}."STAGE_CODE" ;;
  }

  dimension: stage_desc {
    type: string
    sql: ${TABLE}."STAGE_DESC" ;;
  }

  dimension: action_stage {
    type: string
    sql: ${stage_desc} ;;
  }

  dimension: stage_desc_pi {
    type: string
    sql: ${TABLE}."STAGE_DESC_PI" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
