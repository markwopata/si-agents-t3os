view: wc_loss_run {
  sql_table_name: "CLAIMS"."WC_LOSS_RUN"
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
    sql: ${TABLE}.CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension_group: accident_date {
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
    sql: CAST(${TABLE}."ACCIDENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: accident_description {
    type: string
    sql: ${TABLE}."ACCIDENT_DESCRIPTION" ;;
  }

  dimension: accident_description_details {
    type: string
    sql: ${TABLE}."ACCIDENT_DESCRIPTION_DETAILS" ;;
  }

  dimension: accident_state {
    type: string
    sql: ${TABLE}."ACCIDENT_STATE" ;;
  }

  dimension: adjuster_name {
    type: string
    sql: ${TABLE}."ADJUSTER_NAME" ;;
  }

  dimension: claim_description {
    type: string
    sql: ${TABLE}."CLAIM_DESCRIPTION" ;;
  }

  dimension: claim_number {
    type: string
    primary_key: yes
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }

  dimension: claim_status {
    type: string
    sql: ${TABLE}."CLAIM_STATUS" ;;
  }

  dimension: claimant_age {
    type: number
    sql: ${TABLE}."CLAIMANT_AGE" ;;
  }

  dimension: claimant_hire_date {
    type: string
    sql: ${TABLE}."CLAIMANT_HIRE_DATE" ;;
  }

  dimension: claimant_insured_driver_name {
    type: string
    sql: ${TABLE}."CLAIMANT_INSURED_DRIVER_NAME" ;;
  }

  dimension: closed_date {
    type: string
    sql: ${TABLE}."CLOSED_DATE" ;;
  }

  dimension: expense_incurred {
    type: number
    sql: ${TABLE}."EXPENSE_INCURRED" ;;
  }

  dimension: expense_outstanding {
    type: number
    sql: ${TABLE}."EXPENSE_OUTSTANDING" ;;
  }

  dimension: expense_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."EXPENSE_PAID" ;;
  }

  dimension: indemnity_incurred {
    type: number
    sql: ${TABLE}."INDEMNITY_INCURRED" ;;
  }

  dimension: indemnity_outstanding {
    type: number
    sql: ${TABLE}."INDEMNITY_OUTSTANDING" ;;
  }

  dimension: indemnity_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."INDEMNITY_PAID" ;;
  }

  dimension: injured_body_part {
    type: string
    sql: ${TABLE}."INJURED_BODY_PART" ;;
  }

  dimension: injury_severity_description {
    type: string
    sql: ${TABLE}."INJURY_SEVERITY_DESCRIPTION" ;;
  }

  dimension: line_of_business {
    type: string
    sql: ${TABLE}."LINE_OF_BUSINESS" ;;
  }

  dimension: litigation_status {
    type: string
    sql: ${TABLE}."LITIGATION_STATUS" ;;
  }

  dimension: medical_incurred {
    type: number
    sql: ${TABLE}."MEDICAL_INCURRED" ;;
  }

  dimension: medical_outstanding {
    type: number
    sql: ${TABLE}."MEDICAL_OUTSTANDING" ;;
  }

  dimension: medical_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."MEDICAL_PAID" ;;
  }

  dimension: nature_of_injury_description {
    type: string
    sql: ${TABLE}."NATURE_OF_INJURY_DESCRIPTION" ;;
  }

  dimension: ncci_codes {
    type: number
    sql: ${TABLE}."NCCI_CODES" ;;
  }

  dimension: policy_number {
    type: string
    sql: ${TABLE}."POLICY_NUMBER" ;;
  }

  dimension: policy_period {
    type: string
    sql: ${TABLE}."POLICY_PERIOD" ;;
  }

  dimension: released_to_work_date {
    type: string
    sql: ${TABLE}."RELEASED_TO_WORK_DATE" ;;
  }

  dimension: released_with_restrictions_indicator {
    type: string
    sql: ${TABLE}."RELEASED_WITH_RESTRICTIONS_INDICATOR" ;;
  }

  dimension: returned_with_restrictions_indicator {
    type: string
    sql: ${TABLE}."RETURNED_WITH_RESTRICTIONS_INDICATOR" ;;
  }

  dimension: total_incurred {
    type: number
    sql: ${TABLE}."TOTAL_INCURRED" ;;
    value_format: "$#,##0.00"
  }

  dimension: total_outstanding {
    type: number
    sql: ${TABLE}."TOTAL_OUTSTANDING" ;;
  }

  dimension: total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTAL_PAID" ;;
  }

  dimension: total_subrogation {
    type: number
    sql: ${TABLE}."TOTAL_SUBROGATION" ;;
  }

  dimension: total_tpd_days {
    type: number
    sql: ${TABLE}."TOTAL_TPD_DAYS" ;;
  }

  dimension: total_ttd_days {
    type: number
    sql: ${TABLE}."TOTAL_TTD_DAYS" ;;
  }

  dimension: wc_body_part_description {
    type: string
    sql: ${TABLE}."WC_BODY_PART_DESCRIPTION" ;;
  }

  dimension: wc_cause_of_injury_description {
    type: string
    sql: ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" ;;
  }

  dimension: wc_cause_of_injury_description_simplified {
    type: string
    sql: case when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Absorb/Ingest/Inhale NOC' then 'Absorb Ingest Inhale'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Contact with Electrical Current' then 'Burn or Scald'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Caught In/Und/Between NOC' then 'Caught In'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Contact with NOC' then 'Contact With'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" in ('Broken Glass (CUT, PUNCTURE, SCRAPE INJURED BY)', 'Hand Tool, Untensil, Not Powered (CUT, PUNCTURE, SCRAPE INJURED BY)', 'Powered Hand Tool, Appliance (CUT, PUNCTURE, SCRAPE INJURED BY)') then 'Cut Puncture Scrape'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" in ('Fall, Slip or Trip, NOC','From Different Level','From Ladder or Scaffolding','From Liquid or Grease Spills','On Same Level','Into Openings','Jumping','Slipped, Did Not Fall') then 'Fall or Slip'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Other Than Physical Cause' then 'Miscellaneous'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" in ('Collision with Another Vehicle','Motor Vehicle','Motor Vehicle, NOC','Vehicle Upset','Collision with a Fixed Object') then 'Motor Vehicle'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'Repetitive Motion' then 'Repetitive Motion'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" in ('Lifting''Using Tool or Machinery','Holding or Carrying','Pushing or Pulling','Reaching','Strain or Injury By, NOC','Twisting') then 'Strain By'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" in ('Object Being Lifted or Handled','Hand Tool or Machine in Use','Moving Parts of Machine','Object Handled','Falling or Flying Object','Stationary Object','Struck or Injured, NOC') then 'Struck By'
              when ${TABLE}."WC_CAUSE_OF_INJURY_DESCRIPTION" = 'UNKNOWN' then 'Unknown'
              else 'Not Categorized'
              end;;
  }

  dimension: wc_claim_type {
    type: string
    sql: ${TABLE}."WC_CLAIM_TYPE" ;;
  }

  dimension: wc_nature_of_injury_description {
    type: string
    sql: ${TABLE}."WC_NATURE_OF_INJURY_DESCRIPTION" ;;
  }

  measure: count {
    type: count
  }

  dimension: is_material_loss {
    type: yesno
    sql: ${wc_claim_type} = 'LT' ;;
  }

}
