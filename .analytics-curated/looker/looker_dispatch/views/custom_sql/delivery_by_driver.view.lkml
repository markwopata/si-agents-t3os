view: delivery_by_driver {
  derived_table: {
    sql: with base as (
        select d.delivery_id,
        d.scheduled_date
        from ES_WAREHOUSE.PUBLIC.DELIVERIES d
        where driver_user_id is not null
        and d.delivery_status_id = 3
        and convert_timezone('America/Chicago', d.scheduled_date) between {% date_start date_filter %}  and dateadd(day,1,{% date_end date_filter %})
        ),
        transports as (
        select d.delivery_id,
          count(d.delivery_id) as transports
        from deliveries d left join rentals r on d.rental_id = r.rental_id
        where driver_user_id is not null
        and d.delivery_status_id = 3
        and convert_timezone('America/Chicago', d.scheduled_date) between {% date_start date_filter %}  and dateadd(day,1,{% date_end date_filter %})
        and r.rental_id is null
        group by d.delivery_id
        ),
        drop_off as (
        select  d.delivery_id,
        count(d.delivery_id) as drop_off_deliveries
        from deliveries d left join rentals r on d.rental_id = r.rental_id
        where driver_user_id is not null
        and convert_timezone('America/Chicago', d.scheduled_date) between {% date_start date_filter %}  and dateadd(day,1,{% date_end date_filter %})
        and d.delivery_status_id = 3
        and d.delivery_id = r.drop_off_delivery_id
        group by d.delivery_id
        ),
        return_delivery as (
        select d.delivery_id,
        count(d.delivery_id) as return_deliveries
        from deliveries d left join rentals r on d.rental_id = r.rental_id
        where driver_user_id is not null
        and convert_timezone('America/Chicago', d.scheduled_date) between {% date_start date_filter %}  and dateadd(day,1,{% date_end date_filter %})
        and d.delivery_status_id = 3
        and d.delivery_id = r.return_delivery_id
        group by d.delivery_id
        ),
        other_delivery as (
        select d.delivery_id,
        count(d.delivery_id) as other_deliveries
        from deliveries d left join rentals r on d.rental_id = r.rental_id
        where driver_user_id is not null
        and convert_timezone('America/Chicago', d.scheduled_date) between {% date_start date_filter %}  and dateadd(day,1,{% date_end date_filter %})
        and d.delivery_status_id = 3
        and d.delivery_id != r.return_delivery_id
        and d.delivery_id != r.drop_off_delivery_id
        group by d.delivery_id
        )
select d.delivery_id,
  u.user_id,
  concat(u.first_name, ' ', u.last_name) as driver,
  cd.employee_title,
  case when cd.employee_title ilike '%driver%' then 'Driver Title'
when cd.employee_title is null then 'Missing Title' else 'Other Title' end employee_type,
  o.market_id,
  m.name as market,
  d.scheduled_date,
  dof.drop_off_deliveries,
  rd.return_deliveries,
  od.other_deliveries,
  t.transports as transports
from base b
  left join transports t on b.delivery_id = t.delivery_id
  left join drop_off dof on b.delivery_id = dof.delivery_id
  left join return_delivery rd on b.delivery_id = rd.delivery_id
  left join other_delivery od on b.delivery_id = od.delivery_id
  left join deliveries d on d.delivery_id = b.delivery_id
  left join users u on u.user_id = d.driver_user_id
  left join analytics.payroll.company_directory cd on to_char(u.employee_id) = to_char(cd.employee_id)
  left join rentals r on d.rental_id = r.rental_id
  left  join orders o on r.order_id = o.order_id
  left join markets m on o.market_id = m.market_id
--group by d.delivery_id, u.user_id, concat(u.first_name, ' ', u.last_name), m.name,  o.market_id
order by concat(u.first_name, ' ', u.last_name);;
}

dimension: delivery_id{
  type: number
  primary_key: yes
  sql: ${TABLE}."DELIVERY_ID" ;;
}

dimension: user_id {
  type: number
  sql: ${TABLE}."USER_ID" ;;
}

dimension: driver {
  type: string
  sql: ${TABLE}."DRIVER" ;;
}

dimension: employee_type {
    type: string
    sql: ${TABLE}."employee_type" ;;
  }

dimension: market_id {
  type: number
  sql: ${TABLE}."MARKET_ID" ;;
}

dimension: market {
  type: string
  sql: ${TABLE}."MARKET" ;;
}

dimension: scheduled_date {
  type: date
  sql: ${TABLE}."SCHEDULED_DATE" ;;
}

dimension: drop_off_deliveries {
  type: number
  sql: ${TABLE}."DROP_OFF_DELIVERIES" ;;
}

dimension: return_deliveries {
  type: number
  sql: ${TABLE}."RETURN_DELIVERIES" ;;
}

dimension: other_deliveries {
  type: number
  sql: ${TABLE}."OTHER_DELIVERIES" ;;
}

dimension: transports {
  type: number
  sql: ${TABLE}."TRANSPORTS" ;;
}

measure: drop_off_deliveries_count {
  type: sum
  sql: ${TABLE}."DROP_OFF_DELIVERIES" ;;
}

measure: return_deliveries_count {
  type: sum
  sql: ${TABLE}."RETURN_DELIVERIES" ;;
}

measure: other_deliveries_count {
  type: sum
  sql: ${TABLE}."OTHER_DELIVERIES" ;;
}

measure: transports_count {
  type: sum
  sql: ${TABLE}."TRANSPORTS" ;;
}

filter: date_filter {
  type: date
}

}
