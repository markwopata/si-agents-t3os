view: fact_monday_dot_techs {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."FACT_MONDAY_DOT_TECHS" ;;

  dimension_group: date_of_request {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF_REQUEST" ;;
  }
  dimension_group: dot_tech_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DOT_TECH_RECORDTIMESTAMP" ;;
  }
  dimension: last_date_of_dot_unit_inspection {
    type: string
    sql: ${TABLE}."LAST_DATE_OF_DOT_UNIT_INSPECTION" ;;
  }
  dimension: link_to_certification_doc {
    type: string
    sql: ${TABLE}."LINK_TO_CERTIFICATION_DOC" ;;
  }
  dimension: link_to_resume_doc {
    type: string
    sql: ${TABLE}."LINK_TO_RESUME_DOC" ;;
  }
  dimension: link_to_signed_piq_form {
    type: string
    sql: ${TABLE}."LINK_TO_SIGNED_PIQ_FORM" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
  }
  dimension: monday_tech_id {
    type: string
    sql: ${TABLE}."MONDAY_TECH_ID" ;;
  }
  dimension_group: most_recent_fivetran_update {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MOST_RECENT_FIVETRAN_UPDATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: most_recent_monday_update {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MOST_RECENT_MONDAY_UPDATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: request_date_key {
    type: string
    sql: ${TABLE}."REQUEST_DATE_KEY" ;;
  }
  dimension: request_group {
    type: string
    sql: ${TABLE}."REQUEST_GROUP" ;;
  }
  dimension: request_status {
    type: string
    sql: ${TABLE}."REQUEST_STATUS" ;;
  }
  dimension: requestor_email {
    type: string
    sql: ${TABLE}."REQUESTOR_EMAIL" ;;
  }
  dimension: tech_email {
    type: string
    sql: ${TABLE}."TECH_EMAIL" ;;
  }
  dimension: tech_employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TECH_EMPLOYEE_ID" ;;
  }
  dimension: tech_has_certification_doc {
    type: yesno
    sql: ${TABLE}."TECH_HAS_CERTIFICATION_DOC" ;;
  }
  dimension: tech_has_resume {
    type: yesno
    sql: ${TABLE}."TECH_HAS_RESUME" ;;
  }
  dimension: tech_has_signed_piq {
    type: yesno
    sql: ${TABLE}."TECH_HAS_SIGNED_PIQ" ;;
  }
  dimension: tech_is_approved {
    type: yesno
    sql: ${TABLE}."TECH_IS_APPROVED" ;;
  }
  dimension: tech_is_denied {
    type: yesno
    sql: ${TABLE}."TECH_IS_DENIED" ;;
  }
  dimension: tech_manager {
    type: string
    sql: ${TABLE}."TECH_MANAGER" ;;
  }
  dimension: tech_manager_id {
    type: number
    sql: ${TABLE}."TECH_MANAGER_ID" ;;
  }
  dimension: tech_name {
    type: string
    sql: ${TABLE}."TECH_NAME" ;;
  }
  dimension: tech_type {
    type: string
    sql: ${TABLE}."TECH_TYPE" ;;
  }
  dimension: tech_years_experience {
    type: string
    sql: ${TABLE}."TECH_YEARS_EXPERIENCE" ;;
  }
  measure: count {
    type: count
    drill_fields: [tech_name,request_status]
  }
  measure: count_air_brake {
    type: count
    filters: [tech_type: "Air Brake",request_status: "Air Brake Approved"]
    drill_fields: [market_region_xwalk.region_name,
                   count_air_brake_market_lvl
                  ]
  }
  measure: count_nonair_brake {
    type: count
    filters: [tech_type: "Non-Air Brake",request_status: "Non- Air Brake Techs, Air Brake Approved"]
    drill_fields: [market_region_xwalk.region_name,
                   count_nonair_brake_market_lvl
                  ]
  }
  measure: count_air_brake_market_lvl {
    hidden: yes
    type: count
    filters: [tech_type: "Air Brake",request_status: "Air Brake Approved"]
    drill_fields: [market_region_xwalk.market_name,
                   count_air_brake_tech_lvl
                  ]
  }
  measure: count_nonair_brake_market_lvl {
    hidden: yes
    type: count
    filters: [tech_type: "Non-Air Brake",request_status: "Non- Air Brake Techs, Air Brake Approved"]
    drill_fields: [market_region_xwalk.market_name,
                   count_nonair_brake_tech_lvl
                  ]
  }
  measure: count_air_brake_tech_lvl {
    hidden: yes
    type: count
    filters: [tech_type: "Air Brake",request_status: "Air Brake Approved"]
    drill_fields: [tech_employee_id,
                  tech_name,
                  tech_type,
                  tech_years_experience,
                  tech_is_approved,
                  last_date_of_dot_unit_inspection,
                  tech_email,
                  tech_manager,
                  requestor_email,
                  request_status
                  ]
  }
  measure: count_nonair_brake_tech_lvl {
    hidden: yes
    type: count
    filters: [tech_type: "Non-Air Brake",request_status: "Non- Air Brake Techs, Air Brake Approved"]
    drill_fields: [tech_employee_id,
                  tech_name,
                  tech_type,
                  tech_years_experience,
                  tech_is_approved,
                  last_date_of_dot_unit_inspection,
                  tech_email,
                  tech_manager,
                  requestor_email,
                  request_status
                  ]
  }
}
