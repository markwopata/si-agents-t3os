view: ff_out_rep_item_code {
  sql_table_name: "DODGE"."FF_OUT_REP_ITEM_CODE"
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

  dimension: item_category {
    type: string
    sql: ${TABLE}."ITEM_CATEGORY" ;;
  }

  dimension: item_category_code {
    type: number
    sql: ${TABLE}."ITEM_CATEGORY_CODE" ;;
  }

  dimension: item_code {
    type: string
    sql: ${TABLE}."ITEM_CODE" ;;
  }

  dimension: item_value_code {
    type: number
    sql: ${TABLE}."ITEM_VALUE_CODE" ;;
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
