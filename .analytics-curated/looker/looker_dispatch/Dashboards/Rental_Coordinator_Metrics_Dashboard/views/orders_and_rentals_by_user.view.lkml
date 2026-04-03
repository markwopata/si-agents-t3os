view: orders_and_rentals_by_user {
  derived_table: {
    sql:
      WITH rentals AS (SELECT user_id,
                          COUNT(IFF(date_created >= DATEADD('day', -1, current_date()), rental_id,
                                    NULL))                                                               AS total_rentals_1_day,
                          COUNT(IFF(date_created >= DATEADD('day', -7, current_date()), rental_id,
                                    NULL))                                                               AS total_rentals_7_days,
                          COUNT(IFF(date_created >= DATEADD('day', -30, current_date()), rental_id,
                                    NULL))                                                               AS total_rentals_30_days,
                          COUNT(rental_id)                                                               AS total_rentals
                     FROM analytics.public.rentals_by_user
                    WHERE {% condition date_created %} date_created {% endcondition %}
                    GROUP BY user_id),

       orders  AS (SELECT user_id,
                          COUNT(IFF(date_created >= DATEADD('day', -1, current_date()), order_id,
                                    NULL))                                                              AS total_orders_1_day,
                          COUNT(IFF(date_created >= DATEADD('day', -7, current_date()), order_id,
                                    NULL))                                                              AS total_orders_7_days,
                          COUNT(IFF(date_created >= DATEADD('day', -30, current_date()), order_id,
                                    NULL))                                                              AS total_orders_30_days,
                          COUNT(order_id)                                                               AS total_orders
                     FROM analytics.public.orders_by_user
                    WHERE {% condition date_created %} date_created {% endcondition %}
                    GROUP BY user_id)

SELECT o.user_id,
       CONCAT(u.first_name, ' ', u.last_name) AS employee_name,
       o.total_orders_1_day,
       r.total_rentals_1_day,
       o.total_orders_7_days,
       r.total_rentals_7_days,
       o.total_orders_30_days,
       r.total_rentals_30_days,
       o.total_orders,
       r.total_rentals

  FROM orders o
           INNER JOIN rentals r
                      ON o.user_id = r.user_id
           INNER JOIN es_warehouse.public.users u
                      ON o.user_id = u.user_id
           LEFT OUTER JOIN analytics.payroll.company_directory cd
                           ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
 WHERE u.company_id = 1854
   AND NOT u.deleted
   AND cd.employee_status <> 'Terminated'
;;
  }

  filter: date_created {
    type: date
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
    }

  dimension: total_orders_1_day {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS_1_DAY" ;;
    }

  dimension: total_rentals_1_day {
    type: number
    sql: ${TABLE}."TOTAL_RENTALS_1_DAY" ;;
    }

  dimension: total_orders_7_days {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS_7_DAYS" ;;
    }

  dimension: total_rentals_7_days {
    type: number
    sql: ${TABLE}."TOTAL_RENTALS_7_DAYS" ;;
    }

  dimension: total_orders_30_days {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS_30_DAYS" ;;
    }

  dimension: total_rentals_30_days {
    type: number
    sql: ${TABLE}."TOTAL_RENTALS_30_DAYS" ;;
    }

  dimension: total_orders {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS" ;;
  }

  dimension: total_rentals {
    type: number
    sql: ${TABLE}."TOTAL_RENTALS" ;;
    }

    # - - - - - MEASURES - - - - -

    measure: sum_orders {
      type: sum
      sql: ${total_orders} ;;
    }

    measure: sum_rentals {
      type: sum
      sql: ${total_rentals} ;;
    }
}
