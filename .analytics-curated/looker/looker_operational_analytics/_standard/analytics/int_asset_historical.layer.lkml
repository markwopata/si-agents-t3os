include: "/_base/analytics/assets/int_asset_historical.view.lkml"

view: +int_asset_historical {
  label: "Int Asset Historical"

  dimension: custom_primary_key {
    type: string
    sql: concat(${daily_timestamp_raw},'-',${asset_id},'-',${rental_id}) ;;
    primary_key: yes
  }

  measure: sum_rental_fleet_oec {
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format_name: usd
  }

  measure: sum_total_asset_oec {
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd
  }

  measure: model_delivery_trucks {
    type: number
    sql: round(${sum_total_asset_oec} / 8000000) ;;
    value_format_name: decimal_0
  }

  measure: model_service_trucks {
    type: number
    sql: round(${sum_total_asset_oec} / 3500000) ;;
    value_format_name: decimal_0
  }
}
