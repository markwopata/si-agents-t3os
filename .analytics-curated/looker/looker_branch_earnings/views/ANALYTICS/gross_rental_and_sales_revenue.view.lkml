view: gross_rental_and_sales_revenue {
  derived_table: {
    sql:
      select
          gl_date,
          market_id,
          market_name,
          ship_from_state,
          ship_from_city,
          ship_to_state,
          ship_to_city,
          revenue_type,
          revenue_amount
      from analytics.intacct_models.gross_receipts_rental_and_sales_revenue
      ;;
  }


  dimension: gl_date {
    type:  date
    sql:  ${TABLE}.gl_date ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }


  dimension: ship_from_state {
    type: string
    sql: ${TABLE}.ship_from_state ;;
  }

  dimension: ship_from_city {
    type: string
    sql: ${TABLE}.ship_from_city ;;
  }

  dimension: ship_to_state {
    type: string
    sql: ${TABLE}.ship_to_state ;;
  }

  dimension: ship_to_city {
    type: string
    sql: ${TABLE}.ship_to_city ;;
  }

  dimension: revenue_amount {
    type: number
    sql: ${TABLE}.revenue_amount ;;
  }

  dimension: revenue_type {
    type: string
    sql: ${TABLE}.revenue_type ;;
  }
}
