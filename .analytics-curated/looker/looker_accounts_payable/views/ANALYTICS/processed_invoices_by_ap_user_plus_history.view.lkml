view: processed_invoices_by_ap_user_plus_history  {
    derived_table: {
      sql: WITH
    starting_data AS (
    select * from(
    SELECT SUBMITTER, SUBMIT_DATE, COUNT(*) AS num_submissions
    FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER
    GROUP BY SUBMITTER, SUBMIT_DATE

    UNION
    SELECT SUBMITTER, DATE AS SUBMIT_DATE, COUNT AS num_submissions
    FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER_HISTORY
    WHERE num_submissions > 0     GROUP BY SUBMITTER, DATE, COUNT
)--where SUBMITTER in ('Abdelgadir, Amar',
--'Allen, Misty',
--'Bonney, Lindsay',
--'Davis, Brent',
--'Falcone, Madison',
--'Morales, Carlos Fiallo',
--'Romero, Marilyn',
--'System, Concur',
--'Tubbs, Edith',
--'Meketsy, Ellyn',
--'Sobba, Robin',
--'Woodruff, Haley',
--'Hartz, Andrea',
--'Kelly, Katrina',
--'Lawe, Tracie',
--'Johnson, Raeshashan',
--'Drummond, Mylin',
--'Gipson, Jessica',
--'Davenport, Mary',
--'White, TyAmber',
--'Fulton, Cindy')
),
  thirty_days AS (
    SELECT
      SUBMITTER,
      sum(num_submissions) AS num_submissions,
      COUNT(DISTINCT TRUNC(CAST(SUBMIT_DATE AS TIMESTAMP), 'DD')) AS num_working_days
    FROM starting_data
    WHERE SUBMIT_DATE >= DATEADD(DAY, -30, CURRENT_DATE())
    GROUP BY SUBMITTER
  ),
  sixty_days AS (
    SELECT
      SUBMITTER,
      sum(num_submissions) AS num_submissions,
      COUNT(DISTINCT TRUNC(CAST(SUBMIT_DATE AS TIMESTAMP), 'DD')) AS num_working_days
    FROM starting_data
    WHERE SUBMIT_DATE >= DATEADD(DAY, -60, CURRENT_DATE())
    GROUP BY SUBMITTER
  ),
  current_year AS (
    SELECT
      SUBMITTER,
      sum(num_submissions) AS num_submissions,
      COUNT(DISTINCT TRUNC(CAST(SUBMIT_DATE AS TIMESTAMP), 'YEAR')) AS num_working_days
    FROM starting_data
    WHERE YEAR(SUBMIT_DATE) = YEAR(CURRENT_DATE())
    GROUP BY SUBMITTER
  ),
    current_year_b AS (
    SELECT
      SUBMITTER,
      sum(num_submissions) AS num_submissions,
      COUNT(DISTINCT TRUNC(CAST(SUBMIT_DATE AS TIMESTAMP), 'DD')) AS num_working_days
    FROM starting_data
    WHERE YEAR(SUBMIT_DATE) = YEAR(CURRENT_DATE())
    GROUP BY SUBMITTER
  ),
  averages AS (
    SELECT
      thirty_days.SUBMITTER,
      thirty_days.num_submissions / thirty_days.num_working_days AS thirty_day_moving_avg,
      sixty_days.num_submissions / sixty_days.num_working_days AS sixty_day_moving_avg,
      current_year_b.num_submissions / current_year_b.num_working_days AS current_year_avg,
      current_year.num_submissions AS current_year_submissions,
      AVG(current_year.num_submissions / current_year.num_working_days) OVER () AS avg_daily_submissions
    FROM thirty_days
    LEFT JOIN sixty_days ON thirty_days.SUBMITTER = sixty_days.SUBMITTER
    LEFT JOIN current_year_b ON thirty_days.SUBMITTER = current_year_b.SUBMITTER
    LEFT JOIN current_year ON thirty_days.SUBMITTER = current_year.SUBMITTER
  ),
  total_avg AS (
    SELECT
      SUM(thirty_day_moving_avg) AS thirty_day_total,
      SUM(sixty_day_moving_avg) AS sixty_day_total,
      SUM(current_year_avg) AS current_year_total,
      SUM(avg_daily_submissions) AS avg_daily_submissions_total
    FROM averages
  )
SELECT
  SUBMITTER,
  thirty_day_moving_avg,
  sixty_day_moving_avg,
  current_year_avg,
  --TO_CHAR(thirty_day_moving_avg / thirty_day_total * 100, 'FM999D99') || '%' AS thirty_day_percent,
  --TO_CHAR(sixty_day_moving_avg / sixty_day_total * 100, 'FM999D99') || '%' AS sixty_day_percent,
  --TO_CHAR(current_year_submissions / avg_daily_submissions_total * 100, 'FM999D99') || '%' AS current_year_percent,
  --TO_CHAR(current_year_submissions / avg_daily_submissions_total * 100, 'FM999D999') AS current_year_percent,
current_year_submissions / avg_daily_submissions_total AS current_year_percent,
  current_year_submissions
FROM averages, total_avg
       ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: submitter {
      type: string
      sql: ${TABLE}."SUBMITTER" ;;
    }

  dimension: fleet_vs_non_fleet {
    type: string
    sql: CASE WHEN ${submitter} in
        ('Kingsley, Bethany',
        'Fulton, Cindy',
        'Woodruff, Haley',
        'Romero, Marilyn',
        'Davenport, Mary',
        'Ferguson, Rachel',
        'Sobba, Robin',
        'Lawe, Tracie'
        ) then 'fleet'

        when ${submitter} in
        ('Hartz, Andrea',
        'Morales, Carlos Fiallo',
        'Tubbs, Edith',
        'Meketsy, Ellyn',
        'Bonney, Lindsay',
        'Falcone, Madison',
        'Allen, Misty',
        'Drummond, Mylin',
        'Johnson, Raeshashan'
        ) then 'non_fleet'

        else 'other' end;;
  }

    dimension: thirty_day_moving_avg {
      type: number
      value_format: "0"
      sql: ${TABLE}."THIRTY_DAY_MOVING_AVG" ;;
    }

    dimension: sixty_day_moving_avg {
      type: number
      value_format: "0"
      sql: ${TABLE}."SIXTY_DAY_MOVING_AVG" ;;
    }

    dimension: current_year_avg {
      type: number
      value_format: "0"
      sql: ${TABLE}."CURRENT_YEAR_AVG" ;;
    }

    dimension: thirty_day_percent {
      type: string
      sql: ${TABLE}."THIRTY_DAY_PERCENT" ;;
    }

    dimension: sixty_day_percent {
      type: string
      sql: ${TABLE}."SIXTY_DAY_PERCENT" ;;
    }

    dimension: current_year_percent {
      type: string
      value_format: "0%"
      sql: ${TABLE}."CURRENT_YEAR_PERCENT" ;;
    }

    dimension: current_year_submissions {
      type: number
      sql: ${TABLE}."CURRENT_YEAR_SUBMISSIONS" ;;
    }

    set: detail {
      fields: [
        submitter,
        thirty_day_moving_avg,
        sixty_day_moving_avg,
        current_year_avg,
        thirty_day_percent,
        sixty_day_percent,
        current_year_percent,
        current_year_submissions
      ]
    }

  # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: processed_invoices_by_ap_user_plus_history {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
