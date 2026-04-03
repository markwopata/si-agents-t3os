view: contract_complete_rpo_board {
  sql_table_name: "ANALYTICS"."MONDAY"."CONTRACT_COMPLETE_RPO_BOARD" ;;

  dimension: applied_rent {
    type: string
    sql: ${TABLE}."APPLIED_RENT" ;;
  }
  dimension: asset_verified_returned {
    type: yesno
    sql: ${TABLE}."ASSET_VERIFIED_RETURNED" ;;
  }
  dimension: bill_of_sale_signed {
    type: yesno
    sql: ${TABLE}."BILL_OF_SALE_SIGNED" ;;
  }
  dimension_group: completion {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."COMPLETION_DATE" ;;
  }
  dimension: conversion {
    type: string
    sql: ${TABLE}."CONVERSION" ;;
  }
  dimension: conversion_price {
    type: string
    sql: ${TABLE}."CONVERSION_PRICE" ;;
  }
  dimension: credit_application {
    type: string
    sql: ${TABLE}."CREDIT_APPLICATION" ;;
  }
  dimension: credit_approval {
    type: string
    sql: ${TABLE}."CREDIT_APPROVAL" ;;
  }
  dimension: customer_quote_approval {
    type: string
    sql: ${TABLE}."CUSTOMER_QUOTE_APPROVAL" ;;
  }
  dimension_group: date_of_asset_payoff {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF_ASSET_PAYOFF" ;;
  }
  dimension_group: date_rpo_addendum_generated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RPO_ADDENDUM_GENERATED" ;;
  }
  dimension: dealership_or_rental_fleet {
    type: string
    sql: ${TABLE}."DEALERSHIP_OR_RENTAL_FLEET" ;;
  }
  dimension: documents_pictures {
    type: string
    sql: ${TABLE}."DOCUMENTS_PICTURES" ;;
  }
  dimension: full_term_rental_revenue {
    type: string
    sql: ${TABLE}."FULL_TERM_RENTAL_REVENUE" ;;
  }
  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_EMAIL" ;;
  }
  dimension: gross_profit {
    type: string
    sql: ${TABLE}."GROSS_PROFIT" ;;
  }
  dimension: gross_profit_margin {
    type: string
    sql: ${TABLE}."GROSS_PROFIT_MARGIN" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: link_to_promissory_note {
    type: string
    sql: ${TABLE}."LINK_TO_PROMISSORY_NOTE" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension_group: quote {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."QUOTE_DATE" ;;
  }
  dimension: release_filing_number {
    type: string
    sql: ${TABLE}."RELEASE_FILING_NUMBER" ;;
  }
  dimension: rent_contribution {
    type: number
    sql: ${TABLE}."RENT_CONTRIBUTION" ;;
  }
  dimension: rental_agreement_link {
    type: string
    sql: ${TABLE}."RENTAL_AGREEMENT_LINK" ;;
  }
  dimension: rental_invoice_number {
    type: string
    sql: ${TABLE}."RENTAL_INVOICE_NUMBER" ;;
  }
  dimension_group: request {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REQUEST_DATE" ;;
  }
  dimension_group: rpo_beginning {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RPO_BEGINNING_DATE" ;;
  }
  dimension_group: rpo_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RPO_END_DATE" ;;
  }
  dimension: rpo_program {
    type: string
    sql: ${TABLE}."RPO_PROGRAM" ;;
  }
  dimension: rpo_status {
    type: string
    sql: ${TABLE}."RPO_STATUS" ;;
  }
  dimension: rpo_term_months {
    type: string
    sql: ${TABLE}."RPO_TERM_MONTHS" ;;
  }
  dimension: rsm_approval {
    type: string
    sql: ${TABLE}."RSM_APPROVAL" ;;
  }
  dimension: rsm_email {
    type: string
    sql: ${TABLE}."RSM_EMAIL" ;;
  }
  dimension: sales_funds_received {
    type: yesno
    sql: ${TABLE}."SALES_FUNDS_RECEIVED" ;;
  }
  dimension: sales_invoice {
    type: yesno
    sql: ${TABLE}."SALES_INVOICE" ;;
  }
  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }
  dimension: sales_rep_email {
    type: string
    sql: ${TABLE}."SALES_REP_EMAIL" ;;
  }
  dimension: signed_rpo {
    type: yesno
    sql: ${TABLE}."SIGNED_RPO" ;;
  }
  dimension: signor_email_address {
    type: string
    sql: ${TABLE}."SIGNOR_EMAIL_ADDRESS" ;;
  }
  dimension: signor_name {
    type: string
    sql: ${TABLE}."SIGNOR_NAME" ;;
  }
  dimension: state_and_filing_number {
    type: string
    sql: ${TABLE}."STATE_AND_FILING_NUMBER" ;;
  }
  dimension: subitems {
    type: string
    sql: ${TABLE}."SUBITEMS" ;;
  }
  dimension: team_assign {
    type: string
    sql: ${TABLE}."TEAM_ASSIGN" ;;
  }
  dimension: total_asset_sales_price_quote {
    type: string
    sql: ${TABLE}."TOTAL_ASSET_SALES_PRICE_QUOTE" ;;
  }
  dimension: total_base_rental_quote {
    type: string
    sql: ${TABLE}."TOTAL_BASE_RENTAL_QUOTE" ;;
  }
  dimension: total_carrying_cost {
    type: string
    sql: ${TABLE}."TOTAL_CARRYING_COST" ;;
  }
  dimension: total_discounts {
    type: string
    sql: ${TABLE}."TOTAL_DISCOUNTS" ;;
  }
  dimension: total_eqs_cost {
    type: string
    sql: ${TABLE}."TOTAL_EQS_COST" ;;
  }
  dimension: total_eqs_dnet {
    type: string
    sql: ${TABLE}."TOTAL_EQS_DNET" ;;
  }
  dimension: total_ext_warranty_quote {
    type: string
    sql: ${TABLE}."TOTAL_EXT_WARRANTY_QUOTE" ;;
  }
  dimension: total_freight_charges {
    type: string
    sql: ${TABLE}."TOTAL_FREIGHT_CHARGES" ;;
  }
  dimension: total_margin {
    type: string
    sql: ${TABLE}."TOTAL_MARGIN" ;;
  }
  dimension: total_monthly_rent {
    type: string
    sql: ${TABLE}."TOTAL_MONTHLY_RENT" ;;
  }
  dimension: total_pdi {
    type: string
    sql: ${TABLE}."TOTAL_PDI" ;;
  }
  dimension: total_pm_quote {
    type: string
    sql: ${TABLE}."TOTAL_PM_QUOTE" ;;
  }
  dimension: total_sales_tax {
    type: string
    sql: ${TABLE}."TOTAL_SALES_TAX" ;;
  }
  dimension: total_t3_charges {
    type: string
    sql: ${TABLE}."TOTAL_T3_CHARGES" ;;
  }
  dimension: ucc_filed {
    type: string
    sql: ${TABLE}."UCC_FILED" ;;
  }
  dimension: ucc_released {
    type: string
    sql: ${TABLE}."UCC_RELEASED" ;;
  }
  dimension: upload_cust_amort_schedule {
    type: string
    sql: ${TABLE}."UPLOAD_CUST_AMORT_SCHEDULE" ;;
  }
  dimension: yard_name {
    type: string
    sql: ${TABLE}."YARD_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [name, signor_name, yard_name]
  }
}
