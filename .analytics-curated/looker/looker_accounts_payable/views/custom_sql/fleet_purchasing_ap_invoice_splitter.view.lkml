view: fleet_purchasing_ap_invoice_splitter {
  derived_table: {
    sql: Select
          concat(cpot.prefix,'PO',sub.company_purchase_order_id) as"PO",
          sub.asset_id,
          sub.serial,
          sub.market_id,
          sub.invoice_date,
          cpo.vendor_id,
          cp.name as "VENDOR_NAME",
          fpsvm.vendor_sage_id as "SAGE_VENDOR_ID",
          C.value::string as Invoice_Number,
          row_number() over(
          partition by Invoice_Number order by Invoice_Number) line_no,
          to_number(sub.net_price*sub.quantity + ifnull(sub.freight_cost,0) + ifnull(sub.sales_tax,0) + ifnull(sub.rebate,0),38,2) as "TOTAL_OEC",
          a.asset_class,
          sub.year,
          a.make,
          a.model,
          sub.factory_build_specifications,
          m.name as "MARKET_NAME",
          to_date(cpo.created_at) as "PURCHASE_CREATED_DATE"

      from (
      SELECT
      company_purchase_order_id,
      asset_id,
      year,
      factory_build_specifications,
      serial,
      market_id,
      invoice_date,
      REPLACE("ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS".invoice_number,' ','')AS "NSINVOICE_NUMBER",
      net_price,
      quantity,
      freight_cost,
      tax,
      sales_tax,
      rebate
      FROM "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS"
      WHERE "NSINVOICE_NUMBER" IS NOT NULL
      and asset_id IS NOT NULL
      )sub

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDERS" cpo
      on cpo.company_purchase_order_id = sub.company_purchase_order_id

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_TYPES" cpot
      on cpot.company_purchase_order_type_id = cpo.company_purchase_order_type_id

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" a
      on a.asset_id = sub.asset_id

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" m
      on m.market_id = sub.market_id

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" cp
      on cpo.vendor_id = cp.company_id

      LEFT JOIN "ANALYTICS"."GS"."FLEET_PURCHASING_SAGE_VENDOR_MAPPING" fpsvm
      on cp.name = fpsvm.vendor_ft,

      lateral flatten(input=>split(NSINVOICE_NUMBER, '/')) C
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po {
    type: string
    sql: ${TABLE}."PO" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: line_no {
    type: number
    sql: ${TABLE}."LINE_NO" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: purchase_created_date {
    type: date
    sql: ${TABLE}."PURCHASE_CREATED_DATE" ;;
  }

  set: detail {
    fields: [
      po,
      asset_id,
      serial,
      market_id,
      invoice_date,
      vendor_id,
      vendor_name,
      sage_vendor_id,
      invoice_number,
      line_no,
      total_oec,
      asset_class,
      year,
      make,
      model,
      factory_build_specifications,
      market_name,
      purchase_created_date
    ]
  }
}
