view: current_oec_by_market {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select
          to_date(generateddate) generated_date,
          market_id,
          sum(totaloec) as current_oec
        from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS
        group by
          generated_date,
          market_id
        QUALIFY ROW_NUMBER() OVER(PARTITION BY market_id ORDER BY generated_date desc) = 1
        order by generated_date
      ;;
  }
#
#   # Define your dimensions and measures here, like this:
  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: current_oec {
    type: number
    sql: ${TABLE}.current_oec ;;
    value_format: "$#,##0"
  }
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
}
