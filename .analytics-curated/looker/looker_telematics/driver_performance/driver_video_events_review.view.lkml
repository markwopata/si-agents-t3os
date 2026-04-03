
view: driver_video_events_review {
  derived_table: {
    sql: WITH
      category_lookup AS (
        SELECT * FROM (VALUES
          ('Harsh Braking','Aggressive'),
          ('20+ MPH Over Speed Limit','Aggressive'),
          ('Following Distance Warning and Harsh Braking','Aggressive'),
          ('Harsh Braking Repeated 3+','Aggressive'),
          ('Follow Distance Warning Repeated 3+','Aggressive'),
          ('Following Distance Warning and Forward Collision Warning','Aggressive'),
          ('Driver Using Cell Phone','Distraction'),
          ('Driver Distracted','Distraction'),
          ('Driver Distracted and Harsh Braking','Distraction'),
          ('Driver Using Cell Phone and Harsh Braking','Distraction'),
          ('Forward Collision Warning','Collision'),
          ('Following Distance Warning','Collision'),
          ('Forward Collision Warning, Harsh Braking, and 20+ MPH Over Speed Limit','Collision'),
          ('Forward Collision Warning, Harsh Braking, and 10-20 MPH Over Speed Limit','Collision'),
          ('Following Distance Warning and Harsh Braking','Collision'),
          ('Forward Collision Warning and 20+ MPH Over Speed Limit','Collision'),
          ('Forward Collision Warning and 10-20 MPH Over Speed Limit','Collision'),
          ('Forward Collision Warning and Harsh Braking','Collision'),
          ('Forward Collision Warning and Following Distance Warning','Collision'),
          ('Camera Covered','Compliance'),
          ('Driver Smoking','Compliance')
        ) AS t(event_type, category)
      ),
      severity_lookup AS (
        SELECT * FROM (VALUES
          ('20+ MPH Over Speed Limit',5),
          ('Driver Using Cell Phone',5),
          ('Camera Covered',5),
          ('Driver Smoking',5),
          ('Driver Using Cell Phone and Harsh Braking',5),
          ('Forward Collision Warning, Harsh Braking, and 20+ MPH Over Speed Limit',5),
          ('Forward Collision Warning and 20+ MPH Over Speed Limit',5),
          ('Harsh Braking Repeated 3+',4),
          ('Following Distance Warning and Harsh Braking',4),
          ('Driver Distracted and Harsh Braking',4),
          ('Forward Collision Warning and Following Distance Warning',4),
          ('Following Distance Warning and Forward Collision Warning',4),
          ('Forward Collision Warning and Harsh Braking',4),
          ('Driver Distracted',3),
          ('Follow Distance Warning Repeated 3+',3),
          ('Forward Collision Warning, Harsh Braking, and 10-20 MPH Over Speed Limit',3),
          ('Harsh Braking',2),
          ('Following Distance Warning',2),
          ('Forward Collision Warning',2),
          ('Forward Collision Warning and 10-20 MPH Over Speed Limit',2)
        ) AS t(event_type, severity_tier)
      ),
      base AS (
        SELECT
            e.event_id,
            CONVERT_TIMEZONE('America/Chicago', e.event_date) AS event_date,
            afx.es_asset_id,
            da.operator_id,
            da.operator_name,
            COALESCE(et.name,'Undefined') AS event_type,
            et.es_category AS event_category_native,
            et.event_points,
            e.has_video_flag,
            DATE_TRUNC('week', e.event_date) AS event_week,
            IFF(DATE_TRUNC('week', e.event_date) = DATE_TRUNC('month', CURRENT_DATE), TRUE, FALSE) AS ineligible_for_review
        FROM
            analytics.fleetcam.events_testing e
            JOIN analytics.fleetcam.asset_fleetcam_xwalk afx
              ON e.vehicle_id = afx.fleetcam_vehicle_id
            LEFT JOIN analytics.fleetcam.event_types et
              ON e.event_type_id = et.event_type_id
            JOIN analytics.fleetcam.driver_assignments da
              ON e.event_date BETWEEN da.assignment_time AND COALESCE(da.unassignment_time, '2999-12-31'::TIMESTAMP_NTZ)
             AND afx.es_asset_id = da.asset_id
        WHERE
            et.effective_record = TRUE
            AND e.has_video_flag = 1
      )
      SELECT
          b.event_id,
          b.event_date,
          b.es_asset_id,
          b.operator_id,
          b.operator_name,
          b.event_type,
          COALESCE(cl.category, b.event_category_native, 'Undefined') AS event_category,
          sl.severity_tier,
          b.event_points,
          b.has_video_flag,
          b.event_week,
          b.ineligible_for_review
      FROM base b
      LEFT JOIN category_lookup cl ON b.event_type = cl.event_type
      LEFT JOIN severity_lookup sl ON b.event_type = sl.event_type
      WHERE event_category <> 'Undefined'
      QUALIFY ROW_NUMBER() OVER (PARTITION BY b.event_id ORDER BY b.event_date DESC) = 1;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension_group: event_date {
    type: time
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension: es_asset_id {
    type: number
    sql: ${TABLE}."ES_ASSET_ID" ;;
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  dimension: severity_tier {
    type: number
    sql: ${TABLE}."SEVERITY_TIER" ;;
  }

  dimension: event_points {
    type: number
    sql: ${TABLE}."EVENT_POINTS" ;;
  }

  dimension: has_video_flag {
    type: yesno
    sql: ${TABLE}."HAS_VIDEO_FLAG" ;;
  }

  dimension_group: event_week {
    type: time
    sql: ${TABLE}."EVENT_WEEK" ;;
  }

  dimension: ineligible_for_review {
    type: yesno
    sql: ${TABLE}."INELIGIBLE_FOR_REVIEW" ;;
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

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Driver"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2227?Driver={{ operator_name._filterable_value | url_encode}}"target="_blank">
    {{rendered_value}} ➔</a></font>;;
  }

  set: detail {
    fields: [
        event_id,
  event_date_time,
  es_asset_id,
  operator_id,
  operator_name,
  event_type,
  event_category,
  severity_tier,
  event_points,
  has_video_flag,
  event_week_time,
  ineligible_for_review
    ]
  }
}
