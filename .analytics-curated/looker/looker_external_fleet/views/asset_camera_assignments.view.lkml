# The name of this view in Looker is "Asset Camera Assignments"
view: asset_camera_assignments {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "PUBLIC"."ASSET_CAMERA_ASSIGNMENTS" ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Asset Camera ID" in Explore.

  dimension: asset_camera_id {
    type: number
    sql: ${TABLE}."ASSET_CAMERA_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: camera_id {
    type: number
    sql: ${TABLE}."CAMERA_ID" ;;
  }

  dimension_group: date_installed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_INSTALLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_uninstalled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UNINSTALLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${camera_id},${date_installed_date}) ;;
  }

  dimension: camera_install_date {
    group_label: "HTML Formatted Date"
    label: "Camera Install Date"
    type: date
    sql: ${date_installed_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: count {
    type: count
  }
}
