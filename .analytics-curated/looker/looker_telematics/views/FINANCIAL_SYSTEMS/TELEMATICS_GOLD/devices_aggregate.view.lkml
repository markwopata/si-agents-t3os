view: devices_aggregate {
  sql_table_name: "FINANCIAL_SYSTEMS"."TELEMATICS_GOLD"."DEVICES_AGGREGATE" ;;

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension_group: date_installed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_INSTALLED" ;;
  }
  dimension_group: date_uninstalled {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_UNINSTALLED" ;;
  }
  dimension: device_type {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }
  dimension: fk_asset_id {
    type: number
    sql: ${TABLE}."FK_ASSET_ID" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_device_id {
    type: number
    sql: ${TABLE}."FK_DEVICE_ID" ;;
  }
  dimension: pk_assignment_id {
    type: string
    sql: ${TABLE}."PK_ASSIGNMENT_ID" ;;
  }
  dimension: serial_formatted {
    type: string
    sql: ${TABLE}."SERIAL_FORMATTED" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name, asset_name]
  }
}
