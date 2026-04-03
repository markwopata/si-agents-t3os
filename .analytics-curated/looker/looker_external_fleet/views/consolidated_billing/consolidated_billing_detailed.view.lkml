view: consolidated_billing_detailed {
  derived_table: {
    sql:
      WITH current_user AS (
        SELECT security_level_id
        FROM es_warehouse.public.users
        WHERE user_id = {{ _user_attributes['id'] }}
        LIMIT 1
      )
      SELECT b.*
      FROM business_intelligence.triage.stg_t3__consolidated_billing AS b
      LEFT JOIN current_user AS u ON 1=1
      WHERE
        -- Only allow access if the user is in security levels 1, 2, or 3
        u.security_level_id IN (1, 2, 3)
        AND (
          b.company_id IN (
            SELECT company_id
            FROM analytics.bi_ops.parent_company_relationships
            WHERE parent_company_id = {{ _user_attributes['company_id'] }}
            OR company_id = {{ _user_attributes['company_id'] }}
          )
          OR b.company_id = {{ _user_attributes['company_id'] }}
        )
    ;;
  }

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: primary_key {
  primary_key: yes
  type: string
  sql: ${TABLE}.unique_row_id ;;
}

dimension: invoice_ {
  type: string
  label: "Invoice #"
  sql: ${TABLE}."Invoice #" ;;
}

dimension: invoice_id {
  type: number
  sql: ${TABLE}."INVOICE_ID" ;;
}

dimension: date {
  type: date
  sql: ${TABLE}."Date" ;;
}

dimension: vendor {
  type: string
  sql: ${TABLE}."Vendor" ;;
}

dimension: customer {
  type: string
  sql: ${TABLE}."Customer" ;;
}

dimension: line_items {
  type: number
  label: "Line Items"
  sql: ${TABLE}."Line Items" ;;
}

dimension: invoice_total {
  type: number
  label: "Invoice Total"
  sql: ${TABLE}."Invoice Total" ;;
}

dimension: paid {
  type: string
  sql: ${TABLE}."Paid" ;;
}

dimension: invoice_category {
  type: string
  label: "Invoice Category"
  sql: ${TABLE}."Invoice Category" ;;
}

dimension: nam_invoice_category {
  type: string
  label: "NAM Invoice Category"
  sql: ${TABLE}."NAM Invoice Category" ;;
}

  dimension: nam_invoice_category_yes_no {
    type: yesno
    label: "NAM Invoice Category Yes/No"
    sql: ${TABLE}."NAM Invoice Category Yes_No" ;;
  }

dimension: equipment_category {
  type: string
  label: "Equipment Category"
  sql: ${TABLE}."Equipment Category" ;;
}

dimension: equipment_category_id {
  type: number
  label: "Equipment Category ID"
  sql: ${TABLE}."Equipment Category ID" ;;
}

dimension: equipment_parent_category {
  type: string
  label: "Equipment Parent Category"
  sql: ${TABLE}."Equipment Parent Category" ;;
}

dimension: equipment_parent_category_id {
  type: number
  label: "Equipment Parent Category ID"
  sql: ${TABLE}."Equipment Parent Category ID" ;;
}

dimension: is_rental {
  type: yesno
  label: "Is Rental"
  sql: ${TABLE}."Is Rental" ;;
}

dimension: line_item_type_id {
  type: number
  sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
}

dimension: invoice_description {
  type: string
  label: "Invoice Description"
  sql: ${TABLE}."Invoice Description" ;;
}

dimension: equipment_type {
  type: string
  label: "Equipment Type"
  sql: ${TABLE}."Equipment Type" ;;
}

dimension: equipment_ {
  type: string
  label: "Equipment #"
  sql: ${TABLE}."Equipment #" ;;
}

dimension: qty {
  type: number
  sql: ${TABLE}."Qty" ;;
}

dimension: line_total {
  type: number
  label: "Line Total"
  sql: ${TABLE}."Line Total" ;;
}

  measure: line_total_sum {
    type: sum
    label: "Line Total"
    sql: ${line_total} ;;
  }

  measure: line_total_sum_yes {
    type: sum
    label: "Line Total YES"
    sql: ${line_total} ;;
    filters: [is_rental: "yes"]
  }

  measure: line_total_sum_no {
    type: sum
    label: "Line Total NO"
    sql: ${line_total} ;;
    filters: [is_rental: "no"]
  }

  measure: line_total_sum_balance {
    type: number
    label: "Line Total Balance"
    sql: ${line_total_sum_no} + ${line_total_sum_yes} ;;
  }

  dimension: line_item_tax_amount {
    type: number
    label: "Line Item Tax Amount"
    sql: ${TABLE}."Line Item Tax Amount" ;;
  }

dimension: total_tax_amount {
  type: number
  label: "Total Tax Amount"
  sql: ${TABLE}."Total Tax Amount" ;;
}

dimension: total_billed_amount {
  type: number
  label: "Total Billed Amount"
  sql: ${TABLE}."Total Billed Amount" ;;
}

dimension: job_ {
  type: string
  label: "Job #"
  sql: ${TABLE}."Job #" ;;
}

dimension: sub_renter {
  type: string
  label: "Sub Renter"
  sql: ${TABLE}."Sub Renter" ;;
}

  dimension: sub_renter_id {
    type: number
    label: "Sub Renter ID"
    sql: ${TABLE}."Sub Renter ID" ;;
  }

dimension: po_ {
  type: string
  label: "PO #"
  sql: ${TABLE}."PO #" ;;
}

dimension: job_address1 {
  type: string
  label: "Job Address1"
  sql: ${TABLE}."Job Address1" ;;
}

dimension: job_city {
  type: string
  label: "Job City"
  sql: ${TABLE}."Job City" ;;
}

dimension: job_state {
  type: string
  label: "Job State"
  sql: ${TABLE}."Job State" ;;
}

dimension: job_zip {
  type: string
  label: "Job ZIP"
  sql: ${TABLE}."Job ZIP" ;;
}

dimension: quantity {
  type: number
  sql: ${TABLE}."Quantity" ;;
}

dimension: class_number {
  type: string
  label: "Class Number"
  sql: ${TABLE}."Class Number" ;;
}

dimension: serial_ {
  type: string
  label: "Serial #"
  sql: ${TABLE}."Serial #" ;;
}

dimension: make {
  type: string
  sql: ${TABLE}."Make" ;;
}

dimension: model {
  type: string
  sql: ${TABLE}."Model" ;;
}

dimension: model_year {
  type: number
  label: "Model Year"
  sql: ${TABLE}."Model Year" ;;
}

dimension: date_rented {
  type: date
  label: "Date Rented"
  sql: ${TABLE}."Date Rented" ;;
}

dimension: date_returned {
  type: date
  label: "Date Returned"
  sql: ${TABLE}."Date Returned" ;;
}

dimension: billing_start_date {
  type: date
  label: "Billing Start Date"
  sql: ${TABLE}."Billing Start Date" ;;
}

dimension: billing_end_date {
  type: date
  label: "Billing End Date"
  sql: ${TABLE}."Billing End Date" ;;
}

dimension: day_rate {
  type: number
  label: "Day Rate"
  sql: ${TABLE}."Day Rate" ;;
}

dimension: week_rate {
  type: number
  label: "Week Rate"
  sql: ${TABLE}."Week Rate" ;;
}

dimension: 4week_rate {
  type: number
  label: "4-Week Rate"
  sql: ${TABLE}."4-Week Rate" ;;
}

dimension: days_on_rent {
  type: number
  label: "Days On Rent"
  sql: ${TABLE}."Days On Rent" ;;
}

dimension: billed_days {
  type: number
  label: "Billed Days"
  sql: ${TABLE}."Billed Days" ;;
}

dimension: ordered_by {
  type: string
  label: "Ordered By"
  sql: ${TABLE}."Ordered By" ;;
}

  dimension: rental_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Rental Amount"
    sql: ${TABLE}."Rental Amount" ;;
  }

  dimension: misc_tax_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Misc Tax Amount"
    sql: ${TABLE}."Misc Tax Amount" ;;
  }

  dimension: rental_protection_plan_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Rental Protection Plan Amount"
    sql: ${TABLE}."Rental Protection Plan Amount" ;;
  }

  dimension: transport_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Transport Amount"
    sql: ${TABLE}."Transport Amount" ;;
  }

  dimension: fuel_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Fuel Amount"
    sql: ${TABLE}."Fuel Amount" ;;
  }

  dimension: sales_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Sales Amount"
    sql: ${TABLE}."Sales Amount"  ;;
  }

  dimension: misc_charge_amount {
    type: number
    group_label: "Consolidated Amounts"
    label: "Misc Charges Amount"
    sql: ${TABLE}."Misc Charges Amount" ;;
  }

set: detail {
  fields: [
    invoice_,
    invoice_id,
    date,
    vendor,
    customer,
    line_items,
    invoice_total,
    paid,
    invoice_category,
    nam_invoice_category,
    nam_invoice_category_yes_no,
    equipment_category,
    equipment_category_id,
    equipment_parent_category,
    equipment_parent_category_id,
    is_rental,
    line_item_type_id,
    invoice_description,
    equipment_type,
    equipment_,
    qty,
    line_total,
    total_tax_amount,
    total_billed_amount,
    job_,
    sub_renter,
    po_,
    job_address1,
    job_city,
    job_state,
    job_zip,
    quantity,
    class_number,
    serial_,
    make,
    model,
    model_year,
    date_rented,
    date_returned,
    billing_start_date,
    billing_end_date,
    day_rate,
    week_rate,
    4week_rate,
    days_on_rent,
    billed_days,
    ordered_by,
    rental_amount,
    misc_tax_amount,
    rental_protection_plan_amount,
    transport_amount,
    fuel_amount,
    sales_amount,
    misc_charge_amount
  ]
}
}
