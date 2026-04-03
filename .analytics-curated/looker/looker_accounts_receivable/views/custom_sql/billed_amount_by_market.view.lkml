view: billed_amount_by_market {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    explore_source: orders {
      column: Total_Billed_Amount { field: invoices.Invoice_Billed_Amount }
      column: market_id {}
      filters: {
        field: invoices.billing_approved
        value: "Yes"
      }
      expression_custom_filter: ${invoices.invoice_date} >= add_days(-90,now());;
    }
  }
  dimension: Total_Billed_Amount {
    type: number
  }
  dimension: market_id {
    primary_key: yes
    type: number
  }
  measure: revenue {
    type: sum
    sql: ${Total_Billed_Amount} ;;
  }

}
