view: portal_access_guide {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PORTAL_ACCESS_GUIDE" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: access_or_order_instructions_portal_faqs_ {
    type: string
    sql: ${TABLE}."ACCESS_OR_ORDER_INSTRUCTIONS_PORTAL_FAQS_" ;;
  }
  dimension: corporate_contact {
    type: string
    sql: ${TABLE}."CORPORATE_CONTACT" ;;
  }
  dimension: discount {
    type: string
    sql: ${TABLE}."DISCOUNT" ;;
  }
  dimension: link_for_manuals {
    type: string
    sql: ${TABLE}."LINK_FOR_MANUALS" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: order_method {
    type: string
    sql: ${TABLE}."ORDER_METHOD" ;;
  }
  dimension: ordering_instructions {
    type: string
    sql: ${TABLE}."ORDERING_INSTRUCTIONS" ;;
  }
  dimension: our_account_ {
    type: string
    sql: ${TABLE}."OUR_ACCOUNT_" ;;
  }
  dimension: phone_number_email_support {
    type: string
    sql: ${TABLE}."PHONE_NUMBER_EMAIL_SUPPORT" ;;
  }
  dimension: portal_link_if_applicable_portal_faqs_ {
    type: string
    sql: ${TABLE}."PORTAL_LINK_IF_APPLICABLE_PORTAL_FAQS_" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name_in_cost_capture {
    type: string
    sql: ${TABLE}."VENDOR_NAME_IN_COST_CAPTURE" ;;
  }
  dimension: warranty_parts_terms {
    type: string
    sql: ${TABLE}."WARRANTY_PARTS_TERMS" ;;
  }
  dimension: warranty_repair_terms_ {
    type: string
    sql: ${TABLE}."WARRANTY_REPAIR_TERMS_" ;;
  }
  measure: count {
    type: count
  }
}
