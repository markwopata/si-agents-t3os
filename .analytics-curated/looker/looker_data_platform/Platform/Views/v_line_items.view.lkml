view: v_line_items {
  view_label: "Line Items"
  sql_table_name: "GOLD"."V_LINE_ITEMS" ;;

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: line_item_intacct_gl_account_category {
    type: string
    sql: ${TABLE}."LINE_ITEM_INTACCT_GL_ACCOUNT_CATEGORY" ;;
  }
  dimension: line_item_intacct_gl_account_no {
    type: string
    sql: ${TABLE}."LINE_ITEM_INTACCT_GL_ACCOUNT_NO" ;;
  }
  dimension: line_item_intacct_gl_account_title {
    type: string
    sql: ${TABLE}."LINE_ITEM_INTACCT_GL_ACCOUNT_TITLE" ;;
  }
  dimension: line_item_intacct_gl_account_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_INTACCT_GL_ACCOUNT_TYPE" ;;
  }
  dimension: line_item_key {
    type: number
    primary_key:  yes
    sql: ${TABLE}."LINE_ITEM_KEY" ;;
  }
  dimension: line_item_override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."LINE_ITEM_OVERRIDE_MARKET_TAX_RATE" ;;
  }
  dimension: line_item_payouts_processed {
    type: yesno
    sql: ${TABLE}."LINE_ITEM_PAYOUTS_PROCESSED" ;;
  }
  dimension: line_item_recordtimestamp {
    type: date
    sql: ${TABLE}."LINE_ITEM_RECORDTIMESTAMP" ;;
  }
  dimension: line_item_rental_revenue {
    type: yesno
    sql: ${TABLE}."LINE_ITEM_RENTAL_REVENUE" ;;
  }
  dimension: line_item_section_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_SECTION_NAME" ;;
  }
  dimension: line_item_section_number {
    type: number
    sql: ${TABLE}."LINE_ITEM_SECTION_NUMBER" ;;
  }
  dimension: line_item_source {
    type: string
    sql: ${TABLE}."LINE_ITEM_SOURCE" ;;
  }
  dimension: line_item_taxable {
    type: yesno
    sql: ${TABLE}."LINE_ITEM_TAXABLE" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [line_item_section_name, line_item_type_name]
  }
}
