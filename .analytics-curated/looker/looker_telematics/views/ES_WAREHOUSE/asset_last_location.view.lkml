# The name of this view in Looker is "Asset Last Location"
view: asset_last_location {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSET_LAST_LOCATION" ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Address" in Explore.

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: last_checkin_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_CHECKIN_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_location_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_LOCATION_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  measure: count {
    type: count
  }

  dimension: last_contact_time_formatted {
    group_label: "Created" label: "Last Contact"
    sql: ${last_checkin_timestamp_time} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} ;;
    skip_drill_filter: yes
  }

  dimension: last_location_time_formatted {
    group_label: "Created" label: "Last Location"
    sql: ${last_location_timestamp_time} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} ;;
    skip_drill_filter: yes
  }

  dimension: last_location {
    label: "Last Location"
    type: string
    sql: coalesce(${address},${location}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ address._rendered_value }}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

}
