view: ff_out_rep_csi {
  sql_table_name: "DODGE"."FF_OUT_REP_CSI"
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

  dimension: csi_desc {
    type: string
    sql: ${TABLE}."CSI_DESC" ;;
  }

  dimension: csi_desc_code {
    type: number
    sql: ${TABLE}."CSI_DESC_CODE" ;;
  }

  dimension: csi_div_desc {
    type: string
    sql: ${TABLE}."CSI_DIV_DESC" ;;
  }

  dimension: csi_div_desc_code {
    type: number
    sql: ${TABLE}."CSI_DIV_DESC_CODE" ;;
  }

  dimension: csi_group_desc {
    type: string
    sql: ${TABLE}."CSI_GROUP_DESC" ;;
  }

  dimension: csi_group_desc_code {
    type: number
    sql: ${TABLE}."CSI_GROUP_DESC_CODE" ;;
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

  measure: count {
    type: count
    drill_fields: []
  }
}
