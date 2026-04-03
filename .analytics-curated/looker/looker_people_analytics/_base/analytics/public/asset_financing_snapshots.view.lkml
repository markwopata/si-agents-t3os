view: asset_financing_snapshots {
  sql_table_name: "ANALYTICS"."PUBLIC"."ASSET_FINANCING_SNAPSHOTS" ;;

  dimension: aphl_status {
    type: string
    sql: ${TABLE}."APHL_STATUS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: asset_type_adj {
    type: string
    sql: ${TABLE}."ASSET_TYPE_ADJ" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: commencement {
    type: date_raw
    sql: ${TABLE}."COMMENCEMENT_DATE" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: contractor_owned_flag {
    type: string
    sql: ${TABLE}."CONTRACTOR_OWNED_FLAG" ;;
  }
  dimension: created {
    type: date_raw
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: date {
    type: date_raw
    sql: ${TABLE}."DATE" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCIAL_STATUS" ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }
  dimension: first_rental {
    type: date_raw
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }
  dimension: is_payout_program_enroll {
    type: string
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_ENROLL" ;;
  }
  dimension: is_payout_program_unpaid {
    type: string
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_UNPAID" ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}."LENDER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: nbv {
    type: number
    sql: ${TABLE}."NBV" ;;
  }
  dimension: new_last_appraisal {
    type: date_raw
    sql: ${TABLE}."NEW_LAST_APPRAISAL_DATE" ;;
  }
  dimension: new_used {
    type: string
    sql: ${TABLE}."NEW/USED" ;;
  }
  dimension: nlv_nbv_perc {
    type: string
    sql: ${TABLE}."NLV/NBV%" ;;
  }
  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }
  dimension: owned_status {
    type: string
    sql: ${TABLE}."OWNED_STATUS" ;;
  }
  dimension: phoenix_id {
    type: number
    sql: ${TABLE}."PHOENIX_ID" ;;
  }
  dimension: purchase {
    type: date_raw
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }
  dimension: sage_account_number {
    type: number
    sql: ${TABLE}."SAGE_ACCOUNT_NUMBER" ;;
  }
  dimension: sage_operating_type {
    type: string
    sql: ${TABLE}."SAGE_OPERATING_TYPE" ;;
  }
  dimension: snapshot {
    type: date_raw
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
}
