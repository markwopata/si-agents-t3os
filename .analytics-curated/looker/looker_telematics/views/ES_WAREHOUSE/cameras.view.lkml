# The name of this view in Looker is "Cameras"
view: cameras {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CAMERAS"
    ;;
  drill_fields: [vendor_camera_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: vendor_camera_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."VENDOR_CAMERA_ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Camera ID" in Explore.

  dimension: camera_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CAMERA_ID" ;;
  }

  dimension: camera_vendor_id {
    type: number
    sql: ${TABLE}."CAMERA_VENDOR_ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: number_of_feeds {
    type: number
    sql: ${TABLE}."NUMBER_OF_FEEDS" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_number_of_feeds {
    type: sum
    sql: ${number_of_feeds} ;;
  }

  measure: average_number_of_feeds {
    type: average
    sql: ${number_of_feeds} ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [vendor_camera_id, cameras.vendor_camera_id, cameras.count]
  }
}
