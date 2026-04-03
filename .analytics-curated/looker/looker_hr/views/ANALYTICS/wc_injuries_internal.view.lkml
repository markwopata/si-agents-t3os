view: wc_injuries_internal {
    sql_table_name: "CLAIMS"."WC_INJURIES_INTERNAL";;

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
    sql: ${TABLE}.CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    primary_key: yes
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }

  dimension: closed_date {
    type: string
    sql: ${TABLE}."CLOSED_DATE" ;;
  }

  dimension_group: date_of_injury {
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
    sql: CAST(${TABLE}."DATE_OF_INJURY" AS TIMESTAMP_NTZ) ;;
  }

  dimension: days_away {
    type: string
    sql: ${TABLE}."DAYS_AWAY" ;;
  }

  dimension: days_of_restricted_duty_includes_accomodated_work_ {
    type: string
    sql: ${TABLE}."DAYS_OF_RESTRICTED_DUTY_INCLUDES_ACCOMODATED_WORK_" ;;
  }

  dimension: drug_test_ordered_non_dot_dot_none {
    type: string
    sql: ${TABLE}."DRUG_TEST_ORDERED_NON_DOT_DOT_NONE" ;;
  }

  dimension: employee_ {
    type: number
    sql: ${TABLE}."EMPLOYEE_" ;;
  }

  dimension: employee_name_ {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME_" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: injury_summary {
    type: string
    sql: ${TABLE}."INJURY_SUMMARY" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: notes_to_do {
    type: string
    sql: ${TABLE}."NOTES_TO_DO" ;;
  }

  dimension: notification_method {
    type: string
    sql: ${TABLE}."NOTIFICATION_METHOD" ;;
  }

  dimension: OSHA_recordable {
    type: string
    sql: ${TABLE}."RECORDABLE_" ;;
  }

  dimension: returned_to_work_with_no_restrictions_and_or_case_closed_date {
    type: string
    sql: ${TABLE}."RETURNED_TO_WORK_WITH_NO_RESTRICTIONS_AND_OR_CASE_CLOSED_DATE" ;;
  }

  dimension: test_results_positive_negative {
    type: string
    sql: ${TABLE}."TEST_RESULTS_POSITIVE_NEGATIVE" ;;
  }

  dimension: total_dart_days {
    type: string
    sql: ${TABLE}."TOTAL_DART_DAYS" ;;
  }

  dimension: wc_claim_filed_ {
    type: string
    sql: ${TABLE}."WC_CLAIM_FILED_" ;;
  }

  dimension: wc_company {
    type: string
    sql: ${TABLE}."WC_COMPANY" ;;
  }

  dimension: work_comp_rep_info {
    type: string
    sql: ${TABLE}."WORK_COMP_REP_INFO" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  dimension: days_before_accident {
    type: number
    sql: datediff(day, coalesce(${company_directory.date_rehired2_date},${company_directory.date_rehired_date},${company_directory.date_hired2_date},${company_directory.date_hired_date})::date, ${date_of_injury_date}::date) ;;
  }

  # For claims not reported to Hartford, this is the cause listed internally. For claims reported should be blank and ignored.
  dimension: non_claims_clause {
    label: "Cause of Injury"
    description: "The cause given for claims not submitted to insurance."
    type: string
    sql: ${TABLE}."CAUSE_PLEASE_CHOOSE_FOR_CLAIMS_NOT_REPORTED_TO_HARTFORD_" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: sum_total_incurred {
    type: sum
    sql: ${wc_loss_run.total_incurred} ;;
    drill_fields: [detail*]
    value_format: "$#,##0.00"
  }

  measure: sum_dart_days {
    type: sum
    sql: ${total_dart_days} ;;
  }

  measure: count_dart_days {
    type: count
    sql: ${total_dart_days} > 0 ;;
  }

  set: detail {
    fields: [
      claim_number,
      market_name,
      date_of_injury_date,
      employee_title,
      wc_loss_run.total_incurred,
      injury_summary

    ]
  }
}
