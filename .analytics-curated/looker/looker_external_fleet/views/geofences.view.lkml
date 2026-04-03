view: geofences {
  sql_table_name: "PUBLIC"."GEOFENCES"
    ;;
  drill_fields: [geofence_id]

  dimension: geofence_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

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

  dimension: alert_enter {
    type: yesno
    sql: ${TABLE}."ALERT_ENTER" ;;
  }

  dimension: alert_exit {
    type: yesno
    sql: ${TABLE}."ALERT_EXIT" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension_group: deleted {
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
    sql: CAST(${TABLE}."DELETED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: geofence_type_id {
    type: number
    sql: ${TABLE}."GEOFENCE_TYPE_ID" ;;
  }

  dimension: geojson {
    type: string
    sql: ${TABLE}."GEOJSON" ;;
  }

  dimension: geom {
    type: string
    sql: ${TABLE}."GEOM" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  measure: geofence_list {
    group_label: "Geofence List"
    label: "Geofence"
    type: list
    list_field: geofence_name
    # required_fields: [name]
  }

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: name {
    label: "Geofence"
    type: string
    sql: ${TABLE}."NAME" ;;
    required_fields: [geofence_id]
    html:
    <u>
    <font color="#0063f3"><a href="https://app.estrack.com/#/geofences/{{ geofence_id._value }}"
    target= "_blank" ><p >{{value}}</p> </a></u>
  ;;
  }

    # {% if _explore._name == "asset_geofence_details" %}
    # <p style="color: dimgrey><font color="dimgrey"><u><a href="https://app.estrack.com/#/home/geofences/{{ geofences.geofence_id._filterable_value }}" target="_blank">{{value}}</a></font></u></p>
    # {% else %}
    # <p style="color: blue; font-weight: bold"><font color="blue"><u><a href="https://app.estrack.com/#/home/geofences/{{ geofences.geofence_id._filterable_value }}" target="_blank">{{value}}</a></font></u></p>
    # {% endif %}

  dimension: time_fence_id {
    type: number
    sql: ${TABLE}."TIME_FENCE_ID" ;;
  }

  dimension: link_to_geofence_map {
    type: string
    sql: ${location_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/geofences/{{ geofences.geofence_id._filterable_value }}" target="_blank">View Geofence Map</a></font></u>
    ;;
  }



  measure: count {
    type: count
    drill_fields: [geofence_id, name, asset_geofence_encounters.count]
  }
}
