view: warehouse_shipment_data {
  sql_table_name: "FINANCIAL_SYSTEMS"."T3_SAAS_GOLD"."WAREHOUSE_SHIPMENT_DATA" ;;

  dimension: company_name_whs {
    type: string
    sql: ${TABLE}."COMPANY_NAME_WHS" ;;
  }
  dimension: date_deactivated {
    type: string
    sql: ${TABLE}."DATE_DEACTIVATED" ;;
  }
  dimension: fk_deactivation_ticket_id {
    type: string
    sql: ${TABLE}."FK_DEACTIVATION_TICKET_ID" ;;
  }
  dimension: fk_sales_ref_id {
    type: string
    sql: ${TABLE}."FK_SALES_REF_ID" ;;
  }
  dimension: hubspot_pipeline {
    type: string
    sql: ${TABLE}."HUBSPOT_PIPELINE" ;;
  }
  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
    skip_drill_filter: yes
  }
  dimension: invoice_line_sum {
    type: number
    sql: ${TABLE}."INVOICE_LINE_SUM" ;;
    skip_drill_filter: yes
  }
  dimension: invoice_sales_price {
    type: number
    sql: ${TABLE}."INVOICE_SALES_PRICE" ;;
    skip_drill_filter: yes
  }
  dimension: linked_device_type {
    type: string
    sql: ${TABLE}."LINKED_DEVICE_TYPE" ;;
  }
  dimension: device_type {
    type: string
    sql: case when ${linked_device_type} = 'T3Camera' then 'Camera'
              when ${linked_device_type} in ('ECM', 'Keypad') then 'Keypad'
              when ${linked_device_type} = 'Bluetooth' then 'Bluetooth'
              else 'Tracker' end;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_DESCRIPTION" ;;
  }
  dimension: sales_order_number {
    type: string
    sql: ${TABLE}."SALES_ORDER_NUMBER" ;;
  }
  dimension: serial_number_shipped_instance {
    type: number
    sql: ${TABLE}."SERIAL_NUMBER_SHIPPED_INSTANCE" ;;
  }
  dimension: shipped_serial_formatted {
    type: string
    sql: ${TABLE}."SHIPPED_SERIAL_FORMATTED" ;;
  }
  dimension: shipped_serial_number {
    type: string
    sql: ${TABLE}."SHIPPED_SERIAL_NUMBER" ;;
  }
  dimension: sn_unique_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."SN_UNIQUE_IDENTIFIER" ;;
  }
  dimension: shipment_date {
    type: date
    sql: ${TABLE}."WAREHOUSE_PHYSICAL_DATE" ;;
  }
  dimension_group: shipment_date_group {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WAREHOUSE_PHYSICAL_DATE" ;;
  }
  dimension_group: warehouse_requested_ship {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WAREHOUSE_REQUESTED_SHIP_DATE" ;;
  }
  dimension: days_since_shipment {
    type: number
    sql: DATEDIFF('day', ${shipment_date}, CURRENT_DATE()) ;;
    value_format_name: "decimal_0"
    description: "Number of days between shipment date and the current date"
  }
  measure: count {
    type: count
    drill_fields: [
      device_type,
      part_description,
      shipped_serial_number,
      invoice_id,
      invoice_line_sum,
      invoice_sales_price
      ]
  }
}
