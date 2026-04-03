view: estimated_lost_revenue {
  sql_table_name: ANALYTICS.SERVICE.ESTIMATED_LOST_REVENUE;;

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }

  dimension :  asset_most_recent_on_rent_date {
  type:  date
  sql: ${TABLE}.asset_most_recent_on_rent_date ;;
  }

  dimension:  market_id {
    type:  number
    value_format_name: id
    sql:  ${TABLE}.market_id ;;
  }

  dimension: asset_class {
    type:  string
    value_format_name: id
    sql:  ${TABLE}.asset_class ;;
  }

  dimension: days_since_last_rental {
    type: number
    sql:  ${TABLE}.days_since_last_rental ;;
  }

  dimension: avg_daily_revenue_per_asset {
    type:  number
    value_format_name: usd_0
    sql:  ${TABLE}.avg_daily_revenue_per_asset ;;
  }

  dimension: district_class_expected_lost_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.district_class_expected_lost_revenue ;;
  }

  dimension: rank {
    type: number
    value_format_name: id
    sql: ${TABLE}.rank ;;
  }
}
