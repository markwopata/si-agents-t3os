view: processed_invoices_by_ap_user_history_raw  {
    derived_table: {
      sql: select * from(
          SELECT TRIM(SUBMITTER) AS SUBMITTER, SUBMIT_DATE, COUNT(*) AS num_submissions
          FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER
          GROUP BY SUBMITTER, SUBMIT_DATE

        UNION
        SELECT TRIM(SUBMITTER) AS SUBMITTER, DATE AS SUBMIT_DATE, COUNT AS num_submissions
        FROM ANALYTICS.CONCUR.PROCESSED_INVOICES_BY_AP_USER_HISTORY
        WHERE num_submissions > 0     GROUP BY SUBMITTER, DATE, COUNT
        )--where SUBMITTER in ('Abdelgadir, Amar',
        --'Allen, Misty',
        --'Bonney, Lindsay',
        --'Davis, Brent',
        --'Falcone, Madison',
       -- 'Morales, Carlos Fiallo',
        --'Romero, Marilyn',
       -- 'System, Concur',
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
       -- 'Fulton, Cindy')
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

    dimension_group: submit_date {
      type: time

      sql: ${TABLE}."SUBMIT_DATE" ;;
    }
  dimension: number_of_submissions {
    type: number
    sql: ${TABLE}."number_of_submissions" ;;
    }

    dimension: link_to_unsubmitted_db {
      type: string
      html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/844"target="_blank">Unsubmitted by Branch</a></font></u> ;;
      sql: ${TABLE}.REQUEST_NAME ;;

    }

  dimension: name {
    link: {
      label: "Business Pulse By State Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/844"
    }
  }
    measure: num_submissions {
      type: sum
      sql: ${TABLE}."NUM_SUBMISSIONS" ;;
    }

    set: detail {
      fields: [submitter, submit_date_time, num_submissions]
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

# view: processed_invoices_by_ap_user_history_raw {
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
