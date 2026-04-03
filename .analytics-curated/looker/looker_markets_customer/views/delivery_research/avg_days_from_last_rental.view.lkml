
view: avg_days_from_last_rental {
  derived_table: {
    sql: with days_since_last_rental as (
      select
          c.company_id,
          c.name as company_name,
          r.date_created::date as rental_date_created,
          r.rental_id,
          dateadd('day', datediff('day',r.date_created::date, LAG(r.date_created::date) OVER (PARTITION BY c.company_id ORDER BY r.date_created)), r.date_created::date) as previous_rental_date,
          datediff(days,dateadd('day', datediff('day',r.date_created::date, LAG(r.date_created::date) OVER (PARTITION BY c.company_id ORDER BY r.date_created)), r.date_created::date),r.date_created::date) as days_from_last_rental
      from
          ES_WAREHOUSE.PUBLIC.rentals r
          left join orders o on r.order_id = o.order_id
          left join users u on u.user_id = o.user_id
          left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
         --r.date_created between '2023-08-20' AND current_date
         r.date_created BETWEEN {% date_start date_filter%} AND {% date_end date_filter%}
         AND r.rental_status_id not in (1,2,3,4,8)
         AND r.rental_type_id <> 4
      )
      select
          company_id,
          company_name,
          avg(days_from_last_rental) as avg_days_from_last_rental
      from
          days_since_last_rental
      group by
          company_id,
          company_name ;;
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

  dimension: avg_days_from_last_rental {
    type: number
    sql: ${TABLE}."AVG_DAYS_FROM_LAST_RENTAL" ;;
  }

  measure: average_days_between_rentals {
    type: average
    sql: ${avg_days_from_last_rental} ;;
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  set: detail {
    fields: [
        company_id,
  avg_days_from_last_rental
    ]
  }
}
