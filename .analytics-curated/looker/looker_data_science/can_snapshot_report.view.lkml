view: can_snapshot_report {
  derived_table: {
    sql:with tracker_can_snapshot_report AS (
          select c.pgn as pgn,
              t.value:spn as spn,
              min(t.value:value) as min_value,
              max(t.value:value) as max_value,
              stddev(t.value:value) as stdev_value,
              ARRAY_TO_STRING(ARRAY_AGG(DISTINCT c.$1:can_id),',') as can_ids,
              ARRAY_TO_STRING(ARRAY_AGG(DISTINCT c.$1:source_address),',') as source_addresses,
              count(*) as count
          from data_science.public.can_snapshot_data c, table(flatten(c.$1:spn_list, '')) t
          where c.device_serial = {% parameter device_serial %}
              and c.report_timestamp > {% parameter start_timestamp %}
              and c.report_timestamp < DATEADD(DAY, 1, {% parameter end_timestamp %})
              and t.value:value != 'null'
              and IS_REAL(TO_VARIANT(t.value:value))
          group by c.pgn, t.value:spn
        )
        SELECT tracker_can_snapshot_report.*, p.pgn_label, s.spn_name
        from tracker_can_snapshot_report
          LEFT JOIN data_science.public.pgn p ON tracker_can_snapshot_report.pgn = p.pgn
          LEFT JOIN data_science.public.spn s ON tracker_can_snapshot_report.spn = s.spn
        ORDER BY tracker_can_snapshot_report.pgn, tracker_can_snapshot_report.spn
        ;;
  }

  dimension: pgn {
    type: number
    sql: pgn ;;
  }

  dimension: pgn_name {
    type: string
    sql: pgn_label ;;
  }

  parameter: device_serial {
    type: string
    suggestions: ["1345972462"]
  }

  parameter: start_timestamp {
    type: date
  }

  parameter: end_timestamp {
    type: date
  }

  dimension: spn {
    type: number
    sql: spn ;;
  }

  dimension: spn_name {
    type: string
    sql: spn_name ;;
  }

  dimension: min_value {
    type: number
    sql: min_value ;;
  }

  dimension: max_value {
    type: number
    sql: max_value ;;
  }

  dimension: stdev_value {
    type: number
    sql: stdev_value ;;
  }

  dimension: can_ids {
    type: string
    sql: can_ids ;;
  }

  dimension: source_addresses {
    type: string
    sql: source_addresses ;;
  }

  dimension: count {
    type: number
    sql: count ;;
  }

  set: detail {
    fields: [pgn, pgn_name, spn, spn_name, min_value, max_value, stdev_value, can_ids, source_addresses, count]
  }
}
