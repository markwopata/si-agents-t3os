view: collections_by_day {
  derived_table: {
    sql:
      select payment_date::date as payment_date, sum(payment_amount) as collections
      from ANALYTICS.TREASURY.COLLECTIONS_ACTUALS_PAYMENTS
      group by payment_date::date
      ;;}


  dimension: payment_date {
    type: date
    sql: ${TABLE}.PAYMENT_DATE ;;
  }

  measure: collections {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}.COLLECTIONS ;;
  }

  }
