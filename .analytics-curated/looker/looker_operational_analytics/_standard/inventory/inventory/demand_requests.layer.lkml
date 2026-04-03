include: "/_base/inventory/inventory/demand_requests.view.lkml"

view: +demand_requests {
  label: "Demand Requests"

dimension: is_completed {
  type: yesno
  sql: ${TABLE}."DATE_COMPLETED" IS NOT NULL ;;
}

dimension: is_cancelled {
  type: yesno
  sql: ${TABLE}."DATE_CANCELLED" IS NOT NULL ;;
}

dimension: status {
  type: string
  sql:
      CASE
        WHEN ${TABLE}."DATE_CANCELLED" IS NOT NULL THEN 'Cancelled'
        WHEN ${TABLE}."DATE_COMPLETED" IS NOT NULL THEN 'Completed'
        ELSE 'Open'
      END ;;
}

measure: count {
  type: count
  drill_fields: [demand_request_id, request_number, status, date_created_date]
}

measure: open_count {
  type: count
  filters: [status: "Open"]
}

measure: completed_count {
  type: count
  filters: [status: "Completed"]
}

measure: cancelled_count {
  type: count
  filters: [status: "Cancelled"]
}

measure: avg_days_to_complete {
  type: average
  sql: DATEDIFF(
        'day',
        CAST(${TABLE}."DATE_CREATED" AS DATE),
        CAST(${TABLE}."DATE_COMPLETED" AS DATE)
      ) ;;
  value_format_name: decimal_1
}
}
