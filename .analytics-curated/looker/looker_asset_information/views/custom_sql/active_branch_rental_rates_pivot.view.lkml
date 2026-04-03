view: active_branch_rental_rates_pivot {
  derived_table: {
    sql: WITH columns     AS (
                          SELECT branch_id,
                                 equipment_class_id,
                                 rate_type_id,
                                 SUM(price_per_hour)  AS pivotcol1,
                                 SUM(price_per_day)   AS pivotcol2,
                                 SUM(price_per_week)  AS pivotcol3,
                                 SUM(price_per_month) AS pivotcol4
                            FROM es_warehouse.public.branch_rental_rates
                           WHERE active = 'Y'
                           GROUP BY branch_id, equipment_class_id, rate_type_id),
       agg_columns AS (
                          SELECT branch_id,
                                 equipment_class_id,
                                 OBJECT_AGG(rate_type_id, pivotcol1) AS hour_price,
                                 OBJECT_AGG(rate_type_id, pivotcol2) AS day_price,
                                 OBJECT_AGG(rate_type_id, pivotcol3) AS week_price,
                                 OBJECT_AGG(rate_type_id, pivotcol4) AS month_price
                            FROM columns
                           GROUP BY branch_id, equipment_class_id)
SELECT ac.branch_id,
       ac.equipment_class_id,
       ec.name as equipment_class_name,
       ac.hour_price:"1"::integer  AS online_hour_rate,
       ac.day_price:"1"::integer   AS online_day_rate,
       ac.week_price:"1"::integer  AS online_week_rate,
       ac.month_price:"1"::integer AS online_month_rate,
       ac.hour_price:"2"::integer  AS benchmark_hour_rate,
       ac.day_price:"2"::integer   AS benchmark_day_rate,
       ac.week_price:"2"::integer  AS benchmark_week_rate,
       ac.month_price:"2"::integer AS benchmark_month_rate,
       ac.hour_price:"3"::integer  AS floor_hour_rate,
       ac.day_price:"3"::integer   AS floor_day_rate,
       ac.week_price:"3"::integer  AS floor_week_rate,
       ac.month_price:"3"::integer AS floor_month_rate,
       ac.month_price:"3"::integer/28 AS calc_floor_daily_rate,
       ac.month_price:"1"::integer/28 as calc_online_daily_rate
  FROM agg_columns ac
  left join es_warehouse.public.equipment_classes ec on ac.equipment_class_id = ec.equipment_class_id
 --ORDER BY branch_id, equipment_class_id
;;
}

dimension: primary_key {
  type: string
  primary_key: yes
  sql: concat(${branch_id},${equipment_class_id}) ;;
}

dimension: branch_id {
  type: number
  sql: ${TABLE}."BRANCH_ID" ;;
  value_format_name: id
}

dimension: equipment_class_id {
  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  value_format_name: id
}

dimension: equipment_class_name {
  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
}

dimension: online_hour_rate {
  type: number
  sql: ${TABLE}."ONLINE_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: online_day_rate {
  type: number
  sql: ${TABLE}."ONLINE_DAY_RATE" ;;
  value_format_name: usd
}

dimension: online_week_rate {
  type: number
  sql: ${TABLE}."ONLINE_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: online_month_rate {
  type: number
  sql: ${TABLE}."ONLINE_MONTH_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_hour_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_day_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_DAY_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_week_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_month_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_MONTH_RATE" ;;
  value_format_name: usd
}

dimension: floor_hour_rate {
  type: number
  sql: ${TABLE}."FLOOR_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: floor_day_rate {
  type: number
  sql: ${TABLE}."FLOOR_DAY_RATE" ;;
  value_format_name: usd
}

dimension: floor_week_rate {
  type: number
  sql: ${TABLE}."FLOOR_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: floor_month_rate {
  type: number
  sql: ${TABLE}."FLOOR_MONTH_RATE" ;;
  value_format_name: usd
}

#calculated rates for daily rentals (no quoted week or month rates in Admin) -JW 1/16/23
dimension: calc_floor_daily_rate {
  type: number
  sql: ${TABLE}."CALC_FLOOR_DAILY_RATE";;
  value_format_name: usd
}

  dimension: calc_online_daily_rate {
    type: number
    sql: ${TABLE}."CALC_ONLINE_DAILY_RATE";;
    value_format_name: usd
}

  dimension: any_below_floor {
    group_label: "Rate Achievement"
    type: yesno
    sql: case when ${day_rate_achievement} = 'Below Floor' or ${week_rate_achievement} = 'Below Floor' or ${month_rate_achievement} = 'Below Floor'
            then true
            else false
            end;;
  }

  dimension: month_below_floor {
    group_label: "Rate Achievement"
    type: yesno
    sql: case when ${month_rate_achievement} = 'Below Floor'
            then true
            else false
            end;;
  }

  dimension: hour_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${rentals.price_per_hour}< ${active_branch_rental_rates_pivot.floor_hour_rate} then 'Below Floor'
             when ${rentals.price_per_hour}>= ${active_branch_rental_rates_pivot.floor_hour_rate and ${rentals.price_per_hour} < ${active_branch_rental_rates_pivot.online_hour_rate} then 'Above Floor/Below Online'
             when ${rentals.price_per_hour}>= ${active_branch_rental_rates_pivot.online_hour_rate} then 'Above Online'
            else 'Above Floor/Below Online' end;;
  }

##adding new code to account for daily rentals in Admin.
  dimension: day_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case
            when ${rentals.new_rental_type_id} = 10 and ${rentals.price_per_day}< ${active_branch_rental_rates_pivot.calc_floor_daily_rate} then 'Below Floor'
            when ${rentals.new_rental_type_id} = 10 and ${rentals.price_per_day}>= ${active_branch_rental_rates_pivot.calc_online_daily_rate} then 'Above Online'
            when ${rentals.new_rental_type_id} = 10 and ${rentals.price_per_day}>= ${active_branch_rental_rates_pivot.calc_floor_daily_rate}
                                            and ${rentals.price_per_day}< ${active_branch_rental_rates_pivot.calc_online_daily_rate} then 'Above Floor/Below Online'
            when ${rentals.price_per_day}< ${active_branch_rental_rates_pivot.floor_day_rate} then 'Below Floor'
            when ${rentals.price_per_day}>= ${active_branch_rental_rates_pivot.floor_day_rate} and ${rentals.price_per_day}< ${active_branch_rental_rates_pivot.online_day_rate} then 'Above Floor/Below Online'
            when ${rentals.price_per_day}>= ${active_branch_rental_rates_pivot.online_day_rate} then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: week_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${rentals.price_per_week}< ${active_branch_rental_rates_pivot.floor_week_rate} then 'Below Floor'
            when ${rentals.price_per_week}>= ${active_branch_rental_rates_pivot.floor_week_rate} and ${rentals.price_per_week}< ${active_branch_rental_rates_pivot.online_week_rate} then 'Above Floor/Below Online'
            when ${rentals.price_per_week}>= ${active_branch_rental_rates_pivot.online_week_rate} then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: month_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${rentals.price_per_month}< ${active_branch_rental_rates_pivot.floor_month_rate} then 'Below Floor'
            when ${rentals.price_per_month}>= ${active_branch_rental_rates_pivot.floor_month_rate} and ${rentals.price_per_month}< ${active_branch_rental_rates_pivot.online_month_rate} then 'Above Floor/Below Online'
            when ${rentals.price_per_month}>= ${active_branch_rental_rates_pivot.online_month_rate} then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: is_overdue {
    type: yesno
    sql: ${rentals.end_time} < current_timestamp() ;;
  }

# Starts counting once the end_date is in a previous calendar day. Doesn't account for hours.
  dimension: days_overdue {
    type: number
    sql: IFF(${rentals.end_date} < current_date(), datediff('day', ${rentals.end_date}, current_date()), 0) ;;
  }

  dimension: days_on_rent {
    sql: datediff('day', ${rentals.start_date}, ${rentals.end_date}) ;;
  }

  measure: count {
    type: count
  }

  measure: rentals_below_floor {
    type: count_distinct
    sql: ${rentals.rental_id} ;;
    filters: [any_below_floor: "Yes"]
    html: <u><a href="https://equipmentshare.looker.com/dashboards/238?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Employee%20Name={{_filters['users.Full_Name_with_ID'] | url_encode }}&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&&Any+Below+Floor+%28Yes+%2F+No%29=Yes&Month+Rate+Below+Floor="target="_blank">{{rendered_value}}</a></u> ;;
  }


  measure: market_rentals_below_floor {
    type: count_distinct
    sql: ${rentals.rental_id} ;;
    filters: [any_below_floor: "Yes"]
    html: <u><a href="https://equipmentshare.looker.com/dashboards/238?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Full+Name+with+ID=&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&&Any+Below+Floor+%28Yes+%2F+No%29=Yes&Month+Rate+Below+Floor="target="_blank">{{rendered_value}}</a></u> ;;
  }

}
