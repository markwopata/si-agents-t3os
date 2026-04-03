view: ff_out_rep_flex_value {
  sql_table_name: "DODGE"."FF_OUT_REP_FLEX_VALUE"
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

  dimension: flex_desc {
    type: string
    sql: ${TABLE}."FLEX_DESC" ;;
  }

  dimension: flex_value {
    type: number
    sql: ${TABLE}."FLEX_VALUE" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
