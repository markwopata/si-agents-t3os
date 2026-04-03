#
# The purpose of this view is to genericize the company data pulls currently in the Exxon Data Pull folder.
# Rather than a new custom sql view for each company request, this is a generic version of the last iteration:
# /views/custom_sql/ascend_on_off_rent_with_spend.view.lkml
# Requirements are per Brittanie McInnis as of 2023.04.28.
#
# Related Story:
#   [https://app.shortcut.com/businessanalytics/story/257851/data-pull-export-tool-add-deer-park-brittanie-mcinnis]
#
#
# Britt Shanklin | Built 2023-04-28

view: company_on_off_rent_with_spend {
  derived_table: {
    sql: SELECT
          r.rental_id,
          o.order_id,
          r.asset_id as rental_asset_id,
          coalesce(a.asset_class,pt.description,' ') as asset_class,
          coalesce(amt.purchase_order,po.name) as purchase_order_name,
          r.start_date::date as rental_start_date,
          ac.end_this_rental_cycle::date as scheduled_off_rent_date,
          ac.next_cycle_inv_date::date::date as next_cycle_date,
          ac.total_days_on_rent,
          ac.days_left as billing_days_left,
          round(coalesce(amt.amount,0)+coalesce(case when coalesce(amt.purchase_order,po.name) <> po.name then 0 else rrc.cheapest_option end,0),2) as to_date_rental,
          'On Rent' as rental_status,
          c.company_id,
          c.name as company_name,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month,
          coalesce(r.quantity,1) as quantity,
          --l.nickname as jobsite
          l.jobsite,
          concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
          m.name as order_branch_location
      from
          es_warehouse.public.rentals r
          left join es_warehouse.public.assets a on a.asset_id = r.asset_id
          left join es_warehouse.public.admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = r.asset_id
          left join es_warehouse.public.orders o on r.order_id = o.order_id
          left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          left join
          (
          select
                  r.rental_id,
                  po.name as purchase_order,
                  sum(li.amount) as amount
              from
                  es_warehouse.public.orders o
                  join es_warehouse.public.rentals r on o.order_id = r.order_id
                  join analytics.public.v_line_items li on r.rental_id = li.rental_id
                  left join es_warehouse.public.users u on u.user_id = o.user_id
                  join es_warehouse.public.companies c on c.company_id = u.company_id
                  left join es_warehouse.public.invoices i on i.invoice_id = li.invoice_id
                  left join es_warehouse.public.purchase_orders po on po.purchase_order_id = i.purchase_order_id
              where
                  {% condition company_id %} c.company_id {% endcondition %}
              group by
                  r.rental_id, po.name
          ) amt on amt.rental_id = r.rental_id
          left join es_warehouse.public.remaining_rental_cost rrc on rrc.rental_id = r.rental_id and o.purchase_order_id = po.purchase_order_id
          --left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
          left join (select r.rental_id, listagg(l.nickname,', ') as jobsite
                     from es_warehouse.public.rentals r
                     left join es_warehouse.public.orders o on r.order_id = o.order_id
                     left join es_warehouse.public.users u on u.user_id = o.user_id
                     left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
                     left join es_warehouse.public.locations l on l.location_id = rla.location_id
                     where
                     {% condition company_id %} u.company_id {% endcondition %}
                     --and
                     --r.rental_id = 5
                     group by
                     r.rental_id
                    ) l on l.rental_id = r.rental_id
          --left join es_warehouse.public.locations l on l.location_id = rla.location_id
          left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
          left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
          left join es_warehouse.public.markets m on m.market_id = o.market_id
      where
          {% condition company_id %} po.company_id {% endcondition %}
          AND {% condition company_id %} c.company_id {% endcondition %}
          AND (
          r.rental_status_id = 5
          OR (r.rental_status_id = 5 AND r.asset_id is null)
          )
      union
      select
          r.rental_id,
          o.order_id,
          r.asset_id,
          coalesce(a.asset_class,pt.description,' ') as asset_class,
          coalesce(amt.purchase_order,po.name) as purchase_order_name,
          r.start_date::date as rental_start_date,
          NULL,
          NULL,
          NULL,
          NULL,
          round(coalesce(amt.amount,0),2),
          'Off Rent',
          c.company_id,
          c.name,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month,
          coalesce(r.quantity,1) as quantity,
          --l.nickname as jobsite
          l.jobsite,
          concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
          m.name as order_branch_location
      from
          es_warehouse.public.rentals r
          left join es_warehouse.public.orders o on r.order_id = o.order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          left join es_warehouse.public.assets a on r.asset_id = a.asset_id
          left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join
          (
          select
                  r.rental_id,
                  po.name as purchase_order,
                  sum(li.amount) as amount
              from
                  es_warehouse.public.orders o
                  join es_warehouse.public.rentals r on o.order_id = r.order_id
                  join analytics.public.v_line_items li on r.rental_id = li.rental_id
                  left join es_warehouse.public.users u on u.user_id = o.user_id
                  join es_warehouse.public.companies c on c.company_id = u.company_id
                  left join es_warehouse.public.invoices i on i.invoice_id = li.invoice_id
                  left join es_warehouse.public.purchase_orders po on po.purchase_order_id = i.purchase_order_id
              where
                  {% condition company_id %} c.company_id {% endcondition %}
              group by
                  r.rental_id, po.name
          ) amt on amt.rental_id = r.rental_id
          --left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
          --left join es_warehouse.public.locations l on l.location_id = rla.location_id
          left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
          left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
          left join (select r.rental_id, listagg(l.nickname,', ') as jobsite
                     from es_warehouse.public.rentals r
                     left join es_warehouse.public.orders o on r.order_id = o.order_id
                     left join es_warehouse.public.users u on u.user_id = o.user_id
                     left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
                     left join es_warehouse.public.locations l on l.location_id = rla.location_id
                     where
                     {% condition company_id %} u.company_id {% endcondition %}
                     --and
                     --r.rental_id = 5
                     group by
                     r.rental_id
                    ) l on l.rental_id = r.rental_id
          left join es_warehouse.public.markets m on m.market_id = o.market_id
      where
        overlaps(
              '2021-01-01',
              current_date,
              r.start_date::date,
              r.end_date::date
          )
        and {% condition company_id %} u.company_id {% endcondition %}
        and {% condition company_id %} po.company_id {% endcondition %}
        and (
        r.rental_status_id <> 5
        OR (r.rental_status_id <> 5 and r.asset_id is null)
        )
       ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
  }

  dimension: rental_asset_id {
    type: number
    sql: ${TABLE}."RENTAL_ASSET_ID" ;;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: scheduled_off_rent_date {
    type: date
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
  }

  dimension: next_cycle_date {
    type: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }

  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }

  dimension: billing_days_left {
    type: number
    sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
  }

  dimension: to_date_rental {
    type: number
    sql: ${TABLE}."TO_DATE_RENTAL" ;;
    value_format_name: usd
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: order_by_with_phone_number {
    type: string
    sql: ${TABLE}."ORDER_BY_WITH_PHONE_NUMBER" ;;
  }

  dimension: order_branch_location {
    type: string
    sql: ${TABLE}."ORDER_BRANCH_LOCATION" ;;
  }

  set: detail {
    fields: [
      rental_id,
      order_id,
      rental_asset_id,
      asset_class,
      purchase_order_name,
      rental_start_date,
      scheduled_off_rent_date,
      next_cycle_date,
      total_days_on_rent,
      billing_days_left,
      to_date_rental,
      rental_status,
      company_name,
      price_per_day,
      price_per_week,
      price_per_month,
      quantity,
      jobsite
    ]
  }
}
