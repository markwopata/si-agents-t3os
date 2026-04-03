view: v_trips {
  derived_table: {
    sql:
SELECT *
FROM sworks.vehicle_usage_tracker.es_vehicle_trips vt
inner join sworks.vehicle_usage_tracker.user_asset_assignments ua
on vt.end_timestamp between ua.start_date and COALESCE(ua.end_date, '2099-12-31')
where vt.end_timestamp >= {% date_start report_range %}
and vt.end_timestamp < {% date_end report_range %}
    ;;
  }

  filter: report_range {
    type: date
  }

  dimension: lower_bound_date {
    # report can be run for ranges, so use either the report start date or the assignment start date, whichever is most recent
    type: date
    sql: GREATEST(${start_date}, {% date_start report_range %}) ;;
  }

  dimension: upper_bound_date {
    # report can be run for ranges, so use either the report end date or the assignment end date, whichever is oldest
    type: date
    sql: LEAST(COALESCE(${end_date}, {% date_end report_range %}), {% date_end report_range %}) ;;
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
