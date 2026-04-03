view: asset_financing_snapshots {
  sql_table_name: "PUBLIC"."ASSET_FINANCING_SNAPSHOTS" ;;

  dimension: key {
    hidden: yes
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}."DATE"::DATE, ${TABLE}."ASSET_ID" ;;
  }

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
  dimension_group: commencement {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: date {
    type: string
    sql: ${TABLE}."DATE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }
  dimension_group: first_rental {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
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
  dimension_group: new_last_appraisal {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEW_LAST_APPRAISAL_DATE" ;;
  }
  dimension: newused {
    type: string
    sql: ${TABLE}."NEW/USED" ;;
  }
  dimension: nlvnbv {
    type: number
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
  dimension_group: purchase {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: sage_account_number {
    type: string
    sql: ${TABLE}."SAGE_ACCOUNT_NUMBER" ;;
  }
  dimension: sage_operating_type {
    type: string
    sql: ${TABLE}."SAGE_OPERATING_TYPE" ;;
  }
  dimension_group: snapshot {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
}
