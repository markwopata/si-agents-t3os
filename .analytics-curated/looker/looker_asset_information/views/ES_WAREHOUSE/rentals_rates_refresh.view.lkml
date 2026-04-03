include: "rentals.view"
view: rentals_rates_refresh {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS" ;;
  extends: [rentals]

  dimension: new_day_rate_achievement {
    group_label: "New Rate Achievement"
    type: string
    sql: case
            when ${new_rental_type_id} = 10 and ${price_per_day}<proposed_rates_2024q1.daily_floor then 'Below Floor'
            when ${new_rental_type_id} = 10 and ${price_per_day}>=proposed_rates_2024q1.daily_online then 'Above Online'
            when ${new_rental_type_id} = 10 and ${price_per_day}>=proposed_rates_2024q1.daily_floor
                                            and ${price_per_day}<proposed_rates_2024q1.daily_online then 'Above Floor/Below Online'
            when ${price_per_day}<proposed_rates_2024q1.day_floor then 'Below Floor'
            when ${price_per_day}>=proposed_rates_2024q1.day_floor and ${price_per_day}<proposed_rates_2024q1.day_online then 'Above Floor/Below Online'
            when ${price_per_day}>=proposed_rates_2024q1.day_online then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: new_week_rate_achievement {
    group_label: "New Rate Achievement"
    type: string
    sql: case when ${price_per_week}<proposed_rates_2024q1.week_floor then 'Below Floor'
            when ${price_per_week}>=proposed_rates_2024q1.week_floor and ${price_per_week}<proposed_rates_2024q1.week_online then 'Above Floor/Below Online'
            when ${price_per_week}>=proposed_rates_2024q1.week_online then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: new_month_rate_achievement {
    group_label: "New Rate Achievement"
    type: string
    sql: case when ${price_per_month}<proposed_rates_2024q1.month_floor then 'Below Floor'
            when ${price_per_month}>=proposed_rates_2024q1.month_floor and ${price_per_hour}<proposed_rates_2024q1.month_online then 'Above Floor/Below Online'
            when ${price_per_month}>=proposed_rates_2024q1.month_online then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: new_formatted_price_per_day {
    group_label: "New Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    html: {% if new_day_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: new_formatted_price_per_week {
    group_label: "New Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    html: {% if new_week_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: new_formatted_price_per_month {
    group_label: "New Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    html: {% if new_month_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: any_below_new_floor {
    group_label: "New Rate Achievement"
    type: yesno
    sql: case when ${new_day_rate_achievement} = 'Below Floor' or ${new_week_rate_achievement} = 'Below Floor' or ${new_month_rate_achievement} = 'Below Floor'
            then true
            else false
            end;;
  }

  dimension: month_below_new_floor {
    group_label: "New Rate Achievement"
    type: yesno
    sql: case when ${new_month_rate_achievement} = 'Below Floor'
            then true
            else false
            end;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }


  measure: rentals_below_new_floor {
    type: count
    filters: [any_below_new_floor: "Yes"]
    html: <u><a href="https://equipmentshare.looker.com/dashboards/718?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Full+Name+with+ID={{_filters['users.Full_Name_with_ID'] | url_encode }}&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&Any+Rate+Below+Floor=Yes&Month+Rate+Below+Floor="target="_blank">{{rendered_value}}</a></u> ;;
  }

  measure: rentals_month_below_new_floor {
    type: count
    filters: [month_below_new_floor: "Yes"]
    html: <u><a href="https://equipmentshare.looker.com/dashboards/718?Asset+ID=&amp;Market={{_filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{_filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{_filters['market_region_xwalk.region_district'] | url_encode }}&amp;Full+Name+with+ID={{_filters['users.Full_Name_with_ID'] | url_encode }}&Customer=&Job+Name=&Jobsite+Link=&PO=&Rental+ID=&Asset+Class=&Any+Rate+Below+Floor=&Month+Rate+Below+Floor=Yes"target="_blank">{{rendered_value}}</a></u> ;;
  }


}
