view: firmware_watch {
  derived_table: {
    sql: SELECT
          e.event_id,
          e.event_date,
          e.has_video_flag,
          afx.device_serial
      FROM analytics.fleetcam.events e
      JOIN analytics.fleetcam.event_types et ON e.event_type_id = et.event_type_id
      JOIN analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
      WHERE et.name = 'No Seat Belt'
        AND afx.device_serial IN ('003F00B1A1',
                                  '003F0071B1',
                                  '003F007976',
                                  '003F006FEF',
                                  '003F007270',
                                  '003F00AD82',
                                  '003F0064D6',
                                  '003F00A861',
                                  '003F006D7D',
                                  '003F006EBC') ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_detail {
    type: count
    drill_fields: [device_drill*]
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension_group: event_date {
    type: time
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension: has_video_flag {
    type: yesno
    sql: ${TABLE}."HAS_VIDEO_FLAG" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
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

  measure: count_003F00B1A1 {
    label: "003F00B1A1"
    type: count
    filters: [device_serial: "003F00B1A1"]
    drill_fields: [device_drill*]
  }

  measure: count_003F0071B1 {
    label: "003F0071B1"
    type: count
    filters: [device_serial: "003F0071B1"]
    drill_fields: [device_drill*]
  }

  measure: count_003F007976 {
    label: "003F007976"
    type: count
    filters: [device_serial: "003F007976"]
    drill_fields: [device_drill*]
  }

  measure: count_003F006FEF {
    label: "003F006FEF"
    type: count
    filters: [device_serial: "003F006FEF"]
    drill_fields: [device_drill*]
  }

  measure: count_003F007270 {
    label: "003F007270"
    type: count
    filters: [device_serial: "003F007270"]
    drill_fields: [device_drill*]
  }

  measure: count_003F00AD82 {
    label: "003F00AD82"
    type: count
    filters: [device_serial: "003F00AD82"]
    drill_fields: [device_drill*]
  }

  measure: count_003F0064D6 {
    label: "003F0064D6"
    type: count
    filters: [device_serial: "003F0064D6"]
    drill_fields: [device_drill*]
  }

  measure: count_003F00A861 {
    label: "003F00A861"
    type: count
    filters: [device_serial: "003F00A861"]
    drill_fields: [device_drill*]
  }

  measure: count_003F006D7D {
    label: "003F006D7D"
    type: count
    filters: [device_serial: "003F006D7D"]
    drill_fields: [device_drill*]
  }

  measure: count_003F006EBC {
    label: "003F006EBC"
    type: count
    filters: [device_serial: "003F006EBC"]
    drill_fields: [device_drill*]
  }

  set: detail {
    fields: [
      event_date_date,
      device_serial,
      count_detail
    ]
  }

  set: device_drill {
    fields: [
      event_date_time,
      device_serial,
      view_video
    ]
  }
}
