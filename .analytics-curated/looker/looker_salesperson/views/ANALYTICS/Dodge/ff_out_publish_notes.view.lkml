view: ff_out_publish_notes {
  sql_table_name: "DODGE"."FF_OUT_PUBLISH_NOTES"
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

  dimension: publish_notes {
    type: string
    sql: ${TABLE}."PUBLISH_NOTES" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
