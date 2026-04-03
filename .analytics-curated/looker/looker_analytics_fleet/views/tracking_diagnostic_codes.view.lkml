view: tracking_diagnostic_codes {
  sql_table_name: "PUBLIC"."TRACKING_DIAGNOSTIC_CODES"
    ;;
  # drill_fields: [tracking_diagnostic_codes_id]

  dimension: tracking_diagnostic_codes_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKING_DIAGNOSTIC_CODES_ID" ;;
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension_group: cleared {
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
    sql: CAST(${TABLE}."CLEARED" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: code {
    label: "Fault Code"
    type: string
    sql: ${TABLE}."CODE" ;;
  }

  dimension: failure_mode_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."FAILURE_MODE_IDENTIFIER" ;;
    hidden: yes
  }

  dimension_group: last_seen {
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
    sql: CAST(${TABLE}."LAST_SEEN" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: level {
    type: number
    sql: ${TABLE}."LEVEL" ;;
    hidden: yes
  }

  dimension: module_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."MODULE_IDENTIFIER" ;;
    hidden: yes
  }

  dimension: occurrences {
    type: number
    sql: ${TABLE}."OCCURRENCES" ;;
    hidden: yes
  }

  dimension_group: report_timestamp {
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
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: suspect_parameter_number {
    type: number
    sql: ${TABLE}."SUSPECT_PARAMETER_NUMBER" ;;
    hidden: yes
  }

  dimension: tracking_event_id {
    type: number
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
    hidden: yes
  }

  dimension: tracking_obd_dtc_code_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRACKING_OBD_DTC_CODE_ID" ;;
    hidden: yes
  }

  dimension_group: vendor_timestamp {
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
    sql: CAST(${TABLE}."VENDOR_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: asset_has_dtc_code {
    type: yesno
    sql: ${code} is not null and ${report_timestamp_raw} is not null ;;
    hidden: yes
  }

  measure: code_groups {
    label: "Code(s)"
    type: list
    list_field: code
  }

  measure: description_groups {
    label: "Details"
    type: list
    list_field: tracking_obd_dtc_codes.description
    hidden: yes
  }

  dimension: link_to_diagnostic_codes {
    type: string
    sql: ${asset_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ asset_id._filterable_value }}/service/diagnostic-codes" target="_blank">Link To Diagnostic Code</a></font></u>;;
  }

  measure: number_of_codes {
    type: count_distinct
    sql: ${assets.asset_id} ;;
    filters: [asset_has_dtc_code: "yes"]
    drill_fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, trackers.tracker_information, number_of_unique_dtc_codes, link_to_diagnostic_codes, code_groups, failure_mode_identifiers.description_groups, suspect_parameter_numbers.description_groups]
  }
  # description_groups

  measure: number_of_unique_dtc_codes {
    type: count_distinct
    sql: ${code} ;;
    filters: [asset_has_dtc_code: "yes"]
  }

}
