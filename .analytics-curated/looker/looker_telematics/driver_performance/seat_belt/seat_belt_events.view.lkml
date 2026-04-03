
view: seat_belt_events {
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
          e.event_date,
          e.event_id,
          e.vehicle_id,
          e.has_video_flag,
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
        AND e.event_date >= DATEADD('day', -30, CURRENT_DATE)
      )

      SELECT
        operator_id,
        operator_name,
        event_id,
        vehicle_id,
        event_date,
        event_ts_local,
        time_of_day_label,
        has_video_flag
      FROM base_events
      where has_video_flag = true
      {% endraw %} ;;
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

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: vehicle_id {
    type: number
    sql: ${TABLE}."VEHICLE_ID" ;;
  }

  dimension_group: event_date {
    type: time
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension_group: event_ts_local {
    type: time
    sql: ${TABLE}."EVENT_TS_LOCAL" ;;
  }

  dimension: time_of_day_label {
    type: string
    sql: ${TABLE}."TIME_OF_DAY_LABEL" ;;
  }

  dimension: has_video_flag {
    type: yesno
    sql: ${TABLE}."HAS_VIDEO_FLAG" ;;
  }

  dimension: event_date_and_time {
    group_label: "HTML Formatted Date and Time"
    label: "Event Date and Time"
    type: date_time
    sql: ${event_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} ;;
  }

  dimension: view_video {
    type: string
    sql: ${event_id} ;;
    html:
    {% if has_video_flag._value == 'Yes' %}
    <font color="#0063f3"><a href="https://fleetcam.estrack.com/gps/gtcoaching/?section1=driverbehavior&mode=0&tab=events&sdate={{event_date_date._value | date: "%m/%d/%Y" }}&edate={{event_date_date._value | date: "%m/%d/%Y" }}&ampsection2=fcplayer&eventid={{event_id._value | url_encode }}" target="_blank">View Video Clip ➔</a></font>
    {% else %}
    No Video Available
    {% endif %}
    ;;
  }

  set: detail {
    fields: [
        operator_id,
  operator_name,
  event_id,
  vehicle_id,
  event_date_time,
  event_ts_local_time,
  time_of_day_label,
  has_video_flag
    ]
  }
}
