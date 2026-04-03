view: scd_asset_rsp {
  sql_table_name: "SCD"."SCD_ASSET_RSP"
    ;;
  drill_fields: [scd_asset_rsp_id]

  dimension: scd_asset_rsp_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SCD_ASSET_RSP_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/status" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: current_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}."DATE_START";;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [scd_asset_rsp_id]
  }
}
