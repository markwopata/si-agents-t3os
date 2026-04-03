
view: no_rental_floater_or_rpp_charge_with_oec {
  derived_table: {
    sql: with rpp_charge as (
               select
                 c.name,
                 c.company_id,
                 sum(li.amount) as rpp_charged_amount,
                 max(i.date_created) last_invoice_created_date
               from
                  ES_WAREHOUSE.PUBLIC.orders o
                  left join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
                  left join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
                  left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
                  left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
               where
                  li.line_item_type_id = 9
               group by
                  c.name,
                  c.company_id
               ),
               rental_floater as (
               select
                 company_id,
                 RANK() OVER(
                partition by cd.company_id order by valid_until desc) as most_recent_document
               from
                 ES_WAREHOUSE.PUBLIC.company_documents cd
               where
                 company_document_type_id = 1
                 and voided = false
               ),
               oec_by_company as (
               select
               c.company_id,
               sum(aph.oec) as OEC_on_rent

               from
      es_warehouse.public.equipment_assignments ea
       left join es_warehouse.public.rentals r on r.rental_id = ea.rental_id
       left join es_warehouse.public.orders o on r.order_id = o.order_id
       left join es_warehouse.public.users u on u.user_id = o.user_id
       left join es_warehouse.public.companies c on c.company_id = u.company_id
       left join es_warehouse.public.asset_purchase_history aph on aph.asset_id = ea.asset_id
       where
       r.rental_status_id = 5
      group by
          c.company_id
               )
               select
                  rc.name,
               rc.company_id,
               rc.rpp_charged_amount,
               rc.last_invoice_created_date,
               coalesce(oc.OEC_on_rent,0) as OEC_on_rent
               from
                 rpp_charge rc
                 left join rental_floater rf on rc.company_id = rf.company_id
                 left join oec_by_company oc on rc.company_id = oc.company_id
               where
                 rf.company_id is null
                 and rc.rpp_charged_amount = 0 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: rpp_charged_amount {
    type: number
    sql: ${TABLE}."RPP_CHARGED_AMOUNT" ;;
    value_format: "$#,##0"
  }

  dimension_group: last_invoice_created_date {
    type: time
    sql: ${TABLE}."LAST_INVOICE_CREATED_DATE" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format: "$#,##0"
  }

  set: detail {
    fields: [
        name,
  company_id,
  rpp_charged_amount,
  last_invoice_created_date_time,
  oec_on_rent
    ]
  }
}
