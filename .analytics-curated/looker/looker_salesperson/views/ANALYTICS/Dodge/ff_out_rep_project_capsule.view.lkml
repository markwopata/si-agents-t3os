view: ff_out_rep_project_capsule {
  sql_table_name: "DODGE"."FF_OUT_REP_PROJECT_CAPSULE"
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
    type: string
    sql: ${TABLE}."AVAILABLE_FROM_CODE" ;;
  }

  dimension: bid_date {
    type: number
    sql: ${TABLE}."BID_DATE" ;;
  }

  dimension: bid_date_format {
    type: date
    sql: (substring(${bid_date},1,4)||'-'||substring(${bid_date},5,2)||'-'||substring(${bid_date},7,2))::date ;;
  }

  dimension: bid_submit_to {
    type: string
    sql: ${TABLE}."BID_SUBMIT_TO" ;;
  }

  dimension: bid_time {
    type: string
    sql: ${TABLE}."BID_TIME" ;;
  }

  dimension: bid_timestamp_text {
    type: string
    sql: ${TABLE}."BID_TIMESTAMP_TEXT" ;;
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

  dimension: deposit_amt {
    type: number
    sql: ${TABLE}."DEPOSIT_AMT" ;;
  }

  dimension: dimension_uom {
    type: string
    sql: ${TABLE}."DIMENSION_UOM" ;;
  }

  dimension: dimension_val_1 {
    type: number
    sql: ${TABLE}."DIMENSION_VAL_1" ;;
  }

  dimension: dimension_val_2 {
    type: number
    sql: ${TABLE}."DIMENSION_VAL_2" ;;
  }

  dimension: dr_break_away_from {
    type: number
    sql: ${TABLE}."DR_BREAK_AWAY_FROM" ;;
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
    type: string
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

  dimension: item_text {
    type: string
    sql: ${TABLE}."ITEM_TEXT" ;;
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

  dimension: owner_class {
    type: string
    sql: ${TABLE}."OWNER_CLASS" ;;
  }

  dimension: owner_class_code {
    type: number
    sql: ${TABLE}."OWNER_CLASS_CODE" ;;
  }

  dimension: p_addr_line_1 {
    type: string
    sql: ${TABLE}."P_ADDR_LINE_1" ;;
  }

  dimension: p_addr_line_2 {
    type: string
    sql: ${TABLE}."P_ADDR_LINE_2" ;;
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
    sql: substring(${TABLE}."P_ZIP_CODE",0,5) ;;
  }

  dimension: p_zip_code_5 {
    type: number
    sql: ${TABLE}."P_ZIP_CODE_5" ;;
  }

  dimension: permit_issue_date {
    type: number
    sql: ${TABLE}."PERMIT_ISSUE_DATE" ;;
  }

  dimension: plan_available_ind {
    type: string
    sql: ${TABLE}."PLAN_AVAILABLE_IND" ;;
  }

  dimension: plan_ind {
    type: string
    sql: ${TABLE}."PLAN_IND" ;;
  }

  dimension: plan_remark {
    type: string
    sql: ${TABLE}."PLAN_REMARK" ;;
  }

  dimension: prior_publish_date {
    type: number
    sql: ${TABLE}."PRIOR_PUBLISH_DATE" ;;
  }

  dimension: proj_dlvry_sys {
    type: string
    sql: ${TABLE}."PROJ_DLVRY_SYS" ;;
  }

  dimension: proj_title_index {
    type: string
    sql: ${TABLE}."PROJ_TITLE_INDEX" ;;
  }

  dimension: proj_type {
    type: string
    sql: ${TABLE}."PROJ_TYPE" ;;
  }

  dimension: proj_type_code {
    type: number
    sql: ${TABLE}."PROJ_TYPE_CODE" ;;
  }

  dimension: publish_date {
    type: number
    sql: ${TABLE}."PUBLISH_DATE" ;;
  }

  dimension: publish_date_format {
    type:  date
    sql:  (substring(${publish_date},1,4)||'-'||substring(${publish_date},5,2)||'-'||substring(${publish_date},7,2))::date ;;
  }

  dimension: refund_pct {
    type: number
    sql: ${TABLE}."REFUND_PCT" ;;
  }

  dimension: report_type {
    type: string
    sql: ${TABLE}."REPORT_TYPE" ;;
  }

  dimension: source_of_funding {
    type: string
    sql: ${TABLE}."SOURCE_OF_FUNDING" ;;
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

  dimension: stage_code {
    type: string
    sql: ${TABLE}."STAGE_CODE" ;;
  }

  dimension: stage_desc {
    type: string
    sql: ${TABLE}."STAGE_DESC" ;;
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

  dimension: stdin_text {
    type: string
    sql: ${TABLE}."STDIN_TEXT" ;;
  }

  dimension: sub_proj_count {
    type: number
    sql: ${TABLE}."SUB_PROJ_COUNT" ;;
  }

  dimension: target_bid_date {
    type: number
    sql: ${TABLE}."TARGET_BID_DATE" ;;
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

  dimension: project {
    type: string
    link: {
      label: "Dodge Project Firms"
      url: "https://equipmentshare.looker.com/dashboards/186?Project={{ title._value | url_encode }}"
    }
    sql: ${title} ;;
  }

  dimension: work_type {
    type: string
    sql: ${TABLE}."WORK_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [std_county_name, p_county_name, p_city_name]
  }

  dimension: project_market {
    type: string
    sql: case when ${msa.msa} is null and ${p_city_name} is null then ${p_state_id}
          when ${msa.msa} is null and ${p_state_id} is null then ${p_city_name}
          when ${msa.msa} is null then ${p_city_name}||', '||${p_state_id} else ${msa.msa} end ;;
  }

  dimension: firm_market {
    type: string
    sql: case when ${msa.msa} is null and ${ff_out_company_contacts.c_city_name} is null then ${ff_out_company_contacts.c_state_id}
          when ${msa.msa} is null and ${ff_out_company_contacts.c_state_id} is null then ${ff_out_company_contacts.c_city_name}
          when ${msa.msa} is null then ${ff_out_company_contacts.c_city_name}||', '||${ff_out_company_contacts.c_state_id} else ${msa.msa} end ;;
  }

  dimension: project_url {
    type: string
    html:<font color="blue "><u><a href="{{ cn_project_url._value }}" target="_blank">Link to Dodge Project</a></font></u> ;;
    sql: ${cn_project_url} ;;
  }
}
