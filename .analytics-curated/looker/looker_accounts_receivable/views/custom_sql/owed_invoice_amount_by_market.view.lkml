view: owed_invoice_amount_by_market {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    explore_source: orders {
      column: market_id {}
      column: Invoice_Total_Amount { field: invoices.Invoice_Total_Amount }
      filters: {
        field: invoices.paid
        value: "No"
      }
      filters: {
        field: invoices.billing_approved
        value: "Yes"
      }
    }
  }
  dimension: market_id {
    primary_key: yes
    type: number
  }
  dimension: Invoice_Total_Amount {
    value_format_name: usd_0
    type: number
  }

  measure: invoice_total_amount_calculation {
    type: number
    sql: ${Invoice_Total_Amount} ;;
    value_format_name: usd_0
  }
}
