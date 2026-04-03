view: rate_achievement_change {
  derived_table: {
    sql:

  WITH months AS (
    -- Generate a list of months dynamically
    SELECT DATE_TRUNC('MONTH', DATEADD(MONTH, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2022-01-01')) AS month_start
    FROM TABLE (GENERATOR(ROWCOUNT => 37))),
     rate_changes AS (SELECT DATE_TRUNC('MONTH', DATE_CREATED) AS change_month,
                             RATE_TYPE_ID,
                             EQUIPMENT_CLASS_ID,
                             BRANCH_ID,
                             PRICE_PER_HOUR,
                             PRICE_PER_DAY,
                             PRICE_PER_WEEK,
                             PRICE_PER_MONTH
                      FROM es_warehouse.public.branch_rental_rates),
     monthly_changes AS (SELECT m.month_start,
                                r.RATE_TYPE_ID,
                                r.EQUIPMENT_CLASS_ID,
                                r.BRANCH_ID,
                                r.PRICE_PER_HOUR,
                                r.PRICE_PER_DAY,
                                r.PRICE_PER_WEEK,
                                r.PRICE_PER_MONTH
                         FROM months m
                                  LEFT JOIN rate_changes r ON m.month_start = r.change_month),
     change_data AS (SELECT mc.month_start,
                            mc.RATE_TYPE_ID,
                            mc.EQUIPMENT_CLASS_ID,
                            mc.BRANCH_ID,

                            -- Previous month values
                            LAG(mc.PRICE_PER_HOUR) OVER (
                                PARTITION BY mc.RATE_TYPE_ID, mc.EQUIPMENT_CLASS_ID, mc.BRANCH_ID
                                ORDER BY mc.month_start
                                )   AS prev_price_hour,

                            LAG(mc.PRICE_PER_DAY) OVER (
                                PARTITION BY mc.RATE_TYPE_ID, mc.EQUIPMENT_CLASS_ID, mc.BRANCH_ID
                                ORDER BY mc.month_start
                                )   AS prev_price_day,

                            LAG(mc.PRICE_PER_WEEK) OVER (
                                PARTITION BY mc.RATE_TYPE_ID, mc.EQUIPMENT_CLASS_ID, mc.BRANCH_ID
                                ORDER BY mc.month_start
                                )   AS prev_price_week,

                            LAG(mc.PRICE_PER_MONTH) OVER (
                                PARTITION BY mc.RATE_TYPE_ID, mc.EQUIPMENT_CLASS_ID, mc.BRANCH_ID
                                ORDER BY mc.month_start
                                )   AS prev_price_month,

                            -- Price increase counts
                            CASE
                                WHEN mc.PRICE_PER_HOUR > prev_price_hour THEN 1
                                ELSE 0
                                END AS price_hour_higher,

                            CASE
                                WHEN mc.PRICE_PER_DAY > prev_price_day THEN 1
                                ELSE 0
                                END AS price_day_higher,

                            CASE
                                WHEN mc.PRICE_PER_WEEK > prev_price_week THEN 1
                                ELSE 0
                                END AS price_week_higher,

                            CASE
                                WHEN mc.PRICE_PER_MONTH > prev_price_month THEN 1
                                ELSE 0
                                END AS price_month_higher,

                            -- Price decrease counts
                            CASE
                                WHEN mc.PRICE_PER_HOUR < prev_price_hour THEN 1
                                ELSE 0
                                END AS price_hour_lower,

                            CASE
                                WHEN mc.PRICE_PER_DAY < prev_price_day THEN 1
                                ELSE 0
                                END AS price_day_lower,

                            CASE
                                WHEN mc.PRICE_PER_WEEK < prev_price_week THEN 1
                                ELSE 0
                                END AS price_week_lower,

                            CASE
                                WHEN mc.PRICE_PER_MONTH < prev_price_month THEN 1
                                ELSE 0
                                END AS price_month_lower,

                            -- 5%+ increase counts
                            CASE
                                WHEN prev_price_hour IS NOT NULL
                                    AND mc.PRICE_PER_HOUR >= prev_price_hour * 1.05 THEN 1
                                ELSE 0
                                END AS price_hour_higher_5p,

                            CASE
                                WHEN prev_price_day IS NOT NULL
                                    AND mc.PRICE_PER_DAY >= prev_price_day * 1.05 THEN 1
                                ELSE 0
                                END AS price_day_higher_5p,

                            CASE
                                WHEN prev_price_week IS NOT NULL
                                    AND mc.PRICE_PER_WEEK >= prev_price_week * 1.05 THEN 1
                                ELSE 0
                                END AS price_week_higher_5p,

                            CASE
                                WHEN prev_price_month IS NOT NULL
                                    AND mc.PRICE_PER_MONTH >= prev_price_month * 1.05 THEN 1
                                ELSE 0
                                END AS price_month_higher_5p,

                            -- 5%+ decrease counts
                            CASE
                                WHEN prev_price_hour IS NOT NULL
                                    AND mc.PRICE_PER_HOUR <= prev_price_hour * 0.95 THEN 1
                                ELSE 0
                                END AS price_hour_lower_5p,

                            CASE
                                WHEN prev_price_day IS NOT NULL
                                    AND mc.PRICE_PER_DAY <= prev_price_day * 0.95 THEN 1
                                ELSE 0
                                END AS price_day_lower_5p,

                            CASE
                                WHEN prev_price_week IS NOT NULL
                                    AND mc.PRICE_PER_WEEK <= prev_price_week * 0.95 THEN 1
                                ELSE 0
                                END AS price_week_lower_5p,

                            CASE
                                WHEN prev_price_month IS NOT NULL
                                    AND mc.PRICE_PER_MONTH <= prev_price_month * 0.95 THEN 1
                                ELSE 0
                                END AS price_month_lower_5p

                     FROM monthly_changes mc),
     aggregate_data as (SELECT month_start,
                               EQUIPMENT_CLASS_ID,
                               BRANCH_ID,
                               RATE_TYPE_ID,

                               -- Total count of increases per price type
                               SUM(price_hour_higher)     AS price_hour_increases,
                               SUM(price_day_higher)      AS price_day_increases,
                               SUM(price_week_higher)     AS price_week_increases,
                               SUM(price_month_higher)    AS price_month_increases,

                               -- Total count of decreases per price type
                               SUM(price_hour_lower)      AS price_hour_decreases,
                               SUM(price_day_lower)       AS price_day_decreases,
                               SUM(price_week_lower)      AS price_week_decreases,
                               SUM(price_month_lower)     AS price_month_decreases,

                               -- Total count of increases of 5% or more
                               SUM(price_hour_higher_5p)  AS price_hour_increases_5p,
                               SUM(price_day_higher_5p)   AS price_day_increases_5p,
                               SUM(price_week_higher_5p)  AS price_week_increases_5p,
                               SUM(price_month_higher_5p) AS price_month_increases_5p,

                               -- Total count of decreases of 5% or more
                               SUM(price_hour_lower_5p)   AS price_hour_decreases_5p,
                               SUM(price_day_lower_5p)    AS price_day_decreases_5p,
                               SUM(price_week_lower_5p)   AS price_week_decreases_5p,
                               SUM(price_month_lower_5p)  AS price_month_decreases_5p
                        FROM change_data

                        GROUP BY month_start, EQUIPMENT_CLASS_ID, BRANCH_ID, RATE_TYPE_ID
                        ORDER BY month_start asc)

SELECT MONTH_START,
       EQUIPMENT_CLASS_ID,
       BRANCH_ID,
       RATE_TYPE_ID,
       -- Total count of all increases
       SUM(price_hour_increases + price_day_increases + price_week_increases +
           price_month_increases)    AS TOTAL_INCREASES,

       -- Total count of all decreases
       SUM(price_hour_decreases + price_day_decreases + price_week_decreases +
           price_month_decreases)    AS TOTAL_DECREASES,

       -- Total count of increases of 5% or more
       SUM(price_hour_increases_5p + price_day_increases_5p + price_week_increases_5p +
           price_month_increases_5p) AS TOTAL_INCREASES_5P,

       -- Total count of decreases of 5% or more
       SUM(price_hour_decreases_5p + price_day_decreases_5p + price_week_decreases_5p +
           price_month_decreases_5p) AS TOTAL_DECREASES_5P,

       sum(RENTAL_VOLUME)            as RENTAL_VOLUME
from aggregate_data
         left join ( -- seeing if there are any changes based on rental volume
    select COMMISSION_MONTH,
           INVOICE_CLASS_ID,
           PARENT_MARKET_ID,
           RATE_TIER_ID,
           sum(RENTAL_COUNT) as RENTAL_VOLUME
    from analytics.commission.core_commission_increase_table
    group by COMMISSION_MONTH, INVOICE_CLASS_ID, PARENT_MARKET_ID, RATE_TIER_ID) vd
                   on aggregate_data.EQUIPMENT_CLASS_ID = vd.INVOICE_CLASS_ID and
                      aggregate_data.BRANCH_ID = vd.PARENT_MARKET_ID and
                      aggregate_data.month_start = vd.COMMISSION_MONTH and
                      aggregate_data.RATE_TYPE_ID = vd.RATE_TIER_ID
GROUP BY month_start, EQUIPMENT_CLASS_ID, BRANCH_ID, RATE_TYPE_ID
order by month_start desc

;;}


  dimension: EQUIPMENT_CLASS_ID {
    label: "Equipment Class ID"
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: BRANCH_ID {
    label: "Branch ID"
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: RATE_TYPE_ID {
    label: "Rate Type ID"
    type: string
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension_group: MONTH_START {
    type: time
    label: "Month"
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."MONTH_START" ;;
  }

  measure: TOTAL_INCREASES {
    label: "Total Increase"
    type: sum
    sql: ${TABLE}."TOTAL_INCREASES" ;;
  }

  measure: TOTAL_DECREASES {
    label: "Total Decrease"
    type: sum
    sql: ${TABLE}."TOTAL_DECREASES" ;;
  }
  measure: TOTAL_INCREASES_5P {
    label: "Total Increase w 5% or Higher"
    type: sum
    sql: ${TABLE}."TOTAL_INCREASES_5P" ;;
  }
  measure: TOTAL_DECREASES_5P {
    label: "Total Decrease 5% or Higher"
    type: sum
    sql: ${TABLE}."TOTAL_DECREASES_5P" ;;
  }

  measure: RENTAL_VOLUME {
    label: "Rental Volume"
    type: sum
    sql: ${TABLE}."RENTAL_VOLUME" ;;
  }
  }
