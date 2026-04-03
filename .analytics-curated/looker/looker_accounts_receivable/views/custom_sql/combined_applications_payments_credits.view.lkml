view: combined_applications_payments_credits {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql:
    SELECT USER_ID,
       'Payment'              as PAYMENT_OR_CREDIT,
       PAYMENT_APPLICATION_ID as APPLICATION_ID,
       PAYMENT_ID,
       DATE                   as DATE_CREATED,
       AMOUNT
       REVERSED_DATE,
       REVERSED_BY_USER_ID
FROM ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS
UNION ALL
SELECT CREATED_BY_USER_ID        as USER_ID,
       'Credit'                  as PAYMENT_OR_CREDIT,
       CREDIT_NOTE_ALLOCATION_ID as APPLICATION_ID,
       CREDIT_NOTE_ID            as PAYMENT_ID,
       DATE_CREATED,
       AMOUNT
       REVERSAL_DATE,
       REVERSAL_USER_ID
FROM ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_ALLOCATIONS
       ;;
  }
  dimension: user_id {
       type: number
       sql: ${TABLE}.USER_ID ;;
     }

  dimension: payment_or_credit {
    type: string
    sql: ${TABLE}.PAYMENT_OR_CREDIT ;;
  }

  dimension: application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.APPLICATION_ID ;;
  }

  dimension: payment_id {
    type: number
    sql: ${TABLE}.PAYMENT_ID ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.AMOUNT ;;
  }

  dimension_group: reversed_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REVERSED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: reversed_by_user_id {
    type: number
    sql: ${TABLE}.REVERSED_BY_USER_ID ;;
  }

  dimension: is_reversed {
    type:  yesno
    sql: ${TABLE}.REVERSED_DATE is not null ;;
  }

  dimension: created_trailing30 {
    type:  yesno
    sql: datediff(day,${date_created_date},current_date()) <= 30 ;;
  }

  dimension: reversed_trailing30 {
    type:  yesno
    sql: datediff(day,${reversed_date_date},current_date()) <= 30 ;;
  }

  measure: sum_reversed{
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    #drill_fields: []
    filters: [is_reversed: "yes"]
    }

  measure: count{
    type: count
    #drill_fields: []
  }

  #measure: count_reversed{
  #  type: count
    #drill_fields: []
    #filters: [is_reversed: "yes", reversed_trailing30: "yes"]
  #}

  #measure: count_applications{
    #type: count
    #drill_fields: []
    #filters: [created_trailing30: "yes"]
  #}

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

# view: combined_applications_payments_credits {
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
