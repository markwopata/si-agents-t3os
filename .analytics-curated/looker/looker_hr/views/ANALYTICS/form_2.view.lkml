view: form_2 {
  sql_table_name: "INSURANCE_FORMS"."FORM_2"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: asset_ {
    type: string
    sql: ${TABLE}."ASSET_" ;;
  }

  dimension: branch_location_name {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION_NAME" ;;
  }

  dimension: date_incident_occurred {
    type: string
    sql: ${TABLE}."DATE_INCIDENT_OCCURRED" ;;
  }

  dimension: describe_the_incident_ {
    type: string
    sql: ${TABLE}."DESCRIBE_THE_INCIDENT_" ;;
  }

  dimension: email_address {
    type: string
    drill_fields: [describe_the_incident_]
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_ {
    type: string
    sql: ${TABLE}."EMPLOYEE_" ;;
  }

  dimension: employee_address {
    type: string
    sql: ${TABLE}."EMPLOYEE_ADDRESS" ;;
  }

  dimension: employee_involved {
    type: string
    sql: ${TABLE}."EMPLOYEE_INVOLVED" ;;
  }

  dimension: employee_job_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_JOB_TITLE" ;;
  }

  dimension: if_applicable_please_upload_any_photos_and_documents_ {
    type: string
    html: <font color="blue "><u><a href = {{ if_applicable_please_upload_any_photos_and_documents_._value }} target="_blank">Link to Photos and Documents</a></font></u> ;;
    sql: ${TABLE}."IF_APPLICABLE_PLEASE_UPLOAD_ANY_PHOTOS_AND_DOCUMENTS_" ;;
  }

  dimension: location_where_incident_occurred {
    type: string
    sql: ${TABLE}."LOCATION_WHERE_INCIDENT_OCCURRED" ;;
  }

  dimension: owner_s_address_type_es_if_equipment_share_is_owner_ {
    type: string
    sql: ${TABLE}."OWNER_S_ADDRESS_TYPE_ES_IF_EQUIPMENT_SHARE_IS_OWNER_" ;;
  }

  dimension: owner_s_name_type_es_if_equipment_share_is_owner_ {
    type: string
    sql: ${TABLE}."OWNER_S_NAME_TYPE_ES_IF_EQUIPMENT_SHARE_IS_OWNER_" ;;
  }

  dimension: product_make_and_model {
    type: string
    sql: ${TABLE}."PRODUCT_MAKE_AND_MODEL" ;;
  }

  dimension: select_the_appropriate_option_ {
    type: string
    sql: ${TABLE}."SELECT_THE_APPROPRIATE_OPTION_" ;;
  }

  dimension: serial_if_applicable_ {
    type: string
    sql: ${TABLE}."SERIAL_IF_APPLICABLE_" ;;
  }

  dimension: time_incident_occurred {
    type: string
    sql: ${TABLE}."TIME_INCIDENT_OCCURRED" ;;
  }

  dimension: timestamp {
    type: string
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  dimension: was_employee_in_violation_of_a_company_policy_ {
    type: string
    sql: ${TABLE}."WAS_EMPLOYEE_IN_VIOLATION_OF_A_COMPANY_POLICY_" ;;
  }

  dimension: work_order_if_applicable_ {
    type: string
    sql: ${TABLE}."WORK_ORDER_IF_APPLICABLE_" ;;
  }

  measure: count {
    type: count
    drill_fields: [branch_location_name]
  }

  set: form_2_details {
    fields: [describe_the_incident_]
  }
}
