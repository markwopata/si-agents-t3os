view: trackers_mapping {
  sql_table_name: "PUBLIC"."TRACKERS_MAPPING"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: esdb_tracker_id {
    type: number
    sql: ${TABLE}."ESDB_TRACKER_ID" ;;
  }

  dimension: keypad_controller_type_id {
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
  }

  dimension: tracker_device_serial {
    type: string
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }

  dimension: tracker_tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_TRACKER_ID" ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."tracker_grouping" ;;
  }

  dimension: asset_has_tracker {
    type: yesno
    sql: ${asset_id} is not null ;;
  }

  dimension: show_all_assets {
    type: yesno
    sql: (${asset_id} is null) or (${asset_id} is not null) ;;
  }

  parameter: only_show_assets_with_trackers {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  dimension: show_tracker_only_filter {
    label_from_parameter: only_show_assets_with_trackers
    type: yesno
    sql:{% if only_show_assets_with_trackers._parameter_value == "'Yes'" %}
      ${asset_has_tracker}
    {% elsif only_show_assets_with_trackers._parameter_value == "'No'" %}
      ${show_all_assets}
    {% else %}
      NULL
    {% endif %} ;;
    # value_format_name: percent_1
    }

  measure: count {
    type: count
    drill_fields: [asset_name]
  }
}