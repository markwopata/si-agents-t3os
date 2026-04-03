view: fleet_ops_rpo_board {
  sql_table_name: "ANALYTICS"."MONDAY"."FLEET_OPS_RPO_BOARD" ;;

  dimension: applied_rent {
    type: string
    sql: ${TABLE}."APPLIED_RENT" ;;
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
  dimension: documents_and_pictures {
    type: string
    sql: ${TABLE}."DOCUMENTS_AND_PICTURES" ;;
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
  dimension: state_filing_number {
    type: string
    sql: ${TABLE}."STATE_FILING_NUMBER" ;;
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
  dimension: upload_customer_amort_form {
    type: string
    sql: ${TABLE}."UPLOAD_CUSTOMER_AMORT_FORM" ;;
  }
  dimension: yard_name {
    type: string
    sql: ${TABLE}."YARD_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [yard_name, signor_name, name]
  }
}
