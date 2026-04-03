include: "/_base/analytics/hrbp_succession_planning/open_invoice_details.view.lkml"

view: +open_invoice_details {
  label: "Open Invoice Details"

  dimension_group: _update_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${_update_timestamp} ;;
    description: "invoice date"
  }

  dimension: item_display {
    type: string
    sql:
    CASE
      WHEN ${item} = 'invoice_received'
        THEN 'Unreceived POs with Invoice Received'
      WHEN ${item} = 'pending_invoices'
        THEN 'Pending Invoices'
      ELSE ${item}
    END ;;
  }

}
