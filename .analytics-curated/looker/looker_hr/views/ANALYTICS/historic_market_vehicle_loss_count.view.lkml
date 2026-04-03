view: historic_market_vehicle_loss_count {
  sql_table_name: "CLAIMS"."HISTORIC_MARKET_VEHICLE_LOSS_COUNT"
    ;;

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: vehicle_count {
    type: number
    sql: ${TABLE}."VEHICLE_COUNT" ;;
  }

  dimension: loss_count {
    type: number
    sql: ${TABLE}."LOSS_COUNT" ;;
  }

  dimension: last_12 {
    type: yesno
    sql: ${date_date} > current_date() -365 ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: average_vehicle_count_last_12 {
    alias: [avgerage_vehicle_count_last_12] #adding alias so I can correct typo
    type: average
    sql: ${vehicle_count};;
    filters: [last_12: "yes"]
    link: {
      label: "View Auto Accidents"
      url: "https://equipmentshare.looker.com/dashboards/816?Market+Name={{ _filters['market_region_xwalk.market_name'] }}"
    }
  }

  measure: count_loss_last_12 {
    type: sum
    sql: ${loss_count};;
    filters: [last_12: "yes"]
    link: {
      label: "View Auto Accidents"
      url: "https://equipmentshare.looker.com/dashboards/816?Market+Name={{ _filters['market_region_xwalk.market_name'] }}"
      }
    #html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/816?Market+Name={{ _filters['market_region_xwalk.market_name']}}">{{rendered_value}}</a></p></u>;;
  }

}
