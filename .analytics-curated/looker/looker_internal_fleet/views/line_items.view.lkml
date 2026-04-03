view: line_items {
  sql_table_name: "PUBLIC"."LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]

  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: invoice_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    value_format_name: id
    # hidden: yes
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    #most used line items relating to fleet
    # line_item_type_id: 80 name: New Dealership Equipment Sales
    # line_item_type_id: 81 name: Used Fleet Equipment Sales
    #line_item_type_id: 24 name: New Fleet Equipment Sales
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: derived_asset_id {
    hidden:  no
    type: number
    sql: coalesce(${TABLE}."ASSET_ID",
      regexp_substr(${TABLE}."DESCRIPTION", 'Asset: (\\d{1,})', 1, 1, 'e')::integer
    );;
  }

  measure: count {
    type: count
    drill_fields: [details*]
  }

  measure: total_retail_sales {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_new_fleet_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "24, 111"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_used_fleet_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "81, 110"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_dealship_fleet_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "80, 120, 125, 141, 152, 153"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_own_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "123, 127"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_lsd_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "118, 126"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: total_rpo_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "50"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: under_10k_sales {
    type: sum
    sql: ${amount} ;;
    filters: [line_item_type_id: "145, 146, 147, 148, 149, 150"]
    value_format_name: usd_0
    drill_fields: [details*]
  }

  measure: count_new_used_units_invoiced_not_paid {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "No", line_item_type_id: "24, 81, 50", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }
  measure: count_new_used_units_invoiced_paid {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "24, 81, 50", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }
  measure: count_new_used_units_invoiced_paid_in_vendor_payoff {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "24, 81, 50", asset_purchase_history.pending_schedule: "Invoice Paid - Vendor Owed"] # Fiqure out where serial number vendor is
    drill_fields: [details*]
  }
  measure: count_new_used_units_invoiced_paid_in_lender_payoff {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "24, 81, 50", asset_purchase_history.pending_schedule: "Invoice paid - Lender Owed", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }

  measure: count_dealership_units_invoiced_not_paid {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "No", line_item_type_id: "80", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }
  measure: count_dealership_units_invoiced_paid {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "80", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }
  measure: count_dealership_units_invoiced_paid_in_vendor_payoff {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "80", asset_purchase_history.pending_schedule: "Invoice Paid - Vendor Owed",  ]
    drill_fields: [details*]
  }
  measure: count_dealership_units_invoiced_paid_in_lender_payoff {
    type:  count_distinct
    sql: ${line_item_id};;
    filters: [invoices.paid: "Yes", line_item_type_id: "80", asset_purchase_history.pending_schedule: "Invoice paid - Lender Owed", asset_purchase_history.financial_schedule_id: "NOT 1539"]
    drill_fields: [details*]
  }

  parameter: line_item_type_selector {
    suggest_dimension: line_item_type_id
  }

  dimension: selected_line_item_type_id {
    type: yesno
    hidden: yes
    sql: {% condition line_item_type_selector %} ${line_item_type_id} {% endcondition %} ;;
  }

  measure: count_filtered {
    type: count_distinct
    sql: ${line_item_id} ;;
    drill_fields: [details*]
    filters: {
      field: selected_line_item_type_id
      value: "Yes"
    }
  }

  measure: total_filtered {
    type: sum
    sql: ${amount} ;;
    drill_fields: [details*]
    value_format_name: usd_0
    filters: {
      field: selected_line_item_type_id
      value: "Yes"
    }
  }

set:  details {
  fields: [
    derived_asset_id,
    assets.serial_number,
    assets.vin,
    invoices.invoice_no,
    amount,
    invoices.paid_date,
    sales_person.full_name,
    asset_owner.company_name_with_id,
    assets.year,
    equipment_make.name,
    equipment_model.name,
    equipment_class.name,
    asset_purchase_history.finance_status,
    financial_schedules.current_schedule_number,
    asset_purchase_history.pending_schedule,
    asset_purchase_history.oec,
    asset_purchase_history.asset_invoice_url,
    asset_vendors.name,
    asset_nbv.payoff_amt,
    markets.name,
    ]
}

}
