include: "/views/company_purchase_order_types.view.lkml"

view: company_purchase_order_line_items {
  sql_table_name: "PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS"
    ;;
  drill_fields: [company_purchase_order_line_item_id]

  dimension: company_purchase_order_line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID" ;;
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

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }

  dimension: company_purchase_order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_ID" ;;
  }

  dimension: company_purchase_order_line_item_number {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER" ;;
  }

  dimension_group: deleted {
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
    sql: CAST(${TABLE}."DELETED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: freight_cost {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."FREIGHT_COST" ;;
  }

  dimension_group: original_promise {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORIGINAL_PROMISE_DATE" ;;
  }

  dimension_group: current_promise {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CURRENT_PROMISE_DATE" ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: net_price {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."NET_PRICE" ;;
  }

  dimension: extended_price {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."NET_PRICE" * ${TABLE}."QUANTITY";;
  }

  dimension: total_oec {
    type: number
    value_format: "$#,##0.00"
    sql: (coalesce(${TABLE}."NET_PRICE",0) * coalesce(${TABLE}."QUANTITY",0))
    + coalesce(${TABLE}."FREIGHT_COST", 0)
    + coalesce(${TABLE}."SALES_TAX", 0)
    + coalesce(${TABLE}."AFTERMARKET_OEC", 0)
    - coalesce(${TABLE}."REBATE", 0);;
  }

  measure: oec_sum {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."NET_PRICE" * ${TABLE}."QUANTITY" + coalesce(${TABLE}."FREIGHT_COST", 0);;
    drill_fields: [asset_id,total_oec]
  }


  measure: oec_total_with_link {
    type: sum
    value_format_name: usd
    drill_fields: [line_item_detail*]
    sql: ${total_oec} ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: order_status_formatted {
    type: string
    sql: CASE WHEN ${TABLE}."ORDER_STATUS" = 'Okay to Ship'
              THEN 'Released'
              ELSE ${TABLE}."ORDER_STATUS"
         END;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension_group: release {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RELEASE_DATE" ;;
  }

  dimension: weeks_since_release {
    sql: least(floor((CURRENT_DATE - ${TABLE}."RELEASE_DATE")/7), 5) ;;
  }

  dimension: weeks_since_invoice {
    sql: least(floor((CURRENT_DATE - ${TABLE}."INVOICE_DATE")/7), 5) ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: serial_last_5 {
    type: string
    sql: RIGHT(${TABLE}."SERIAL", 5) ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: order_number {
    type:  string
    sql:  concat(${company_purchase_order_types.prefix}, 'PO', ${TABLE}."COMPANY_PURCHASE_ORDER_ID", '-', ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER") ;;
  }

  dimension: date_marked_as_shipped {
    type: date
    sql: ${invoice_date} ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_quantity{
    type: sum
    sql: ${quantity} ;;
    drill_fields: [line_item_detail*]
  }

  measure: average_oec {
    type:  average
    value_format_name: usd
    sql: ${TABLE}."NET_PRICE" * ${TABLE}."QUANTITY" + coalesce(${TABLE}."FREIGHT_COST", 0) ;;
  }

  # used solely for redirect from shipped assets to incoming fleet dashboard, delete after 6.1.2023
  dimension: redirect_link {
    type: string
    sql: '' ;;
    html: <a href="https://equipmentshare.looker.com/dashboards/746">This information is now found in the Incoming Fleet Report. Click here to view</a>;;
  }

  dimension: sage_record_id {
    type: string
    sql: ${TABLE}."SAGE_RECORD_ID" ;;
  }
  dimension: rebate {
    type: number
    sql: ${TABLE}."REBATE" ;;
  }
  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }
  dimension: title_status {
    type: string
    # hidden: yes
    sql: ${TABLE}."TITLE_STATUS" ;;
  }
  dimension: due_date{
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: reconciliation_status_date{
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS_DATE" ;;
  }
  dimension: sales_tax {
    type: number
    sql: ${TABLE}."SALES_TAX" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: week_to_be_paid {
    type: string
    sql: ${TABLE}."WEEK_TO_BE_PAID" ;;
  }
  dimension: aftermarket_oec {
    type: number
    sql: ${TABLE}."AFTERMARKET_OEC" ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      vendors.name,
      serial,
      equipment_classes.name,
      order_number,
      year,
      equipment_makes.name,
      equipment_models.name,
      factory_build_specifications,
      attachments,
      net_price,
      quantity,
      extended_price,
      release_date,
      markets_public_rsps.name,
      order_status,
      asset_id,
      freight_cost,
      total_oec,
      invoice_number,
      invoice_date,
      finance_status,
      note
    ]
  }

  set: line_item_detail {
    fields: [
      order_number,
      vendors.name,
      serial,
      asset_id,
      equipment_classes.name,
      year,
      equipment_makes.name,
      equipment_models.name,
      factory_build_specifications,
      note,
      quantity,
      order_status,
      release_date,
      company_purchase_orders.modified_date,
      invoice_number,
      date_marked_as_shipped,
      original_promise_date,
      current_promise_date
    ]
  }
}
