view: financial_schedules {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."FINANCIAL_SCHEDULES"
    ;;
  drill_fields: [financial_schedule_id]

  dimension: financial_schedule_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
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
  }

  dimension: adjustment_period_days {
    type: number
    sql: ${TABLE}."ADJUSTMENT_PERIOD_DAYS" ;;
  }

  dimension: advance_payment_month {
    type: string
    sql: ${TABLE}."ADVANCE_PAYMENT_MONTH" ;;
  }

  dimension: agreement_type_id {
    type: number
    sql: ${TABLE}."AGREEMENT_TYPE_ID" ;;
  }

  dimension: asset_owner_id {
    type: number
    sql: ${TABLE}."ASSET_OWNER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: cross_colateralization {
    type: yesno
    sql: ${TABLE}."CROSS_COLATERALIZATION" ;;
  }

  dimension: cross_default {
    type: yesno
    sql: ${TABLE}."CROSS_DEFAULT" ;;
  }

  dimension: current_schedule_number {
    type: string
    sql: ${TABLE}."CURRENT_SCHEDULE_NUMBER" ;;
  }

  dimension: debt_payment_stream_financier_id {
    type: number
    sql: ${TABLE}."DEBT_PAYMENT_STREAM_FINANCIER_ID" ;;
  }

  dimension: downpayment_application_type_id {
    type: number
    sql: ${TABLE}."DOWNPAYMENT_APPLICATION_TYPE_ID" ;;
  }

  dimension_group: equipment_acceptance {
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
    sql: CAST(${TABLE}."EQUIPMENT_ACCEPTANCE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: es_has_pptx_responsibility {
    type: yesno
    sql: ${TABLE}."ES_HAS_PPTX_RESPONSIBILITY" ;;
  }

  dimension: financial_ratio_covenants {
    type: string
    sql: ${TABLE}."FINANCIAL_RATIO_COVENANTS" ;;
  }

  dimension: financial_reporting_covenants {
    type: string
    sql: ${TABLE}."FINANCIAL_REPORTING_COVENANTS" ;;
  }

  dimension_group: financial_schedule {
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
    sql: CAST(${TABLE}."FINANCIAL_SCHEDULE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: first_payment {
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
    sql: CAST(${TABLE}."FIRST_PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: implicit_interest_rate {
    type: number
    sql: ${TABLE}."IMPLICIT_INTEREST_RATE" ;;
  }

  dimension: interest_rate_calculation_type_id {
    type: number
    sql: ${TABLE}."INTEREST_RATE_CALCULATION_TYPE_ID" ;;
  }

  dimension: interest_rate_index_id {
    type: number
    sql: ${TABLE}."INTEREST_RATE_INDEX_ID" ;;
  }

  dimension: interest_rate_type_id {
    type: number
    sql: ${TABLE}."INTEREST_RATE_TYPE_ID" ;;
  }

  dimension: lender_has_pptx_responsibility {
    type: yesno
    sql: ${TABLE}."LENDER_HAS_PPTX_RESPONSIBILITY" ;;
  }

  dimension: lfr {
    type: number
    sql: ${TABLE}."LFR" ;;
  }

  dimension: loan_servicer_id {
    type: number
    sql: ${TABLE}."LOAN_SERVICER_ID" ;;
  }

  dimension: loan_term_months {
    type: number
    sql: ${TABLE}."LOAN_TERM_MONTHS" ;;
  }

  dimension_group: master_agreement {
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
    sql: CAST(${TABLE}."MASTER_AGREEMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: master_agreement_number {
    type: string
    sql: ${TABLE}."MASTER_AGREEMENT_NUMBER" ;;
  }

  dimension: master_agreement_url {
    type: string
    sql: ${TABLE}."MASTER_AGREEMENT_URL" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: originating_lender_id {
    type: number
    sql: ${TABLE}."ORIGINATING_LENDER_ID" ;;
  }

  dimension: personal_guarantees_granted {
    type: yesno
    sql: ${TABLE}."PERSONAL_GUARANTEES_GRANTED" ;;
  }

  dimension: prepayment_penalty {
    type: yesno
    sql: ${TABLE}."PREPAYMENT_PENALTY" ;;
  }

  dimension: prepayment_penalty_for_selling {
    type: yesno
    sql: ${TABLE}."PREPAYMENT_PENALTY_FOR_SELLING" ;;
  }

  dimension: prepayment_penalty_year_1 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_1" ;;
  }

  dimension: prepayment_penalty_year_2 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_2" ;;
  }

  dimension: prepayment_penalty_year_3 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_3" ;;
  }

  dimension: prepayment_penalty_year_4 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_4" ;;
  }

  dimension: prepayment_penalty_year_5 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_5" ;;
  }

  dimension: prepayment_penalty_year_6 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_6" ;;
  }

  dimension: prepayment_penalty_year_7 {
    type: number
    sql: ${TABLE}."PREPAYMENT_PENALTY_YEAR_7" ;;
  }

  dimension: prepayment_type_id {
    type: number
    sql: ${TABLE}."PREPAYMENT_TYPE_ID" ;;
  }

  dimension: previous_schedule_number {
    type: string
    sql: ${TABLE}."PREVIOUS_SCHEDULE_NUMBER" ;;
  }

  dimension: reporting_frequency_type_id {
    type: number
    sql: ${TABLE}."REPORTING_FREQUENCY_TYPE_ID" ;;
  }

  dimension_group: schedule_start {
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
    sql: CAST(${TABLE}."SCHEDULE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: schedule_url {
    type: string
    sql: ${TABLE}."SCHEDULE_URL" ;;
  }

  dimension: skip_number_of_months {
    type: number
    sql: ${TABLE}."SKIP_NUMBER_OF_MONTHS" ;;
  }

  dimension: skip_payment_type_id {
    type: number
    sql: ${TABLE}."SKIP_PAYMENT_TYPE_ID" ;;
  }

  dimension: spread {
    type: number
    sql: ${TABLE}."SPREAD" ;;
  }

  measure: count {
    type: count
    drill_fields: [financial_schedule_id]
  }
}
