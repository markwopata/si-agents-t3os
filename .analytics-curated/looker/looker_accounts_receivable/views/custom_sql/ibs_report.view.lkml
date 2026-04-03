view: ibs_report {
  derived_table: {
    sql:
    with greensill_lender_rentals as (
    select
        r.rental_id,
        'Yes' as greensill_lender
    from
        es_warehouse.public.rentals r
        left join es_warehouse.public.asset_purchase_history aph on r.asset_id = aph.asset_id
        left join es_warehouse.public.financial_schedules f on aph.financial_schedule_id = f.financial_schedule_id
        left join es_warehouse.public.financial_lenders fl on f.originating_lender_id = fl.financial_lender_id
    where
        fl.financial_lender_id = 533
),
all_invoices as (
    --user only wants the first record for an invoice
    select
        branch,
        company_id,
        rental_customer,
        invoice_no,
        amount,
        owed_amount,
        PO,
        inv_type,
        invoice_date,
        due_date,
        rental_id,
        order_id,
        greensill_lender
    from (
          select
              distinct coalesce(m2.name, 'No Branch Assigned') as branch,
              c.company_id,
              c.name as rental_customer,
              i.invoice_no,
              i.billed_amount as amount,
              i.owed_amount as owed_amount,
              coalesce(po.name, i.reference) as PO,
              case
                  when li.line_item_type_id in (24, 50, 80, 81) then 'Equipment Sale'
                  when li.line_item_type_id in (22, 23) then 'Warranty'
                  else 'Other'
              end as inv_type,
              convert_timezone('America/Chicago', i.invoice_date)::date as invoice_date,
              convert_timezone('America/Chicago', i.due_date)::date as due_date,
              li.rental_id,
              i.order_id,
              coalesce(g.greensill_lender, 'No') as greensill_lender,
              row_number() over (partition by i.invoice_no order by li.rental_id) as row_num
          from
              es_warehouse.public.invoices i
              left join es_warehouse.public.orders o on i.order_id = o.order_id
              --left join es_warehouse.public.rentals r on i.order_id = r.order_id
              left join es_warehouse.public.line_items li on i.invoice_id = li.invoice_id
              left join greensill_lender_rentals g on li.rental_id = g.rental_id
              left join es_warehouse.public.users u on o.user_id = u.user_id
              left join es_warehouse.public.companies c on i.company_id = c.company_id
              left join es_warehouse.public.markets m on o.market_id = m.market_id
              left join es_warehouse.public.markets m2 on li.branch_id = m2.market_id
              left join es_warehouse.public.purchase_orders po on o.purchase_order_id = po.purchase_order_id
          where
              convert_timezone('America/Chicago', i.invoice_date)::date >= {% date_start date_filter %}
              and convert_timezone('America/Chicago', i.invoice_date)::date < {% date_end date_filter %}
              and o.deleted = false
              and c.company_id not in (1120, 1854, 3119, 5458, 7105, 7234)
              and li.line_item_type_id not in (10, 18, 36)
              and i.billing_approved = true
          )
          where row_num = 1
),
credit_note_inv as (
    --user only wants the first record for an invoice
    select
        branch,
        company_id,
        rental_customer,
        invoice_no,
        amount,
        owed_amount,
        PO,
        inv_type,
        invoice_date,
        due_date,
        rental_id,
        order_id,
        greensill_lender
    from (
          select
              distinct coalesce(m.name, m2.name) as branch,
              c.company_id,
              c.name as rental_customer,
              cn.credit_note_number as invoice_no,
              cn.total_credit_amount * -1 as amount,
              --i.owed_amount * -1 as owed_amount,
              --User wants the total_credit_amount to show for these, and only wants owed_amount in the final report
              --so I'm putting the total_credit_amount in the same column as the invoice's owed amount.
              --It's not great but it's what she wants.
              cn.total_credit_amount * -1 as owed_amount,
              i.invoice_no as PO,
              'Credit Note' as inv_type,
              convert_timezone('America/Chicago', cn.date_created)::date as invoice_date,
              convert_timezone('America/Chicago', i.due_date)::date as due_date,
              li.rental_id,
              i.order_id,
              coalesce(g.greensill_lender, 'No') as greensill_lender,
              row_number() over (partition by i.invoice_no order by li.rental_id) as row_num
          from
              es_warehouse.public.credit_notes cn
              left join es_warehouse.public.invoices i on cn.originating_invoice_id = i.invoice_id
              left join es_warehouse.public.orders o on i.order_id = o.order_id
              left join es_warehouse.public.line_items li on i.invoice_id = li.invoice_id
              --left join es_warehouse.public.rentals r on o.order_id = r.order_id
              left join greensill_lender_rentals g on li.rental_id = g.rental_id
              left join es_warehouse.public.users u on o.user_id = u.user_id
              left join es_warehouse.public.companies c on u.company_id = c.company_id
              left join es_warehouse.public.markets m on o.market_id = m.market_id
              left join es_warehouse.public.markets m2 on li.branch_id = m2.market_id
          where
              convert_timezone('America/Chicago', cn.date_created)::date >= {% date_start date_filter %}
              and convert_timezone('America/Chicago', cn.date_created)::date < {% date_end date_filter %}
              and cn.credit_note_type_id = 1
          order by
              credit_note_number,
              convert_timezone('America/Chicago', cn.date_created)::date
          )
    where row_num = 1
)
select
    a.*,
    coalesce(sum(cn.remaining_credit_amount), 0) as remaining_credit_amount
from
    all_invoices a
    left join es_warehouse.public.credit_notes cn on a.company_id = cn.company_id
group by
    branch,
    a.company_id,
    rental_customer,
    invoice_no,
    amount,
    owed_amount,
    PO,
    inv_type,
    invoice_date,
    due_date,
    rental_id,
    order_id,
    greensill_lender
union
select
    c.*,
    coalesce(sum(cn.remaining_credit_amount), 0) as remaining_credit_amount
from
    credit_note_inv c
    left join es_warehouse.public.credit_notes cn on c.company_id = cn.company_id
group by
    branch,
    c.company_id,
    rental_customer,
    invoice_no,
    amount,
    owed_amount,
    PO,
    inv_type,
    invoice_date,
    due_date,
    rental_id,
    order_id,
    greensill_lender
order by
    rental_customer,
    invoice_no;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: rental_customer {
    type: string
    sql: ${TABLE}."RENTAL_CUSTOMER" ;;
  }

  dimension: invoice_no {
    primary_key: yes
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: po {
    type: string
    sql: ${TABLE}."PO" ;;
  }

  dimension: inv_type {
    type: string
    sql: ${TABLE}."INV_TYPE" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: greensill_lender {
    type: string
    sql: ${TABLE}."GREENSILL_LENDER" ;;
  }

  dimension: remaining_credit_amount {
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
  }

  measure: count {
    type: count
  }

  filter: date_filter {
    type: date
  }
}
