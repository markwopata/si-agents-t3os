view: invoices {
  derived_table: {
    sql:
    select
      gi.*,
      vli.li_billed_amount
    from
      es_warehouse.public.invoices gi
    LEFT JOIN
      (select
        invoice_id,
        sum(amount) as li_billed_amount
      from
        ANALYTICS.PUBLIC.V_LINE_ITEMS
      group by
        1
    ) vli on gi.invoice_id = vli.invoice_id
    where gi.billing_approved = true
      ;;
  }
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
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

  # dimension: are_tax_cals_missing {
  #   type: yesno
  #   sql: ${TABLE}."ARE_TAX_CALS_MISSING" ;;
  # }

  # dimension: avalara_transaction_id {
  #   type: string
  #   sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  # }

  # dimension_group: avalara_transaction_id_update_dt_tm {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."AVALARA_TRANSACTION_ID_UPDATE_DT_TM" AS TIMESTAMP_NTZ) ;;
  # }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  # dimension: billing_approved_by_user_id {
  #   type: number
  #   sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  # }

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # dimension: billing_provider_id {
  #   type: number
  #   sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  # }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  # dimension: created_by_user_id {
  #   type: number
  #   sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  # }

  dimension: customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # dimension_group: date_updated {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  # }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: due_date_outstanding {
    type: number
    sql: ${TABLE}."DUE_DATE_OUTSTANDING" ;;
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: li_billed_amount {
    label: "Line Item Billed Amount"
    type: number
    sql: ${TABLE}."LI_BILLED_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: ordered_by_user_id {
    type: number
    sql: ${TABLE}."ORDERED_BY_USER_ID" ;;
  }

  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # dimension: private_note {
  #   type: string
  #   sql: ${TABLE}."PRIVATE_NOTE" ;;
  # }

  # dimension: public_note {
  #   type: string
  #   sql: ${TABLE}."PUBLIC_NOTE" ;;
  # }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }

  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }

  # dimension: ship_from {
  #   type: string
  #   sql: ${TABLE}."SHIP_FROM" ;;
  # }

  # dimension: ship_to {
  #   type: string
  #   sql: ${TABLE}."SHIP_TO" ;;
  # }

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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  # dimension_group: taxes_invalidated_dt_tm {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."TAXES_INVALIDATED_DT_TM" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension: xero_id {
  #   type: string
  #   sql: ${TABLE}."XERO_ID" ;;
  # }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: 30_days_from_current_date {
    type: date
    sql: current_date() - interval '30 days' ;;
  }

  dimension: view_invoices_table {
    label: "View Invoices Summary"
    type: string
    sql: 'View Invoices Summary' ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/rentals/invoices?status=all&start={{ 30_days_from_current_date._value | date: "%m-%d-%Y"}}&end={{ current_date._value | date: "%m-%d-%Y"}}" target="_blank">View Invoices Summary</a></font></u> ;;
  }

  dimension: view_invoice {
    group_item_label: "Link to Invoice"
    label: "Invoice No"
    type: string
    required_fields: [invoice_id]
    sql: ${invoice_no} ;;
    html:
    {% if user_is_america_timezone._value == "Yes" %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{invoice_id._value}}" target="_blank">{{invoice_no._value}}</a></font></u>
    {% else %}
    {{invoice_no._value}}
    {% endif %};;
  }


  dimension: user_is_america_timezone {
    type: yesno
    sql: substr('{{ _user_attributes['user_timezone'] }}',0,7) = 'America' ;;
  }

  dimension: invoice_status {
    type: string
    sql: case when ${paid} = 'Yes' then 'Paid'
    when ${due_date_outstanding} > 0 AND ${due_date_outstanding} is not null then 'Past Due'
    Else 'Due'
    END;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_id, orders.purchase_order_id, line_items.count]
  }
}
