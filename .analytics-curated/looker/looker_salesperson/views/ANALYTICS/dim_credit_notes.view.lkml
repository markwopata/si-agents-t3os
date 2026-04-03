
view: dim_credit_notes {

  sql_table_name: analytics.intacct_models.dim_credit_notes  ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: credit_note_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_id_link {
    label: "Credit Note ID"
    type: string
    sql: ${credit_note_id} ;;
    html: <font color="#0063f3 "><u><a href="{{url_credit_note_admin}}" target="_blank">{{credit_note_id._rendered_value}} ➔ </a></font></u> ;;
  }

  measure: credit_note_count {
    type: count_distinct
    sql: ${credit_note_id} ;;
  }

  measure: credit_note_count_cm {
    label: "Current Month Credit Count"
    type: count_distinct
    sql: CASE WHEN ${credit_created_date.is_current_month} THEN ${credit_note_id} END;;
  }

  measure: credit_note_count_pm {
    label: "Prior Month Credit Count"
    type: count_distinct
    sql: CASE WHEN ${credit_created_date.is_prior_month} THEN ${credit_note_id} END;;
  }


  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: originating_invoice_id {
    type: string
    sql: ${TABLE}."ORIGINATING_INVOICE_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: credit_note_type_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
  }

  dimension: credit_note_status_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }

  dimension: credit_note_status_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
  }

  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: admin_link_to_invoice {
    label: "Invoice Number"
    type: string
    html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_number}}&includeDeletedInvoices=false" target="_blank">{{invoice_number._rendered_value}} ➔ </a></font></u> ;;
    sql: ${invoice_number}  ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: created_by_user_id {
    type: string
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  set: credit_note_detail {
    fields: [
      credit_note_id_link,
      dim_companies_bi.company_and_id_with_na_icon_and_link_int_credit_app,
      dim_salesperson_enhanced_historical.rep_home_perm_enh,
      admin_link_to_invoice,
      fct_credit_notes.credit_amount_sum
    ]
  }

  set: detail {
    fields: [
        credit_note_id,
  company_id,
  originating_invoice_id,
  market_id,
  credit_note_type_id,
  created_by_user_id,
  credit_note_status_id,
  credit_note_status_name,
  url_credit_note_admin,
  invoice_number,
  credit_note_number,
  created_by,
  date_created_time
    ]
  }
}
