view: offer {
  sql_table_name: "GREENHOUSE"."OFFER" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: custom_application_id {
    type: number
    sql: ${TABLE}."CUSTOM_APPLICATION_ID" ;;
  }
  dimension: custom_application_id_offer_1690811009_685192 {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOM_APPLICATION_ID_OFFER_1690811009_685192" ;;
  }
  dimension: custom_benefits {
    type: string
    sql: ${TABLE}."CUSTOM_BENEFITS" ;;
  }
  dimension: custom_bonus {
    type: string
    sql: ${TABLE}."CUSTOM_BONUS" ;;
  }
  dimension: custom_commission {
    type: string
    sql: ${TABLE}."CUSTOM_COMMISSION" ;;
  }
  dimension: custom_commission_eligible_ {
    type: string
    sql: ${TABLE}."CUSTOM_COMMISSION_ELIGIBLE_" ;;
  }
  dimension: custom_company_vehicle {
    type: yesno
    sql: ${TABLE}."CUSTOM_COMPANY_VEHICLE" ;;
  }
  dimension_group: custom_date_of_birth {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CUSTOM_DATE_OF_BIRTH" ;;
  }
  dimension: custom_employment_type {
    type: string
    sql: ${TABLE}."CUSTOM_EMPLOYMENT_TYPE" ;;
  }
  dimension: custom_hiring_manager {
    type: string
    sql: ${TABLE}."CUSTOM_HIRING_MANAGER" ;;
  }
  dimension: custom_hiring_manager_title {
    type: string
    sql: ${TABLE}."CUSTOM_HIRING_MANAGER_TITLE" ;;
  }
  dimension: custom_hourly_rate {
    type: string
    sql: ${TABLE}."CUSTOM_HOURLY_RATE" ;;
  }
  dimension: custom_internal_external_applicant {
    type: string
    sql: ${TABLE}."CUSTOM_INTERNAL_EXTERNAL_APPLICANT" ;;
  }
  dimension: custom_notes {
    type: string
    sql: ${TABLE}."CUSTOM_NOTES" ;;
  }
  dimension: custom_options {
    type: string
    sql: ${TABLE}."CUSTOM_OPTIONS" ;;
  }
  dimension: custom_options_offered_ {
    type: string
    sql: ${TABLE}."CUSTOM_OPTIONS_OFFERED_" ;;
  }
  dimension: custom_previous_job_title {
    type: string
    sql: ${TABLE}."CUSTOM_PREVIOUS_JOB_TITLE" ;;
  }
  dimension: custom_previous_manager {
    type: string
    sql: ${TABLE}."CUSTOM_PREVIOUS_MANAGER" ;;
  }
  dimension: custom_previous_manager_offer_1689255728_0972328 {
    type: string
    sql: ${TABLE}."CUSTOM_PREVIOUS_MANAGER_OFFER_1689255728_0972328" ;;
  }
  dimension: custom_previous_wage {
    type: string
    sql: ${TABLE}."CUSTOM_PREVIOUS_WAGE" ;;
  }
  dimension: custom_pto_days {
    type: number
    sql: ${TABLE}."CUSTOM_PTO_DAYS" ;;
  }
  dimension: custom_pto_hours {
    type: number
    sql: ${TABLE}."CUSTOM_PTO_HOURS" ;;
  }
  dimension: custom_recruiter {
    type: string
    sql: ${TABLE}."CUSTOM_RECRUITER" ;;
  }
  dimension: custom_relocation_bonus_offered_ {
    type: string
    sql: ${TABLE}."CUSTOM_RELOCATION_BONUS_OFFERED_" ;;
  }
  dimension: custom_salary {
    type: string
    sql: ${TABLE}."CUSTOM_SALARY" ;;
  }
  dimension: custom_signing_bonus_amount {
    type: string
    sql: ${TABLE}."CUSTOM_SIGNING_BONUS_AMOUNT" ;;
  }
  dimension: custom_signing_bonus_offered_ {
    type: string
    sql: ${TABLE}."CUSTOM_SIGNING_BONUS_OFFERED_" ;;
  }
  dimension: custom_starting_pay {
    type: string
    sql: ${TABLE}."CUSTOM_STARTING_PAY" ;;
  }
  dimension_group: resolved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RESOLVED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: sent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SENT_AT" ;;
  }
  dimension_group: starts {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."STARTS_AT" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: version {
    type: number
    sql: ${TABLE}."VERSION" ;;
  }
  dimension: recruiter_name {
    type: string
    sql: TO_CHAR(GET(${TABLE}."CUSTOM_RECRUITER",'name')) ;;
  }
  measure: count {
    type: count
    drill_fields: [id]
  }

  measure: unique_offer_count {
    type: count_distinct
    drill_fields: [drill_fields*]
    sql: ${id} ;;
  }

  set: drill_fields {
    fields: [id,
      application_id,
      application_info_view.candidate_name,
      application_info_view.job_name,
      created_date,
      sent_date,
      resolved_date]
  }
}
