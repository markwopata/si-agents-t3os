view: ff_out_rep_subproject_capsule {
  sql_table_name: "DODGE"."FF_OUT_REP_SUBPROJECT_CAPSULE"
    ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

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

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
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
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: addenda_ind {
    type: string
    sql: ${TABLE}."ADDENDA_IND" ;;
  }

  dimension: available_from {
    type: string
    sql: ${TABLE}."AVAILABLE_FROM" ;;
  }

  dimension: available_from_code {
    type: number
    sql: ${TABLE}."AVAILABLE_FROM_CODE" ;;
  }

  dimension: bid_date {
    type: number
    sql: ${TABLE}."BID_DATE" ;;
  }

  dimension: bid_submit_to {
    type: string
    sql: ${TABLE}."BID_SUBMIT_TO" ;;
  }

  dimension: bid_time {
    type: string
    sql: ${TABLE}."BID_TIME" ;;
  }

  dimension: bid_zone {
    type: string
    sql: ${TABLE}."BID_ZONE" ;;
  }

  dimension: cn_project_url {
    type: string
    sql: ${TABLE}."CN_PROJECT_URL" ;;
  }

  dimension: contract_nbr {
    type: string
    sql: ${TABLE}."CONTRACT_NBR" ;;
  }

  dimension: currency_type {
    type: string
    sql: ${TABLE}."CURRENCY_TYPE" ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}."DR_NBR" ;;
  }

  dimension: dr_ver {
    type: number
    sql: ${TABLE}."DR_VER" ;;
  }

  dimension: est_high {
    type: number
    sql: ${TABLE}."EST_HIGH" ;;
  }

  dimension: est_high_value {
    type: number
    sql: ${TABLE}."EST_HIGH_VALUE" ;;
  }

  dimension: est_low {
    type: string
    sql: ${TABLE}."EST_LOW" ;;
  }

  dimension: est_low_value {
    type: number
    sql: ${TABLE}."EST_LOW_VALUE" ;;
  }

  dimension: first_issue_bid_stage_ind {
    type: string
    sql: ${TABLE}."FIRST_ISSUE_BID_STAGE_IND" ;;
  }

  dimension: first_publish_date {
    type: number
    sql: ${TABLE}."FIRST_PUBLISH_DATE" ;;
  }

  dimension: framing {
    type: string
    sql: ${TABLE}."FRAMING" ;;
  }

  dimension: nbr_of_bldg {
    type: number
    sql: ${TABLE}."NBR_OF_BLDG" ;;
  }

  dimension: nbr_of_story_ag {
    type: number
    sql: ${TABLE}."NBR_OF_STORY_AG" ;;
  }

  dimension: nbr_of_story_bg {
    type: number
    sql: ${TABLE}."NBR_OF_STORY_BG" ;;
  }

  dimension: p_addr_line_1 {
    type: string
    sql: ${TABLE}."P_ADDR_LINE_1" ;;
  }

  dimension: p_city_name {
    type: string
    sql: ${TABLE}."P_CITY_NAME" ;;
  }

  dimension: p_country_id {
    type: string
    sql: ${TABLE}."P_COUNTRY_ID" ;;
  }

  dimension: p_county_name {
    type: string
    sql: ${TABLE}."P_COUNTY_NAME" ;;
  }

  dimension: p_state_id {
    type: string
    sql: ${TABLE}."P_STATE_ID" ;;
  }

  dimension: p_zip_code {
    type: string
    sql: ${TABLE}."P_ZIP_CODE" ;;
  }

  dimension: p_zip_code_2 {
    type: number
    sql: ${TABLE}."P_ZIP_CODE_2" ;;
  }

  dimension: plan_available_ind {
    type: string
    sql: ${TABLE}."PLAN_AVAILABLE_IND" ;;
  }

  dimension: plan_ind {
    type: string
    sql: ${TABLE}."PLAN_IND" ;;
  }

  dimension: proj_dlvry_sys {
    type: string
    sql: ${TABLE}."PROJ_DLVRY_SYS" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  dimension: publish_date {
    type: number
    sql: ${TABLE}."PUBLISH_DATE" ;;
  }

  dimension: report_type {
    type: string
    sql: ${TABLE}."REPORT_TYPE" ;;
  }

  dimension: source_rlse_date {
    type: number
    sql: ${TABLE}."SOURCE_RLSE_DATE" ;;
  }

  dimension: spec_ind {
    type: string
    sql: ${TABLE}."SPEC_IND" ;;
  }

  dimension: square_footage {
    type: number
    sql: ${TABLE}."SQUARE_FOOTAGE" ;;
  }

  dimension: square_footage_uom {
    type: string
    sql: ${TABLE}."SQUARE_FOOTAGE_UOM" ;;
  }

  dimension: status_proj_dlvry_sys {
    type: string
    sql: ${TABLE}."STATUS_PROJ_DLVRY_SYS" ;;
  }

  dimension: status_text {
    type: string
    sql: ${TABLE}."STATUS_TEXT" ;;
  }

  dimension: std_county_name {
    type: string
    sql: ${TABLE}."STD_COUNTY_NAME" ;;
  }

  dimension: std_fips_code {
    type: number
    sql: ${TABLE}."STD_FIPS_CODE" ;;
  }

  dimension: sub_proj_count {
    type: number
    sql: ${TABLE}."SUB_PROJ_COUNT" ;;
  }

  dimension: target_finish_date {
    type: number
    sql: ${TABLE}."TARGET_FINISH_DATE" ;;
  }

  dimension: target_start_date {
    type: number
    sql: ${TABLE}."TARGET_START_DATE" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  measure: count {
    type: count
    drill_fields: [std_county_name, p_city_name, p_county_name]
  }
}
