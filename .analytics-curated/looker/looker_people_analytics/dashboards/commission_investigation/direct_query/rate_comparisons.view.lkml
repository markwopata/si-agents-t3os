view: rate_comparisons {
  label: "Rate Comparisons"

  derived_table: {
    sql:
      WITH data AS (
        SELECT
          li.LINE_ITEM_ID,
          i.BILLING_APPROVED_DATE                                  AS invoice_billing_approved_date,
          brr.DATE_CREATED                                         AS branch_rate_date_created,
          brr.DATE_VOIDED                                          AS branch_rate_date_voided,

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

      brr.PRICE_PER_HOUR                                       AS rate_per_hour,
      brr.PRICE_PER_DAY                                        AS rate_per_day,
      brr.PRICE_PER_WEEK                                       AS rate_per_week,
      brr.PRICE_PER_MONTH                                      AS rate_per_max,

      ROUND(li.amount::float, 2)                               AS billed_amount,
      ROUND(
      COALESCE(hour_count * quote_per_hour, 0) +
      COALESCE(day_count  * quote_per_day, 0) +
      COALESCE(week_count * quote_per_week, 0) +
      COALESCE(max_count  * quote_per_max, 0)
      , 2)                                                     AS calculated_floor_amount

      FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
      LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES i
      ON i.INVOICE_ID = li.INVOICE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS r
      ON li.RENTAL_ID = r.RENTAL_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr
      ON li.BRANCH_ID = brr.BRANCH_ID
      AND r.EQUIPMENT_CLASS_ID = brr.EQUIPMENT_CLASS_ID
      AND brr.RATE_TYPE_ID = 3
      )
      SELECT
      data.*,
      quote_per_hour < rate_per_hour           AS quote_below_floor_hour,
      quote_per_day  < rate_per_day            AS quote_below_floor_day,
      quote_per_week < rate_per_week           AS quote_below_floor_week,
      quote_per_max  < rate_per_max            AS quote_below_floor_max,
      billed_amount != calculated_floor_amount  AS billed_amount_mismatch,
      bc.BILLING_CYCLE
      FROM data
      left join (select LINE_ITEM_ID,
      case
      when (DAILY_BILLING_FLAG = true
      OR (billing_type_extended = 'four_week_prorated' and cycle_length > 28)) then '31 Days Billing Cycle'
      else '28 Billing Cycle' end as BILLING_CYCLE
      from ANALYTICS.RATE_ACHIEVEMENT.RATE_ACHIEVEMENT_COMMISSIONS_DETAILS_BILLING_UPDATE) as bc on bc.LINE_ITEM_ID = data.line_item_id
      where invoice_billing_approved_date between branch_rate_date_created and coalesce(branch_rate_date_voided, '2099-12-31')
      ORDER BY branch_rate_date_created DESC
      ;;
  }


  dimension: billing_cycle {
    label: "Billing Cycle on Rate Achivement"
    type: string
    sql:
          ${TABLE}.BILLING_CYCLE
        ;;
  }

  dimension: billing_date_within_rate_window {
    label: "Billing Date Within Rate Window"
    type: yesno
    sql:
          ${invoice_billing_approved_date}
          BETWEEN
          ${branch_rate_date_created_date}
          AND
          COALESCE(${branch_rate_date_voided_date}, '2999-12-31'::date)
        ;;
  }

  # --- Primary key
  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.LINE_ITEM_ID ;;
  }

  # --- Dates
  dimension_group: invoice_billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.INVOICE_BILLING_APPROVED_DATE ;;
  }

  dimension_group: branch_rate_date_created {
    type: time
    description: "When the branch rate date was created"
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.BRANCH_RATE_DATE_CREATED ;;
  }

  dimension_group: branch_rate_date_voided {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.BRANCH_RATE_DATE_VOIDED ;;
  }

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

  # --- Floor rates
  dimension: rate_per_hour { label:"Floor Rate per Hour" type: number sql: ${TABLE}.RATE_PER_HOUR ;; value_format_name: usd }
  dimension: rate_per_day  { label:"Floor Rate per Day" type: number sql: ${TABLE}.RATE_PER_DAY  ;; value_format_name: usd }
  dimension: rate_per_week { label:"Floor Rate per Week"type: number sql: ${TABLE}.RATE_PER_WEEK ;; value_format_name: usd }
  dimension: rate_per_max  { label:"Floor Rate per Max" type: number sql: ${TABLE}.RATE_PER_MAX  ;; value_format_name: usd }

  # --- Flags
  dimension: quote_below_floor_hour { type: yesno sql: ${TABLE}.QUOTE_BELOW_FLOOR_HOUR ;; }
  dimension: quote_below_floor_day  { type: yesno sql: ${TABLE}.QUOTE_BELOW_FLOOR_DAY  ;; }
  dimension: quote_below_floor_week { type: yesno sql: ${TABLE}.QUOTE_BELOW_FLOOR_WEEK ;; }
  dimension: quote_below_floor_max  { type: yesno sql: ${TABLE}.QUOTE_BELOW_FLOOR_MAX  ;; }

  dimension: billed_amount_mismatch { type: yesno sql: ${TABLE}.BILLED_AMOUNT_MISMATCH ;; }

  # --- Amounts
  measure: billed_amount_sum {
    type: sum
    sql: ${TABLE}.BILLED_AMOUNT ;;
    value_format_name: usd
  }

  measure: calculated_floor_amount_sum {
    type: sum
    sql: ${TABLE}.CALCULATED_FLOOR_AMOUNT ;;
    value_format_name: usd
  }

  measure: mismatch_count {
    type: count
    filters: [billed_amount_mismatch: "yes"]
  }

  measure: mismatch_rate {
    type: number
    sql:
      CASE WHEN ${count} = 0 THEN 0
           ELSE ${mismatch_count} / ${count}
      END ;;
    value_format_name: percent_2
  }

  measure: count {
    type: count
  }
}
