view: intercompanyinvoices {
  derived_table: {
    sql:
      SELECT
          inv.invoice_no,
          inv.company_id,
          inv.invoice_date,
          c.name AS company_name,
          po.name AS DocNumber,
          m.name AS Market,

      lit.extended_data:part_id::NUMBER      AS part_id,
      lit.extended_data:part_number::STRING  AS part_number,
      lit.number_of_units           AS quantity,
      lit.price_per_unit            AS price_per_unit
      FROM es_warehouse.public.invoices inv
      LEFT JOIN es_warehouse.public.line_items lit
      ON lit.invoice_id = inv.invoice_id
      LEFT JOIN es_warehouse.public.companies c
      ON c.company_id = inv.company_id
      LEFT JOIN es_warehouse.public.purchase_orders po
      ON po.purchase_order_id = inv.purchase_order_id
      LEFT JOIN es_warehouse.public.orders ord
      ON ord.order_id = inv.order_id
      LEFT JOIN es_warehouse.public.markets m
      ON m.market_id = ord.market_id
      WHERE inv.company_id IN (77747, 147241, 92240)
      and inv.billing_approved = TRUE
      ;;
  }

  # ---- Dimensions ----
  dimension: invoice_number{
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: docnumber {
    type: string
    sql: ${TABLE}.DocNumber ;;
  }

  dimension: Branch {
    type: string
    sql: ${TABLE}.Market ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}.part_id ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: price_per_unit {
    type: number
    value_format_name: usd
    sql: ${TABLE}.price_per_unit ;;
  }

  dimension: extended_line_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.extended_line_amount ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.invoice_date ;;
  }

  }
