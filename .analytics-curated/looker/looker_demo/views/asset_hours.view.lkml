view: asset_hours {
  derived_table: {
    sql: with start_hours as (
      select distinct
        h.asset_id,
        date_start,
        hours
      from
        scd.scd_asset_hours h
      where
        h.date_start <= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date())))
        and coalesce(h.date_end, current_timestamp) >= convert_timezone('America/Chicago', 'UTC', COALESCE({% parameter start_date %}::timestamp,current_date() - interval '3 days'))
      QUALIFY row_number() over (PARTITION BY h.asset_id order by date_start::timestamp) = 1
      )
      , end_hours as (
      select
        h.asset_id,
        date_start,
        date_end, hours
      from
        scd.scd_asset_hours h
      where
        h.date_start <= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date())))
        and coalesce(h.date_end, (current_timestamp + interval '2 day')) >= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date() - interval '3 days')))
      QUALIFY row_number() over (PARTITION BY h.asset_id order by date_start::timestamp desc) = 1
      )
      select
        s.asset_id,
        s.date_start,
        s.hours as start_hours,
        e.date_end,
        e.hours as end_hours,
        e.hours-s.hours as hours_worked
      from
        start_hours s
        left join end_hours e on e.asset_id = s.asset_id
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

  dimension_group: date_start {
    type: time
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension: start_hours {
    type: number
    sql: ${TABLE}."START_HOURS" ;;
  }

  dimension_group: date_end {
    type: time
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension: end_hours {
    type: number
    sql: ${TABLE}."END_HOURS" ;;
  }

  dimension: hours_worked {
    type: number
    sql: ${TABLE}."HOURS_WORKED" ;;
  }

  parameter: start_date {
    type: date
    # default_value: "2020-10-08"
  }

  parameter: end_date {
    type: date
    # default_value: "2020-10-14"
  }

  set: detail {
    fields: [
      asset_id,
      date_start_time,
      start_hours,
      date_end_time,
      end_hours,
      hours_worked
    ]
  }
}
