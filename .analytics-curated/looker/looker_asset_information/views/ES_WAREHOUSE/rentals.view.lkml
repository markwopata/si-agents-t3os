view: rentals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS"
    ;;
  drill_fields: [rental_id]

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: rental_id_with_track_link {
    label: "Rental ID"
    type: string
    sql: ${rental_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/assets/all/rentals/{{ rental_id._value }}/overview" target="_blank">{{ rental_id._value }}</a></font></u> ;;
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: borrower_user_id {
    type: number
    sql: ${TABLE}."BORROWER_USER_ID" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: delivery_charge {
    type: number
    sql: ${TABLE}."DELIVERY_CHARGE" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension: drop_off_delivery_required {
    type: yesno
    sql: ${TABLE}."DROP_OFF_DELIVERY_REQUIRED" ;;
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: end_date_estimated {
    type: yesno
    sql: ${TABLE}."END_DATE_ESTIMATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: lien_notice_sent {
    type: yesno
    sql: ${TABLE}."LIEN_NOTICE_SENT" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: formatted_price_per_day {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    html: {% if active_branch_rental_rates_pivot.day_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: formatted_price_per_month {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    html: {% if active_branch_rental_rates_pivot.month_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: formatted_price_per_week {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    html: {% if active_branch_rental_rates_pivot.week_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  # dimension: any_below_floor {
  #   group_label: "Rate Achievement"
  #   type: yesno
  #   sql: case when ${day_rate_achievement} = 'Below Floor' or ${week_rate_achievement} = 'Below Floor' or ${month_rate_achievement} = 'Below Floor'
  #           then true
  #           else false
  #           end;;
  # }

  # dimension: month_below_floor {
  #   group_label: "Rate Achievement"
  #   type: yesno
  #   sql: case when ${month_rate_achievement} = 'Below Floor'
  #           then true
  #           else false
  #           end;;
  # }

  dimension: rental_protection_plan_id {
    type: number
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_ID" ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: rental_type_id {
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }

  dimension: new_rental_type_id {
    type: number
    sql: case when ${price_per_week} is null and ${price_per_month} is null
         then 10
         else ${rental_type_id}
         end;;
  }

  dimension: return_charge {
    type: number
    sql: ${TABLE}."RETURN_CHARGE" ;;
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension: return_delivery_required {
    type: yesno
    sql: ${TABLE}."RETURN_DELIVERY_REQUIRED" ;;
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: start_date_estimated {
    type: yesno
    sql: ${TABLE}."START_DATE_ESTIMATED" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }


  dimension: rental_start_date_in_next_two_months {
    type: yesno
    sql: (date_trunc('month',${start_raw}) = date_trunc('month',current_date) AND date_trunc('year',${start_raw}) = date_trunc('year',current_date) AND date_trunc('day',${start_raw}) >= date_trunc('day',current_date))  OR date_trunc('month',${start_raw}) = (date_trunc('month',current_date) + interval '1 months') ;;
  }

  dimension: rental_end_date_in_the_last_seven_days {
    type: yesno
    sql: (date_trunc('month',${end_raw}) = date_trunc('month',current_date) AND date_trunc('year',${end_raw}) = date_trunc('year',current_date) AND (date_trunc('day',${end_raw}) <= date_trunc('day',current_date) AND date_trunc('day',${end_raw}) >= date_trunc('day',current_date - interval '7 days'))) ;;
  }

  dimension: rental_start_date_in_the_last_seven_days {
    type: yesno
    sql: (date_trunc('month',${start_raw}) = date_trunc('month',current_date) AND date_trunc('year',${start_raw}) = date_trunc('year',current_date) AND (date_trunc('day',${start_raw}) <= date_trunc('day',current_date) AND date_trunc('day',${start_raw}) >= date_trunc('day',current_date - interval '7 days'))) ;;
  }


  dimension: rental_end_past_today {
    type: yesno
    sql: ${end_date} >= current_timestamp() ;;
  }

  dimension: rental_start_past_today {
    type: yesno
    sql: ${start_date} >= current_timestamp() ;;
  }

# dimension: hour_rate_achievement {
#   group_label: "Rate Achievement"
#   type: string
#   sql: case when ${price_per_hour}< ${active_branch_rental_rates_pivot.floor_hour_rate} then 'Below Floor'
#             when ${price_per_hour}>= ${active_branch_rental_rates_pivot.floor_hour_rate and ${price_per_hour} < ${active_branch_rental_rates_pivot.online_hour_rate} then 'Above Floor/Below Online'
#             when ${price_per_hour}>= ${active_branch_rental_rates_pivot.online_hour_rate} then 'Above Online'
#             else 'Above Floor/Below Online' end;;
# }

# ##adding new code to account for daily rentals in Admin.
# dimension: day_rate_achievement {
#   group_label: "Rate Achievement"
#   type: string
#   sql: case
#             when ${new_rental_type_id} = 10 and ${price_per_day}< ${active_branch_rental_rates_pivot.calc_floor_daily_rate} then 'Below Floor'
#             when ${new_rental_type_id} = 10 and ${price_per_day}>= ${active_branch_rental_rates_pivot.calc_online_daily_rate} then 'Above Online'
#             when ${new_rental_type_id} = 10 and ${price_per_day}>= ${active_branch_rental_rates_pivot.calc_floor_daily_rate}
#                                             and ${price_per_day}< ${active_branch_rental_rates_pivot.calc_online_daily_rate} then 'Above Floor/Below Online'
#             when ${price_per_day}< ${active_branch_rental_rates_pivot.floor_day_rate} then 'Below Floor'
#             when ${price_per_day}>= ${active_branch_rental_rates_pivot.floor_day_rate} and ${price_per_day}< ${active_branch_rental_rates_pivot.online_day_rate} then 'Above Floor/Below Online'
#             when ${price_per_day}>= ${active_branch_rental_rates_pivot.online_day_rate} then 'Above Online'
#           else 'Above Floor/Below Online' end;;
# }

# dimension: week_rate_achievement {
#   group_label: "Rate Achievement"
#   type: string
#   sql: case when ${price_per_week}< ${active_branch_rental_rates_pivot.floor_week_rate} then 'Below Floor'
#             when ${price_per_week}>= ${active_branch_rental_rates_pivot.floor_week_rate} and ${price_per_week}< ${active_branch_rental_rates_pivot.online_week_rate} then 'Above Floor/Below Online'
#             when ${price_per_week}>= ${active_branch_rental_rates_pivot.online_week_rate} then 'Above Online'
#           else 'Above Floor/Below Online' end;;
# }

# dimension: month_rate_achievement {
#   group_label: "Rate Achievement"
#   type: string
#   sql: case when ${price_per_month}< ${active_branch_rental_rates_pivot.floor_month_rate} then 'Below Floor'
#             when ${price_per_month}>= ${active_branch_rental_rates_pivot.floor_month_rate} and ${price_per_month}< ${active_branch_rental_rates_pivot.online_month_rate} then 'Above Floor/Below Online'
#             when ${price_per_month}>= ${active_branch_rental_rates_pivot.online_month_rate} then 'Above Online'
#           else 'Above Floor/Below Online' end;;
# }

dimension: is_overdue {
  type: yesno
  sql: ${end_time} < current_timestamp() ;;
}

# Starts counting once the end_date is in a previous calendar day. Doesn't account for hours.
dimension: days_overdue {
  type: number
  sql: IFF(${end_date} < current_date(), datediff('day', ${end_date}, current_date()), 0) ;;
}

dimension: days_on_rent {
  sql: datediff('day', ${start_date}, ${end_date}) ;;
  }

# - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: rentals_ended_last_seven_days {
    type: count
    filters: [rental_end_date_in_the_last_seven_days: "Yes"]
    drill_fields: [markets.name, companies.name, asset_id, assets.make_and_model,assets_inventory.make_and_model, assets.name, assets_inventory.name,start_date,end_date,orders_pump_and_power_reservations.order_id_with_link_to_order]
  }

  measure: rentals_started_last_seven_days {
    type: count
    filters: [rental_start_date_in_the_last_seven_days: "Yes"]
    drill_fields: [markets.name, companies.name, asset_id, assets.make_and_model,assets_inventory.make_and_model, assets.name, assets_inventory.name,start_date, orders_pump_and_power_reservations.order_id_with_link_to_order]
  }

  # measure: rentals_below_floor {
  #   type: count
  #   filters: [any_below_floor: "Yes"]
  #   html: <u><a href="https://equipmentshare.looker.com/dashboards/238?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Full+Name+with+ID={{_filters['users.Full_Name_with_ID'] | url_encode }}&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&Any+Rate+Below+Floor=Yes&Month+Rate+Below+Floor="target="_blank">{{rendered_value}}</a></u> ;;
  # }


  # measure: market_rentals_below_floor {
  #   type: count
  #   filters: [any_below_floor: "Yes"]
  #   html: <u><a href="https://equipmentshare.looker.com/dashboards/238?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Full+Name+with+ID=&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&Any+Rate+Below+Floor=Yes&Month+Rate+Below+Floor="target="_blank">{{rendered_value}}</a></u> ;;
  # }

  # Only showing those over a calendar day old (not 24 hours):
  # https://equipmentshare.slack.com/archives/CSMH54ZNG/p1662753182290639
  measure: overdue_rentals {
    type: count
    filters: [days_overdue: "> 0"]
    drill_fields: [market_region_xwalk.market_name, rental_id_with_track_link, assets_aggregate.asset_id_t3_link, assets_aggregate.make_model,
                   assets_aggregate.custom_name, start_date, end_date, days_overdue]
  }

  dimension: bulk_label {
    type: string
    sql: ${TABLE}.bulk_label ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      rental_id,
      orders.order_id,
      assets.driver_name,
      assets.asset_id,
      assets.custom_name,
      assets.name
    ]
  }
}
