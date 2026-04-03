view: scd_asset_company {
  sql_table_name: "SCD"."SCD_ASSET_COMPANY"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_scd_company_id {
    type: number
    sql: ${TABLE}."ASSET_SCD_COMPANY_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: current_flag {
    type: number
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }

  dimension_group: date_end {
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
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_start {
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
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
