
view: seat_belt_detection {
  derived_table: {
    sql: {% raw %} WITH active_operators AS (
        SELECT DISTINCT oa.operator_id
        FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__OPERATOR_ASSIGNMENTS oa
        JOIN es_warehouse.public.users u
          ON u.user_id = TRY_TO_NUMBER(oa.user_id)
        JOIN analytics.payroll.company_directory cd
          ON TRY_TO_NUMBER(cd.employee_id) = TRY_TO_NUMBER(u.employee_id)
        WHERE cd.employee_status NOT IN ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
          AND cd.employee_title NOT IN (
            'Territory Account Manager', 'Strategic Account Manager',
            'Rental Territory Manager', 'Market Consultant Manager',
            'Territory Retail Sales Representative', 'Retail Account Manager'
          )
      ),

      base_events AS (
        SELECT
          da.operator_id,
          da.operator_name,
          CONVERT_TIMEZONE('UTC', COALESCE(u.timezone, 'UTC'), e.event_date) AS event_ts_local,
          CASE
            WHEN EXTRACT(HOUR FROM CONVERT_TIMEZONE('UTC', COALESCE(u.timezone, 'UTC'), e.event_date))
                 BETWEEN 7 AND 17
            THEN 'Daylight'
            ELSE 'Potential False Alert'
          END AS time_of_day_label
        FROM analytics.fleetcam.events e
        JOIN analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
        JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__OPERATOR_ASSIGNMENTS da
          ON e.event_date >= da.assignment_time
         AND e.event_date < COALESCE(da.unassignment_time, '2999-12-31'::TIMESTAMP)
         AND afx.es_asset_id = da.asset_id
        JOIN active_operators ao ON ao.operator_id = da.operator_id
        LEFT JOIN es_warehouse.public.users u ON u.user_id = da.user_id
        WHERE e.event_type_id IN (
          SELECT event_type_id
          FROM analytics.fleetcam.event_types
          WHERE name = 'No Seat Belt'
        )
          AND e.event_date >= DATEADD('day', -60, CURRENT_DATE)
      ),

      daily_counts AS (
        SELECT
          operator_id,
          operator_name,
          event_ts_local::DATE AS event_date_local,
          COUNT_IF(time_of_day_label = 'Daylight')              AS daylight_event_count,
          COUNT_IF(time_of_day_label = 'Potential False Alert')  AS off_hours_event_count
        FROM base_events
        GROUP BY 1, 2, 3
      )

      SELECT
        operator_id,
        operator_name,

        -- current 30-day counts
        COUNT_IF(event_date_local >= CURRENT_DATE - 30
                 AND daylight_event_count > 0)                          AS days_with_daylight_events,
        SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                daylight_event_count, 0))                               AS daylight_events,
        SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                off_hours_event_count, 0))                              AS off_hours_events,
        ROUND(AVG(IFF(event_date_local >= CURRENT_DATE - 30
                      AND daylight_event_count > 0,
                      daylight_event_count, NULL)), 1)                  AS avg_daylight_events_per_day,
        ROUND(
          COUNT_IF(event_date_local >= CURRENT_DATE - 30
                   AND daylight_event_count > 0) * 100.0 / 30.0,
          1
        )                                                               AS pct_days_with_events,

        -- prior 30-day counts (days 31-60 ago)
        SUM(IFF(event_date_local < CURRENT_DATE - 30,
                daylight_event_count, 0))                               AS prior_30d_daylight_events,
        SUM(IFF(event_date_local < CURRENT_DATE - 30,
                off_hours_event_count, 0))                              AS prior_30d_off_hours_events,

        -- trend
        SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                daylight_event_count, 0))
        - SUM(IFF(event_date_local < CURRENT_DATE - 30,
                  daylight_event_count, 0))                             AS daylight_event_change,
        CASE
          WHEN SUM(IFF(event_date_local < CURRENT_DATE - 30,
                       daylight_event_count, 0)) = 0
           AND SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                       daylight_event_count, 0)) > 0
          THEN 'New'
          WHEN SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                       daylight_event_count, 0))
             > SUM(IFF(event_date_local < CURRENT_DATE - 30,
                       daylight_event_count, 0))
          THEN 'Increasing'
          WHEN SUM(IFF(event_date_local >= CURRENT_DATE - 30,
                       daylight_event_count, 0))
             < SUM(IFF(event_date_local < CURRENT_DATE - 30,
                       daylight_event_count, 0))
          THEN 'Decreasing'
          ELSE 'Stable'
        END                                                             AS trend

      FROM daily_counts
      GROUP BY 1, 2
      HAVING SUM(IFF(event_date_local >= CURRENT_DATE - 30, daylight_event_count, 0)) > 0
      ORDER BY daylight_events DESC, days_with_daylight_events DESC {% endraw %} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: days_with_daylight_events {
    type: number
    sql: ${TABLE}."DAYS_WITH_DAYLIGHT_EVENTS" ;;
  }

  dimension: daylight_events {
    type: number
    sql: ${TABLE}."DAYLIGHT_EVENTS" ;;
  }

  dimension: off_hours_events {
    type: number
    sql: ${TABLE}."OFF_HOURS_EVENTS" ;;
  }

  dimension: avg_daylight_events_per_day {
    type: number
    sql: ${TABLE}."AVG_DAYLIGHT_EVENTS_PER_DAY" ;;
  }

  dimension: pct_days_with_events {
    type: number
    sql: ${TABLE}."PCT_DAYS_WITH_EVENTS" ;;
    html: {{rendered_value}}% ;;
  }

  dimension: prior_30_d_daylight_events {
    type: number
    sql: ${TABLE}."PRIOR_30D_DAYLIGHT_EVENTS" ;;
  }

  dimension: prior_30_d_off_hours_events {
    type: number
    sql: ${TABLE}."PRIOR_30D_OFF_HOURS_EVENTS" ;;
  }

  dimension: daylight_event_change {
    type: number
    sql: ${TABLE}."DAYLIGHT_EVENT_CHANGE" ;;
  }

  dimension: trend {
    type: string
    sql: ${TABLE}."TREND" ;;
  }

  # measure: view_events {
  #   type: string
  #   sql: 'View Events' ;;
  #   drill_fields: [operator_name, seat_belt_events.event_date_and_time, seat_belt_events.view_video]
  # }

  measure: view_events {
    type: number
    sql: 1 ;;
    html: <a href="#drillmenu" target="_self" style="color: #1A73E8; text-decoration: underline;">View Events</a> ;;
    drill_fields: [operator_name, seat_belt_events.event_date_and_time, seat_belt_events.view_video]
  }

  set: detail {
    fields: [
      operator_id,
      operator_name,
      days_with_daylight_events,
      daylight_events,
      off_hours_events,
      avg_daylight_events_per_day,
      pct_days_with_events,
      prior_30_d_daylight_events,
      prior_30_d_off_hours_events,
      daylight_event_change,
      trend
    ]
  }
}
