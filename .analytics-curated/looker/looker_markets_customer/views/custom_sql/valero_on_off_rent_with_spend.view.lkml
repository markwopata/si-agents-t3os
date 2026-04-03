view: valero_on_off_rent_with_spend {
  derived_table: {
    sql: SELECT
          r.rental_id,
          o.order_id,
          r.asset_id as rental_asset_id,
          a.asset_class,
          po.name as purchase_order_name,
          r.start_date::date as rental_start_date,
          ac.end_this_rental_cycle::date as scheduled_off_rent_date,
          ac.next_cycle_inv_date::date::date as next_cycle_date,
          ac.total_days_on_rent,
          ac.days_left as billing_days_left,
          round(coalesce(amt.amount,0)+coalesce(rrc.cheapest_option,0),2) as to_date_rental,
          'On Rent' as rental_status,
          c.name as company_name,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month
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
                  sum(li.amount) as amount
              from
                  es_warehouse.public.orders o
                  join es_warehouse.public.rentals r on o.order_id = r.order_id
                  join es_warehouse.public.line_items li on r.rental_id = li.rental_id
              group by
                  r.rental_id
          ) amt on amt.rental_id = r.rental_id
          left join es_warehouse.public.remaining_rental_cost rrc on rrc.rental_id = r.rental_id
      where
          po.company_id in (select company_id from es_warehouse.public.companies where company_id = 47388)
          AND c.company_id in (select company_id from es_warehouse.public.companies where company_id = 47388)
          AND (
          r.rental_status_id = 5
          OR (r.rental_status_id = 5 AND r.asset_id is null)
          )
      union
      select
          r.rental_id,
          o.order_id,
          r.asset_id,
          a.asset_class,
          po.name as purchase_order_name,
          r.start_date::date as rental_start_date,
          NULL,
          NULL,
          NULL,
          NULL,
          round(coalesce(amt.amount,0),2),
          'Off Rent',
          c.name,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month
      from
          es_warehouse.public.rentals r
          left join es_warehouse.public.orders o on r.order_id = o.order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join es_warehouse.public.assets a on r.asset_id = a.asset_id
          left join (
          select
                  r.rental_id,
                  sum(li.amount) as amount
              from
                  es_warehouse.public.orders o
                  join es_warehouse.public.rentals r on o.order_id = r.order_id
                  join es_warehouse.public.line_items li on r.rental_id = li.rental_id
              group by
                  r.rental_id
          ) amt on amt.rental_id = r.rental_id
      where
        overlaps(
              '2021-01-01',
              current_date,
              r.start_date::date,
              r.end_date::date
          )
        and u.company_id in (select company_id from es_warehouse.public.companies where company_id = 47388)
        and po.company_id in (select company_id from es_warehouse.public.companies where company_id = 47388)
        and (
        r.rental_status_id <> 5
        OR (r.rental_status_id <> 5 and r.asset_id is null)
        )
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: rental_asset_id {
    type: number
    sql: ${TABLE}."RENTAL_ASSET_ID" ;;
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
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
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
      company_name
    ]
  }
}
