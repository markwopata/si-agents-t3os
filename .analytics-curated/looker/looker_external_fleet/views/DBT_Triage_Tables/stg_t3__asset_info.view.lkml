view: stg_t3__asset_info {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__ASSET_INFO" ;;

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }
  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }
  dimension: asset_class {
    label: "Class"
    type: string
    sql: COALESCE(${TABLE}."ASSET_CLASS",'Unassigned') ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: archived_status {
    type: string
    sql: COALESCE(${TABLE}."ARCHIVED_STATUS",'Active') ;;
  }
  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }
  dimension: service_branch {
    label: "Serviced By"
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: contact_in_72_hours {
    type: string
    sql: ${TABLE}."CONTACT_IN_72_HOURS" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }
  dimension_group: data_refresh_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATA_REFRESH_TIMESTAMP" ;;
  }
  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }
  dimension: esdb_tracker_id {
    type: number
    sql: ${TABLE}."ESDB_TRACKER_ID" ;;
  }
  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
    value_format_name: decimal_0
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: serial_number_vin {
    label: "Serial Num / VIN"
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }
  dimension: tracker_device_serial {
    type: string
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }
  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."TRACKER_GROUPING" ;;
  }
  dimension: tracker_tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_TRACKER_ID" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: maintenance_group_name {
    label: "Service Group Assignment"
    type: string
    sql: COALESCE(${TABLE}."MAINTENANCE_GROUP_NAME",'N/A') ;;
  }
  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }
  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [custom_name, driver_name]
  }
}
