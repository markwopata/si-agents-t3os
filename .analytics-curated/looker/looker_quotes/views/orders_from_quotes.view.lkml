view: orders_from_quotes {
  derived_table: {
    sql:
      SELECT
        fq.order_key,
        fq.quote_key,
        fq.created_date_key   -- 👈 THIS is your quote_created_date anchor
      FROM BUSINESS_INTELLIGENCE.GOLD.V_FACT_QUOTES fq
      WHERE fq.order_key IS NOT NULL
      GROUP BY 1,2,3 ;;
  }

  dimension: order_key {
    primary_key: yes
    sql: ${TABLE}.order_key ;;
  }

  dimension: quote_key {
    sql: ${TABLE}.quote_key ;;
  }

  dimension: created_date_key {
    sql: ${TABLE}.created_date_key ;;
  }
}
