view: asset_last_location {
  sql_table_name: "PUBLIC"."ASSET_LAST_LOCATION"
    ;;

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
    hidden: yes
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
    hidden: yes
  }

  dimension_group: last_location_timestamp {
    type: time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
    hidden: yes
  }

  dimension: location {
    group_label: "Table Value"
    type: string
    sql: ${TABLE}."LOCATION" ;;
    hidden: yes
  }

  dimension: last_contact_time_formatted {
   label: "Last Contact"
    sql: convert_timezone(('{{ _user_attributes['company_timezone'] }}'),${last_checkin_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
    skip_drill_filter: yes
    view_label: "Assets"
    group_label: "Assets Last Known Location"
  }

  dimension: last_location_time_formatted {
    label: "Last Location"
    sql: convert_timezone(('{{ _user_attributes['company_timezone'] }}'),${last_location_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
    skip_drill_filter: yes
    view_label: "Assets"
    group_label: "Assets Last Known Location"
  }

  measure: count {
    type: count
    drill_fields: []
    hidden: yes
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    hidden: yes
  }

  dimension: last_location {
    type: string
    sql: coalesce(${geofences},${address},${location}) ;;
    hidden: yes
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${last_location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
    view_label: "Assets"
    group_label: "Assets Last Known Location"
  }

  dimension: location_address_with_rental_id {
    label: "Location"
    type: string
    sql: ${last_location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/rentals/{{ rentals.rental_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
    hidden: yes
  }

}
