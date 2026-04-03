view: fact_invoice_line_allocations {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_INVOICE_LINE_ALLOCATIONS" ;;

  # PRIMARY KEY
  dimension: invoice_line_allocation_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."INVOICE_LINE_ALLOCATION_KEY" ;;
    hidden: yes
  }

  # FOREIGN KEYS (Surrogate Keys)
  dimension: invoice_line_item_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_ITEM_KEY" ;;
    hidden: yes
  }

  dimension: invoice_key {
    type: string
    sql: ${TABLE}."INVOICE_KEY" ;;
    hidden: yes
  }

  dimension: rental_key {
    type: string
    sql: ${TABLE}."RENTAL_KEY" ;;
    hidden: yes
  }

  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
    hidden: yes
  }

  dimension: location_key {
    type: string
    sql: ${TABLE}."LOCATION_KEY" ;;
    hidden: yes
  }

  dimension: purchase_order_key {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_KEY" ;;
    hidden: yes
  }

  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS (Degenerate Dimensions)
  dimension: invoice_line_item_id {
    type: number
    sql: ${TABLE}."INVOICE_LINE_ITEM_ID" ;;
    value_format_name: id
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
    label: "Customer Company ID"
    description: "Natural key for the customer company that ordered the rental"
  }

  # ATTRIBUTES
  dimension: invoice_line_item_type_name {
    type: string
    sql: ${TABLE}."INVOICE_LINE_ITEM_TYPE_NAME" ;;
    label: "Line Item Type"
  }

  dimension: invoice_line_item_rental_revenue {
    type: yesno
    sql: ${TABLE}."INVOICE_LINE_ITEM_RENTAL_REVENUE" ;;
    label: "Is Rental Revenue"
  }

  # FILTER FIELDS
  # Note: company_id dimension already defined above (line 92)

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
    label: "Billing Approved"
  }


  # TEMPORAL METRICS
  dimension_group: rental_location_start {
    type: time
    timeframes: [raw, date, week, month]
    sql: ${TABLE}."RENTAL_LOCATION_START_DATE" ;;
    label: "Location Start"
  }

  dimension_group: rental_location_end {
    type: time
    timeframes: [raw, date, week, month]
    sql: ${TABLE}."RENTAL_LOCATION_END_DATE" ;;
    label: "Location End"
  }

  dimension: overlap_seconds {
    type: number
    sql: ${TABLE}."OVERLAP_SECONDS" ;;
    hidden: yes
  }

  dimension: invoice_total_seconds {
    type: number
    sql: ${TABLE}."INVOICE_TOTAL_SECONDS" ;;
    hidden: yes
  }

  dimension: allocation_percentage {
    type: number
    sql: ${TABLE}."ALLOCATION_PERCENTAGE" ;;
    value_format_name: percent_2
    label: "Allocation %"
  }

  # REFERENCE AMOUNTS
  dimension: original_line_item_amount {
    type: number
    sql: ${TABLE}."ORIGINAL_LINE_ITEM_AMOUNT" ;;
    value_format_name: usd
    label: "Original Invoice Total"
    description: "Original invoice total amount (for reference)"
  }

  dimension: original_line_item_tax {
    type: number
    sql: ${TABLE}."ORIGINAL_LINE_ITEM_TAX" ;;
    value_format_name: usd
    label: "Original Invoice Tax"
  }

  dimension: total_line_item_count {
    type: number
    sql: ${TABLE}."TOTAL_LINE_ITEM_COUNT" ;;
    label: "Line Items on Invoice"
  }

  dimension: prorated_amount {
    type: number
    sql: ${TABLE}."PRORATED_AMOUNT" ;;
    value_format_name: usd
    label: "Prorated Amount"
    description: "Invoice total / line item count (before temporal allocation)"
  }

  # BASE MEASURES (Line Item Amounts)
  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
    value_format_name: usd
    label: "Line Item Amount"
    description: "Individual line item amount (before allocation)"
  }

  dimension: line_item_tax_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_TAX_AMOUNT" ;;
    value_format_name: usd
    label: "Line Item Tax"
  }

  # ALLOCATED MEASURES (Primary spend metrics)
  dimension: allocated_line_item_amount {
    type: number
    sql: ${TABLE}."ALLOCATED_LINE_ITEM_AMOUNT" ;;
    value_format_name: usd
    label: "Allocated Amount"
    description: "Line item amount allocated to this location/time period (float division - mathematically correct)"
  }

  dimension: allocated_tax_amount {
    type: number
    sql: ${TABLE}."ALLOCATED_TAX_AMOUNT" ;;
    value_format_name: usd
    label: "Allocated Tax"
  }

  dimension: allocated_total_amount {
    type: number
    sql: ${TABLE}."ALLOCATED_TOTAL_AMOUNT" ;;
    value_format_name: usd
    label: "Allocated Total"
    description: "Total allocated amount including tax"
  }

  # MEASURES
  measure: count {
    type: count
    label: "Number of Allocations"
  }

  measure: total_line_item_amount {
    type: sum
    sql: ${line_item_amount} ;;
    value_format_name: usd
    label: "Total Line Item Amount"
    description: "Sum of individual line item amounts (before allocation)"
  }

  measure: total_allocated_amount {
    type: sum
    sql: ${allocated_line_item_amount} ;;
    value_format_name: usd
    label: "Total Allocated Amount"
    description: "Sum of allocated amounts (PRIMARY SPEND METRIC)"
    drill_fields: [allocation_detail*]
  }

  measure: total_allocated_tax {
    type: sum
    sql: ${allocated_tax_amount} ;;
    value_format_name: usd
    label: "Total Allocated Tax"
  }

  measure: total_allocated_with_tax {
    type: sum
    sql: ${allocated_total_amount} ;;
    value_format_name: usd
    label: "Total Allocated (with Tax)"
    drill_fields: [allocation_detail*]
  }

  measure: average_allocation_percentage {
    type: average
    sql: ${allocation_percentage} ;;
    value_format_name: percent_2
    label: "Avg Allocation %"
  }

  # RUNTIME HOURS - Aggregated at asset level (following legacy pattern)
  # Legacy approach: Pre-aggregate runtime by asset_id, then join to spend data
  # This handles fan-out correctly because runtime is asset-scoped, not rental-scoped
  # See: rental_jobsite_spend.view.lkml for reference implementation

  # AUDIT FIELDS
  dimension_group: created {
    type: time
    timeframes: [raw, time, date]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  # ============================================================================
  # LEGACY FIELD COMPATIBILITY (rentals_spend_by)
  # ============================================================================
  # These fields provide backward compatibility with the legacy rentals_spend_by explore

  # LEGACY PARAMETER: spend_by (Jobsite, Purchase Order, Class)
  parameter: spend_by {
    type: string
    allowed_value: { value: "Jobsite"}
    allowed_value: { value: "Purchase Order"}
    allowed_value: { value: "Class"}
    description: "Select grouping type (legacy compatibility)"
  }

  # LEGACY DIMENSION: type_
  dimension: type_ {
    type: string
    sql:
      {% if spend_by._parameter_value == "'Jobsite'" %}
        'jobsite'
      {% elsif spend_by._parameter_value == "'Purchase Order'" %}
        'po'
      {% else %}
        'class'
      {% endif %}
    ;;
    label: "Type"
    description: "Legacy: Type of grouping (jobsite/po/class)"
  }

  # LEGACY DIMENSION: parameter (the dynamic value based on spend_by selection)
  # This dimension dynamically returns the grouping field based on spend_by parameter
  # - Jobsite: UPPER(location_nickname) - matches legacy behavior
  # - Purchase Order: PO name with active status suffix
  # - Class: Equipment class name or 'No Class Assigned'
  dimension: parameter {
    type: string
    label_from_parameter: spend_by
    sql:
      {% if spend_by._parameter_value == "'Jobsite'" %}
        UPPER(${dim_locations.location_nickname})
      {% elsif spend_by._parameter_value == "'Purchase Order'" %}
        CASE
          WHEN ${dim_purchase_orders.purchase_order_active} = TRUE
          THEN COALESCE(${dim_purchase_orders.purchase_order_name}, 'No PO')
          ELSE CONCAT(COALESCE(${dim_purchase_orders.purchase_order_name}, 'No PO'), ' - NA')
        END
      {% else %}
        COALESCE(${equipment_classes.name}, 'No Class Assigned')
      {% endif %}
    ;;
    description: "Legacy: Dynamic dimension based on spend_by parameter - groups by Jobsite, Purchase Order, or Class"
  }

  # LEGACY DIMENSION: dynamic_spend_by_selection (alias of parameter)
  dimension: dynamic_spend_by_selection {
    type: string
    label_from_parameter: spend_by
    sql: ${parameter} ;;
    description: "Legacy: Alias of parameter field"
  }

  # LEGACY DIMENSION: invoice_no
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    label: "Invoice No"
  }

  # LEGACY DIMENSION: po_name
  dimension: po_name {
    type: string
    sql: ${dim_purchase_orders.purchase_order_name} ;;
    label: "PO Name"
    description: "Legacy: Purchase order name (directly from dim_purchase_orders)"
  }

  # LEGACY DIMENSION: asset_list (from joined dim_assets)
  dimension: asset_list {
    type: string
    sql: ${dim_assets.asset_custom_name} ;;
    label: "Asset List"
    description: "Legacy: Asset custom name (use GROUP_CONCAT for aggregation)"
  }

  # LEGACY DIMENSION: billed_amount (alias for allocated_line_item_amount)
  dimension: billed_amount {
    type: number
    sql: ${allocated_line_item_amount} ;;
    value_format_name: usd
    label: "Billed Amount"
    description: "Legacy: Alias for allocated_line_item_amount"
  }

  # LEGACY DIMENSION: budget_amount (from joined dim_purchase_orders)
  dimension: budget_amount {
    type: number
    sql: ${dim_purchase_orders.purchase_order_budget_amount} ;;
    value_format_name: usd
    label: "Budget Amount"
    description: "Legacy: PO budget amount"
  }

  # LEGACY DIMENSION: pcnt_budget_remaining (from budget_remaining_by_invoice join)
  dimension: pcnt_budget_remaining {
    type: number
    sql: ${budget_remaining_by_invoice.pcnt_budget_remaining} ;;
    value_format_name: percent_0
    label: "% of Budget Remaining"
    description: "Legacy: Percentage of budget remaining"
  }

  # LEGACY DIMENSION_GROUP: invoice_start_date (mapped to invoice period dates)
  dimension_group: invoice_start_date {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}."INVOICE_START_DATE" ;;
    label: "Invoice Start"
  }

  # LEGACY DIMENSION_GROUP: invoice_end_date (mapped to invoice period dates)
  dimension_group: invoice_end_date {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}."INVOICE_END_DATE" ;;
    label: "Invoice End"
  }

  # LEGACY FILTER: date_filter
  filter: date_filter {
    type: date_time
    description: "Legacy: Date range filter (use billing_approved_date filter instead)"
  }

  # LEGACY FILTER: jobsite_filter
  filter: jobsite_filter {
    type: string
    description: "Legacy: Filter by jobsite (use dim_locations.location_nickname filter instead)"
  }

  # LEGACY FILTER: class_filter
  filter: class_filter {
    type: string
    description: "Legacy: Filter by equipment class (use equipment_classes.name filter instead)"
  }

  # LEGACY FILTER: po_filter
  filter: po_filter {
    type: string
    description: "Legacy: Filter by PO (use dim_purchase_orders.purchase_order_name filter instead)"
  }

  # LEGACY MEASURE: total_billed_amount (primary spend measure)
  measure: total_billed_amount {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    label: "Total Billed Amount"
    description: "Legacy: Sum of billed amounts (same as total_allocated_amount)"
    drill_fields: [rental_spend_by*]
  }

  # LEGACY MEASURE: total_billed_amount_po (filtered by type)
  measure: total_billed_amount_po {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "po"]
    value_format_name: usd
    label: "Total Billed Amount (PO)"
    description: "Legacy: Sum filtered to PO grouping only"
  }

  # LEGACY MEASURE: total_billed_amount_job (filtered by type)
  measure: total_billed_amount_job {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "jobsite"]
    value_format_name: usd
    label: "Total Billed Amount (Jobsite)"
    description: "Legacy: Sum filtered to jobsite grouping only"
  }

  # LEGACY MEASURE: total_billed_amount_class (filtered by type)
  measure: total_billed_amount_class {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "class"]
    value_format_name: usd
    label: "Total Billed Amount (Class)"
    description: "Legacy: Sum filtered to class grouping only"
  }

  # LEGACY MEASURE: dynamic_spend_by_selection_amount
  measure: dynamic_spend_by_selection_amount {
    label_from_parameter: spend_by
    view_label: "Total Spend"
    type: sum
    value_format_name: usd
    sql:
      {% if spend_by._parameter_value == "'Jobsite'" %}
        CASE WHEN ${type_} = 'jobsite' THEN ${billed_amount} ELSE 0 END
      {% elsif spend_by._parameter_value == "'Purchase Order'" %}
        CASE WHEN ${type_} = 'po' THEN ${billed_amount} ELSE 0 END
      {% elsif spend_by._parameter_value == "'Class'" %}
        CASE WHEN ${type_} = 'class' THEN ${billed_amount} ELSE 0 END
      {% else %}
        0
      {% endif %}
    ;;
    drill_fields: [rental_spend_by*]
    description: "Legacy: Dynamic measure based on spend_by parameter"
  }

  # LEGACY MEASURE: max_budget_remaining
  measure: max_budget_remaining {
    type: max
    sql: CASE WHEN ${budget_remaining_by_invoice.budget_remaining} < 0 THEN NULL ELSE ${budget_remaining_by_invoice.budget_remaining} END ;;
    value_format_name: usd_0
    label: "Budget Remaining"
    description: "Legacy: Max budget remaining (positive values only)"
  }

  # LEGACY MEASURE: no_budget_remaining
  measure: no_budget_remaining {
    type: max
    sql: CASE WHEN ${budget_remaining_by_invoice.budget_remaining} >= 0 THEN NULL ELSE ${budget_remaining_by_invoice.budget_remaining} * -1 END ;;
    value_format_name: usd_0
    label: "No Budget Remaining"
    description: "Legacy: Absolute value of negative budget remaining"
  }

  # LEGACY MEASURE: budget_amount_percentage
  measure: budget_amount_percentage {
    type: max
    sql: ${pcnt_budget_remaining} ;;
    value_format_name: percent_0
    label: "Budget % Remaining"
    description: "Legacy: Percentage of budget remaining"
  }

  # LEGACY MEASURE: total_budget_amount
  measure: total_budget_amount {
    type: max
    sql: ${budget_amount} ;;
    value_format_name: usd_0
    label: "Total Budget Amount"
    description: "Legacy: Max budget amount"
  }

  # LEGACY DIMENSION: max_date (for display in budget info)
  dimension: max_date {
    type: date
    sql: CURRENT_DATE ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }} ;;
    skip_drill_filter: yes
    label: "Current Date"
    description: "Legacy: Current date for budget calculations"
  }

  # LEGACY MEASURE: dynamic_budget_amount (with HTML formatting)
  measure: dynamic_budget_amount {
    label_from_parameter: spend_by
    view_label: "Budget Amount"
    type: number
    value_format_name: usd_0
    sql:
      {% if spend_by._parameter_value == "'Purchase Order'" %}
        ${total_budget_amount}
      {% else %}
        NULL
      {% endif %}
    ;;
    html: {{rendered_value}} (Budget % Remaining: {{budget_amount_percentage._rendered_value}} as of {{max_date._rendered_value | date: "%b %d, %Y" }}  ) ;;
    description: "Legacy: Dynamic budget display for PO grouping"
  }

  # LEGACY MEASURE: dynamic_budget_percent_remaining
  measure: dynamic_budget_percent_remaining {
    label_from_parameter: spend_by
    view_label: "Budget Remaining"
    type: max
    value_format_name: usd_0
    sql:
      {% if spend_by._parameter_value == "'Purchase Order'" %}
        CASE WHEN ${budget_remaining_by_invoice.budget_remaining} < 0 THEN NULL ELSE ${budget_remaining_by_invoice.budget_remaining} END
      {% else %}
        NULL
      {% endif %}
    ;;
    drill_fields: [rental_spend_by*]
    description: "Legacy: Dynamic budget remaining for PO grouping"
  }

  # LEGACY MEASURE: dynamic_no_budget_remaining
  measure: dynamic_no_budget_remaining {
    label_from_parameter: spend_by
    view_label: "No Budget Remaining"
    type: max
    value_format_name: usd_0
    sql:
      {% if spend_by._parameter_value == "'Purchase Order'" %}
        CASE WHEN ${budget_remaining_by_invoice.budget_remaining} >= 0 THEN NULL ELSE ${budget_remaining_by_invoice.budget_remaining} * -1 END
      {% else %}
        NULL
      {% endif %}
    ;;
    drill_fields: [rental_spend_by*]
    description: "Legacy: Dynamic over-budget amount for PO grouping"
  }

  # LEGACY DIMENSION: view_invoices_table (link to invoice detail)
  dimension: view_invoices_table {
    group_label: "Links to Invoice"
    label: "Invoice No"
    type: string
    sql: ${invoice_id} ;;
    html:
      {% if user_is_america_timezone._value == "Yes" %}
        <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{invoice_id._value}}" target="_blank">{{invoice_no._value}}</a></font></u>
      {% else %}
        {{invoice_no._value}}
      {% endif %}
    ;;
    description: "Legacy: Clickable invoice number link"
  }

  # LEGACY DIMENSION: user_is_america_timezone
  dimension: user_is_america_timezone {
    type: yesno
    sql: SUBSTR('{{ _user_attributes['user_timezone'] }}', 0, 7) = 'America' ;;
    hidden: yes
    description: "Legacy: Check if user is in America timezone"
  }

  # DRILL SETS
  set: allocation_detail {
    fields: [
      invoice_id,
      rental_id,
      asset_id,
      location_id,
      line_item_amount,
      allocated_line_item_amount,
      allocation_percentage,
      overlap_seconds
    ]
  }

  # LEGACY DRILL SET: rental_spend_by
  set: rental_spend_by {
    fields: [
      parameter,
      view_invoices_table,
      invoice_start_date_date,
      invoice_end_date_date,
      asset_list,
      po_name,
      budget_amount,
      budget_remaining_by_invoice.budget_remaining,
      budget_remaining_by_invoice.pcnt_budget_remaining,
      total_billed_amount
    ]
  }

  # LEGACY DRILL SET: detail
  set: detail {
    fields: [
      type_,
      parameter,
      invoice_no,
      invoice_start_date_time,
      invoice_end_date_time,
      asset_list,
      po_name,
      billed_amount,
      budget_amount,
      pcnt_budget_remaining
    ]
  }

}
