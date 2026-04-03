view: quote_details {
  derived_table: {
    sql:
      SELECT
              li.LINE_ITEM_ID as LINE_ITEM_ID,
              i.billing_approved_date as INVOICE_BILLING_APPROVED_DATE,
            li.EXTENDED_DATA:rental:cheapest_period_hour_count::int  AS hour_count,
            li.EXTENDED_DATA:rental:cheapest_period_day_count::int   AS day_count,
            li.EXTENDED_DATA:rental:cheapest_period_week_count::int  AS week_count,
            GREATEST(
            COALESCE(li.EXTENDED_DATA:rental:cheapest_period_four_week_count::int, 0),
            COALESCE(li.EXTENDED_DATA:rental:cheapest_period_cycle_max_count::int, 0),
            COALESCE(li.EXTENDED_DATA:rental:cheapest_period_month_count::int, 0)
            )                                                        AS max_count,

      li.EXTENDED_DATA:rental:price_per_hour                   AS quote_per_hour,
      li.EXTENDED_DATA:rental:price_per_day                    AS quote_per_day,
      li.EXTENDED_DATA:rental:price_per_week                   AS quote_per_week,
      GREATEST(
      COALESCE(li.EXTENDED_DATA:rental:price_per_four_weeks::int, 0),
      COALESCE(li.EXTENDED_DATA:rental:price_per_month::int, 0)
      )                                                        AS quote_per_max,

      ROUND(li.amount::float, 2)                               AS billed_amount,

      FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
      left join ES_WAREHOUSE.PUBLIC.INVOICES i on li.invoice_id = i.invoice_id;;
  }

  dimension: line_item_id { type: number sql: ${TABLE}.LINE_ITEM_ID ;; }

  # --- Counts
  dimension: hour_count { type: number sql: ${TABLE}.HOUR_COUNT ;; }
  dimension: day_count  { type: number sql: ${TABLE}.DAY_COUNT ;; }
  dimension: week_count { type: number sql: ${TABLE}.WEEK_COUNT ;; }
  dimension: max_count  { type: number sql: ${TABLE}.MAX_COUNT ;; }

  # --- Quote rates
  dimension: quote_per_hour { type: number sql: ${TABLE}.QUOTE_PER_HOUR ;; value_format_name: usd }
  dimension: quote_per_day  { type: number sql: ${TABLE}.QUOTE_PER_DAY  ;; value_format_name: usd }
  dimension: quote_per_week { type: number sql: ${TABLE}.QUOTE_PER_WEEK ;; value_format_name: usd }
  dimension: quote_per_max  { type: number sql: ${TABLE}.QUOTE_PER_MAX  ;; value_format_name: usd }

  dimension: billed_amount  { type: number sql: ${TABLE}.BILLED_AMOUNT  ;; value_format_name: usd }

  # --- Dates
  dimension_group: invoice_billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.INVOICE_BILLING_APPROVED_DATE ;;
  }


}
