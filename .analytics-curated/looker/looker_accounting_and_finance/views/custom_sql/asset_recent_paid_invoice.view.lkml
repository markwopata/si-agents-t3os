view: asset_recent_paid_invoice {
  derived_table: {
    sql: with all_invoices as(
select
a.asset_id
, i.date_created::date as date_created
, i.invoice_id
, i.invoice_no
, i.billed_amount
, i.paid
, i.paid_date::date as paid_date
,ROW_NUMBER() OVER (PARTITION BY a.asset_id ORDER BY i.date_created DESC) AS rn
from ES_WAREHOUSE.public.assets a
left join ES_WAREHOUSE.public.rentals r
on a.asset_id=r.asset_id
left join ES_WAREHOUSE.public.orders o
on o.order_id = r.order_id
left join ES_WAREHOUSE.public.line_items li
on r.rental_id=li.rental_id
left join ES_WAREHOUSE.public.invoices i
on li.invoice_id=i.invoice_id
where line_item_type_id = 8
and i.billed_amount > 0
and (i.paid = true or i.owed_amount = 0)
order by asset_id, date_created desc
)
select
*
from all_invoices
where rn= 1
     ;;
   }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: admin_link_to_invoice {
    label: "Admin Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }


 }
