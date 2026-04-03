view: rentals_solo {
    sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS"
      ;;
    drill_fields: [rental_id]

    dimension: rental_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."RENTAL_ID" ;;
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
    }

    dimension: price_per_hour {
      type: number
      sql: ${TABLE}."PRICE_PER_HOUR" ;;
    }

    dimension: price_per_month {
      type: number
      sql: ${TABLE}."PRICE_PER_MONTH" ;;
    }

    dimension: price_per_week {
      type: number
      sql: ${TABLE}."PRICE_PER_WEEK" ;;
    }

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

    dimension: is_below_floor_rate {
      type: yesno
      sql: ${TABLE}."IS_BELOW_FLOOR_RATE" ;;
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

    dimension: formatted_price_per_day {
      group_label: "Rate Achievement"
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."PRICE_PER_DAY" ;;
      html: {% if day_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
    }

    dimension: formatted_price_per_month {
      group_label: "Rate Achievement"
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."PRICE_PER_MONTH" ;;
      html: {% if month_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
    }

    dimension: formatted_price_per_week {
      group_label: "Rate Achievement"
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."PRICE_PER_WEEK" ;;
      html: {% if week_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
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
      sql: case when ${price_per_hour}<active_branch_rental_rates_pivot.floor_hour_rate then 'Below Floor'
             when ${price_per_hour}>=active_branch_rental_rates_pivot.floor_hour_rate and ${price_per_hour}<active_branch_rental_rates_pivot.online_hour_rate then 'Above Floor/Below Online'
             when ${price_per_hour}>=active_branch_rental_rates_pivot.online_hour_rate then 'Above Online'
            else 'Above Floor/Below Online' end;;
    }

    dimension: day_rate_achievement {
      group_label: "Rate Achievement"
      type: string
      sql: case when ${price_per_day}<active_branch_rental_rates_pivot.floor_day_rate then 'Below Floor'
            when ${price_per_day}>=active_branch_rental_rates_pivot.floor_day_rate and ${price_per_day}<active_branch_rental_rates_pivot.online_day_rate then 'Above Floor/Below Online'
            when ${price_per_day}>=active_branch_rental_rates_pivot.online_day_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
    }

    dimension: week_rate_achievement {
      group_label: "Rate Achievement"
      type: string
      sql: case when ${price_per_week}<active_branch_rental_rates_pivot.floor_week_rate then 'Below Floor'
            when ${price_per_week}>=active_branch_rental_rates_pivot.floor_week_rate and ${price_per_week}<active_branch_rental_rates_pivot.online_week_rate then 'Above Floor/Below Online'
            when ${price_per_week}>=active_branch_rental_rates_pivot.online_week_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
    }

    dimension: month_rate_achievement {
      group_label: "Rate Achievement"
      type: string
      sql: case when ${price_per_month}<active_branch_rental_rates_pivot.floor_month_rate then 'Below Floor'
            when ${price_per_month}>=active_branch_rental_rates_pivot.floor_month_rate and ${price_per_hour}<active_branch_rental_rates_pivot.online_month_rate then 'Above Floor/Below Online'
            when ${price_per_month}>=active_branch_rental_rates_pivot.online_month_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
    }



    measure: count {
      type: count
      drill_fields: [detail*]
    }

    # ----- Sets of fields for drilling ------
    set: detail {
      fields: [
        rental_id,
        orders.purchase_order_id,
        assets.asset_id,
        assets.name,
        assets.custom_name,
        assets.driver_name
      ]
    }
  }
