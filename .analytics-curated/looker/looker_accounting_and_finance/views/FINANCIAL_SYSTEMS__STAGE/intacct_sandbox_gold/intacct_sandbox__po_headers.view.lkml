view: intacct_sandbox__po_headers {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__PO_HEADERS" ;;

  dimension: amount_original {
    type: string
    sql: ${TABLE}."AMOUNT_ORIGINAL" ;;
  }
  dimension: amount_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_SUBTOTAL" ;;
  }
  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
  }
  dimension: amount_total_converted {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_CONVERTED" ;;
  }
  dimension: amount_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
  }
  dimension: amount_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_ENTERED" ;;
  }
  dimension: amount_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
  }
  dimension: amount_total_price_converted {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_PRICE_CONVERTED" ;;
  }
  dimension: amount_total_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_REMAINING" ;;
  }
  dimension: amount_trx_revised_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_REVISED_SUBTOTAL" ;;
  }
  dimension: amount_trx_revised_total {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_REVISED_TOTAL" ;;
  }
  dimension: amount_trx_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SUBTOTAL" ;;
  }
  dimension: amount_trx_total {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL" ;;
  }
  dimension: amount_trx_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_DUE" ;;
  }
  dimension: amount_trx_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_ENTERED" ;;
  }
  dimension: amount_trx_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
  }
  dimension: bill_to_address_line_1 {
    type: string
    sql: ${TABLE}."BILL_TO_ADDRESS_LINE_1" ;;
  }
  dimension: bill_to_address_line_2 {
    type: string
    sql: ${TABLE}."BILL_TO_ADDRESS_LINE_2" ;;
  }
  dimension: bill_to_address_line_3 {
    type: string
    sql: ${TABLE}."BILL_TO_ADDRESS_LINE_3" ;;
  }
  dimension: bill_to_city {
    type: string
    sql: ${TABLE}."BILL_TO_CITY" ;;
  }
  dimension: bill_to_company_name {
    type: string
    sql: ${TABLE}."BILL_TO_COMPANY_NAME" ;;
  }
  dimension: bill_to_contact_name {
    type: string
    sql: ${TABLE}."BILL_TO_CONTACT_NAME" ;;
  }
  dimension: bill_to_country {
    type: string
    sql: ${TABLE}."BILL_TO_COUNTRY" ;;
  }
  dimension: bill_to_country_code {
    type: string
    sql: ${TABLE}."BILL_TO_COUNTRY_CODE" ;;
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
  dimension: bill_to_first_name {
    type: string
    sql: ${TABLE}."BILL_TO_FIRST_NAME" ;;
  }
  dimension: bill_to_initial {
    type: string
    sql: ${TABLE}."BILL_TO_INITIAL" ;;
  }
  dimension: bill_to_last_name {
    type: string
    sql: ${TABLE}."BILL_TO_LAST_NAME" ;;
  }
  dimension: bill_to_pager {
    type: string
    sql: ${TABLE}."BILL_TO_PAGER" ;;
  }
  dimension: bill_to_phone_cell {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_CELL" ;;
  }
  dimension: bill_to_phone_primary {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_PRIMARY" ;;
  }
  dimension: bill_to_phone_secondary {
    type: string
    sql: ${TABLE}."BILL_TO_PHONE_SECONDARY" ;;
  }
  dimension: bill_to_postal_code {
    type: string
    sql: ${TABLE}."BILL_TO_POSTAL_CODE" ;;
  }
  dimension: bill_to_prefix {
    type: string
    sql: ${TABLE}."BILL_TO_PREFIX" ;;
  }
  dimension: bill_to_print_as {
    type: string
    sql: ${TABLE}."BILL_TO_PRINT_AS" ;;
  }
  dimension: bill_to_state {
    type: string
    sql: ${TABLE}."BILL_TO_STATE" ;;
  }
  dimension: bill_to_url_primary {
    type: string
    sql: ${TABLE}."BILL_TO_URL_PRIMARY" ;;
  }
  dimension: bill_to_url_secondary {
    type: string
    sql: ${TABLE}."BILL_TO_URL_SECONDARY" ;;
  }
  dimension: class_document {
    type: string
    sql: ${TABLE}."CLASS_DOCUMENT" ;;
  }
  dimension: code_currency {
    type: string
    sql: ${TABLE}."CODE_CURRENCY" ;;
  }
  dimension: code_terms {
    type: string
    sql: ${TABLE}."CODE_TERMS" ;;
  }
  dimension: contact_address_line_1 {
    type: string
    sql: ${TABLE}."CONTACT_ADDRESS_LINE_1" ;;
  }
  dimension: contact_address_line_2 {
    type: string
    sql: ${TABLE}."CONTACT_ADDRESS_LINE_2" ;;
  }
  dimension: contact_address_line_3 {
    type: string
    sql: ${TABLE}."CONTACT_ADDRESS_LINE_3" ;;
  }
  dimension: contact_city {
    type: string
    sql: ${TABLE}."CONTACT_CITY" ;;
  }
  dimension: contact_company_name {
    type: string
    sql: ${TABLE}."CONTACT_COMPANY_NAME" ;;
  }
  dimension: contact_country {
    type: string
    sql: ${TABLE}."CONTACT_COUNTRY" ;;
  }
  dimension: contact_country_code {
    type: string
    sql: ${TABLE}."CONTACT_COUNTRY_CODE" ;;
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
  dimension: contact_first_name {
    type: string
    sql: ${TABLE}."CONTACT_FIRST_NAME" ;;
  }
  dimension: contact_initial {
    type: string
    sql: ${TABLE}."CONTACT_INITIAL" ;;
  }
  dimension: contact_last_name {
    type: string
    sql: ${TABLE}."CONTACT_LAST_NAME" ;;
  }
  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }
  dimension: contact_pager {
    type: string
    sql: ${TABLE}."CONTACT_PAGER" ;;
  }
  dimension: contact_phone_cell {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_CELL" ;;
  }
  dimension: contact_phone_primary {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_PRIMARY" ;;
  }
  dimension: contact_phone_secondary {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_SECONDARY" ;;
  }
  dimension: contact_postal_code {
    type: string
    sql: ${TABLE}."CONTACT_POSTAL_CODE" ;;
  }
  dimension: contact_prefix {
    type: string
    sql: ${TABLE}."CONTACT_PREFIX" ;;
  }
  dimension: contact_print_as {
    type: string
    sql: ${TABLE}."CONTACT_PRINT_AS" ;;
  }
  dimension: contact_state {
    type: string
    sql: ${TABLE}."CONTACT_STATE" ;;
  }
  dimension: contact_url_primary {
    type: string
    sql: ${TABLE}."CONTACT_URL_PRIMARY" ;;
  }
  dimension: contact_url_secondary {
    type: string
    sql: ${TABLE}."CONTACT_URL_SECONDARY" ;;
  }
  dimension_group: date_cancel_after {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CANCEL_AFTER" ;;
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
  dimension: deliver_to_address_line_1 {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS_LINE_1" ;;
  }
  dimension: deliver_to_address_line_2 {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS_LINE_2" ;;
  }
  dimension: deliver_to_address_line_3 {
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS_LINE_3" ;;
  }
  dimension: deliver_to_city {
    type: string
    sql: ${TABLE}."DELIVER_TO_CITY" ;;
  }
  dimension: deliver_to_company_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_COMPANY_NAME" ;;
  }
  dimension: deliver_to_contact_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_CONTACT_NAME" ;;
  }
  dimension: deliver_to_country {
    type: string
    sql: ${TABLE}."DELIVER_TO_COUNTRY" ;;
  }
  dimension: deliver_to_country_code {
    type: string
    sql: ${TABLE}."DELIVER_TO_COUNTRY_CODE" ;;
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
  dimension: deliver_to_first_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_FIRST_NAME" ;;
  }
  dimension: deliver_to_initial {
    type: string
    sql: ${TABLE}."DELIVER_TO_INITIAL" ;;
  }
  dimension: deliver_to_last_name {
    type: string
    sql: ${TABLE}."DELIVER_TO_LAST_NAME" ;;
  }
  dimension: deliver_to_pager {
    type: string
    sql: ${TABLE}."DELIVER_TO_PAGER" ;;
  }
  dimension: deliver_to_phone_cell {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_CELL" ;;
  }
  dimension: deliver_to_phone_primary {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_PRIMARY" ;;
  }
  dimension: deliver_to_phone_secondary {
    type: string
    sql: ${TABLE}."DELIVER_TO_PHONE_SECONDARY" ;;
  }
  dimension: deliver_to_postal_code {
    type: string
    sql: ${TABLE}."DELIVER_TO_POSTAL_CODE" ;;
  }
  dimension: deliver_to_prefix {
    type: string
    sql: ${TABLE}."DELIVER_TO_PREFIX" ;;
  }
  dimension: deliver_to_print_as {
    type: string
    sql: ${TABLE}."DELIVER_TO_PRINT_AS" ;;
  }
  dimension: deliver_to_state {
    type: string
    sql: ${TABLE}."DELIVER_TO_STATE" ;;
  }
  dimension: deliver_to_url_primary {
    type: string
    sql: ${TABLE}."DELIVER_TO_URL_PRIMARY" ;;
  }
  dimension: deliver_to_url_secondary {
    type: string
    sql: ${TABLE}."DELIVER_TO_URL_SECONDARY" ;;
  }
  dimension: fk_concur_image_id {
    type: string
    sql: ${TABLE}."FK_CONCUR_IMAGE_ID" ;;
  }
  dimension: fk_concur_request_key {
    type: string
    sql: ${TABLE}."FK_CONCUR_REQUEST_KEY" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_pr_record_id {
    type: string
    sql: ${TABLE}."FK_PR_RECORD_ID" ;;
  }
  dimension: fk_project_id {
    type: string
    sql: ${TABLE}."FK_PROJECT_ID" ;;
  }
  dimension: fk_store_received_id {
    type: number
    sql: ${TABLE}."FK_STORE_RECEIVED_ID" ;;
  }
  dimension: fk_yooz_doc_id {
    type: string
    sql: ${TABLE}."FK_YOOZ_DOC_ID" ;;
  }
  dimension: flag_has_change {
    type: yesno
    sql: ${TABLE}."FLAG_HAS_CHANGE" ;;
  }
  dimension: flag_updates_inventory {
    type: string
    sql: ${TABLE}."FLAG_UPDATES_INVENTORY" ;;
  }
  dimension: flag_used_as_contract {
    type: string
    sql: ${TABLE}."FLAG_USED_AS_CONTRACT" ;;
  }
  dimension: id_project {
    type: string
    sql: ${TABLE}."ID_PROJECT" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: is_bill_to_visible {
    type: yesno
    sql: ${TABLE}."IS_BILL_TO_VISIBLE" ;;
  }
  dimension: is_blanket_po {
    type: yesno
    sql: ${TABLE}."IS_BLANKET_PO" ;;
  }
  dimension: is_contact_visible {
    type: yesno
    sql: ${TABLE}."IS_CONTACT_VISIBLE" ;;
  }
  dimension: is_deliver_to_visible {
    type: yesno
    sql: ${TABLE}."IS_DELIVER_TO_VISIBLE" ;;
  }
  dimension: is_fleet_email_sent {
    type: yesno
    sql: ${TABLE}."IS_FLEET_EMAIL_SENT" ;;
  }
  dimension: is_ship_to_visible {
    type: yesno
    sql: ${TABLE}."IS_SHIP_TO_VISIBLE" ;;
  }
  dimension: is_system_generated {
    type: yesno
    sql: ${TABLE}."IS_SYSTEM_GENERATED" ;;
  }
  dimension: message_internal {
    type: string
    sql: ${TABLE}."MESSAGE_INTERNAL" ;;
  }
  dimension: message_to_ap {
    type: string
    sql: ${TABLE}."MESSAGE_TO_AP" ;;
  }
  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }
  dimension: name_doc_created_from {
    type: string
    sql: ${TABLE}."NAME_DOC_CREATED_FROM" ;;
  }
  dimension: name_document {
    type: string
    sql: ${TABLE}."NAME_DOCUMENT" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_fleet_email_sent_by {
    type: string
    sql: ${TABLE}."NAME_FLEET_EMAIL_SENT_BY" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: name_mega_entity_id {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY_ID" ;;
  }
  dimension: name_t3_po_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PO_CREATED_BY" ;;
  }
  dimension: name_t3_pr_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PR_CREATED_BY" ;;
  }
  dimension: name_term {
    type: string
    sql: ${TABLE}."NAME_TERM" ;;
  }
  dimension: name_user_id {
    type: string
    sql: ${TABLE}."NAME_USER_ID" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: note_sync {
    type: string
    sql: ${TABLE}."NOTE_SYNC" ;;
  }
  dimension: num_document {
    type: string
    sql: ${TABLE}."NUM_DOCUMENT" ;;
  }
  dimension: num_type_document {
    type: string
    sql: ${TABLE}."NUM_TYPE_DOCUMENT" ;;
  }
  dimension: pk_po_header_id {
    type: number
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
  }
  dimension: quantity_total_converted {
    type: number
    sql: ${TABLE}."QUANTITY_TOTAL_CONVERTED" ;;
  }
  dimension: quantity_total_remaining {
    type: number
    sql: ${TABLE}."QUANTITY_TOTAL_REMAINING" ;;
  }
  dimension: ship_to_address_line_1 {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS_LINE_1" ;;
  }
  dimension: ship_to_address_line_2 {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS_LINE_2" ;;
  }
  dimension: ship_to_address_line_3 {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS_LINE_3" ;;
  }
  dimension: ship_to_city {
    type: string
    sql: ${TABLE}."SHIP_TO_CITY" ;;
  }
  dimension: ship_to_company_name {
    type: string
    sql: ${TABLE}."SHIP_TO_COMPANY_NAME" ;;
  }
  dimension: ship_to_contact_name {
    type: string
    sql: ${TABLE}."SHIP_TO_CONTACT_NAME" ;;
  }
  dimension: ship_to_country {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY" ;;
  }
  dimension: ship_to_country_code {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY_CODE" ;;
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
  dimension: ship_to_first_name {
    type: string
    sql: ${TABLE}."SHIP_TO_FIRST_NAME" ;;
  }
  dimension: ship_to_initial {
    type: string
    sql: ${TABLE}."SHIP_TO_INITIAL" ;;
  }
  dimension: ship_to_last_name {
    type: string
    sql: ${TABLE}."SHIP_TO_LAST_NAME" ;;
  }
  dimension: ship_to_pager {
    type: string
    sql: ${TABLE}."SHIP_TO_PAGER" ;;
  }
  dimension: ship_to_phone_cell {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_CELL" ;;
  }
  dimension: ship_to_phone_primary {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_PRIMARY" ;;
  }
  dimension: ship_to_phone_secondary {
    type: string
    sql: ${TABLE}."SHIP_TO_PHONE_SECONDARY" ;;
  }
  dimension: ship_to_postal_code {
    type: string
    sql: ${TABLE}."SHIP_TO_POSTAL_CODE" ;;
  }
  dimension: ship_to_prefix {
    type: string
    sql: ${TABLE}."SHIP_TO_PREFIX" ;;
  }
  dimension: ship_to_print_as {
    type: string
    sql: ${TABLE}."SHIP_TO_PRINT_AS" ;;
  }
  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }
  dimension: ship_to_url_primary {
    type: string
    sql: ${TABLE}."SHIP_TO_URL_PRIMARY" ;;
  }
  dimension: ship_to_url_secondary {
    type: string
    sql: ${TABLE}."SHIP_TO_URL_SECONDARY" ;;
  }
  dimension: state_po {
    type: string
    sql: ${TABLE}."STATE_PO" ;;
  }
  dimension: status_backorder {
    type: string
    sql: ${TABLE}."STATUS_BACKORDER" ;;
  }
  dimension: status_payment {
    type: string
    sql: ${TABLE}."STATUS_PAYMENT" ;;
  }
  dimension: status_po {
    type: string
    sql: ${TABLE}."STATUS_PO" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
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
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: type_document {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT" ;;
  }
  dimension: type_document_increment {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT_INCREMENT" ;;
  }
  dimension: url_yooz {
    type: string
    sql: ${TABLE}."URL_YOOZ" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	ship_to_company_name,
	ship_to_contact_name,
	deliver_to_first_name,
	contact_company_name,
	deliver_to_company_name,
	deliver_to_contact_name,
	contact_name,
	ship_to_last_name,
	bill_to_contact_name,
	bill_to_first_name,
	contact_first_name,
	bill_to_last_name,
	bill_to_company_name,
	deliver_to_last_name,
	ship_to_first_name,
	contact_last_name
	]
  }

}
