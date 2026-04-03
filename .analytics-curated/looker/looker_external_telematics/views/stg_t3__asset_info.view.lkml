view: stg_t3__asset_info {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__ASSET_INFO" ;;

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
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
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: ownership {
    hidden: yes
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: serial_number_vin {
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

  dimension: ownership_filter {
    label: "Ownership"
    type: string
    sql: case when {{ _user_attributes['company_id'] }}::numeric = ${company_id} then 'Owned'
          else 'Rented'
          end ;;
  }


  measure: count {
    type: count
    drill_fields: [custom_name, driver_name]
  }
}
