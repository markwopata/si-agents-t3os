view: dim_line_items {
  sql_table_name: "PLATFORM"."GOLD"."DIM_LINE_ITEMS" ;;

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
    type: string
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
  dimension_group: line_item_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: is_ram_commissionable {
    type: yesno
    sql: ${line_item_type_id} IN (8, 43, 80, 110, 141, 24, 81, 111, 123) ;;
    group_label: "Salesperson Logic"
    label: "RAM Commissionable"
  }
  dimension: is_tam_commissionable {
    type: yesno
    sql: ${line_item_type_id} IN (6, 8, 108, 109, 43, 5, 44, 49, 129, 130, 131, 132, 80, 110, 141, 24, 81, 111, 123) ;;
    group_label: "Salesperson Logic"
    label: "TAM Commissionable"
  }
  dimension: is_nam_commissionable {
    type: yesno
    sql: ${line_item_type_id} IN (6, 8, 108, 109, 43, 5, 44, 49, 129, 130, 131, 132) ;;
    group_label: "Salesperson Logic"
    label: "NAM Commissionable"
  }
  dimension: line_item_category {
    type: string
    sql:
    CASE
      WHEN ${line_item_type_id} IN (24, 111) THEN 'New Fleet Sales'

      WHEN ${line_item_type_id} IN (81,110) THEN 'Used Fleet Sales'

      WHEN ${line_item_type_id} IN (80, 120, 125, 141, 152, 153) THEN 'Dealership Fleet Sales'

      WHEN ${line_item_type_id} IN (123, 127) THEN 'Own Sales'

      WHEN ${line_item_type_id} IN (118, 126) THEN 'LSD Sales'

      WHEN ${line_item_type_id} IN (50) THEN 'RPO Sales'

      WHEN ${line_item_type_id} IN (145, 146, 147, 148, 149, 150) THEN 'Under 10k Sales'

      ELSE 'Other'
      END ;;
  }
  measure: count {
    type: count
    drill_fields: [line_item_type_name, line_item_section_name]
  }
}
