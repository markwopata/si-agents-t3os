view: asset_battery_prev_week_trend {
  derived_table: {
    sql: with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    '{{ _user_attributes['user_timezone'] }}'))
    )
    select
        al.asset_id,
        report_timestamp::date,
        a.battery_voltage_type_id,
        coalesce(round(avg(battery_voltage),2),0) as daily_average_battery_voltage
      from
          asset_list al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp > current_timestamp - interval '1 weeks' and report_timestamp <= current_timestamp
          and engine_active = FALSE
      group by
        al.asset_id,
        report_timestamp::date,
        a.battery_voltage_type_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: report_timestampdate {
    type: date
    sql: ${TABLE}."REPORT_TIMESTAMP::DATE" ;;
  }

  dimension: daily_average_battery_voltage {
    type: number
    sql: coalesce(${TABLE}."DAILY_AVERAGE_BATTERY_VOLTAGE",0) ;;
  }

  dimension: battery_voltage_type_id {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${report_timestampdate}) ;;
  }

  set: detail {
    fields: [asset_id, report_timestampdate, daily_average_battery_voltage]
  }

  measure: battery_voltage {
    label: "Avg. Engine Off Voltage"
    type: average
    sql: coalesce(${daily_average_battery_voltage},0) ;;
  }

  dimension: days_from_current {
    type: number
    sql: datediff(day,${report_timestampdate},current_date) ;;
  }

  dimension: 12v_battery_thresholds {
    type: yesno
    sql: ${battery_voltage_type_id} = 1 and ${daily_average_battery_voltage} <= 11.8 and ${daily_average_battery_voltage} > 0
    OR
    ${battery_voltage_type_id} = 1 and ${daily_average_battery_voltage} >= 18
    ;;
  }

  dimension: 24v_low_battery {
    type: yesno
    sql: ${battery_voltage_type_id} = 2 and ${daily_average_battery_voltage} <= 23.8 and ${daily_average_battery_voltage} > 0
    OR
    ${battery_voltage_type_id} = 2 and ${daily_average_battery_voltage} >= 30
    ;;
  }

  measure: current_day_voltage {
    type: average
    label: "Avg. Voltage Today"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "0"]
  }

  measure: one_day_ago_voltage {
    type: average
    label: "Avg. Voltage Yesterday"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "1"]
  }

  measure: two_days_ago_voltage {
    type: average
    label: "Avg. Voltage Two Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "2"]
  }

  measure: three_days_ago_voltage {
    type: average
    label: "Avg. Voltage Three Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "3"]
  }

  measure: four_days_ago_voltage {
    type: average
    label: "Avg. Voltage Four Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "4"]
  }

  measure: five_days_ago_voltage {
    type: average
    label: "Avg. Voltage Five Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "5"]
  }

  measure: six_days_ago_voltage {
    type: average
    label: "Avg. Voltage Six Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "6"]
  }

  measure: seven_days_ago_voltage {
    type: average
    label: "Avg. Voltage Seven Days Ago"
    sql: ${daily_average_battery_voltage} ;;
    filters: [days_from_current: "7"]
  }
}