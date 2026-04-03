view: can_snapshot_data_usage {
  derived_table: {
    sql: with daily_breakdown as (
           select tracker_id,
              date(date_created) as day,
              sum(payload_length)/1024 as data_size
           from trackers_db.tracker_data_uploads
           where date(date_created) > now() - interval '1 month'
              and tracker_id in (
                 select distinct tt.tracker_id
                 from trackers_db.tracker_data_uploads
                    join trackers_db.trackers tt using (tracker_id)
                    join trackers t using (device_serial)
                    join assets a on (t.tracker_id = a.tracker_id)
                    join equipment_classes_models_xref using (equipment_model_id)
                    join equipment_classes ec using (equipment_class_id)
                 where ec.name ilike {% parameter equipment_class_keyword %}  -- '%telehandler%'
              )
           group by tracker_id, date(date_created)
        ) SELECT day, avg(data_size) as "Average CAN Snapshot Data Size"
        FROM daily_breakdown
        GROUP BY day
        order by day
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

  dimension: average_can_snapshot_data_size {
    type: number
    label: "Average CAN Snapshot Data Size"
    sql: ${TABLE}."Average CAN Snapshot Data Size" ;;
  }

  parameter: equipment_class_keyword {
    type: string
    allowed_value: {
      label: "telehandlers"
      value: "%telehandler%"
    }
    allowed_value: {
      label: "generators"
      value: "%generator%"
    }
    allowed_value: {
      label: "booms"
      value: "%boom%"
    }
    allowed_value: {
      label: "scissors"
      value: "%scissor%"
    }
    suggestions: ["telehandlers"]
  }

  set: detail {
    fields: [day, average_can_snapshot_data_size]
  }
}
