view: user_asset_assignments {
  sql_table_name: "VEHICLE_USAGE_TRACKER"."USER_ASSET_ASSIGNMENTS"
    ;;

  parameter: quarter {
    type: string
    default_value: "Q1-Q3 2022"

    allowed_value: {
      value: "Q1-Q3 2022"
    }
    allowed_value: {
      value: "Q4 2022"
    }
    allowed_value: {
      value: "Q1 2023"
    }
    allowed_value: {
      value: "Q2 2023"
    }
    allowed_value: {
      value: "Q3 2023"
    }
    allowed_value: {
      value: "Q4 2023"
    }
    allowed_value: {
      value: "Q1 2024"
    }
    allowed_value: {
      value: "Q2 2024"
    }
    allowed_value: {
      value: "Q3 2024"
    }
    allowed_value: {
      value: "Q4 2024"
    }
    allowed_value: {
      value: "Q1 2025"
    }
    allowed_value: {
      value: "Q2 2025"
    }
    allowed_value: {
      value: "Q3 2025"
    }
    allowed_value: {
      value: "Q4 2025"
    }
  }

  dimension: report_start_date {
    type: date
    sql:
    {% if quarter._parameter_value == "'Q1-Q3 2022'" %}
    '2022-01-01'
    {% elsif quarter._parameter_value == "'Q4 2022'" %}
    '2022-09-01'
    {% elsif quarter._parameter_value == "'Q1 2023'" %}
    '2022-12-01'
    {% elsif quarter._parameter_value == "'Q2 2023'" %}
    '2023-03-01'
    {% elsif quarter._parameter_value == "'Q3 2023'" %}
    '2023-06-01'
    {% elsif quarter._parameter_value == "'Q4 2023'" %}
    '2023-09-01'
    {% elsif quarter._parameter_value == "'Q1 2024'" %}
    '2023-12-01'
    {% elsif quarter._parameter_value == "'Q2 2024'" %}
    '2024-03-01'
    {% elsif quarter._parameter_value == "'Q3 2024'" %}
    '2024-06-01'
    {% elsif quarter._parameter_value == "'Q4 2024'" %}
    '2024-09-01'
    {% elsif quarter._parameter_value == "'Q1 2025'" %}
    '2024-12-01'
    {% elsif quarter._parameter_value == "'Q2 2025'" %}
    '2025-03-01'
    {% elsif quarter._parameter_value == "'Q3 2025'" %}
    '2025-06-01'
    {% elsif quarter._parameter_value == "'Q4 2025'" %}
    '2025-09-01'
    {% else %}
    '2022-01-01'
    {% endif %}
    ;;
  }

# When updating this, make sure that you add one to the day since the sql_always_where
# is using `<` not `<=`. For example, if the date range Tax gives you is
# 2022-12-01 to 2023-02-28, use 2023-03-01 as the end date. This is done to match
# David Beach's logic in the original Python script he wrote (and still uses).
  dimension: report_end_date {
    type: date
    sql:
    {% if quarter._parameter_value == "'Q1-Q3 2022'" %}
    '2022-09-01'
    {% elsif quarter._parameter_value == "'Q4 2022'" %}
    '2022-12-01'
    {% elsif quarter._parameter_value == "'Q1 2023'" %}
    '2023-03-01'
    {% elsif quarter._parameter_value == "'Q2 2023'" %}
    '2023-06-01'
    {% elsif quarter._parameter_value == "'Q3 2023'" %}
    '2023-09-01'
    {% elsif quarter._parameter_value == "'Q4 2023'" %}
    '2023-12-01'
    {% elsif quarter._parameter_value == "'Q1 2024'" %}
    '2024-03-01'
    {% elsif quarter._parameter_value == "'Q2 2024'" %}
    '2024-06-01'
    {% elsif quarter._parameter_value == "'Q3 2024'" %}
    '2024-09-01'
    {% elsif quarter._parameter_value == "'Q4 2024'" %}
    '2024-12-01'
    {% elsif quarter._parameter_value == "'Q1 2025'" %}
    '2025-03-01'
    {% elsif quarter._parameter_value == "'Q2 2025'" %}
    '2025-06-01'
    {% elsif quarter._parameter_value == "'Q3 2025'" %}
    '2025-09-01'
    {% elsif quarter._parameter_value == "'Q4 2025'" %}
    '2025-12-01'
    {% else %}
    '2022-09-01'
    {% endif %}
    ;;
  }

  dimension: lower_bound_date {
    # report can be run for ranges, so use either the report start date or the assignment start date, whichever is most recent
    type: date
    # sql: GREATEST(${start_date}, {% date_start report_range %}) ;;
    sql: GREATEST(${start_date}, ${report_start_date}) ;;
  }

  dimension: upper_bound_date {
  # report can be run for ranges, so use either the report end date or the assignment end date, whichever is oldest
    type: date
    # sql: LEAST(COALESCE(DATEADD('day', 1, ${end_date}), {% date_end report_range %}), {% date_end report_range %}) ;;
    sql: LEAST(COALESCE(DATEADD('day', 1, ${end_date}), ${report_end_date}), ${report_end_date}) ;;
  }

  dimension: days_with_vehicle {
    type: string
    # Set the difference of lower_bound_date and upper_bound_date to null if the assignment ended before the report start date.
    sql: IFF(DATEDIFF('days', ${lower_bound_date}, ${upper_bound_date}) > 0, DATEDIFF('days', ${lower_bound_date}, ${upper_bound_date}), null);;
  }

  dimension: year_days {
    # This was hardcoded as 365 in the original script.
    type: number
    sql: DAYOFYEAR(LAST_DAY(${upper_bound_date}::date, 'year')) ;;
  }

  dimension: calendar_day_proration {
    type: number
    value_format_name: percent_2
    sql: ${days_with_vehicle} / ${year_days} ;;
  }


  dimension: user_asset_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ASSET_ASSIGNMENT_ID" ;;
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

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: []
  }
}
