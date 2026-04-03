view: rpo_assets_revenue {

  derived_table: {
    sql: select
a.asset_id
,askv.value as rpo_status
,i.date_created::date as date_created
,sum(li.amount ) as rental_revenue
from es_warehouse.public.assets a
left join es_warehouse.public.asset_status_key_values askv
on a.asset_id = askv.asset_id
left join es_warehouse.public.rentals r
on a.asset_id=r.asset_id
left join es_warehouse.public.orders o
on o.order_id = r.order_id
left join es_warehouse.public.line_items li
on r.rental_id=li.rental_id
left join es_warehouse.public.invoices i
on li.invoice_id=i.invoice_id
where askv.name = 'asset_inventory_status'
and askv.value like '%RPO%'
and a.company_id = 1854
and li.line_item_type_id = 8
and split_part(li.description, 'option:',2) != ' .'
and amount > 1
and (SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR'
or a.serial_number is null )
group by
a.asset_id
,askv.name
,askv.value
,i.date_created
                             ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rpo_status {
    type: string
    sql: ${TABLE}."RPO_STATUS" ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  }
