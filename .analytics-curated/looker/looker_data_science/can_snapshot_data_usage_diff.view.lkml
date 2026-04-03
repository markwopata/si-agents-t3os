view: can_snapshot_data_usage_diff {
  derived_table: {
    sql: with daily_breakdown as (
           select tracker_id,
              date(date_created) as day,
              sum(payload_length)/1024 as data_size_kb
           from trackers_db.tracker_data_uploads
           where date(date_created) >= date_trunc('day', now()) - interval '1 day'
            and date(date_created) < date_trunc('day', now())
           group by tracker_id, date(date_created)
        ), frequency_filter_updates as (
          select tracker_id,
            day,
            data_size_kb,
            data_size_kb - 120 as data_size_diff_from_target,
            abs(data_size_kb - 120) as data_size_diff_from_target_abs,
            (120.0 - data_size_kb)/data_size_kb as frequency_filter_relative_update
          from daily_breakdown
        )
        SELECT day,
          data_size_kb,
          data_size_diff_from_target,
          data_size_diff_from_target_abs,
          frequency_filter_relative_update
        FROM frequency_filter_updates
        order by data_size_diff_from_target desc
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."day" ;;
  }

  dimension: data_size_kb {
    type: number
    label: "data_size_kb"
    sql: ${TABLE}."data_size_kb" ;;
  }

  dimension: data_size_diff_from_target {
    type: number
    label: "data_size_diff_from_target"
    sql: ${TABLE}."data_size_diff_from_target" ;;
  }

  dimension: data_size_diff_from_target_abs {
    type: number
    label: "data_size_diff_from_target_abs"
    sql: ${TABLE}."data_size_diff_from_target_abs" ;;
  }

  dimension: frequency_filter_relative_update {
    type: number
    label: "frequency_filter_relative_update"
    sql: ${TABLE}."frequency_filter_relative_update" ;;
  }

  set: detail {
    fields: [day, data_size_kb, data_size_diff_from_target, data_size_diff_from_target_abs, frequency_filter_relative_update]
  }
}
