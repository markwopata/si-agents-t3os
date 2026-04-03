view: po_over_specified_amount {
  sql_table_name: BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__PO_OVER_SPECIFIED_AMOUNT ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: preferred {
    type: string
    sql: ${TABLE}."PREFERRED" ;;
  }

  dimension: total_po_cost {
    type: number
    sql: ${TABLE}."TOTAL_PO_COST" ;;
  }

  dimension: po_date_created {
    label: "PO Date Created"
    type: date
    sql: ${TABLE}."PO_DATE_CREATED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: link_to_purchase_order {
    group_label: "Link To PO"
    label: "Purchase Order Number"
    sql: ${purchase_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://costcapture.estrack.com/purchase-orders/{{rendered_value}}/detail" target="_blank">{{purchase_order_number._rendered_value}}</a></font></u>;;
  }

  dimension: item_service {
    label: "Item/Service"
    type: string
    sql: ${TABLE}."ITEM_SERVICE" ;;
  }

  dimension: item_service_count {
    type: number
    sql: ${TABLE}."ITEM_SERVICE_COUNT" ;;
  }

  dimension_group: date_received {
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: line_item_description {
    label: "Description"
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: date_received_date_html {
    group_label: "HTML Format"
    label: "Date Received"
    type: date
    sql: ${date_received_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: open_more_than_12_months {
    type: yesno
    sql: ${TABLE}."OPEN_MORE_THAN_12_MONTHS" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  # Filters - these collect user input for the liquid templating in the explore
  filter: date_filter {
    type: date_time
  }

  filter: cost_center_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.cost_center
  }

  filter: region_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.region_name
  }

  filter: district_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.district_name
  }

  filter: market_open_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.open_more_than_12_months
  }

  filter: status_filter {
  }

  filter: vendor_filter {
  }

  filter: preferred_filter {
  }

  # Parameters - these collect user choices for the liquid templating in the explore
  parameter: over_total_cost_of {
    type: string
    allowed_value: { value: "$5,000"}
    allowed_value: { value: "$10,000"}
    allowed_value: { value: "$15,000"}
  }

  parameter: view_by {
    type: string
    allowed_value: { value: "Date Created"}
    allowed_value: { value: "Date Received"}
  }

  measure: total_purchase_order_cost {
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
  }

  dimension: cost_tier_level {
    type: string
    sql: case
          when ${total_po_cost} >= 5000 AND ${total_po_cost} < 10000 then '$5,000-$10,000'
          when ${total_po_cost} >= 10000 AND ${total_po_cost} < 15000 then '$10,000-$15,000'
          else '$15,000+'
          end;;
  }

  measure: five_to_ten_thousand_total_po_cost {
    label: "Total Purchase Orders Over $5,000-$10,000"
    type: count
    filters: [cost_tier_level: "'$5,000-$10,000'"]
    drill_fields: [detail*]
  }

  measure: ten_to_fifteen_thousand_total_po_cost {
    label: "Total Purchase Orders Over $10,000-$15,000"
    type: count
    filters: [cost_tier_level: "'$10,000-$15,000'"]
    drill_fields: [detail*]
  }

  measure: over_fifteen_thousand_total_po_cost {
    label: "Total Purchase Orders Over $15,000"
    type: count
    filters: [cost_tier_level: "'$15,000+'"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [po_date_created, date_received_date_html, link_to_purchase_order, vendor, preferred, reference, item_service, line_item_description, created_by, cost_center, total_purchase_order_cost]
  }
}
