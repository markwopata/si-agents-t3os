view: vic_po_line_detail {
  derived_table: {
    sql: select poh.po_number,
      poh.type_matching,
      poh.id_vendor,
      poh.name_vendor,
      poh.amount as po_total,
      poh.description,
      pol.po_line_number,
      pol.matching_type,
      pol.product_number,
      pol.product_description,
      pol.qty_requested,
      pol.qty_received,
      pol.status_matching,
      pol.amount_unit,
      d.name_dim_short as dept_id,
      d.name_dim as dept_name,
      poh.url_vic,
      poh.name_environment
      from financial_systems.vic_gold.vic__po_lines pol
      left join financial_systems.vic_gold.vic__po_headers poh on pol.fk_vic_po_header_id = poh.pk_vic_po_header_id
      left join financial_systems.vic_gold.vic__dimensions d on pol.fk_dim_vic_department_id = d.pk_vic_dimension_id and d.type_dim_name = 'department' ;;
  }
  dimension: po_number {
    type: string
    label: "PO Number"
    sql: ${TABLE}.po_number ;;
    html: <a href="{{ url_vic._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }
  dimension: matching_status {
    type: string
    label: "Status - Matching"
    sql: ${TABLE}.status_matching ;;
  }
  dimension: header_matching_type {
    type: string
    label: "Matching Type"
    sql: ${TABLE}.type_matching ;;
  }
  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}.id_vendor ;;
  }
  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}.name_vendor ;;
  }
  dimension: po_total {
    type: number
    label: "PO Total Amount"
    sql: ${TABLE}.po_total ;;
  }
  dimension: header_description {
    type: string
    label: "Header Description"
    sql: ${TABLE}.description ;;
  }
  dimension: po_line_number {
    type: string
    label: "PO Line Number"
    sql: ${TABLE}.po_line_number ;;
  }
  dimension: product_number {
    type: string
    label: "Product Number"
    sql: ${TABLE}.product_number ;;
  }
  dimension: product_description {
    type: string
    label: "Product Description"
    sql: ${TABLE}.product_description ;;
  }
  dimension: qty_requested {
    type: number
    label: "Quantity Requested"
    sql: ${TABLE}.qty_requested ;;
  }
  dimension: qty_received {
    type: number
    label: "Quantity Received"
    sql: ${TABLE}.qty_received ;;
  }
  dimension: price {
    type: number
    label: "Price"
    sql: ${TABLE}.amount_unit ;;
  }
  dimension: dept_id {
    type: string
    label: "Market/Department ID"
    sql: ${TABLE}.dept_id ;;
  }
  dimension: dept_name {
    type: string
    label: "Market/Department Name"
    sql: ${TABLE}.dept_name ;;
  }
  dimension: name_environment {
    type: string
    label: "Vic Environment"
    sql: ${TABLE}.name_environment ;;
  }
  dimension: url_vic {
    type: string
    label: "Vic URL"
    sql: ${TABLE}.url_vic ;;
  }
}
