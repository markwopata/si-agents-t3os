view: credit_specialist_onboarding {
  derived_table: {
    sql: with check_all_rentals as (
    select c.company_id::int as company_id
         , c.name            as company_name
         , min(r.rental_id) as first_rental_id
        ,min(r.START_DATE)::date as rental_start_date
    from ES_WAREHOUSE.public.assets a
             left join ES_WAREHOUSE.public.rentals r
                       on a.asset_id = r.asset_id
             left join ES_WAREHOUSE.PUBLIC.RENTAL_STATUSES rs
                       on r.RENTAL_STATUS_ID = rs.RENTAL_STATUS_ID
             left join ES_WAREHOUSE.public.orders o
                       on o.order_id = r.order_id
             left join ES_WAREHOUSE.public.markets m
                       on o.market_id = m.market_id
             left join ES_WAREHOUSE.public.users cu
                       on o.user_id = cu.user_id
             left join ANALYTICS.public.v_line_items li
                       on r.rental_id = li.rental_id
             left join ES_WAREHOUSE.public.invoices i
                       on li.invoice_id = i.invoice_id
             left join ES_WAREHOUSE.public.users u
                       on i.salesperson_user_id = u.user_id
             left join ES_WAREHOUSE.public.companies c
                       on cu.company_id = c.company_id
    where --date_trunc('quarter',current_timestamp()::date - interval '6 months') <= i.date_created::date
            (current_timestamp()::date - interval '1 year') <= i.date_created::date
      and line_item_type_id in (6,8,108,109)
      and split_part(li.description, 'option:', 2) != ' .'
      and amount > 1
      and (SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
        or SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR'
        or a.serial_number is null)
      and m.company_id = 1854
      and m.is_public_rsp = true
    and rs.RENTAL_STATUS_ID != 8
    group by c.company_id
         , c.name
)
, check_all_invoices as (
    select c.company_id::int as company_id
         , c.name            as company_name
         , min(i.INVOICE_ID) as first_invoice_id
        ,min(i.START_DATE)::date as invoice_start_date
--     ,rs.NAME as rental_status
    from ES_WAREHOUSE.public.assets a
             left join ES_WAREHOUSE.public.rentals r
                       on a.asset_id = r.asset_id
             left join ES_WAREHOUSE.PUBLIC.RENTAL_STATUSES rs
                       on r.RENTAL_STATUS_ID = rs.RENTAL_STATUS_ID
             left join ES_WAREHOUSE.public.orders o
                       on o.order_id = r.order_id
             left join ES_WAREHOUSE.public.markets m
                       on o.market_id = m.market_id
             left join ES_WAREHOUSE.public.users cu
                       on o.user_id = cu.user_id
             left join ANALYTICS.public.v_line_items li
                       on r.rental_id = li.rental_id
             left join ES_WAREHOUSE.public.invoices i
                       on li.invoice_id = i.invoice_id
             left join ES_WAREHOUSE.public.users u
                       on i.salesperson_user_id = u.user_id
             left join ES_WAREHOUSE.public.equipment_classes_models_xref x
                       on a.equipment_model_id = x.equipment_model_id
             left join ES_WAREHOUSE.public.companies c
                       on cu.company_id = c.company_id
    where --date_trunc('quarter',current_timestamp()::date - interval '6 months') <= i.date_created::date
            (current_timestamp()::date - interval '1 year') <= i.date_created::date
      and line_item_type_id in (6,8,108,109)
      and split_part(li.description, 'option:', 2) != ' .'
      and amount > 1
      and (SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
        or SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR'
        or a.serial_number is null)
      and m.company_id = 1854
      and m.is_public_rsp = true
    and rs.RENTAL_STATUS_ID != 8
    group by c.company_id
         , c.name
)
, check_payments as( select c.company_id::int as company_id
         , c.name            as company_name
                          ,case when(min(pa.date) < min(p.date_created)) then min(pa.PAYMENT_ID) else min(p.PAYMENT_ID) end as first_payment_id
                          ,case when(min(pa.date) < min(p.date_created)) then min(pa.date)::date else min(p.date_created)::date end as first_payment_date
--     ,rs.NAME as rental_status
    from ES_WAREHOUSE.public.assets a
             left join ES_WAREHOUSE.public.rentals r
                       on a.asset_id = r.asset_id
             left join ES_WAREHOUSE.PUBLIC.RENTAL_STATUSES rs
                       on r.RENTAL_STATUS_ID = rs.RENTAL_STATUS_ID
             left join ES_WAREHOUSE.public.orders o
                       on o.order_id = r.order_id
             left join ES_WAREHOUSE.public.markets m
                       on o.market_id = m.market_id
             left join ES_WAREHOUSE.public.users cu
                       on o.user_id = cu.user_id
             left join ANALYTICS.public.v_line_items li
                       on r.rental_id = li.rental_id
             left join ES_WAREHOUSE.public.invoices i
                       on li.invoice_id = i.invoice_id
             left join ES_WAREHOUSE.public.companies c
                       on cu.company_id = c.company_id
            left join ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS pa
                        on i.INVOICE_ID=pa.INVOICE_ID
            left join es_warehouse.public.payments p
                        on c.COMPANY_ID=p.COMPANY_ID
    where --date_trunc('quarter',current_timestamp()::date - interval '6 months') <= i.date_created::date
            (current_timestamp()::date - interval '1 year') <= i.date_created::date
      and line_item_type_id in (6,8,108,109)
      and split_part(li.description, 'option:', 2) != ' .'
      and li.amount > 1
      and (SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
        or SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR'
        or a.serial_number is null)
      and m.company_id = 1854
      and m.is_public_rsp = true
    and rs.RENTAL_STATUS_ID != 8
    group by c.company_id
         , c.name
)
select
       c.COMPANY_ID
,c.name as company_name
,car.first_rental_id
,car.rental_start_date
,cai.first_invoice_id
,cai.invoice_start_date
,cp.first_payment_id
,cp.first_payment_date
from ES_WAREHOUSE.PUBLIC.COMPANIES c
    left join check_all_rentals car
        on c.COMPANY_ID=car.company_id
    left join check_all_invoices cai
        on c.COMPANY_ID=cai.company_id
    left join check_payments cp
        on c.COMPANY_ID=cp.company_id
where car.first_rental_id is not null
and cai.first_invoice_id is not null
and cp.first_payment_id is not null
      ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: first_rental_id {
    type: number
    sql: ${TABLE}."FIRST_RENTAL_ID" ;;
  }

  dimension_group: rental_start {
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
    sql: CAST(${TABLE}."RENTAL_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: first_invoice_id {
    type: number
    sql: ${TABLE}."FIRST_INVOICE_ID" ;;
  }

  dimension_group: invoice_start {
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
    sql: CAST(${TABLE}."INVOICE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: first_payment_id {
    type: number
    sql: ${TABLE}."FIRST_PAYMENT_ID" ;;
  }

  dimension_group: payment {
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
    sql: CAST(${TABLE}."FIRST_PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

}
