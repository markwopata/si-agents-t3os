view: asset_last_location {
  sql_table_name: "PUBLIC"."ASSET_LAST_LOCATION"
    ;;

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

  dimension_group: last_location_timestamp {
    type: time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: location {
    group_label: "Table Value"
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: last_contact_time_formatted {
    group_label: "Created" label: "Last Contact"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: last_location_time_formatted {
    group_label: "Created" label: "Last Location"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_location_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: last_location {
    type: string
    sql: coalesce(${geofences},${address},${location}) ;;
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${last_location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  dimension: location_address_with_rental_id {
    label: "Location"
    type: string
    sql: ${last_location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/rentals/{{ rentals.rental_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  dimension: street_address_location {
    group_label: "HTML Formatted"
    label: "Address"
    type: string
    sql: ${address} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  dimension: geofence_location{
    group_label: "HTML Formatted"
    label: "Geofence"
    type: string
    sql: ${geofences} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  parameter: show_last_location_options {
    type: string
    allowed_value: { value: "Default"}
    allowed_value: { value: "Geofence"}
    allowed_value: { value: "Address"}
  }

  dimension: dynamic_last_location {
    label_from_parameter: show_last_location_options
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence_location}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${street_address_location}
    {% else %}
      NULL
    {% endif %} ;;
  }

}
