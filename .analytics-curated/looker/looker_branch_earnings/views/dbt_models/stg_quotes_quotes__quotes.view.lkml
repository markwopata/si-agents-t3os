view: stg_quotes_quotes__quotes {
  sql_table_name: "INTACCT_MODELS"."STG_QUOTES_QUOTES__QUOTES" ;;

  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }
  dimension: contact_id {
    type: number
    sql: ${TABLE}."CONTACT_ID" ;;
  }
  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }
  dimension: contact_phone {
    type: string
    sql: ${TABLE}."CONTACT_PHONE" ;;
  }
  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: deliver_to {
    type: string
    sql: ${TABLE}."DELIVER_TO" ;;
  }
  dimension: deliver_to_address {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS" ;;
  }
  dimension: deliver_to_latitude {
    type: number
    sql: ${TABLE}."DELIVER_TO_LATITUDE" ;;
  }
  dimension: deliver_to_longitude {
    type: number
    sql: ${TABLE}."DELIVER_TO_LONGITUDE" ;;
  }
  dimension: delivery_fee {
    type: number
    sql: ${TABLE}."DELIVERY_FEE" ;;
  }
  dimension: delivery_mileage {
    type: number
    sql: ${TABLE}."DELIVERY_MILEAGE" ;;
  }
  dimension: delivery_type_id {
    type: number
    sql: ${TABLE}."DELIVERY_TYPE_ID" ;;
  }
  dimension: delivery_type_name {
    type: string
    sql: ${TABLE}."DELIVERY_TYPE_NAME" ;;
  }
  dimension: duplicated_from_quote_id {
    type: string
    sql: ${TABLE}."DUPLICATED_FROM_QUOTE_ID" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: escalation_id {
    type: string
    sql: ${TABLE}."ESCALATION_ID" ;;
  }
  dimension_group: expiry {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EXPIRY_DATE" ;;
  }
  dimension: has_pdf {
    type: yesno
    sql: ${TABLE}."HAS_PDF" ;;
  }
  dimension: is_tax_exempt {
    type: yesno
    sql: ${TABLE}."IS_TAX_EXEMPT" ;;
  }
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }
  dimension: last_modified_by {
    type: number
    sql: ${TABLE}."LAST_MODIFIED_BY" ;;
  }
  dimension_group: last_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_MODIFIED_DATE" ;;
  }
  dimension: location_description {
    type: string
    sql: ${TABLE}."LOCATION_DESCRIPTION" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: missed_rental_reason {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON" ;;
  }
  dimension: missed_rental_reason_other {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON_OTHER" ;;
  }
  dimension: new_company_name {
    type: string
    sql: ${TABLE}."NEW_COMPANY_NAME" ;;
  }
  dimension: new_location_info {
    type: string
    sql: ${TABLE}."NEW_LOCATION_INFO" ;;
  }
  dimension_group: order_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ORDER_CREATED_AT" ;;
  }
  dimension: order_created_by {
    type: number
    sql: ${TABLE}."ORDER_CREATED_BY" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }
  dimension: ordered_by_email {
    type: string
    sql: ${TABLE}."ORDERED_BY_EMAIL" ;;
  }
  dimension: ordered_by_phone {
    type: string
    sql: ${TABLE}."ORDERED_BY_PHONE" ;;
  }
  dimension: phase_id {
    type: number
    sql: ${TABLE}."PHASE_ID" ;;
  }
  dimension: phase_name {
    type: string
    sql: ${TABLE}."PHASE_NAME" ;;
  }
  dimension: pickup_fee {
    type: number
    sql: ${TABLE}."PICKUP_FEE" ;;
  }
  dimension: po_id {
    type: string
    sql: ${TABLE}."PO_ID" ;;
  }
  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }
  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }
  dimension_group: quote_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."QUOTE_CREATED_AT" ;;
  }
  dimension: quote_id {
    type: string
    sql: ${TABLE}."QUOTE_ID" ;;
  }
  dimension: quote_number {
    type: number
    sql: ${TABLE}."QUOTE_NUMBER" ;;
  }
  dimension: request_source_id {
    type: string
    sql: ${TABLE}."REQUEST_SOURCE_ID" ;;
  }
  dimension: rpp_id {
    type: number
    sql: ${TABLE}."RPP_ID" ;;
  }
  dimension: rpp_name {
    type: string
    sql: ${TABLE}."RPP_NAME" ;;
  }
  dimension: rsp_company_id {
    type: number
    sql: ${TABLE}."RSP_COMPANY_ID" ;;
  }
  dimension: sales_rep_id {
    type: number
    sql: ${TABLE}."SALES_REP_ID" ;;
  }
  dimension: sales_tax_percentage {
    type: number
    sql: ${TABLE}."SALES_TAX_PERCENTAGE" ;;
  }
  dimension: scope_of_work {
    type: string
    sql: ${TABLE}."SCOPE_OF_WORK" ;;
  }
  dimension: site_contact_name {
    type: string
    sql: ${TABLE}."SITE_CONTACT_NAME" ;;
  }
  dimension: site_contact_phone {
    type: string
    sql: ${TABLE}."SITE_CONTACT_PHONE" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: state_specific_tax_percentage {
    type: number
    sql: ${TABLE}."STATE_SPECIFIC_TAX_PERCENTAGE" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	new_company_name,
	phase_name,
	company_name,
	job_name,
	rpp_name,
	po_name,
	delivery_type_name,
	contact_name,
	site_contact_name
	]
  }

}
