
view: active_total_rentals_by_company {
  derived_table: {
    sql: select
          u.company_id,
          c.name as company_name,
          sum(case when rental_status_id = 5 then 1 end) as total_active_rentals,
          count(*) as total_company_rentals
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
          {% date_start date_filter %}::timestamp_tz,
          {% date_end date_filter %}::timestamp_tz
          )
      group by
          u.company_id,
          c.name ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: total_active_rentals {
    type: number
    sql: ${TABLE}."TOTAL_ACTIVE_RENTALS" ;;
  }

  dimension: total_company_rentals {
    type: number
    sql: ${TABLE}."TOTAL_COMPANY_RENTALS" ;;
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  measure: total_on_rent_rentals {
    type: sum
    sql: ${total_active_rentals} ;;
  }

  measure: total_rentals {
    type: sum
    sql: ${total_company_rentals} ;;
  }

  set: detail {
    fields: [
        company_id,
  company_name,
  total_active_rentals,
  total_company_rentals
    ]
  }
}
