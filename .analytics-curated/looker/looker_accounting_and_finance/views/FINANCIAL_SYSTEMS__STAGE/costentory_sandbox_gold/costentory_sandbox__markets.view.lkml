view: costentory_sandbox__markets {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__MARKETS" ;;

  dimension: address_city {
    type: string
    sql: ${TABLE}."ADDRESS_CITY" ;;
  }
  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }
  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }
  dimension: address_state {
    type: string
    sql: ${TABLE}."ADDRESS_STATE" ;;
  }
  dimension: address_zip_code {
    type: string
    sql: ${TABLE}."ADDRESS_ZIP_CODE" ;;
  }
  dimension: email_sales {
    type: string
    sql: ${TABLE}."EMAIL_SALES" ;;
  }
  dimension: email_service {
    type: string
    sql: ${TABLE}."EMAIL_SERVICE" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: fk_district_id {
    type: number
    sql: ${TABLE}."FK_DISTRICT_ID" ;;
  }
  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
  }
  dimension: fk_p1_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_P1_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: fk_p2_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_P2_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: fk_p3_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_P3_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: fk_p4_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_P4_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: fk_p5_department_id_intacct {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_P5_DEPARTMENT_ID_INTACCT" ;;
  }
  dimension: is_active_in_platform {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE_IN_PLATFORM" ;;
  }
  dimension: is_default_branch {
    type: yesno
    sql: ${TABLE}."IS_DEFAULT_BRANCH" ;;
  }
  dimension: is_eligible_to_post {
    type: yesno
    sql: ${TABLE}."IS_ELIGIBLE_TO_POST" ;;
  }
  dimension: is_location_jobsite {
    type: yesno
    sql: ${TABLE}."IS_LOCATION_JOBSITE" ;;
  }
  dimension: is_location_needs_review {
    type: yesno
    sql: ${TABLE}."IS_LOCATION_NEEDS_REVIEW" ;;
  }
  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }
  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }
  dimension: is_status_mismatch {
    type: yesno
    sql: ${TABLE}."IS_STATUS_MISMATCH" ;;
  }
  dimension: is_unmapped_market_in_sage {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_MARKET_IN_SAGE" ;;
  }
  dimension: name_intacct_department {
    type: number
    sql: ${TABLE}."NAME_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }
  dimension: name_market {
    type: string
    sql: ${TABLE}."NAME_MARKET" ;;
  }
  dimension: name_market_abbreviation {
    type: string
    sql: ${TABLE}."NAME_MARKET_ABBREVIATION" ;;
  }
  dimension: name_market_canonical {
    type: string
    sql: ${TABLE}."NAME_MARKET_CANONICAL" ;;
  }
  dimension: name_p1_intacct_department {
    type: number
    sql: ${TABLE}."NAME_P1_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_p2_intacct_department {
    type: number
    sql: ${TABLE}."NAME_P2_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_p3_intacct_department {
    type: number
    sql: ${TABLE}."NAME_P3_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_p4_intacct_department {
    type: number
    sql: ${TABLE}."NAME_P4_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_p5_intacct_department {
    type: number
    sql: ${TABLE}."NAME_P5_INTACCT_DEPARTMENT" ;;
  }
  dimension: name_state_abbreviation {
    type: string
    sql: ${TABLE}."NAME_STATE_ABBREVIATION" ;;
  }
  dimension: pk_market_id_platform {
    type: number
    value_format_name: id
    sql: ${TABLE}."PK_MARKET_ID_PLATFORM" ;;
    primary_key: yes
  }
  dimension: status_market_intacct {
    type: string
    sql: ${TABLE}."STATUS_MARKET_INTACCT" ;;
  }
  dimension: status_p1_intacct_department {
    type: string
    sql: ${TABLE}."STATUS_P1_INTACCT_DEPARTMENT" ;;
  }
  dimension: status_p2_intacct_department {
    type: string
    sql: ${TABLE}."STATUS_P2_INTACCT_DEPARTMENT" ;;
  }
  dimension: status_p3_intacct_department {
    type: string
    sql: ${TABLE}."STATUS_P3_INTACCT_DEPARTMENT" ;;
  }
  dimension: status_p4_intacct_department {
    type: string
    sql: ${TABLE}."STATUS_P4_INTACCT_DEPARTMENT" ;;
  }
  dimension: status_p5_intacct_department {
    type: string
    sql: ${TABLE}."STATUS_P5_INTACCT_DEPARTMENT" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
