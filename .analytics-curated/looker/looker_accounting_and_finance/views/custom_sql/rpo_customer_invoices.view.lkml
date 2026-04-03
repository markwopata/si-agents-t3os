view: rpo_customer_invoices {
  derived_table: {
    sql: SELECT distinct i.company_id, c.name as company, i.invoice_no, i.date_created, rpo.name as rpo_term, i.start_date, i.end_date, i.billed_amount, i.paid_date, i.owed_amount, i.billing_approved
      FROM es_warehouse.public.invoices i
      join analytics.public.v_line_items li on li.invoice_id = i.invoice_id
      join es_warehouse.public.orders o on i.order_id = o.order_id
      join es_warehouse.public.order_salespersons os on o.order_id = os.order_id
      join es_warehouse.public.companies c on c.company_id = i.company_id
      left join es_warehouse.public.rentals r ON li.rental_id = r.rental_id
      left join es_warehouse.public.rental_purchase_options rpo ON r.rental_purchase_option_id = rpo.rental_purchase_option_id
      WHERE li.line_item_type_id in (6,8,108,109)
        AND os.salesperson_type_id = 1
        AND c.name ilike '%(RPO)' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: rpo_term {
    type: string
    sql: ${TABLE}."RPO_TERM" ;;
  }

  dimension_group: start_date {
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension_group: paid_date {
    type: time
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  set: detail {
    fields: [
      company_id,
      company,
      invoice_no,
      date_created_time,
      rpo_term,
      start_date_time,
      end_date_time,
      billed_amount,
      paid_date_time,
      owed_amount,
      billing_approved
    ]
  }
}
