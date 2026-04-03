view: events {
  derived_table: {
    sql: SELECT
        e.event_id,
        CONVERT_TIMEZONE('America/Chicago', e.event_date) as event_date,
        afx.es_asset_id,
        da.operator_id,
        da.operator_name,
        et.name as event_type,
        et.es_category as event_category,
        et.event_points,
        e.has_video_flag
    from
    analytics.fleetcam.events e
    join analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
    join analytics.fleetcam.event_types et ON e.event_type_id = et.event_type_id
    join analytics.fleetcam.driver_assignments da
        on e.event_date BETWEEN da.assignment_time AND coalesce(da.unassignment_time,'2999-12-31'::timestamp_ntz)
        and afx.es_asset_id = da.asset_id
    where et.effective_record = TRUE ;;
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

  dimension: event_points {
    type: number
    sql: ${TABLE}."EVENT_POINTS" ;;
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

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Operator Name"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1668?Operator+Name={{operator_name._filterable_value | url_encode}}"target="_blank">
    {{rendered_value}} ➔</a>
    ;;
  }

  set: detail {
    fields: [
      event_id,
      event_date_time,
      es_asset_id,
      operator_name,
      event_type,
      event_category,
      event_points,
      has_video_flag
    ]
  }
}
