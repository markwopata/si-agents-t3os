view: dot_inspections {
  sql_table_name: "PARTS_INVENTORY"."DOT_INSPECTIONS" ;;

  dimension: basic_violations_per_inspection {
    type: number
    sql: ${TABLE}."BASIC_VIOLATIONS_PER_INSPECTION" ;;
  }
  dimension: codriver_date_of_birth {
    type: date
    sql: ${TABLE}."CODRIVER_DATE_OF_BIRTH" ;;
  }
  dimension: codriver_first_name {
    type: number
    sql: ${TABLE}."CODRIVER_FIRST_NAME" ;;
  }
  dimension: codriver_last_name {
    type: number
    sql: ${TABLE}."CODRIVER_LAST_NAME" ;;
  }
  dimension: codriver_license_number {
    type: number
    sql: ${TABLE}."CODRIVER_LICENSE_NUMBER" ;;
  }
  dimension: codriver_license_state {
    type: number
    sql: ${TABLE}."CODRIVER_LICENSE_STATE" ;;
  }
  dimension: convicted_of_a_different_charge {
    type: string
    sql: ${TABLE}."CONVICTED_OF_A_DIFFERENT_CHARGE" ;;
  }
  dimension: date_updated {
    type: date
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: hm_inspection {
    type: string
    sql: ${TABLE}."HM_INSPECTION" ;;
  }
  dimension: out_of_service {
    type: string
    sql: ${TABLE}."OUT_OF_SERVICE" ;;
  }
  dimension: placardable_hm_vehicle_inspection {
    type: string
    sql: ${TABLE}."PLACARDABLE_HM_VEHICLE_INSPECTION" ;;
  }
  dimension: primary_driver_date_of_birth {
    type: date
    sql: ${TABLE}."PRIMARY_DRIVER_DATE_OF_BIRTH" ;;
  }
  dimension: primary_driver_first_name {
    type: string
    sql: ${TABLE}."PRIMARY_DRIVER_FIRST_NAME" ;;
  }
  dimension: primary_driver_last_name {
    type: string
    sql: ${TABLE}."PRIMARY_DRIVER_LAST_NAME" ;;
  }
  dimension: primary_driver_license_number {
    type: string
    sql: ${TABLE}."PRIMARY_DRIVER_LICENSE_NUMBER" ;;
  }
  dimension: primary_driver_license_state {
    type: string
    sql: ${TABLE}."PRIMARY_DRIVER_LICENSE_STATE" ;;
  }
  dimension: report_date {
    type: date
    sql: ${TABLE}."REPORT_DATE" ;;
  }
  dimension: report_level {
    type: number
    sql: ${TABLE}."REPORT_LEVEL" ;;
  }
  dimension: report_number {
    type: string
    sql: ${TABLE}."REPORT_NUMBER" ;;
  }
  dimension: report_state {
    type: string
    sql: ${TABLE}."REPORT_STATE" ;;
  }
  dimension: time_weight {
    type: number
    sql: ${TABLE}."TIME_WEIGHT" ;;
  }
  dimension: unit {
    type: string
    sql: ${TABLE}."UNIT" ;;
  }
  dimension: vehicle_unit_1_license_number {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_1_LICENSE_NUMBER" ;;
  }
  dimension: vehicle_unit_1_license_state {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_1_LICENSE_STATE" ;;
  }
  dimension: vehicle_unit_1_make {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_1_MAKE" ;;
  }
  dimension: vehicle_unit_1_type {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_1_TYPE" ;;
  }
  dimension: vehicle_unit_1_vin {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_1_VIN" ;;
  }
  dimension: vehicle_unit_2_license_number {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_2_LICENSE_NUMBER" ;;
  }
  dimension: vehicle_unit_2_license_state {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_2_LICENSE_STATE" ;;
  }
  dimension: vehicle_unit_2_make {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_2_MAKE" ;;
  }
  dimension: vehicle_unit_2_type {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_2_TYPE" ;;
  }
  dimension: vehicle_unit_2_vin {
    type: string
    sql: ${TABLE}."VEHICLE_UNIT_2_VIN" ;;
  }
  dimension: violation_basic {
    type: string
    sql: ${TABLE}."VIOLATION_BASIC" ;;
  }
  dimension: violation_code {
    type: string
    sql: ${TABLE}."VIOLATION_CODE" ;;
  }
  dimension: violation_description {
    type: string
    sql: ${TABLE}."VIOLATION_DESCRIPTION" ;;
  }
  dimension: violation_group_description {
    type: string
    sql: ${TABLE}."VIOLATION_GROUP_DESCRIPTION" ;;
  }
  dimension: violation_severity_weight {
    type: number
    sql: ${TABLE}."VIOLATION_SEVERITY_WEIGHT" ;;
  }
  dimension: report_number_violation_code {
    type: string
    primary_key: yes
    sql: concat(${report_number},'-',${violation_code}) ;;
  }
  measure: count {
    type: count_distinct
    sql: ${report_number_violation_code} ;;
    drill_fields: [report_date, report_number, report_state, primary_driver_last_name, primary_driver_first_name, vehicle_unit_1_license_number, assets_aggregate.asset_id, violation_group_description, violation_description]
  }
}
