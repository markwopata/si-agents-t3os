#
# The purpose of this view is to compare expected to actual hours usage
# to reduce surprise billing for asset overage hours for assets either
# currently on rent or for which invoices have not been approved (aka current).
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/195494/asset-hour-overages-steven-desormeaux]
#
# Britt Shanklin | Built 2022-12-06 | Modified 2023-01-09
view: asset_hours_overage_current {
  sql_table_name: "ANALYTICS"."PUBLIC"."ASSET_OVERAGE_HOURS" ;;

      dimension: order_id {
        type: number
        sql: ${TABLE}."ORDER_ID" ;;
        value_format_name: id
      }

      dimension: rental_id {
        type: number
        sql: ${TABLE}."RENTAL_ID" ;;
        primary_key: yes
        value_format_name: id
      }

      dimension: invoice_id {
        type: number
        sql: ${TABLE}."INVOICE_ID" ;;
        value_format_name: id
      }

      dimension: invoice_id_string {
        type: string
        sql: case
             when ${invoice_id} = 0 then 'No Invoice'
             else TO_VARCHAR(${invoice_id}) end ;;
      }

      dimension: equipment_class_id {
        type: number
        sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
        value_format_name: id
      }

      dimension: market_id  {
        type: number
        sql: ${TABLE}."MARKET_ID" ;;
        value_format_name: id
      }

      dimension: market_name {
        type: string
        sql: ${TABLE}."MARKET_NAME" ;;
      }

      dimension: return_asset_id {
        type: string
        sql: ${TABLE}."RETURN_ASSET" ;;
        value_format_name: id
      }

      dimension: rental_asset_id {
        type: string
        sql: ${TABLE}."ASSET_ID" ;;
        value_format_name: id
      }

      dimension_group: rental_start_date {
        type: time
        timeframes: [
          raw,
          time,
          time_of_day,
          date,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}."RENTAL_START_DATE" ;;
      }

      dimension_group: rental_end_date {
        type: time
        timeframes: [
          raw,
          time,
          time_of_day,
          date,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}."RENTAL_END_DATE" ;;
      }

      dimension_group: invoice_start_date {
        type: time
        timeframes: [
          raw,
          time,
          time_of_day,
          date,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}."INVOICE_START_DATE" ;;
      }

      dimension_group: invoice_end_date {
        type: time
        timeframes: [
          raw,
          time,
          time_of_day,
          date,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}."INVOICE_END_DATE" ;;
      }

      dimension: total_rental_days {
        type: number
        sql: ${TABLE}."TOTAL_RENTAL_DAYS" ;;
      }

      dimension: total_rental_hours {
        type: number
        sql: ${TABLE}."TOTAL_RENTAL_HOURS" ;;
        value_format_name: decimal_2
      }
      dimension: total_hours_billed {
        type: number
        sql: ${TABLE}."TOTAL_HOURS_BILLED" ;;
        value_format_name: decimal_2
      }

      dimension: total_hours_incurred {
        type: number
        sql: ${TABLE}."TOTAL_HOURS_INCURRED" ;;
        value_format_name: decimal_2
      }

      dimension: current_rental_days {
        type: number
        sql: ${TABLE}."CURRENT_RENTAL_DAYS" ;;
      }

      dimension: current_rental_hours {
        type: number
        sql: ${TABLE}."CURRENT_RENTAL_HOURS" ;;
        value_format_name: decimal_2
      }
      dimension: current_hours_billed {
        type: number
        sql: ${TABLE}."TOTAL_HOURS_BILLED" ;;
        value_format_name: decimal_2
      }

      dimension: current_hours_incurred {
        type: number
        sql: ${TABLE}."CURRENT_HOURS_INCURRED" ;;
        value_format_name: decimal_2
      }

      dimension: price_per_day {
        type: number
        sql: ${TABLE}."PRICE_PER_DAY" ;;
        value_format_name: usd
      }

      dimension: price_per_week {
        type: number
        sql: ${TABLE}."PRICE_PER_WEEK" ;;
        value_format_name: usd
      }

      dimension: price_per_month {
        type: number
        sql: ${TABLE}."PRICE_PER_MONTH" ;;
        value_format_name: usd
      }

      dimension: day_benchmark  {
        type: number
        sql: ${TABLE}."DAY_BENCHMARK" ;;
        value_format_name: usd
      }

      dimension: week_benchmark {
        type: number
        sql: ${TABLE}."WEEK_BENCHMARK" ;;
        value_format_name: usd
      }

      dimension: month_benchmark {
        type: number
        sql: ${TABLE}."MONTH_BENCHMARK" ;;
        value_format_name: usd
      }

      dimension: day_floor {
        type: number
        sql: ${TABLE}."DAY_FLOOR" ;;
        value_format_name: usd
      }

      dimension: week_floor {
        type: number
        sql: ${TABLE}."WEEK_FLOOR" ;;
        value_format_name: usd
      }

      dimension: month_floor {
        type: number
        sql: ${TABLE}."MONTH_FLOOR" ;;
        value_format_name: usd
      }

      dimension: overage_ind {
        type: string
        sql: ${TABLE}."OVERAGE_IND" ;;
      }

      dimension: overage_hours {
        type: number
        sql: ${TABLE}."OVERAGE_HOURS" ;;
      }

      dimension: target_overage_rate {
        type: number
        sql: ${TABLE}."OVERAGE_RATE" ;;
      }

      dimension: current_overage_hours {
        type: number
        sql: ${TABLE}."CURRENT_OVERAGE_HOURS" ;;
      }

      dimension: current_overage_rate {
        type: number
        sql: ${TABLE}."CURRENT_OVERAGE_RATE" ;;
      }


      dimension: equipment_class {
        type: string
        sql: ${TABLE}."EQUIPMENT_CLASS" ;;
      }

      dimension: district {
        type: string
        sql: ${TABLE}."DISTRICT" ;;
      }

      dimension: region_name {
        type: string
        sql: ${TABLE}."REGION_NAME" ;;
      }

      dimension: today {
        hidden: yes
        type: date
        sql: CURRENT_DATE() ;;
      }

      dimension: invoice_id_with_link {
        type: string
        sql: ${invoice_id_string} ;;
        html:
        {% if invoice_id_string._value != 'No Invoice' %}
        <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id_string}}" target="_blank">{{ invoice_id_string._value }}</a></font></u>
        {% endif %};;
      }

      dimension: asset_id_t3_link {
        label: "Asset ID T3"
        type: string
        value_format_name: id
        sql: ${rental_asset_id} ;;
        html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ rental_asset_id }}/history?selectedDate={{ today._value }}&returnTo=/assets/assets/" target="_blank">{{rendered_value}}</a></font></u> ;;
      }


      dimension: order_id_with_link {
        type: number
        value_format_name: id
        sql: ${order_id} ;;
        html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/orders/{{ order_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
      }

      dimension: rental_id_with_link {
        type: number
        value_format_name: id
        sql: ${rental_id} ;;
        html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
      }
      # Compare rate to benchmark, if target_overage_rate is double or triple of hours
      # then make sure charging 1.5-3x benchmark - based on highest of day, week or month rate
      # (in LOOKML because subject to change)
      dimension: day_rate {
        type: number
        hidden: no
        sql: CASE
                when NULLIFZERO(${day_floor}) is null then -1
                when ${price_per_day} is null then 0
                else ${price_per_day}/${day_floor} end;;
       }

      dimension: week_rate {
        type: number
        hidden: no
        sql: CASE
                    when NULLIFZERO(${week_floor}) is null then -1
                    when ${price_per_week} is null then 0
                    else ${price_per_week}/${week_floor} end;;
      }

      dimension: month_rate {
        type: number
        hidden: no
        sql: CASE
                    when NULLIFZERO(${month_floor}) is null then -1
                    when ${price_per_month} is null then 0
                    else ${price_per_month}/${month_floor} end;;
      }

      dimension: max_rate {
        type: number
        hidden: yes
        sql: CASE
                  when ${day_rate} >= ${week_rate} and ${day_rate} >= ${month_rate}
                       then ${day_rate}
                  when ${day_rate} < ${week_rate} and ${week_rate} >= ${month_rate}
                       then ${week_rate}
                  else ${month_rate} end;;
      }

      dimension: actual_shift_hours {
        type: string
        sql: case
                when ${target_overage_rate} = 1 then 'Single'
                when ${target_overage_rate} = 2 then 'Double'
                when ${target_overage_rate} = 3 then 'Triple'
                else ''
             end
              ;;
      }

      dimension: contract_shift_rate {
        type: string
        sql:  case when ${max_rate} = -1 then 'No Floor Rate'
                   when ${max_rate} < 1.5 then 'Single'
                   when ${max_rate} >= 1.5 and ${max_rate} < 2 then 'Double'
                   when ${max_rate} >= 2 then 'Triple'
                  else '' end ;;
      }

      dimension: check_rate {
        type: string
        sql: CASE
                  when ${contract_shift_rate} = 'No Floor Rate' then 'No Floor Rate'
                  when ${contract_shift_rate} = 'Single' and ${actual_shift_hours} <> 'Single' then 'Check Rate'
                  when ${contract_shift_rate} = 'Double' and ${actual_shift_hours} = 'Triple' then 'Check Rate'
                  when ${actual_shift_hours} <> ${contract_shift_rate} then 'Rate Mismatch'
                  else '' end ;;
      }

      dimension: estimated_billed_revenue {
        hidden: yes
        type: number
        sql: ${TABLE}."EST_TOTAL_COST" ;;
        value_format_name: usd_0
      }

      dimension: estimated_benchmark_cost {
        hidden: yes
        type: number
        sql: ${TABLE}."BENCHMARK_TOTAL_COST" ;;
      }

      dimension: estimated_missed_revenue{
        hidden: no
        type: number
        sql: ${TABLE}."EST_MISSED_REVENUE" ;;
        value_format_name: usd_0
       }

      dimension: appropriate_rate {
        type: yesno
        sql: ${contract_shift_rate} = 'No Floor Rate' or ${contract_shift_rate} = 'Triple' or (${contract_shift_rate} = 'Single' and ${actual_shift_hours} = 'Single') or (${contract_shift_rate} = 'Double' and ${actual_shift_hours} <> 'Triple') ;;
      }

      measure: asset_count {
        type: count_distinct
        sql: ${rental_asset_id} ;;
        link: {
          label: "Click for Details"
          url: "https://equipmentshare.looker.com/dashboards/745"
          }
      }

      measure: missed_revenue_total {
        type: sum_distinct
        sql: ${estimated_missed_revenue} ;;
        value_format_name: usd_0
      }

      measure: overage_charge {
        type: sum_distinct
        sql: ${TABLE}."OVERAGE_SURCHARGE" ;;
        value_format_name: usd_0
      }

}
