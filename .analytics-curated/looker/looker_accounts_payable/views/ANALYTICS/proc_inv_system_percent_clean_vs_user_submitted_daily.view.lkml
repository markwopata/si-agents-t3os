view: proc_inv_system_percent_clean_vs_user_submitted_daily {
    derived_table: {
      sql: WITH daily_submissions AS (
          SELECT SUBMITTER, SUBMIT_DATE, COUNT(*) AS num_submissions
          FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER
          GROUP BY SUBMITTER, SUBMIT_DATE
          UNION
          SELECT SUBMITTER, DATE AS SUBMIT_DATE, COUNT AS num_submissions
          FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER_HISTORY
          WHERE num_submissions > 0
          GROUP BY SUBMITTER, DATE, COUNT
      ),
      pivot_data AS (
          SELECT
              SUBMIT_DATE,
              SUM(CASE WHEN SUBMITTER = 'System, Concur' THEN num_submissions ELSE 0 END) AS system_submissions,
              SUM(CASE WHEN SUBMITTER <> 'System, Concur' THEN num_submissions ELSE 0 END) AS other_submissions,
              SUM(num_submissions) AS total_submissions
          FROM daily_submissions
          GROUP BY SUBMIT_DATE
      )
      SELECT
          SUBMIT_DATE,
          system_submissions,
          other_submissions,
          total_submissions,
          system_submissions * 100.0 / (system_submissions + other_submissions) AS system_percent,
          other_submissions * 100.0 / (system_submissions + other_submissions) AS other_percent
      FROM pivot_data
      ORDER BY SUBMIT_DATE
       ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: submit_date {
      type: time
      sql: ${TABLE}."SUBMIT_DATE" ;;
    }

    dimension: system_concur_submissions {
      type: number
      sql: ${TABLE}."SYSTEM_SUBMISSIONS" ;;
    }

    dimension: team_submissions {
      type: number
      sql: ${TABLE}."OTHER_SUBMISSIONS" ;;
    }

    dimension: total_submissions {
      type: number
      sql: ${TABLE}."TOTAL_SUBMISSIONS" ;;
    }

    dimension: system_concur_percent {
      type: number
      value_format: "0\%"
      sql: ${TABLE}."SYSTEM_PERCENT" ;;
    }

    dimension: team_percent {
      type: number
      value_format: "0\%"
      sql: ${TABLE}."OTHER_PERCENT" ;;
    }

    set: detail {
      fields: [
        submit_date_time,
        system_concur_submissions,
        team_submissions,
        total_submissions,
        system_concur_percent,
        team_percent
      ]
    }
  }



# view: system_percent_clean_vs_user_submitted_daily {
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
