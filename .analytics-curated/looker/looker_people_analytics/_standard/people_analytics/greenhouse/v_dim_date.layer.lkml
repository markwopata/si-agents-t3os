include: "/_base/people_analytics/greenhouse/v_dim_date.view.lkml"


view: +v_dim_date {
  label: "Dim Date"

  ############### PARAMETERS ###############
  parameter: select_timeframe {
    type: unquoted
    default_value: "365"
    allowed_value: {
      value: "365"
      label: "Last 365 Days"
    }
    allowed_value: {
      value: "180"
      label: "Last 180 Days"
    }
    allowed_value: {
      value: "90"
      label: "Last 90 Days"
    }
    allowed_value: {
      value: "30"
      label: "Last 30 Days"
    }
  }

  parameter: select_period_over_period {
    type: unquoted
    default_value: "1"
    allowed_value: {
      value: "1"
      label: "MoM"
    }
    allowed_value: {
      value: "2"
      label: "WoW"
    }
    allowed_value: {
      value: "3"
      label: "QoQ"
    }
    allowed_value: {
      value: "4"
      label: "YoY"
    }
    allowed_value: {
      value: "5"
      label: "2023 MoM"
    }
    allowed_value: {
      value: "6"
      label: "2024 MoM"
    }
    allowed_value: {
      value: "7"
      label: "2025 MoM"
    }
  }


  ################ DIMENSIONS ################

  dimension: dt_key {
    value_format_name: id
    description: "Date Key used to join all the different date tables"
  }

  dimension: candidate_id {
    value_format_name: id
    description: "ID used to identify a candidate"
  }

  dimension: select_timeframe_flag {
    type: yesno
    sql:
      case
    when {{ select_timeframe._parameter_value }} = 30 then ${last_30_days} = true
    when {{ select_timeframe._parameter_value }} = 90 then ${last_90_days} = true
    when {{ select_timeframe._parameter_value }} = 180 then ${last_180_days} = true
    when {{ select_timeframe._parameter_value }} = 365 then ${last_365_days} = true
    else ${last_365_days} = true
    end
    ;;
  }

  dimension: period_over_period_date {
    type: date
    sql:
      case
    when {{ select_period_over_period._parameter_value }} = 1 then date_trunc('MONTH',${date})
    when {{ select_period_over_period._parameter_value }} = 2 then date_trunc('WEEK',${date})
    when {{ select_period_over_period._parameter_value }} = 3 then date_trunc('QUARTER',${date})
    when {{ select_period_over_period._parameter_value }} = 4 then date_trunc('YEAR',${date})
    else date_trunc('MONTH',${date})
    end
    ;;
  }

  dimension: period_over_period_string {
    type: string
    sql:
      case
    when {{ select_period_over_period._parameter_value }} = 3 then CAST(EXTRACT(YEAR from ${date})||' '||'Q'||EXTRACT(QUARTER from ${date}) as STRING)
    when {{ select_period_over_period._parameter_value }} in (1,5,6,7) then CAST(EXTRACT(YEAR from ${date})||' '||MONTHNAME(${date}) as STRING)
    when {{ select_period_over_period._parameter_value }} = 4 then CAST(EXTRACT(YEAR from ${date}) as STRING)
    else CAST(${period_over_period_date} as STRING)
    end
    ;;
  }

  dimension: period_over_period_flag {
    type: yesno
    sql:
      case
    when {{ select_period_over_period._parameter_value }} = 1 then ${last_365_days} = true
    when {{ select_period_over_period._parameter_value }} = 2 then ${last_60_days} = true
    when {{ select_period_over_period._parameter_value }} = 3 then ${date_date} >= to_date(dateadd('month',-24,date_trunc('month',current_date)))
    when {{ select_period_over_period._parameter_value }} = 4 then ${date_year} >= 2023
    when {{ select_period_over_period._parameter_value }} = 5 then ${date_year} = 2023
    when {{ select_period_over_period._parameter_value }} = 6 then ${date_year} = 2024
    when {{ select_period_over_period._parameter_value }} = 7 then ${date_year} = 2025
    else ${last_365_days} = true
    end
    ;;
  }

  ################ DATES ################

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date} ;;
  }
}
