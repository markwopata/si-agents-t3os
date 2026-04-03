view: tracker_types {
  sql_table_name: "PUBLIC"."TRACKER_TYPES"
    ;;
  drill_fields: [tracker_type_id]

  dimension: tracker_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_TYPE_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    view_label: "Trackers"
    label: "Tracker Type Description"
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
    hidden: yes
  }

  dimension: is_ble_node {
    type: yesno
    sql: ${TABLE}."IS_BLE_NODE" ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    view_label: "Trackers"
    label: "Tracker Name"
  }

  dimension: tracker_vendor_id {
    type: number
    sql: ${TABLE}."TRACKER_VENDOR_ID" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [tracker_type_id, name]
    view_label: "Trackers"
    label: "Tracker Type Count"
  }
}
