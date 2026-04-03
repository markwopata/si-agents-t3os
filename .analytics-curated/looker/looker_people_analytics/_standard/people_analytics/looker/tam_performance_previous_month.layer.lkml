include: "/_base/people_analytics/looker/tam_performance_previous_month.view.lkml"

view: +tam_performance_previous_month {

  ############### DIMENSIONS ###############
  dimension: user_id {
    value_format_name: id
  }
  dimension: employee_id {
    value_format_name: id
  }
  dimension: direct_manager_employee_id {
    value_format_name: id
  }
  dimension: greenhouse_application_id {
    value_format_name: id
  }
  dimension: primary_in_market_rental_pct {
    value_format_name: percent_2
  }
  dimension: primary_in_market_total_pct {
    value_format_name: percent_2
  }
  dimension: secondary_in_market_rental_pct {
    value_format_name: percent_2
  }
  dimension: secondary_in_market_total_pct {
    value_format_name: percent_2
  }
  dimension: total_in_market_rental_pct {
    value_format_name: percent_2
  }
  dimension: total_in_market_total_pct {
    value_format_name: percent_2
  }
  dimension: oec_on_rent {
    value_format: "$#,##0.00"
  }
  dimension: primary_rental_revenue {
    value_format: "$#,##0.00"
  }
  dimension: primary_delivery_revenue {
    value_format: "$#,##0.00"
  }
  dimension: primary_bulk_revenue {
    value_format: "$#,##0.00"
  }
  dimension: primary_parts_revenue {
    value_format: "$#,##0.00"
  }
  dimension: primary_total_revenue {
    value_format: "$#,##0.00"
  }
  dimension: secondary_rental_revenue {
    value_format: "$#,##0.00"
  }
  dimension: secondary_delivery_revenue {
    value_format: "$#,##0.00"
  }
  dimension: secondary_bulk_revenue {
    value_format: "$#,##0.00"
  }
  dimension: secondary_parts_revenue {
    value_format: "$#,##0.00"
  }
  dimension: secondary_total_revenue {
    value_format: "$#,##0.00"
  }
  dimension: total_rental_revenue {
    value_format: "$#,##0.00"
  }
  dimension: total_delivery_revenue {
    value_format: "$#,##0.00"
  }
  dimension: total_bulk_revenue {
    value_format: "$#,##0.00"
  }
  dimension: total_parts_revenue {
    value_format: "$#,##0.00"
  }
  dimension: total_total_revenue {
    value_format: "$#,##0.00"
  }
  dimension: tenure_buckets {
    type: string
    sql: CASE WHEN ${tenure_in_months} >= 0 and ${tenure_in_months} <= 2 then '0-3 Months'
    WHEN ${tenure_in_months} >= 3 and ${tenure_in_months} <= 5 then '4-6 Months'
    WHEN ${tenure_in_months} >= 6 and ${tenure_in_months} <= 11 then '6-12 Months'
    WHEN ${tenure_in_months} >= 12 and ${tenure_in_months} <= 23 then '12-24 Months'
    ELSE '24+ Months' END;;
  }
  dimension: tenure_buckets_order {
    type: number
    sql: CASE WHEN ${tenure_buckets} = '0-3 Months' then 1
          WHEN ${tenure_buckets} = '4-6 Months' then 2
          WHEN ${tenure_buckets} = '6-12 Months' then 3
          WHEN ${tenure_buckets} = '12-24 Months' then 4
          ELSE 5 END;;
  }
  dimension: average_total_total_revenue {
    type: number
    value_format: "$#,##0.00"
    sql: case when ${tenure_in_months} = 2 then ${total_total_revenue}/2
    when ${tenure_in_months} < 2 then ${total_total_revenue}
    else ${total_total_revenue}/3 end;;
    description: "Total Total Revenue divided by tenure months if tenure months is less than three and by three if they're more since the query takes the last three months of data."
  }

  ############### DATES ###############
  dimension_group: guarantee_start_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${guarantee_start};;
  }
  dimension_group: guarantee_end_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${guarantee_end};;
  }
  dimension_group: commission_start_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${commission_start};;
  }
  dimension_group: date_hired {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${date_hired};;
  }
  dimension_group: date_terminated {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${date_terminated};;
  }
}
