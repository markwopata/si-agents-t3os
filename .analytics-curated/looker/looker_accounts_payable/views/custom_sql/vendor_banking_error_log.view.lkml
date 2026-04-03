
view: vendor_banking_error_log {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.CLUSTDOC.VENDOR_BANKING_ERROR
      WHERE CORRECTED = 0 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension_group: date_added {
    type: time
    sql: ${TABLE}."DATE_ADDED" ;;
  }

  dimension: corrected {
    type: number
    sql: ${TABLE}."CORRECTED" ;;
  }

  set: detail {
    fields: [
        vendor_id,
	application_id,
	date_added_time,
	corrected
    ]
  }
}
