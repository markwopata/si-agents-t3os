
view: actively_renting_customers_during_timeframe {
  derived_table: {
    sql: with rental_info as (
      select
          u.company_id,
          c.name as company_name
      from
          es_warehouse.public.rentals r
          join es_warehouse.public.orders o on r.order_id = o.order_id
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          o.deleted = false
          and r.deleted = false
          AND r.rental_type_id <> 4 --Internal rentals
          AND r.rental_status_id not in (1,2,3,8) --1 Needs approval,2 draft,3 pending,8 cancelled
          AND
          overlaps (
          r.start_date,
          r.end_date,
          {% date_start date_filter%},
          {% date_end date_filter%}
          --'2023-08-20'::timestamp_ntz,
          --current_date::timestamp_ntz
          )
      UNION
      select
          u.company_id,
          c.name as company_name
      from
          es_warehouse.public.rentals r
          join es_warehouse.public.orders o on r.order_id = o.order_id
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          o.deleted = false
          and r.deleted = false
          AND r.rental_type_id <> 4 --Internal rentals
          AND r.rental_status_id not in (1,2,3,8) --1 Needs approval,2 draft,3 pending,8 cancelled
          AND r.start_date > current_date
          AND datediff(days,current_date,r.start_date) BETWEEN 0 AND 30
      UNION
      select
          u.company_id,
          c.name as company_name
      from
          es_warehouse.public.rentals r
          join es_warehouse.public.orders o on r.order_id = o.order_id
          join es_warehouse.public.users u on o.user_id = u.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          o.deleted = false
          and r.deleted = false
          AND r.rental_type_id <> 4 --Internal rentals
          AND r.rental_status_id not in (1,2,3,8) --1 Needs approval,2 draft,3 pending,8 cancelled
          AND r.end_date <= {% date_start date_filter%}
          AND datediff(days,{% date_start date_filter%},r.end_date) BETWEEN -30 AND 0
      )
      select
          distinct(company_id) as company_id,
          company_name
      from
          rental_info;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  measure: count_of_companies {
    type: count_distinct
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  measure: total_active_customers {
    type: count_distinct
    sql: ${company_id} ;;
  }

  set: detail {
    fields: [
        company_id,
  company_name
    ]
  }
}
