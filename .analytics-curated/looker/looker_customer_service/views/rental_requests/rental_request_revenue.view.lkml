view: rental_request_revenue {
  derived_table: {
    sql: with total_billed as
(
select

sum(i.billed_amount) as total_billed

from
es_warehouse.public.orders o
left join quotes.quotes.quote q on q.order_id = o.order_id
left join es_warehouse.public.invoices i on i.order_id = o.order_id
where
(q.sales_rep_id = 6052
and o.date_created >= '2024-09-01')
--or
--(q.sales_rep_id = 171481
--and o.date_created >= '2024-10-15')
)
select
o.date_created as order_date_created
, q.contact_name
, case when q.sales_rep_id = 171481 then 'Tanner Jones' else 'Amy Howard' end as Sales_Rep_Name
, case when q.sales_rep_id in (6052, 171481) then 'Amy/Tanner' else 'TAMs' end as rep_group
, o.order_id
, i.date_created as invoice_date_created
, i.billing_approved_date as invoice_billed_date
, i.invoice_id
, rr.created_at as request_create_date
, rr.order_total as request_total
, rr.id as rental_request_id
, q.quote_number
, q.branch_id
, q.sales_rep_id
, i.billed_amount
, i.paid
, i.paid_date
, r.rental_id
, r.rental_status_id
, r.asset_id
, rs.name as current_rental_status
, aph.oec
, tb.total_billed
, 1 as counter
from
quotes.quotes.quote q
left join es_warehouse.public.orders o on q.order_id = o.order_id
left join rental_order_request.public.rental_requests rr on q.id = rr.quote_id
left join es_warehouse.public.invoices i on i.order_id = o.order_id
left join es_warehouse.public.rentals r on r.order_id = o.order_id
left join es_warehouse.public.rental_statuses rs on r.rental_status_id = rs.rental_status_id
left join es_warehouse.public.assets a on r.asset_id = a.asset_id
LEFT JOIN es_warehouse.public.asset_purchase_history aph ON aph.asset_id = a.asset_id
cross join total_billed tb
where
--(q.sales_rep_id = 6052 and
q.created_date >= '2024-09-01'
--)
--or
--(q.sales_rep_id = 171481
--and o.date_created >= '2024-10-15')

;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."ORDER_DATE_CREATED" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: request_create_date {
    type: date
    sql: ${TABLE}."REQUEST_CREATE_DATE" ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  dimension: rental_request_id {
    type: number
    sql: ${TABLE}."RENTAL_REQUEST_ID" ;;
  }

  dimension: quote_number {
    type: number
    sql: ${TABLE}."QUOTE_NUMBER" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: sales_rep_id {
    type: number
    sql: ${TABLE}."SALES_REP_ID" ;;
  }

  dimension: sales_rep_name {
    type: string
    sql: ${TABLE}."SALES_REP_NAME" ;;
  }

  dimension: rep_group {
    type: string
    sql: ${TABLE}."REP_GROUP" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid_date {
    type: time
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: current_rental_status {
    type: string
    sql: ${TABLE}."CURRENT_RENTAL_STATUS" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: total_billed {
    type: number
    sql: ${TABLE}."TOTAL_BILLED" ;;
  }

  dimension: counter {
    type: number
    sql: ${TABLE}."COUNTER" ;;
  }

  measure: invoice_billed_amount{
    type: number
    value_format_name: usd_0
    sql: sum(${total_billed}) / sum(${counter}) ;;
  }

  measure: rental_requests{
    type: count_distinct
    sql: ${rental_request_id} ;;
  }

  measure: quotes{
    type: count_distinct
    sql: ${quote_number} ;;
  }

  measure: orders{
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: rented_assets {
    type: count_distinct
    sql: ${rental_id} ;;
  }

  measure: invoices{
    type: count_distinct
    sql: ${invoice_id} ;;
  }

  measure: order_conversion_percent{
    type: number
    value_format_name: percent_1
    sql: ${orders} / ${quotes} ;;
  }

  measure: on_rent_assets{
    type: sum
    value_format_name: decimal_0
    filters: [rental_status_id: "5", sales_rep_id: "6052, 171481"]
    sql: ${counter} ;;
  }

  measure: on_rent_oec{
    type: sum
    value_format_name: usd_0
    filters: [rental_status_id: "5", sales_rep_id: "6052, 171481"]
    sql: ${oec} ;;
  }

  measure: billed_amount_by_month{
    type: sum
    value_format_name: usd_0
    filters: [current_rental_status: "Billed, On Rent", sales_rep_id: "6052, 171481"]
    sql: ${billed_amount} ;;

  }

    set: detail {
      fields: [
        date_created_time,
        order_id,
        invoice_id,
        request_create_date,
        request_total,
        rental_request_id,
        quote_number,
        branch_id,
        sales_rep_id,
        sales_rep_name,
        billed_amount,
        paid,
        paid_date_time,
        rental_id,
        rental_status_id,
        asset_id,
        current_rental_status,
        oec,
        total_billed
      ]
    }
  }
