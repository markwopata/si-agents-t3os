view: retail_to_rental_board {
  sql_table_name: "ANALYTICS"."MONDAY"."RETAIL_TO_RENTAL_BOARD" ;;

  dimension: additional_information {
    type: string
    sql: ${TABLE}."ADDITIONAL_INFORMATION" ;;
  }
  dimension: attachment_yes_or_no {
    type: string
    sql: ${TABLE}."ATTACHMENT_YES_OR_NO" ;;
  }
  dimension: avg_yard_30_day_utilization {
    type: number
    sql: ${TABLE}."AVG_YARD_30_DAY_UTILIZATION" ;;
  }
  dimension: branch_location {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION" ;;
  }
  dimension: branch_location_is_other {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION_IS_OTHER" ;;
  }
  dimension: cat_class {
    type: string
    sql: ${TABLE}."CAT_CLASS" ;;
  }
  dimension: credit_pdf {
    type: string
    sql: ${TABLE}."CREDIT_PDF" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: finance_status_updated {
    type: yesno
    sql: ${TABLE}."FINANCE_STATUS_UPDATED" ;;
  }
  dimension: floor_plan_unit_or_paid_asset {
    type: string
    sql: ${TABLE}."FLOOR_PLAN_UNIT_OR_PAID_ASSET" ;;
  }
  dimension: ies_to_es_invoice {
    type: string
    sql: ${TABLE}."IES_TO_ES_INVOICE" ;;
  }
  dimension: ies_vendor_invoice {
    type: string
    sql: ${TABLE}."IES_VENDOR_INVOICE" ;;
  }
  dimension: internally_transfer {
    type: string
    sql: ${TABLE}."INTERNALLY_TRANSFER" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: length_of_rental_in_days {
    type: number
    sql: ${TABLE}."LENGTH_OF_RENTAL_IN_DAYS" ;;
  }
  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }
  dimension: msp_rsp {
    type: yesno
    sql: ${TABLE}."MSP_RSP" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: national_account_price {
    type: number
    sql: ${TABLE}."NATIONAL_ACCOUNT_PRICE" ;;
  }
  dimension: ownership_updated {
    type: yesno
    sql: ${TABLE}."OWNERSHIP_UPDATED" ;;
  }
  dimension: people {
    type: string
    sql: ${TABLE}."PEOPLE" ;;
  }
  dimension: projected_rental_rate_per_30_days {
    type: string
    sql: ${TABLE}."PROJECTED_RENTAL_RATE_PER_30_DAYS" ;;
  }
  dimension: reason_for_denial {
    type: string
    sql: ${TABLE}."REASON_FOR_DENIAL" ;;
  }
  dimension: regional_manager {
    type: string
    sql: ${TABLE}."REGIONAL_MANAGER" ;;
  }
  dimension: rental_in_30_days {
    type: string
    sql: ${TABLE}."RENTAL_IN_30_DAYS" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension: retail_credit {
    type: string
    sql: ${TABLE}."RETAIL_CREDIT" ;;
  }
  dimension: retail_oec {
    type: number
    sql: ${TABLE}."RETAIL_OEC" ;;
  }
  dimension: rm_email {
    type: string
    sql: ${TABLE}."RM_EMAIL" ;;
  }
  dimension: sales_rep_name_and_number {
    type: string
    sql: ${TABLE}."SALES_REP_NAME_AND_NUMBER" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: status_1 {
    type: string
    sql: ${TABLE}."STATUS_1" ;;
  }
  dimension: status_notes {
    type: string
    sql: ${TABLE}."STATUS_NOTES" ;;
  }
  dimension: subitems {
    type: string
    sql: ${TABLE}."SUBITEMS" ;;
  }
  dimension_group: submitted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBMITTED_DATE" ;;
  }
  dimension: support_column_for_units {
    type: string
    sql: ${TABLE}."SUPPORT_COLUMN_FOR_UNITS" ;;
  }
  dimension: unit_photos {
    type: string
    sql: ${TABLE}."UNIT_PHOTOS" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: why_not_transfer {
    type: string
    sql: ${TABLE}."WHY_NOT_TRANSFER" ;;
  }
  measure: count {
    type: count
    drill_fields: [customer_name, name]
  }
}
