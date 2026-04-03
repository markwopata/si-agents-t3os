view: ff_out_rep_type_of_item {
  sql_table_name: "DODGE"."FF_OUT_REP_TYPE_OF_ITEM"
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

  dimension: item_type {
    type: string
    sql: ${TABLE}."ITEM_TYPE" ;;
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
