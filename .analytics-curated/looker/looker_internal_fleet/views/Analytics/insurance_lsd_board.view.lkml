view: insurance_lsd_board {
  sql_table_name: "ANALYTICS"."MONDAY"."INSURANCE_LSD_BOARD" ;;

  dimension: abs_owner {
    type: string
    sql: ${TABLE}."ABS_OWNER" ;;
  }
  dimension: amount_collected {
    type: number
    sql: ${TABLE}."AMOUNT_COLLECTED" ;;
  }
  dimension: amount_due_from_3_p {
    type: number
    sql: ${TABLE}."AMOUNT_DUE_FROM_3P" ;;
  }
  dimension: amount_paid_es_fault {
    type: number
    sql: ${TABLE}."AMOUNT_PAID_ES_FAULT" ;;
  }
  dimension: asset_year {
    type: string
    sql: ${TABLE}."ASSET_YEAR" ;;
  }
  dimension: assets_owner {
    type: string
    sql: ${TABLE}."ASSETS_OWNER" ;;
  }
  dimension: assigned {
    type: string
    sql: ${TABLE}."ASSIGNED" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }
  dimension_group: closed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CLOSED_DATE" ;;
  }
  dimension: confidential_file_notes {
    type: string
    sql: ${TABLE}."CONFIDENTIAL_FILE_NOTES" ;;
  }
  dimension: customer_ins_policy_number {
    type: string
    sql: ${TABLE}."CUSTOMER_INS_POLICY_NUMBER" ;;
  }
  dimension: customer_insurance_company {
    type: string
    sql: ${TABLE}."CUSTOMER_INSURANCE_COMPANY" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: customer_quote {
    type: number
    sql: ${TABLE}."CUSTOMER_QUOTE" ;;
  }
  dimension: customer_quote_needed {
    type: string
    sql: ${TABLE}."CUSTOMER_QUOTE_NEEDED" ;;
  }
  dimension_group: date_of_incident {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF_INCIDENT" ;;
  }
  dimension: documents_and_photos {
    type: string
    sql: ${TABLE}."DOCUMENTS_AND_PHOTOS" ;;
  }
  dimension: file_notes {
    type: string
    sql: ${TABLE}."FILE_NOTES" ;;
  }
  dimension: fmv_quote {
    type: number
    sql: ${TABLE}."FMV_QUOTE" ;;
  }
  dimension: fmv_quote_needed {
    type: string
    sql: ${TABLE}."FMV_QUOTE_NEEDED" ;;
  }
  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }
  dimension: google_drive_link {
    type: string
    sql: ${TABLE}."GOOGLE_DRIVE_LINK" ;;
  }
  dimension: incident_location {
    type: string
    sql: ${TABLE}."INCIDENT_LOCATION" ;;
  }
  dimension: ins_claim_filed {
    type: string
    sql: ${TABLE}."INS_CLAIM_FILED" ;;
  }
  dimension: item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: last_action_taken {
    type: string
    sql: ${TABLE}."LAST_ACTION_TAKEN" ;;
  }
  dimension: lender_contact_information {
    type: string
    sql: ${TABLE}."LENDER_CONTACT_INFORMATION" ;;
  }
  dimension: lender_lessor {
    type: string
    sql: ${TABLE}."LENDER_LESSOR" ;;
  }
  dimension: link_to_lsd_asset_management {
    type: string
    sql: ${TABLE}."LINK_TO_LSD_ASSET_MANAGEMENT" ;;
  }
  dimension: link_to_lsd_fleet_ops {
    type: string
    sql: ${TABLE}."LINK_TO_LSD_FLEET_OPS" ;;
  }
  dimension_group: lsd_designation {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LSD_DESIGNATION_DATE" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: need_lender_contact {
    type: string
    sql: ${TABLE}."NEED_LENDER_CONTACT" ;;
  }
  dimension: open_closed {
    type: string
    sql: ${TABLE}."OPEN_CLOSED" ;;
  }
  dimension_group: reminder {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REMINDER_DATE" ;;
  }
  dimension: rental_contract {
    type: string
    sql: ${TABLE}."RENTAL_CONTRACT" ;;
  }
  dimension_group: rental_contract {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_CONTRACT_DATE" ;;
  }
  dimension_group: repair {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REPAIR_DATE" ;;
  }
  dimension: repair_invoice {
    type: string
    sql: ${TABLE}."REPAIR_INVOICE" ;;
  }
  dimension_group: report {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REPORT_DATE" ;;
  }
  dimension: reported_by {
    type: string
    sql: ${TABLE}."REPORTED_BY" ;;
  }
  dimension: responsible_payer {
    type: string
    sql: ${TABLE}."RESPONSIBLE_PAYER" ;;
  }
  dimension: rpp {
    type: string
    sql: ${TABLE}."RPP" ;;
  }
  dimension: rpp_charge {
    type: number
    sql: ${TABLE}."RPP_CHARGE" ;;
  }
  dimension: rpp_status {
    type: string
    sql: ${TABLE}."RPP_STATUS" ;;
  }
  dimension: rpp_status_comments {
    type: string
    sql: ${TABLE}."RPP_STATUS_COMMENTS" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: special_tag_optional {
    type: string
    sql: ${TABLE}."SPECIAL_TAG_OPTIONAL" ;;
  }
  dimension: subitems {
    type: string
    sql: ${TABLE}."SUBITEMS" ;;
  }
  dimension: test_board {
    type: string
    sql: ${TABLE}."TEST_BOARD" ;;
  }
  dimension: total_loss {
    type: string
    sql: ${TABLE}."TOTAL_LOSS" ;;
  }
  dimension: total_loss_mirror {
    type: number
    sql: ${TABLE}."TOTAL_LOSS_MIRROR" ;;
  }
  dimension: total_turn_time {
    type: string
    sql: ${TABLE}."TOTAL_TURN_TIME" ;;
  }
  dimension: type_of_loss {
    type: string
    sql: ${TABLE}."TYPE_OF_LOSS" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: will_ins_pay_lender_directly {
    type: string
    sql: ${TABLE}."WILL_INS_PAY_LENDER_DIRECTLY" ;;
  }
  dimension: work_order {
    type: string
    sql: ${TABLE}."WORK_ORDER" ;;
  }
  dimension: days_from_report_to_lsd_designation {
    type: number
    sql: IFF(
          TRY_TO_DATE(${TABLE}."REPORT_DATE") IS NULL
          OR TRY_TO_DATE(${TABLE}."LSD_DESIGNATION_DATE") IS NULL,
          NULL,
          DATEDIFF(
            day,
            TRY_TO_DATE(${TABLE}."REPORT_DATE"),
            TRY_TO_DATE(${TABLE}."LSD_DESIGNATION_DATE")
          )
        ) ;;
    drill_fields: [details*]
  }
  measure: avg_days_from_report_to_lsd_designation {
    type: average
    value_format_name: decimal_1
    sql: ${days_from_report_to_lsd_designation} ;;
    drill_fields: [details*]
  }
  measure: count {
    type: count
    drill_fields: [branch_name, vendor_name, customer_name, name]
  }
  set: details {
    fields: [
      # Primary identifiers
      item_id,
      name,
      customer_name,
      branch_name,

      # Asset context
      make,
      model,
      asset_year,
      serial_number,
      assets_owner,

      # Incident + timeline
      date_of_incident_date,
      report_date,
      lsd_designation_date,
      closed_date,
      days_from_report_to_lsd_designation,

      # Financials
      customer_quote,
      fmv_quote,
      rpp_charge,
      amount_collected,
      amount_due_from_3_p,
      amount_paid_es_fault,
      total_loss_mirror,

      # Responsibility / payer
      responsible_payer,
      customer_insurance_company,
      customer_ins_policy_number,
      will_ins_pay_lender_directly,

      # Ops / workflow
      assigned,
      abs_owner,
      open_closed,
      total_loss,
      type_of_loss,
      last_action_taken,
      rpp_status,
      rpp_status_comments,

      # Lender / docs / links / notes
      lender_lessor,
      lender_contact_information,
      need_lender_contact,
      google_drive_link,
      documents_and_photos,
      file_notes,
      confidential_file_notes,
      link_to_lsd_asset_management,
      link_to_lsd_fleet_ops
    ]
  }
}
