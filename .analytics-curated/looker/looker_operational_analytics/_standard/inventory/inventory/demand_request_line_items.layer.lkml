include: "/_base/inventory/inventory/demand_request_line_items.view.lkml"


# Fields referencing other views:
# demand_request_line_items.days_until_needed, demand_request_line_items.avg_days_to_complete, demand_request_line_items.total_units_requested_excluding_non_stockable, demand_request_line_items.dc_fulfillment_rate

view: +demand_request_line_items {
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

  dimension: days_until_needed {
    type: number
    sql: DATEDIFF(
          'day',
          ${demand_requests.date_created_date::date},
          ${needed_by_date::date}
        ) ;;
  }

  dimension: days_to_complete {
    type: number
    sql: DATEDIFF(
          'day',
          ${demand_requests.date_created_date::date},
          ${date_completed_date::date}
        ) ;;
  }

  dimension: fulfillment_method {
    type: string
    sql:
    CASE
      WHEN ${status} != 'Completed' THEN NULL
      WHEN ${TABLE}."FULFILLER_NOTES" ILIKE 'PO%' THEN 'PO'
      WHEN ${TABLE}."FULFILLER_NOTES" ILIKE 'TX%' THEN 'Transfer'
      ELSE NULL
    END ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, demand_request_id, product_id, status, needed_by_date]
  }

  measure: total_quantity_requested {
    type: sum
    sql: ${quantity_requested} ;;
    value_format_name: decimal_0
  }

  measure: completed_request_count {
    type: count_distinct
    sql: ${demand_request_id} ;;
    filters: [status: "Completed"]
  }

  measure: total_quantity_completed {
    type: sum
    sql: ${quantity_requested} ;;
    value_format_name: decimal_0
    filters: [status: "Completed"]
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

  measure: avg_days_until_needed {
    type: average
    sql: DATEDIFF(
        'day',
        ${demand_requests.date_created_date::date},
        ${needed_by_date::date}
      ) ;;
    value_format_name: decimal_1
  }

  measure: avg_days_to_complete {
    type: average
    sql: DATEDIFF(
      'day',
      ${demand_requests.date_created_date::date},
      ${date_completed_date::date}
    ) ;;
    filters: [status: "Completed"]
    value_format_name: decimal_1
  }

  measure: transfer_requests_completed {
    type: count_distinct
    sql: ${demand_request_id} ;;
    filters: [fulfillment_method: "Transfer"]
  }

  measure: po_requests_completed {
    type: count_distinct
    sql: ${demand_request_id} ;;
    filters: [fulfillment_method: "PO"]
  }

  measure: po_units_completed {
    type: sum
    sql: ${quantity_requested} ;;
    filters: [fulfillment_method: "PO"]
    value_format_name: decimal_0
  }

  measure: fulfilled_units_completed {
    type: sum
    sql: ${quantity_requested} ;;
    filters: [status: "Completed"]
    value_format_name: decimal_0
  }

  measure: transfer_units_completed {
    type: sum
    sql: ${quantity_requested} ;;
    filters: [fulfillment_method: "Transfer"]
    value_format_name: decimal_0
  }

  measure: total_units_requested_excluding_non_stockable {
    type: sum
    sql: ${quantity_requested} ;;
    filters: [fulfillment_parts_attributes.fc_stockable: "Yes"]
    value_format_name: decimal_0
  }

  measure: dc_fulfillment_rate {
    type: number
    sql:
    COALESCE(${transfer_units_completed}, 0)
    / NULLIF(COALESCE(${total_units_requested_excluding_non_stockable}, 0), 0) ;;
    value_format_name: percent_2
  }
}
