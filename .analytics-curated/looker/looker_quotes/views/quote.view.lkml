view: quote {

  derived_table: {
    sql:
      select
        q.*,
        concat(u.first_name, ' ', u.last_name) as sales_rep,
        u.email_address
      from quotes.quotes.quote q
      left join es_warehouse.public.users u on q.sales_rep_id = u.user_id
    ;;
  }
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: _es_load_timestamp {
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
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _es_update_timestamp {
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

  dimension_group: created_date {
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
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: deliver_to {
    type: string
    sql: ${TABLE}."DELIVER_TO" ;;
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

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: expiry {
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

  dimension: last_modified_by {
    type: number
    sql: ${TABLE}."LAST_MODIFIED_BY" ;;
  }

  dimension_group: last_modified {
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

  dimension: new_company_name {
    type: string
    sql: ${TABLE}."NEW_COMPANY_NAME" ;;
  }

  dimension: order_created_by {
    type: number
    sql: ${TABLE}."ORDER_CREATED_BY" ;;
  }

  dimension_group: order_created {
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
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
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

  dimension: quote_number {
    type: number
    sql: ${TABLE}."QUOTE_NUMBER" ;;
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

  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: sales_rep_id {
    type: number
    sql: ${TABLE}."SALES_REP_ID" ;;
  }

  dimension: sales_tax_percentage {
    type: number
    sql: ${TABLE}."SALES_TAX_PERCENTAGE" ;;
  }

  dimension_group: start {
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

  measure: quote_distinct_count {
    type: count_distinct
    label: "Count of Quotes"
    sql: ${quote_number};;
    drill_fields: [quote_number, company_name]
  }

  measure: order_id_distinct_count {
    type: count_distinct
    label: "Count of Orders"
    sql: ${order_id};;
    drill_fields: [order_id, company_name]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      company_name,
      new_company_name,
      delivery_type_name,
      po_name,
      rpp_name,
      contact_name,
      audit_history.count,
      equipment_type.count,
      sale_item.count
    ]
  }
}
