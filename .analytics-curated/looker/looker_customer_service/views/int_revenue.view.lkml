view: int_revenue {

  derived_table: {
    sql:
      SELECT
        ir."COMPANY_ID" AS company_id,

      SUM(ir."AMOUNT") AS rental_revenue,

      CASE
      WHEN SUM(ir."AMOUNT") < 10000 THEN '<10k'
      WHEN SUM(ir."AMOUNT") < 100000 THEN '10–100k'
      WHEN SUM(ir."AMOUNT") < 500000 THEN '100–500k'
      WHEN SUM(ir."AMOUNT") < 1000000 THEN '500k–1M'
      WHEN SUM(ir."AMOUNT") < 5000000 THEN '1–5M'
      ELSE '>5M'
      END AS revenue_bucket

      FROM "ANALYTICS"."INTACCT_MODELS"."INT_REVENUE" ir

      WHERE ir."IS_RENTAL_REVENUE" = TRUE
      AND ir."INVOICE_DATE" >= DATEADD(day, -365, CURRENT_DATE())

      GROUP BY 1 ;;
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.company_id ;;
  }

  measure: rental_revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.rental_revenue ;;
  }

  dimension: revenue_bucket {
    type: string
    sql: ${TABLE}.revenue_bucket ;;
  }

  measure: company_count {
    type: count
  }
}
