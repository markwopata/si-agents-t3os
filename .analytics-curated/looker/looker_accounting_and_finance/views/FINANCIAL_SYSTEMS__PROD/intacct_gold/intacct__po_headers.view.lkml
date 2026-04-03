view: intacct__po_headers {
  sql_table_name: "INTACCT_GOLD"."INTACCT__PO_HEADERS" ;;

  dimension: pk_po_header_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_document {
    type: string
    sql: ${TABLE}."NAME_DOCUMENT" ;;
  }

  dimension: num_document {
    type: string
    sql: ${TABLE}."NUM_DOCUMENT" ;;
  }

  dimension: type_document {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: num_source_document {
    type: string
    sql: ${TABLE}."NUM_SOURCE_DOCUMENT" ;;
  }

  dimension: num_grandparent_document {
    type: string
    sql: ${TABLE}."NUM_GRANDPARENT_DOCUMENT" ;;
  }

  dimension: name_doc_created_from {
    type: string
    sql: ${TABLE}."NAME_DOC_CREATED_FROM" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: name_term {
    type: string
    sql: ${TABLE}."NAME_TERM" ;;
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: name_t3_po_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PO_CREATED_BY" ;;
  }

  dimension: name_t3_pr_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PR_CREATED_BY" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_user_id {
    type: string
    sql: ${TABLE}."NAME_USER_ID" ;;
  }

  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }

  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
  }

  dimension: amount_requested {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
  }

  dimension: amount_converted {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
  }

  dimension: amount_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
  }

  dimension: amount_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
    value_format_name: usd
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

  dimension: amount_trx_revised_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_REVISED_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_trx_revised_total {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_REVISED_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_trx_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL" ;;
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

  dimension: code_currency {
    type: string
    sql: ${TABLE}."CODE_CURRENCY" ;;
  }

  dimension: code_terms {
    type: string
    sql: ${TABLE}."CODE_TERMS" ;;
  }

  dimension: class_document {
    type: string
    sql: ${TABLE}."CLASS_DOCUMENT" ;;
  }

  dimension: num_type_document {
    type: string
    sql: ${TABLE}."NUM_TYPE_DOCUMENT" ;;
  }

  dimension: type_document_increment {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT_INCREMENT" ;;
  }

  dimension: status_backorder {
    type: string
    sql: ${TABLE}."STATUS_BACKORDER" ;;
  }

  dimension: status_payment {
    type: string
    sql: ${TABLE}."STATUS_PAYMENT" ;;
  }

  dimension: state_document {
    type: string
    sql: ${TABLE}."STATE_DOCUMENT" ;;
  }

  dimension: status_po {
    type: string
    sql: ${TABLE}."STATUS_PO" ;;
  }

  dimension: state_source_document {
    type: string
    sql: ${TABLE}."STATE_SOURCE_DOCUMENT" ;;
  }

  dimension: state_grandparent_document {
    type: string
    sql: ${TABLE}."STATE_GRANDPARENT_DOCUMENT" ;;
  }

  dimension: flag_has_change {
    type: yesno
    sql: ${TABLE}."FLAG_HAS_CHANGE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: flag_updates_inventory {
    type: string
    sql: ${TABLE}."FLAG_UPDATES_INVENTORY" ;;
  }

  dimension: flag_used_as_contract {
    type: string
    sql: ${TABLE}."FLAG_USED_AS_CONTRACT" ;;
  }

  dimension: is_blanket_po {
    type: yesno
    sql: ${TABLE}."IS_BLANKET_PO" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_bill_to_visible {
    type: yesno
    sql: ${TABLE}."IS_BILL_TO_VISIBLE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_contact_visible {
    type: yesno
    sql: ${TABLE}."IS_CONTACT_VISIBLE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_deliver_to_visible {
    type: yesno
    sql: ${TABLE}."IS_DELIVER_TO_VISIBLE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_ship_to_visible {
    type: yesno
    sql: ${TABLE}."IS_SHIP_TO_VISIBLE" ;;
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

  dimension: note_sync {
    type: string
    sql: ${TABLE}."NOTE_SYNC" ;;
  }

  dimension: message_internal {
    type: string
    sql: ${TABLE}."MESSAGE_INTERNAL" ;;
  }

  dimension: bill_to_company_name {
    type: string
    sql: ${TABLE}."BILL_TO_COMPANY_NAME" ;;
  }

  dimension: bill_to_contact_name {
    type: string
    sql: ${TABLE}."BILL_TO_CONTACT_NAME" ;;
  }

  dimension: bill_to_print_as {
    type: string
    sql: ${TABLE}."BILL_TO_PRINT_AS" ;;
  }

  dimension: bill_to_first_name {
    type: string
    sql: ${TABLE}."BILL_TO_FIRST_NAME" ;;
  }

  dimension: bill_to_last_name {
    type: string
    sql: ${TABLE}."BILL_TO_LAST_NAME" ;;
  }

  dimension: bill_to_prefix {
    type: string
    sql: ${TABLE}."BILL_TO_PREFIX" ;;
  }

  dimension: bill_to_initial {
    type: string
    sql: ${TABLE}."BILL_TO_INITIAL" ;;
  }

  dimension: bill_to_phone_primary {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_PRIMARY" ;;
  }

  dimension: bill_to_phone_secondary {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_SECONDARY" ;;
  }

  dimension: bill_to_phone_cell {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_CELL" ;;
  }

  dimension: bill_to_email_primary {
    type: string
    sql: ${TABLE}."BILL_TO_EMAIL_PRIMARY" ;;
  }

  dimension: bill_to_email_secondary {
    type: string
    sql: ${TABLE}."BILL_TO_EMAIL_SECONDARY" ;;
  }

  dimension: bill_to_fax {
    type: string
    sql: ${TABLE}."BILL_TO_FAX" ;;
  }

  dimension: bill_to_pager {
    type: string
    sql: ${TABLE}."BILL_TO_PAGER" ;;
  }

  dimension: bill_to_address_line_1 {
    type: string
    sql: ${TABLE}."BILL_TO_ADDRESS_LINE_1" ;;
  }

  dimension: bill_to_address_line_2 {
    type: string
    sql: ${TABLE}."BILL_TO_ADDRESS_LINE_2" ;;
  }

  dimension: bill_to_city {
    type: string
    sql: ${TABLE}."BILL_TO_CITY" ;;
  }

  dimension: bill_to_state {
    type: string
    sql: ${TABLE}."BILL_TO_STATE" ;;
  }

  dimension: bill_to_postal_code {
    type: string
    sql: ${TABLE}."BILL_TO_POSTAL_CODE" ;;
  }

  dimension: bill_to_country {
    type: string
    sql: ${TABLE}."BILL_TO_COUNTRY" ;;
  }

  dimension: bill_to_country_code {
    type: string
    sql: ${TABLE}."BILL_TO_COUNTRY_CODE" ;;
  }

  dimension: bill_to_url_primary {
    type: string
    sql: ${TABLE}."BILL_TO_URL_PRIMARY" ;;
  }

  dimension: bill_to_url_secondary {
    type: string
    sql: ${TABLE}."BILL_TO_URL_SECONDARY" ;;
  }

  dimension: deliver_to_company_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_COMPANY_NAME" ;;
  }

  dimension: deliver_to_contact_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_CONTACT_NAME" ;;
  }

  dimension: deliver_to_print_as {
    type: string
    sql: ${TABLE}."DELIVER_TO_PRINT_AS" ;;
  }

  dimension: deliver_to_first_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_FIRST_NAME" ;;
  }

  dimension: deliver_to_last_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_LAST_NAME" ;;
  }

  dimension: deliver_to_prefix {
    type: string
    sql: ${TABLE}."DELIVER_TO_PREFIX" ;;
  }

  dimension: deliver_to_initial {
    type: string
    sql: ${TABLE}."DELIVER_TO_INITIAL" ;;
  }

  dimension: deliver_to_phone_primary {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_PRIMARY" ;;
  }

  dimension: deliver_to_phone_secondary {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_SECONDARY" ;;
  }

  dimension: deliver_to_phone_cell {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_CELL" ;;
  }

  dimension: deliver_to_email_primary {
    type: string
    sql: ${TABLE}."DELIVER_TO_EMAIL_PRIMARY" ;;
  }

  dimension: deliver_to_email_secondary {
    type: string
    sql: ${TABLE}."DELIVER_TO_EMAIL_SECONDARY" ;;
  }

  dimension: deliver_to_fax {
    type: string
    sql: ${TABLE}."DELIVER_TO_FAX" ;;
  }

  dimension: deliver_to_pager {
    type: string
    sql: ${TABLE}."DELIVER_TO_PAGER" ;;
  }

  dimension: deliver_to_address_line_1 {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS_LINE_1" ;;
  }

  dimension: deliver_to_address_line_2 {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS_LINE_2" ;;
  }

  dimension: deliver_to_city {
    type: string
    sql: ${TABLE}."DELIVER_TO_CITY" ;;
  }

  dimension: deliver_to_state {
    type: string
    sql: ${TABLE}."DELIVER_TO_STATE" ;;
  }

  dimension: deliver_to_postal_code {
    type: string
    sql: ${TABLE}."DELIVER_TO_POSTAL_CODE" ;;
  }

  dimension: deliver_to_country {
    type: string
    sql: ${TABLE}."DELIVER_TO_COUNTRY" ;;
  }

  dimension: deliver_to_country_code {
    type: string
    sql: ${TABLE}."DELIVER_TO_COUNTRY_CODE" ;;
  }

  dimension: deliver_to_url_primary {
    type: string
    sql: ${TABLE}."DELIVER_TO_URL_PRIMARY" ;;
  }

  dimension: deliver_to_url_secondary {
    type: string
    sql: ${TABLE}."DELIVER_TO_URL_SECONDARY" ;;
  }

  dimension: contact_company_name {
    type: string
    sql: ${TABLE}."CONTACT_COMPANY_NAME" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_print_as {
    type: string
    sql: ${TABLE}."CONTACT_PRINT_AS" ;;
  }

  dimension: contact_first_name {
    type: string
    sql: ${TABLE}."CONTACT_FIRST_NAME" ;;
  }

  dimension: contact_last_name {
    type: string
    sql: ${TABLE}."CONTACT_LAST_NAME" ;;
  }

  dimension: contact_prefix {
    type: string
    sql: ${TABLE}."CONTACT_PREFIX" ;;
  }

  dimension: contact_initial {
    type: string
    sql: ${TABLE}."CONTACT_INITIAL" ;;
  }

  dimension: contact_phone_primary {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_PRIMARY" ;;
  }

  dimension: contact_phone_secondary {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_SECONDARY" ;;
  }

  dimension: contact_phone_cell {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_CELL" ;;
  }

  dimension: contact_email_primary {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL_PRIMARY" ;;
  }

  dimension: contact_email_secondary {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL_SECONDARY" ;;
  }

  dimension: contact_fax {
    type: string
    sql: ${TABLE}."CONTACT_FAX" ;;
  }

  dimension: contact_pager {
    type: string
    sql: ${TABLE}."CONTACT_PAGER" ;;
  }

  dimension: contact_address_line_1 {
    type: string
    sql: ${TABLE}."CONTACT_ADDRESS_LINE_1" ;;
  }

  dimension: contact_address_line_2 {
    type: string
    sql: ${TABLE}."CONTACT_ADDRESS_LINE_2" ;;
  }

  dimension: contact_city {
    type: string
    sql: ${TABLE}."CONTACT_CITY" ;;
  }

  dimension: contact_state {
    type: string
    sql: ${TABLE}."CONTACT_STATE" ;;
  }

  dimension: contact_postal_code {
    type: string
    sql: ${TABLE}."CONTACT_POSTAL_CODE" ;;
  }

  dimension: contact_country {
    type: string
    sql: ${TABLE}."CONTACT_COUNTRY" ;;
  }

  dimension: contact_country_code {
    type: string
    sql: ${TABLE}."CONTACT_COUNTRY_CODE" ;;
  }

  dimension: contact_url_primary {
    type: string
    sql: ${TABLE}."CONTACT_URL_PRIMARY" ;;
  }

  dimension: contact_url_secondary {
    type: string
    sql: ${TABLE}."CONTACT_URL_SECONDARY" ;;
  }

  dimension: ship_to_company_name {
    type: string
    sql: ${TABLE}."SHIP_TO_COMPANY_NAME" ;;
  }

  dimension: ship_to_contact_name {
    type: string
    sql: ${TABLE}."SHIP_TO_CONTACT_NAME" ;;
  }

  dimension: ship_to_print_as {
    type: string
    sql: ${TABLE}."SHIP_TO_PRINT_AS" ;;
  }

  dimension: ship_to_first_name {
    type: string
    sql: ${TABLE}."SHIP_TO_FIRST_NAME" ;;
  }

  dimension: ship_to_last_name {
    type: string
    sql: ${TABLE}."SHIP_TO_LAST_NAME" ;;
  }

  dimension: ship_to_prefix {
    type: string
    sql: ${TABLE}."SHIP_TO_PREFIX" ;;
  }

  dimension: ship_to_initial {
    type: string
    sql: ${TABLE}."SHIP_TO_INITIAL" ;;
  }

  dimension: ship_to_phone_primary {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_PRIMARY" ;;
  }

  dimension: ship_to_phone_secondary {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_SECONDARY" ;;
  }

  dimension: ship_to_phone_cell {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_CELL" ;;
  }

  dimension: ship_to_email_primary {
    type: string
    sql: ${TABLE}."SHIP_TO_EMAIL_PRIMARY" ;;
  }

  dimension: ship_to_email_secondary {
    type: string
    sql: ${TABLE}."SHIP_TO_EMAIL_SECONDARY" ;;
  }

  dimension: ship_to_fax {
    type: string
    sql: ${TABLE}."SHIP_TO_FAX" ;;
  }

  dimension: ship_to_pager {
    type: string
    sql: ${TABLE}."SHIP_TO_PAGER" ;;
  }

  dimension: ship_to_address_line_1 {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS_LINE_1" ;;
  }

  dimension: ship_to_address_line_2 {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS_LINE_2" ;;
  }

  dimension: ship_to_city {
    type: string
    sql: ${TABLE}."SHIP_TO_CITY" ;;
  }

  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }

  dimension: ship_to_postal_code {
    type: string
    sql: ${TABLE}."SHIP_TO_POSTAL_CODE" ;;
  }

  dimension: ship_to_country {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY" ;;
  }

  dimension: ship_to_country_code {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY_CODE" ;;
  }

  dimension: ship_to_url_primary {
    type: string
    sql: ${TABLE}."SHIP_TO_URL_PRIMARY" ;;
  }

  dimension: ship_to_url_secondary {
    type: string
    sql: ${TABLE}."SHIP_TO_URL_SECONDARY" ;;
  }

  dimension_group: date_cancel_after {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CANCEL_AFTER" ;;
  }

  dimension_group: date_po_close {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PO_CLOSE" ;;
  }

  dimension_group: date_promised {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PROMISED" ;;
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

  dimension: fk_source_po_header_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_grandparent_po_header_id {
    type: number
    sql: ${TABLE}."FK_GRANDPARENT_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_concur_image_id {
    type: string
    sql: ${TABLE}."FK_CONCUR_IMAGE_ID" ;;
  }

  dimension: fk_concur_request_id {
    type: number
    sql: ${TABLE}."FK_CONCUR_REQUEST_ID" ;;
    value_format_name: id
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
    value_format_name: id
  }

  dimension: id_project {
    type: string
    sql: ${TABLE}."ID_PROJECT" ;;
  }

  dimension: fk_project_id {
    type: number
    sql: ${TABLE}."FK_PROJECT_ID" ;;
    value_format_name: id
  }

  dimension: fk_pr_record_id {
    type: number
    sql: ${TABLE}."FK_PR_RECORD_ID" ;;
    value_format_name: id
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_source_intacct {
    type: string
    sql: ${TABLE}."URL_SOURCE_INTACCT" ;;
    link: {
      label: "URL Source Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_grandparent_intacct {
    type: string
    sql: ${TABLE}."URL_GRANDPARENT_INTACCT" ;;
    link: {
      label: "URL Grandparent Intacct"
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
      pk_po_header_id,
      id_vendor,
      name_document,
      num_document,
      type_document,
      reference,
      num_source_document,
      num_grandparent_document,
      name_doc_created_from,
      name_vendor,
      name_term,
      id_location,
      name_location,
      name_t3_po_created_by,
      name_t3_pr_created_by,
      name_created_by_user,
      name_user_id,
      qty_requested,
      qty_converted,
      qty_remaining,
      amount_requested,
      amount_converted,
      amount_remaining,
      amount_subtotal,
      amount_total,
      amount_total_due,
      amount_total_entered,
      amount_total_paid,
      amount_trx_revised_subtotal,
      amount_trx_revised_total,
      amount_trx_subtotal,
      amount_trx_total,
      amount_trx_total_due,
      amount_trx_total_entered,
      amount_trx_total_paid,
      code_currency,
      code_terms,
      class_document,
      num_type_document,
      type_document_increment,
      status_backorder,
      status_payment,
      state_document,
      status_po,
      state_source_document,
      state_grandparent_document,
      flag_has_change,
      flag_updates_inventory,
      flag_used_as_contract,
      is_blanket_po,
      is_bill_to_visible,
      is_contact_visible,
      is_deliver_to_visible,
      is_ship_to_visible,
      is_system_generated,
      note_sync,
      message_internal,
      bill_to_company_name,
      bill_to_contact_name,
      bill_to_print_as,
      bill_to_first_name,
      bill_to_last_name,
      bill_to_prefix,
      bill_to_initial,
      bill_to_phone_primary,
      bill_to_phone_secondary,
      bill_to_phone_cell,
      bill_to_email_primary,
      bill_to_email_secondary,
      bill_to_fax,
      bill_to_pager,
      bill_to_address_line_1,
      bill_to_address_line_2,
      bill_to_city,
      bill_to_state,
      bill_to_postal_code,
      bill_to_country,
      bill_to_country_code,
      bill_to_url_primary,
      bill_to_url_secondary,
      deliver_to_company_name,
      deliver_to_contact_name,
      deliver_to_print_as,
      deliver_to_first_name,
      deliver_to_last_name,
      deliver_to_prefix,
      deliver_to_initial,
      deliver_to_phone_primary,
      deliver_to_phone_secondary,
      deliver_to_phone_cell,
      deliver_to_email_primary,
      deliver_to_email_secondary,
      deliver_to_fax,
      deliver_to_pager,
      deliver_to_address_line_1,
      deliver_to_address_line_2,
      deliver_to_city,
      deliver_to_state,
      deliver_to_postal_code,
      deliver_to_country,
      deliver_to_country_code,
      deliver_to_url_primary,
      deliver_to_url_secondary,
      contact_company_name,
      contact_name,
      contact_print_as,
      contact_first_name,
      contact_last_name,
      contact_prefix,
      contact_initial,
      contact_phone_primary,
      contact_phone_secondary,
      contact_phone_cell,
      contact_email_primary,
      contact_email_secondary,
      contact_fax,
      contact_pager,
      contact_address_line_1,
      contact_address_line_2,
      contact_city,
      contact_state,
      contact_postal_code,
      contact_country,
      contact_country_code,
      contact_url_primary,
      contact_url_secondary,
      ship_to_company_name,
      ship_to_contact_name,
      ship_to_print_as,
      ship_to_first_name,
      ship_to_last_name,
      ship_to_prefix,
      ship_to_initial,
      ship_to_phone_primary,
      ship_to_phone_secondary,
      ship_to_phone_cell,
      ship_to_email_primary,
      ship_to_email_secondary,
      ship_to_fax,
      ship_to_pager,
      ship_to_address_line_1,
      ship_to_address_line_2,
      ship_to_city,
      ship_to_state,
      ship_to_postal_code,
      ship_to_country,
      ship_to_country_code,
      ship_to_url_primary,
      ship_to_url_secondary,
      date_cancel_after_date,
      date_po_close_date,
      date_promised_date,
      date_created_date,
      date_due_date,
      fk_source_po_header_id,
      fk_grandparent_po_header_id,
      fk_concur_image_id,
      fk_concur_request_id,
      fk_created_by_user_id,
      fk_mega_entity_id,
      id_project,
      fk_project_id,
      fk_pr_record_id,
      url_intacct,
      url_source_intacct,
      url_grandparent_intacct,
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

  measure: total_amount_requested {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_subtotal {
    type: sum
    sql: ${TABLE}."AMOUNT_SUBTOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_due {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
    value_format_name: usd
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

  measure: total_amount_trx_revised_subtotal {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_REVISED_SUBTOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_revised_total {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_REVISED_TOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_subtotal {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_SUBTOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL" ;;
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
}
