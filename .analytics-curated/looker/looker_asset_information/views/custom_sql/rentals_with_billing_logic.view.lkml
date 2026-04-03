view: rentals_with_billing_logic {
  sql_table_name: ANALYTICS.RATE_ACHIEVEMENT.RENTALS_WITH_BILLING_LOGIC ;;


    # === DIMENSIONS ===
    dimension: rental_id {
      primary_key: yes
      type: number
      sql: ${TABLE}.RENTAL_ID ;;
      }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
      }

    dimension: branch_id {
      type: number
      sql: ${TABLE}.BRANCH_ID ;;
      }

    dimension: rental_price_per_month {
      type: number
      value_format_name: usd
      sql: ${TABLE}.RENTAL_PRICE_PER_MONTH ;;
      }

    dimension: rental_price_per_week {
      type: number
      value_format_name: usd
      sql: ${TABLE}.RENTAL_PRICE_PER_WEEK ;;
      }

    dimension: rental_price_per_day {
      type: number
      value_format_name: usd
      sql: ${TABLE}.RENTAL_PRICE_PER_DAY ;;
      }

    dimension: ref_floor_monthly {
      type: number
      value_format_name: usd
      sql: ${TABLE}.REF_FLOOR_MONTHLY ;;
      }

    dimension: ref_floor_weekly {
      type: number
      value_format_name: usd
      sql: ${TABLE}.REF_FLOOR_WEEKLY ;;
      }

    dimension: ref_floor_daily {
      type: number
      value_format_name: usd
      sql: ${TABLE}.REF_FLOOR_DAILY ;;
      }

    dimension: month_below_floor {
      type: string
      sql: CASE WHEN ${TABLE}.BELOW_FLOOR_MONTHLY_FLAG = 1 then 'Yes' else 'No' end ;;
      }

    dimension: week_below_floor {
      type: string
      sql: CASE WHEN ${TABLE}.BELOW_FLOOR_WEEKLY_FLAG = 1 then 'Yes' else 'No' end ;;
      }

    dimension: day_below_floor {
      type: string
      sql: CASE WHEN ${TABLE}.BELOW_FLOOR_DAILY_FLAG = 1 then 'Yes' else 'No' end ;;
      }


    dimension: amount_below_floor {
      type:  number
      value_format_name: usd_0
      sql: CASE WHEN ${TABLE}.BELOW_FLOOR_MONTHLY_FLAG = 1 THEN ${TABLE}.REF_FLOOR_MONTHLY - ${TABLE}.RENTAL_PRICE_PER_MONTH else 0 end ;; }


  dimension: formatted_price_per_month {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_PRICE_PER_MONTH" ;;
    html: {% if month_below_floor._value == 'Yes'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }


  dimension: formatted_price_per_week {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_PRICE_PER_WEEK" ;;
    html: {% if week_below_floor._value == 'Yes'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }


  dimension: formatted_price_per_day {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_PRICE_PER_DAY" ;;
    html: {% if day_below_floor._value == 'Yes'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }


  dimension: any_below_floor {
    group_label: "Rate Achievement"
    type: yesno
    sql: case when ${TABLE}.BELOW_FLOOR_MONTHLY_FLAG = '1' or ${TABLE}.BELOW_FLOOR_WEEKLY_FLAG = '1' or ${TABLE}.BELOW_FLOOR_DAILY_FLAG = '1'
            then true
            else false
            end;;
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
