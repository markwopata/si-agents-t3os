view: intacct__ap_headers {
  sql_table_name: "INTACCT_GOLD"."INTACCT__AP_HEADERS" ;;

  dimension: pk_ap_header_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_AP_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: type_record {
    type: string
    sql: ${TABLE}."TYPE_RECORD" ;;
  }

  dimension: name_module {
    type: string
    sql: ${TABLE}."NAME_MODULE" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: id_record {
    type: string
    sql: ${TABLE}."ID_RECORD" ;;
  }

  dimension: name_doc_header_converted {
    type: string
    sql: ${TABLE}."NAME_DOC_HEADER_CONVERTED" ;;
  }

  dimension: num_po_document {
    type: string
    sql: ${TABLE}."NUM_PO_DOCUMENT" ;;
  }

  dimension: num_vi_document {
    type: string
    sql: ${TABLE}."NUM_VI_DOCUMENT" ;;
  }

  dimension: currency_code_base {
    type: string
    sql: ${TABLE}."CURRENCY_CODE_BASE" ;;
  }

  dimension: priority_payment {
    type: string
    sql: ${TABLE}."PRIORITY_PAYMENT" ;;
  }

  dimension: delivery_method {
    type: string
    sql: ${TABLE}."DELIVERY_METHOD" ;;
  }

  dimension: template_bill_back {
    type: string
    sql: ${TABLE}."TEMPLATE_BILL_BACK" ;;
  }

  dimension: amount_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_ENTERED" ;;
    value_format_name: usd
  }

  dimension: amount_total_paid {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
    value_format_name: usd
  }

  dimension: amount_total_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_RETAINED" ;;
    value_format_name: usd
  }

  dimension: amount_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
    value_format_name: usd
  }

  dimension: amount_payment {
    type: number
    sql: ${TABLE}."AMOUNT_PAYMENT" ;;
    value_format_name: usd
  }

  dimension: amount_trx_entity_due {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_ENTITY_DUE" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_DUE" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_ENTERED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_paid {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_released {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RELEASED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RETAINED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
    value_format_name: usd
  }

  dimension: is_on_hold {
    type: yesno
    sql: ${TABLE}."IS_ON_HOLD" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_system_generated {
    type: string
    sql: ${TABLE}."IS_SYSTEM_GENERATED" ;;
  }

  dimension: is_pr_batch_no_gl {
    type: yesno
    sql: ${TABLE}."IS_PR_BATCH_NO_GL" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_inclusive_tax {
    type: yesno
    sql: ${TABLE}."IS_INCLUSIVE_TAX" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_bill_back_template_use_iet {
    type: yesno
    sql: ${TABLE}."IS_BILL_BACK_TEMPLATE_USE_IET" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: state_raw {
    type: string
    sql: ${TABLE}."STATE_RAW" ;;
  }

  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
  }

  dimension: status_record {
    type: string
    sql: ${TABLE}."STATUS_RECORD" ;;
  }

  dimension: status_cleared {
    type: string
    sql: ${TABLE}."STATUS_CLEARED" ;;
  }

  dimension: status_pr_batch {
    type: string
    sql: ${TABLE}."STATUS_PR_BATCH" ;;
  }

  dimension: state_po_document {
    type: string
    sql: ${TABLE}."STATE_PO_DOCUMENT" ;;
  }

  dimension: type_payment {
    type: string
    sql: ${TABLE}."TYPE_PAYMENT" ;;
  }

  dimension: name_pr_batch {
    type: string
    sql: ${TABLE}."NAME_PR_BATCH" ;;
  }

  dimension: account_paid_from {
    type: string
    sql: ${TABLE}."ACCOUNT_PAID_FROM" ;;
  }

  dimension: name_payment_provider {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_PROVIDER" ;;
  }

  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }

  dimension: num_days_payment_term {
    type: string
    sql: ${TABLE}."NUM_DAYS_PAYMENT_TERM" ;;
  }

  dimension: name_bill_pay_to_contact {
    type: string
    sql: ${TABLE}."NAME_BILL_PAY_TO_CONTACT" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: days_due_in {
    type: string
    sql: ${TABLE}."DAYS_DUE_IN" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: exchange_rate {
    type: number
    sql: ${TABLE}."EXCHANGE_RATE" ;;
  }

  dimension: id_exchange_rate_type {
    type: number
    sql: ${TABLE}."ID_EXCHANGE_RATE_TYPE" ;;
  }

  dimension: entity_paid_from {
    type: string
    sql: ${TABLE}."ENTITY_PAID_FROM" ;;
  }

  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: id_sup_doc {
    type: string
    sql: ${TABLE}."ID_SUP_DOC" ;;
  }

  dimension: id_tax_solution {
    type: string
    sql: ${TABLE}."ID_TAX_SOLUTION" ;;
  }

  dimension: id_yooz_doc {
    type: string
    sql: ${TABLE}."ID_YOOZ_DOC" ;;
  }

  dimension: form_1099_box {
    type: string
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }

  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }

  dimension: type_vendor_1099 {
    type: string
    sql: ${TABLE}."TYPE_VENDOR_1099" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_payment_term_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_TERM_ID" ;;
    value_format_name: id
  }

  dimension: fk_concur_image_id {
    type: string
    sql: ${TABLE}."FK_CONCUR_IMAGE_ID" ;;
  }

  dimension: fk_pay_to_tax_group_record_id {
    type: number
    sql: ${TABLE}."FK_PAY_TO_TAX_GROUP_RECORD_ID" ;;
    value_format_name: id
  }

  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
    value_format_name: id
  }

  dimension: fk_bill_pay_to_contact_id {
    type: number
    sql: ${TABLE}."FK_BILL_PAY_TO_CONTACT_ID" ;;
    value_format_name: id
  }

  dimension: fk_pr_batch_id {
    type: number
    sql: ${TABLE}."FK_PR_BATCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_user_key {
    type: number
    sql: ${TABLE}."FK_USER_KEY" ;;
  }

  dimension: fk_ship_return_contact_id {
    type: number
    sql: ${TABLE}."FK_SHIP_RETURN_CONTACT_ID" ;;
    value_format_name: id
  }

  dimension: fk_vi_header_id {
    type: number
    sql: ${TABLE}."FK_VI_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_receipt_header_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_po_header_id {
    type: number
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension_group: date_cleared {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CLEARED" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
  }

  dimension_group: date_discount {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DISCOUNT" ;;
  }

  dimension_group: date_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAID" ;;
  }

  dimension_group: date_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT" ;;
  }

  dimension_group: date_payment_recommended {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT_RECOMMENDED" ;;
  }

  dimension_group: date_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTED" ;;
  }

  dimension_group: date_receipt {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECEIPT" ;;
  }

  dimension_group: date_reconciled {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECONCILED" ;;
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_vi_intacct {
    type: string
    sql: ${TABLE}."URL_VI_INTACCT" ;;
    link: {
      label: "URL Vi Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_receipt_intacct {
    type: string
    sql: ${TABLE}."URL_RECEIPT_INTACCT" ;;
    link: {
      label: "URL Receipt Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_po_intacct {
    type: string
    sql: ${TABLE}."URL_PO_INTACCT" ;;
    link: {
      label: "URL Po Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_yooz {
    type: string
    sql: ${TABLE}."URL_YOOZ" ;;
    link: {
      label: "URL Yooz"
      url: "{{ value }}"
    }
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      pk_ap_header_id,
      type_record,
      name_module,
      id_vendor,
      name_vendor,
      id_record,
      name_doc_header_converted,
      num_po_document,
      num_vi_document,
      currency_code_base,
      priority_payment,
      delivery_method,
      template_bill_back,
      amount_total_entered,
      amount_total_paid,
      amount_total_due,
      amount_total_retained,
      amount_total_selected,
      amount_payment,
      amount_trx_entity_due,
      amount_trx_total_due,
      amount_trx_total_entered,
      amount_trx_total_paid,
      amount_trx_total_released,
      amount_trx_total_retained,
      amount_trx_total_selected,
      is_on_hold,
      is_system_generated,
      is_pr_batch_no_gl,
      is_inclusive_tax,
      is_bill_back_template_use_iet,
      state_raw,
      state_record,
      status_record,
      status_cleared,
      status_pr_batch,
      state_po_document,
      type_payment,
      name_pr_batch,
      account_paid_from,
      name_payment_provider,
      name_payment_term,
      num_days_payment_term,
      name_bill_pay_to_contact,
      description,
      memo,
      days_due_in,
      entity,
      exchange_rate,
      id_exchange_rate_type,
      entity_paid_from,
      id_mega_entity,
      name_location,
      id_sup_doc,
      id_tax_solution,
      id_yooz_doc,
      form_1099_box,
      form_1099_type,
      type_vendor_1099,
      name_created_by_user,
      name_modified_by_user,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_payment_term_id,
      fk_concur_image_id,
      fk_pay_to_tax_group_record_id,
      fk_location_id,
      fk_mega_entity_id,
      fk_bill_pay_to_contact_id,
      fk_pr_batch_id,
      fk_user_key,
      fk_ship_return_contact_id,
      fk_vi_header_id,
      fk_receipt_header_id,
      fk_po_header_id,
      date_cleared_date,
      date_created_date,
      date_due_date,
      date_discount_date,
      date_paid_date,
      date_payment_date,
      date_payment_recommended_date,
      date_posted_date,
      date_receipt_date,
      date_reconciled_date,
      url_intacct,
      url_vi_intacct,
      url_receipt_intacct,
      url_po_intacct,
      url_yooz,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_dds_loaded_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_total_entered {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_ENTERED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_due {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_retained {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_RETAINED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_selected {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_payment {
    type: sum
    sql: ${TABLE}."AMOUNT_PAYMENT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_entity_due {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_ENTITY_DUE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_due {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_DUE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_entered {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_ENTERED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_released {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RELEASED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_retained {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RETAINED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_selected {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
