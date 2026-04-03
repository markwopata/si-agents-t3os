view: asset_class_30_day_utilization {
  derived_table: {
    sql:
    select aa.ASSET_CLASS,
           hu.MARKET_ID,
           count(hu.dte)                            as num_days,
           round(sum(zeroifnull(hu.DAY_RATE)),2)    as total_rate,
           round(total_rate/num_days,2)             as achieved_daily_rental_rate,
           count(distinct hu.ASSET_ID)
    from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION    as hu
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE       as aa
        on hu.ASSET_ID = aa.ASSET_ID
    where hu.DTE >= dateadd(day,-30,current_date())
    group by aa.asset_class, hu.market_id
    order by achieved_daily_rental_rate desc ;;
  }
  dimension: asset_class {
    type: string
    drill_fields: []
    order_by_field: achieved_daily_rental_rate
  }
  dimension: market_id {
    type: string
  }
  dimension: num_days {
    type: number
  }
  dimension: total_rate {
    type: number
    value_format_name: usd
  }
  dimension: achieved_daily_rental_rate {
    label: "Daily Rental Revenue Impact"
    type: number
    value_format_name: usd
  }
  measure: sum_num_days {
    type: sum
    sql: ${num_days} ;;
    drill_fields: [
                  asset_class,
                  work_orders_with_high_rental_revenue.work_order_id_with_link_to_work_order,
                  work_orders_with_high_rental_revenue.days_open,
                  sum_achieved_rate
                  ]
  }
  measure: sum_total_rate {
    type: sum
    value_format_name: usd
    sql: ${total_rate} ;;
  }
  measure: sum_achieved_rate {
    label: "Daily Rental Revenue Impact"
    type: sum
    value_format_name: usd
    sql: ${achieved_daily_rental_rate};;
    drill_fields: [
                  market_region_xwalk.market_name,
                  sum_achieved_rate_details,
                  work_orders_with_high_rental_revenue.count
                  ]
  }
  measure: sum_achieved_rate_details {
    label: "Daily Rental Revenue Impact"
    hidden: yes
    type: sum
    value_format_name: usd
    sql: ${achieved_daily_rental_rate};;
    drill_fields: [
                  asset_class,
                  work_orders_with_high_rental_revenue.work_order_id_with_link_to_work_order,
                  work_orders_with_high_rental_revenue.days_open,
                  sum_achieved_rate
                  ]
  }


#    explore_source: historical_utilization {
#      column: asset_id {}
#      #Dates must be fully scoped due to the way dates can be referenced (_date, _month, _year)
#      column: dte {field: historical_utilization.dte_date}
#      column: market_id {}
#      column: num_days {}
#      column: total_rate {}
#      column: achieved_daily_rental_rate {}
#    }
#  }
#  dimension: asset_id {
#    primary_key: yes
#    type: number
#  }
#  dimension_group: dte {
#    type: time
#    timeframes: [raw,date,week,month,quarter,year]
#    convert_tz: no
#    datatype: date
#  }
#  dimension: num_days {
#    type: number
#  }
#  dimension: market_id {
#    type: number
#    value_format_name: id
#  }
#  dimension: total_rate {
#    type: number
#    value_format_name: usd
#  }
#  dimension: achieved_daily_rental_rate {
#    type: number
#    value_format_name: usd
#  }
}
