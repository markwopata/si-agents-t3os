view: cip_expense_classifications {
  derived_table: {
    sql:
      select
        ca.pk_gl_detail_id,
        ca.market_id,
        ca.market_name,
        ca.entry_date,
        ca.journal_type,
        ca.journal_transaction_number,
        ca.journal_title,
        ca.entry_description,
        ca.actual_amount,
        ca.created_by_username,
        ca.vendor_id,
        ca.vendor_name,
        ca.document_type,
        ca.document_number,
        ca.source_document_name,
        ca.originating_po_number,
        ca.line_description,
        ca.url_journal,
        ca.url_concur,
        ca.url_invoice_sage,
        ca.url_po_sage,
        ca.url_po_t3,
        ca.division_code,
        ca.division_name,
        ca.project_code
      from analytics.intacct_models.int_cip_actuals ca
      ;;
  }

  # Primary Key
  dimension: pk_gl_detail_id {
    label: "PK GL Detail ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.pk_gl_detail_id ;;
  }

  # Market dimensions
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: project_code {
    type:  string
    sql: ${TABLE}.project_code ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  # Date dimension for entry_date
  dimension: entry_date {
    type: date
    sql: ${TABLE}.entry_date ;;
  }

  # Journal fields
  dimension: journal_type {
    type: string
    sql: ${TABLE}.journal_type ;;
  }

  dimension: journal_transaction_number {
    type: string
    sql: ${TABLE}.journal_transaction_number ;;
  }

  dimension: journal_title {
    type: string
    sql: ${TABLE}.journal_title ;;
  }

  dimension: entry_description {
    type: string
    sql: ${TABLE}.entry_description ;;
  }

  # GL Amount (rounded)
  dimension: gl_amount {
    type: number
    sql: ${TABLE}.actual_amount ;;
    value_format_name: "usd"  # Adjust value_format if needed
  }

  # Measures on GL Amount
  measure: total_gl_amount {
    type: sum
    sql: ${gl_amount} ;;
    value_format_name: "usd"
  }

  # User info
  dimension: created_by_username {
    type: string
    sql: ${TABLE}.created_by_username ;;
  }

  # Vendor details
  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  # Document details
  dimension: document_type {
    type: string
    sql: ${TABLE}.document_type ;;
  }

  dimension: document_number {
    type: string
    sql: ${TABLE}.document_number ;;
  }

  dimension: source_document_name {
    type: string
    sql: ${TABLE}.source_document_name ;;
  }

  dimension: originating_po_number {
    label: "Originating PO"
    type: string
    sql: ${TABLE}.originating_po_number ;;
  }

  # Description field (for PO/AP/GL)
  dimension: line_description {
    type: string
    sql: ${TABLE}.line_description ;;
  }

  # URL fields
  dimension: url_journal {
    type: string
    sql: ${TABLE}.url_journal ;;
  }

  dimension: url_concur {
    type: string
    sql: ${TABLE}.url_concur ;;
  }

  dimension: url_invoice_sage {
    type: string
    sql: ${TABLE}.url_invoice_sage ;;
  }

  dimension: url_po_sage {
    type: string
    sql: ${TABLE}.url_po_sage ;;
  }

  dimension: url_po_t3 {
    type: string
    sql: ${TABLE}.url_po_t3 ;;
  }

  dimension: links {
    type: string
    sql: concat(coalesce(${url_po_sage}, ''), coalesce(${url_invoice_sage},''), coalesce(${url_concur},''), coalesce(${url_po_t3},''), coalesce(${url_journal},'')) ;;
    html: {% if url_po_t3._value != null and url_po_t3._value != '' %}
            <a href="{{ url_po_t3._value }}" target="_blank">
            <img src="https://unav.equipmentshare.com/fleet.svg" width="16" height="16"> T3</a><br>
          {% endif %}
          {% if url_po_sage._value != null and url_po_sage._value != '' %}
            <a href="{{ url_po_sage._value }}" target="_blank">
            <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> PO</a><br>
          {% endif %}
          {% if url_invoice_sage._value != null and url_invoice_sage._value != '' %}
            <a href="{{ url_invoice_sage._value }}" target="_blank">
            <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> Invoice</a><br>
          {% endif %}
          {% if url_journal._value != null and url_journal._value != '' %}
            <a href="{{ url_journal._value }}" target="_blank">
            <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> Journal</a><br>
          {% endif %}
          {% if url_concur._value != null and url_concur._value != '' %}
            <a href="{{ url_concur._value }}" target="_blank">
            <img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Concur</a><br>
          {% endif %}
          ;;
  }

  # Division details
  dimension: division_code {
    type: string
    sql: ${TABLE}.division_code ;;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}.division_name ;;
  }

  set: cip_expense_line_detail {
    fields: [
      division_code,
      division_name,
      market_id,
      market_name,
      entry_date,
      journal_type,
      journal_transaction_number,
      document_type,
      document_number,
      source_document_name,
      originating_po_number,
      journal_title,
      line_description,
      gl_amount,
      created_by_username,
      vendor_id,
      vendor_name,
      links
    ]
  }
}
