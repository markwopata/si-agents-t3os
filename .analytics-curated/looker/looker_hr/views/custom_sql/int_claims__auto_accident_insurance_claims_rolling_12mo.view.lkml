view: int_claims__auto_accident_insurance_claims_rolling_12mo {
  derived_table: {
    sql: select *,date_trunc(month,date_of_claim)::date as month_of_claim
         from analytics.claims.int_claims__auto_accident_insurance_claims
        where month_of_claim between dateadd(month, -11, (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}))
      and (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}) ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: date_of_claim {
    type: date
    sql: ${TABLE}."DATE_OF_CLAIM" ;;
  }

  dimension: amount_collected_from_third_party {
    type: number
    sql: ${TABLE}."AMOUNT_COLLECTED_FROM_THIRD_PARTY" ;;
  }
  dimension: amount_paid_by_es {
    type: number
    sql: ${TABLE}."AMOUNT_PAID_BY_ES" ;;
  }
  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_MAKE" ;;
  }
  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_MODEL" ;;
  }
  dimension: asset_number {
    type: string
    sql: ${TABLE}."ASSET_NUMBER" ;;
  }
  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
  }
  dimension: at_fault_payer {
    type: string
    sql: ${TABLE}."AT_FAULT_PAYER" ;;
  }
  dimension: claim_id {
    type: string
    sql: ${TABLE}."CLAIM_ID" ;;
  }

  dimension: driver_employee_id {
    type: string
    sql: ${TABLE}."DRIVER_EMPLOYEE_ID" ;;
  }
  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }
  dimension: file_notes {
    type: string
    sql: ${TABLE}."FILE_NOTES" ;;
  }
  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }
  dimension: google_drive_link {
    type: string
    sql: ${TABLE}."GOOGLE_DRIVE_LINK" ;;
  }
  dimension: is_material_loss {
    type: yesno
    sql: ${TABLE}."IS_MATERIAL_LOSS" ;;
  }
  dimension_group: last_action_taken {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_ACTION_TAKEN_DATE" ;;
  }
  dimension: license_plate {
    type: string
    sql: ${TABLE}."LICENSE_PLATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: repair_invoice {
    type: string
    sql: ${TABLE}."REPAIR_INVOICE" ;;
  }
  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }
  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }
  dimension: status_comments {
    type: string
    sql: ${TABLE}."STATUS_COMMENTS" ;;
  }
  dimension: total_due_from_es {
    type: number
    sql: ${TABLE}."TOTAL_DUE_FROM_ES" ;;
  }
  dimension: total_due_from_third_party {
    type: number
    sql: ${TABLE}."TOTAL_DUE_FROM_THIRD_PARTY" ;;
  }
  measure: count {
    type: count
    drill_fields: [driver_name]
  }
}
