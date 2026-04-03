view: proc_inv_ap_prod_year_to_date_submissions {

    derived_table: {
      sql: WITH yearly_submissions AS (
          SELECT SUBMITTER, year, num_submissions
          FROM (
              SELECT SUBMITTER, YEAR(SUBMIT_DATE) AS year, COUNT(*) AS num_submissions
              FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER
              WHERE YEAR(SUBMIT_DATE) = YEAR(CURRENT_DATE())
              GROUP BY SUBMITTER, YEAR(SUBMIT_DATE)
              UNION ALL
              SELECT SUBMITTER, YEAR(DATE) AS year, SUM(COUNT) AS num_submissions
              FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER_HISTORY
              WHERE YEAR(DATE) = YEAR(CURRENT_DATE())
              GROUP BY SUBMITTER, YEAR(DATE)
          ) AS sub
      ),
      total_submissions AS (
          SELECT
              year,
              SUM(CASE WHEN SUBMITTER = 'System, Concur' THEN num_submissions ELSE 0 END) AS system_submissions,
              SUM(CASE WHEN SUBMITTER <> 'System, Concur' THEN num_submissions ELSE 0 END) AS other_submissions,
              SUM(num_submissions) AS total_submissions
          FROM yearly_submissions
          GROUP BY year
      )
      SELECT
          year,
          system_submissions,
          other_submissions,
          total_submissions,
          system_submissions  / total_submissions AS system_percent,
          other_submissions  / total_submissions AS other_percent
      FROM total_submissions
       ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: year {
      type: number
      value_format: "#"
      sql: ${TABLE}."YEAR" ;;
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
     value_format: "0%"
      sql: ${TABLE}."SYSTEM_PERCENT" ;;
    }

    dimension: team_percent {
      type: number
      value_format: "0%"

      sql: ${TABLE}."OTHER_PERCENT" ;;
    }

    set: detail {
      fields: [
        year,
        system_concur_submissions,
        team_submissions,
        total_submissions,
        system_concur_percent,
        team_percent
      ]
    }


  # # You can specify the table name if it's different from the view name:
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

# view: ap_prod_year_to_date_submissions {
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
