
view: deleted_invoices {
  derived_table: {
    sql: select * from CONCUR.DELETED_INVOICES ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: vendor_invoice_number {
    type: string
    sql: ${TABLE}."VENDOR_INVOICE_NUMBER" ;;
  }

  dimension: deleted_date {
    type: date
    sql: ${TABLE}."DELETED_DATE" ;;
  }

  dimension: employee_login_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_LOGIN_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        request_id,
	vendor_id,
	po_number,
	vendor_invoice_number,
	deleted_date,
	employee_login_id,
	_es_update_timestamp_time
    ]
  }
}
