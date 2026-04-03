view: ff_out_rep_county {
  sql_table_name: "DODGE"."FF_OUT_REP_COUNTY"
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

  dimension: dodge_county_name {
    type: string
    sql: ${TABLE}."DODGE_COUNTY_NAME" ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}."DR_NBR" ;;
  }

  dimension: dr_ver {
    type: number
    sql: ${TABLE}."DR_VER" ;;
  }

  dimension: p_fips_county {
    type: string
    sql: ${TABLE}."P_FIPS_COUNTY" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  dimension: std_county_name {
    type: string
    sql: ${TABLE}."STD_COUNTY_NAME" ;;
  }

  dimension: std_fips_code {
    type: number
    sql: ${TABLE}."STD_FIPS_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [dodge_county_name, std_county_name]
  }
}
