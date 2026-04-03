view: admin_cycle {
  sql_table_name: "PUBLIC"."ADMIN_CYCLE"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: current_cycle {
    type: number
    sql: ${TABLE}."CURRENT_CYCLE" ;;
  }

  dimension: current_rental_days {
    type: number
    sql: ${TABLE}."CURRENT_RENTAL_DAYS" ;;
  }

  dimension: days_left {
    type: number
    sql: ${TABLE}."DAYS_LEFT" ;;
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
    sql:convert_timezone('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ)) ;;
    label: "Scheduled Off-Rent"
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: end_this_rental_cycle {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    label: "Next Cycle"
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."END_THIS_RENTAL_CYCLE") ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: last_cycle_inv {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_CYCLE_INV_DATE" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: net_select {
    type: number
    sql: ${TABLE}."NET_SELECT" ;;
  }

  dimension: net_terms_id {
    type: number
    sql: ${TABLE}."NET_TERMS_ID" ;;
  }

  dimension_group: next_cycle_inv {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEXT_CYCLE_INV_DATE" ;;
    label: "Next Cycle"
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
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
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."START_DATE") ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: start_this_rental_cycle {
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
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."START_THIS_RENTAL_CYCLE" AS TIMESTAMP_NTZ)) ;;
  }

  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }

  dimension: cycles_next_seven_days {
    type: string
    sql: ${TABLE}."CYCLES_NEXT_SEVEN_DAYS" ;;
  }

  # dimension: end_rental_cycle_vs_today {
  #   type: number
  #   sql: datediff(day,current_timestamp(),${end_this_rental_cycle_date})  ;;
  # }

  # dimension: cycles_next_seven_days {
  #   type: yesno
  #   sql: ${end_rental_cycle_vs_today} <= 7 and ${end_rental_cycle_vs_today} >= 0 ;;
  # }

  dimension: rental_duration {
    type: number
    sql: datediff('day',${start_date},${end_date}) ;;
  }

  measure: cycling_this_week {
    type: count
    filters: [cycles_next_seven_days: "TRUE"]
    drill_fields: [cycling_rental_kpi*]
  }

  set: cycling_rental_kpi {
    fields: [assets.custom_name_make_model, locations.jobsite_group, purchase_orders.name, assets.asset_class, start_date, next_cycle_inv_date]
  }

  measure: count {
    type: count
    drill_fields: [
      asset_id,
      make,
      model,
      rental_id,
      start_date,
      end_date,
      total_days_on_rent,
      end_this_rental_cycle_date]
  }
}