view: ap_accrual_receipt_to_conversion {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select gd.amount                                                                             gl_amount,
                 gd.FK_SUBLEDGER_LINE_ID                                                               FK_RESOLVE_PO_LINE_RECORDNO,
                 pd.RECEIPT_NUMBER,
                 pd.DOCUMENT_NAME,
                 pd.quantity,
                 pd.unit_price,
                 pd.extended_amount,
                 coalesce(pd.ACCOUNT_NUMBER, right(pd.item_id, 4))                                     expense_account_number,
                 listagg(distinct case
                                      when pd_v.document_type = 'Closed Purchase Order' then 'closed receipt'
                                      when pd_v.document_type = 'Vendor Invoice' then 'invoice matched to receipt'
                                      when pd_v.document_type is not null
                                          then 'Other Document Type - ' || pd_v.document_type
                                      when pd_v.FK_PO_LINE_ID is null then 'n/a'
                                      else 'unknown'
                     end, ',')                                                                         relieved_by,
                 sum(pd_v.quantity)                                                                    relieved_quantity,
                 listagg(distinct case
                                      when pd_v.document_type = 'Closed Purchase Order'
                                          then pd_v.DOCUMENT_NUMBER || 'π' || coalesce(pd_v.URL_SAGE, 'no url') end,
                         'π')                                                                          closed_receipts,
                 listagg(distinct ad.invoice_number || 'π' || coalesce(ad.url_invoice, 'no url'), 'π') bill_numbers,
                 pd.URL_SAGE                                                                           url_receipt,
                 gd.entry_date,
                 gd.url_journal,
                 gd.journal_transaction_number                                                         journal_number,
                 pd.vendor_id,
                 pd.vendor_name
          from analytics.INTACCT_MODELS.gl_detail gd
                   left join analytics.INTACCT_MODELS.po_detail pd
                             on gd.FK_SUBLEDGER_LINE_ID = pd.FK_PO_LINE_ID
                                 and gd.INTACCT_MODULE = '9.PO'
                   left join analytics.INTACCT_MODELS.po_detail pd_v
                             on pd_v.FK_SOURCE_PO_LINE_ID = pd.FK_PO_LINE_ID
                                 and pd_v.source_document_name = pd.document_name -- Need both to truly convert
                   left join analytics.INTACCT_MODELS.AP_DETAIL AD
                             on ad.LINE_NUMBER - 1 = pd_v.LINE_NUMBER
                                 and ad.source_document_name = pd_v.document_name
          where 1 = 1
            and gd.ACCOUNT_NUMBER = '2014'
            and pd.DOCUMENT_TYPE = 'Purchase Order'
          group by gd.amount, gd.FK_SUBLEDGER_LINE_ID, pd.RECEIPT_NUMBER, pd.DOCUMENT_NAME, pd.quantity, pd.unit_price,
                   pd.extended_amount, coalesce(pd.ACCOUNT_NUMBER, right(pd.item_id, 4)), pd.URL_SAGE, gd.entry_date,
                   gd.url_journal, gd.journal_transaction_number, pd.vendor_id, pd.vendor_name

      ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}."ENTRY_DATE" ;;
    convert_tz: no
  }

  dimension: url_receipt {
    type: string
    sql: ${TABLE}."URL_RECEIPT" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: receipt_number {
    type: string
    sql: ${TABLE}."RECEIPT_NUMBER" ;;
    html: <a href="{{ url_receipt._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: document_name {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
  }

  dimension: fk_resolve_po_line_recordno {
    type: number
    sql: ${TABLE}."FK_RESOLVE_PO_LINE_RECORDNO" ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}."UNIT_PRICE" ;;
    value_format_name: usd

  }

  measure: quantity {
    type: sum
    sql: ${TABLE}."QUANTITY" ;;
  }

  measure: extended_amount {
    type: sum
    sql: ${TABLE}."EXTENDED_AMOUNT" ;;
    value_format_name: usd
  }

  measure: gl_amount {
    label: "GL Amount"
    type: sum
    sql: ${TABLE}."GL_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: expense_account_number {
    type: string
    sql: ${TABLE}."EXPENSE_ACCOUNT_NUMBER" ;;
  }

  dimension: relieved_by {
    type: string
    sql: ${TABLE}."RELIEVED_BY" ;;
  }

  measure: relieved_quantity {
    type: sum
    sql: ${TABLE}."RELIEVED_QUANTITY" ;;
  }

  dimension: closed_receipts {
    type: string
    sql: ${TABLE}."CLOSED_RECEIPTS" ;;
    html: {% assign items = value | split: 'π' %}
          {% assign links = '' %}
          {% for item in items %}
            {% assign index_mod = forloop.index0 | modulo: 2 %}
            {% if index_mod == 0 %}
              {% assign key = item %}
            {% else %}
              {% assign url = item %}
              {% assign link = key %}
              {% if url != 'no url' %}
                {% assign link = "<a href='" | append: url | append: "' target='_blank' style='color: blue;'>" | append: key | append: "</a>" %}
              {% endif %}
              {% assign links = links | append: link %}
              {% if forloop.last == false %}
                {% assign links = links | append: ', ' %}
              {% endif %}
            {% endif %}
          {% endfor %}
          {{ links | strip_newlines }}
          ;;
  }

  dimension: bill_numbers {
    type: string
    sql: ${TABLE}."BILL_NUMBERS" ;;
    html: {% assign items = value | split: 'π' %}
          {% assign links = '' %}
          {% for item in items %}
            {% assign index_mod = forloop.index0 | modulo: 2 %}
            {% if index_mod == 0 %}
              {% assign key = item %}
            {% else %}
              {% assign url = item %}
              {% assign link = key %}
              {% if url != 'no url' %}
                {% assign link = "<a href='" | append: url | append: "' target='_blank' style='color: blue;'>" | append: key | append: "</a>" %}
              {% endif %}
              {% assign links = links | append: link %}
              {% if forloop.last == false %}
                {% assign links = links | append: ', ' %}
              {% endif %}
            {% endif %}
          {% endfor %}
          {{ links | strip_newlines }}
          ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: url_journal {
    type: string
    sql: ${TABLE}."URL_JOURNAL" ;;
  }

  dimension: journal_number {
    type: string
    sql: ${TABLE}."JOURNAL_NUMBER" ;;
    html: <a href="{{ url_journal._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  measure: count {
    type: count
  }
}
