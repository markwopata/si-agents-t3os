
view: fct_credit_notes {
  sql_table_name: analytics.intacct_models.fct_credit_notes ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  measure: credit_note_count {
    type: count_distinct
    sql: ${credit_note_id} ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT";;
    value_format_name: usd_0
  }

  measure: credit_amount_sum {
    type: sum
    sql: ${credit_amount} * (-1);;
    value_format_name: usd_0
    drill_fields: [credit_note_detail*]
  }

  measure: credit_amount_sum_cm {
    type: sum
    sql: case when ${credit_created_date.is_current_month} THEN ${credit_amount} * (-1) END ;;
    value_format_name: usd_0
    drill_fields: [credit_note_detail*]

  }

  measure: credit_amount_sum_pm {
    type: sum
    sql: case when ${credit_created_date.is_prior_month} THEN ${credit_amount} * (-1) END ;;
    value_format_name: usd_0
    drill_fields: [credit_note_detail*]

  }

  measure: credit_amount_sum_cm_filter {
    type: sum
    sql: ${credit_amount}*(-1) ;;
    filters: [credit_created_date.is_current_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [credit_note_detail*]

  }

  measure: credit_amount_sum_pm_filter {
    type: sum
    sql: ${credit_amount}*(-1) ;;
    filters: [credit_created_date.is_prior_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [credit_note_detail*]

  }




  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: remaining_credit_amount {
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: date_created {
    type: string
    label: "Credit Created Date"
    sql: ${credit_created_date.date} ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  set: credit_note_detail {
    fields: [
      dim_credit_notes.credit_note_id_link,
      date_created,
      dim_companies_bi.company_and_id_with_na_icon_and_link_int_credit_app,
      dim_salesperson_enhanced_historical.rep_home_perm_enh,
      dim_credit_notes.admin_link_to_invoice,
      credit_amount_sum
    ]
  }

  set: detail {
    fields: [
        credit_note_id,
  credit_amount,
  tax_amount,
  remaining_credit_amount,
  line_item_amount
    ]
  }
}
