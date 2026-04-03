view: gs_fleet_vendor_list {
  sql_table_name: "FLEET"."GS_FLEET_VENDOR_LIST" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: additional_net_term_notes {
    type: string
    sql: ${TABLE}."ADDITIONAL_NET_TERM_NOTES" ;;
  }
  dimension: analyst_back_up {
    type: string
    sql: ${TABLE}."ANALYST_BACK_UP" ;;
  }
  dimension: assigned_fleet_analyst_ {
    type: string
    sql: ${TABLE}."ASSIGNED_FLEET_ANALYST_" ;;
  }
  dimension: associated_make_to_help_identify_ {
    type: string
    sql: ${TABLE}."ASSOCIATED_MAKE_TO_HELP_IDENTIFY_" ;;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."BOOK_OF_BUSINESS" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: core_non_core_vehicles {
    type: string
    sql: ${TABLE}."CORE_NON_CORE_VEHICLES" ;;
  }
  dimension: equipment_net_terms {
    type: string
    sql: ${TABLE}."EQUIPMENT_NET_TERMS" ;;
  }
  dimension: financing_designation {
    type: string
    sql: ${TABLE}."FINANCING_DESIGNATION" ;;
  }
  dimension: fleet_track_vendor_number {
    type: number
    sql: ${TABLE}."FLEET_TRACK_VENDOR_NUMBER" ;;
  }
  dimension: invoice_nomenclature {
    type: string
    sql: ${TABLE}."INVOICE_NOMENCLATURE" ;;
  }
  dimension: preferred_method_of_payment {
    type: string
    sql: ${TABLE}."PREFERRED_METHOD_OF_PAYMENT" ;;
  }
  dimension: purchaser_assigned {
    type: string
    sql: ${TABLE}."PURCHASER_ASSIGNED" ;;
  }
  dimension: reimbursement_eligible_2024 {
    type: yesno
    sql: ${TABLE}."REIMBURSEMENT_ELIGIBLE_2024" ;;
  }
  dimension: reviewed_by {
    type: string
    sql: ${TABLE}."REVIEWED_BY" ;;
  }
  dimension: reviewed_date {
    type: string
    sql: ${TABLE}."REVIEWED_DATE" ;;
  }
  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID" ;;
  }
  dimension: terms_reviewed_in_2024 {
    type: yesno
    sql: ${TABLE}."TERMS_REVIEWED_IN_2024" ;;
  }
  dimension: vendor_exact_name_in_fleet_track {
    type: string
    sql: ${TABLE}."VENDOR_EXACT_NAME_IN_FLEET_TRACK" ;;
  }
  dimension: wire_confirmed_date {
    type: string
    sql: ${TABLE}."WIRE_CONFIRMED_DATE" ;;
  }
  measure: count {
    type: count
  }
}
