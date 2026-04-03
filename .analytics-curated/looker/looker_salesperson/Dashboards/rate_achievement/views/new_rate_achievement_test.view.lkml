view: new_rate_achievement_test {
  # sql_table_name: "RATE_ACHIEVEMENT"."NEW_RATE_ACHIEVEMENT_TEST" ;;
derived_table: {
  sql:
    with date_lookup as (
        SELECT
        li.LINE_ITEM_ID,
        q.CREATED_DATE as quote_created_date,
        ord.DATE_CREATED as order_date_created,
        i.billing_approved_date,
        r.START_DATE as rental_start_date,
       DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25 as diff_order_n_billing_approved,
       FLOOR(DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25) as floor_diff_order_n_billing_approved,
       DATEADD(year, FLOOR(DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25), ord.DATE_CREATED) as year_added_floor_diff_order_n_billing_approved,
       -- Step 1: determine if quote was created within 30 days of the order
       CASE
          WHEN q.CREATED_DATE IS NOT NULL AND DATEDIFF(day, q.CREATED_DATE, ord.DATE_CREATED) <= 30
          THEN q.CREATED_DATE
           WHEN ord.DATE_CREATED is null then i.BILLING_APPROVED_DATE
          ELSE ord.DATE_CREATED
        END AS original_rate_date,
        -- Step 2: calculate rate date used for lookup based on anniversary logic
        CASE
          WHEN ord.DATE_CREATED is null then i.BILLING_APPROVED_DATE
            WHEN DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25 < 1 THEN original_rate_date
          ELSE
            DATEADD(year,
                    FLOOR(DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25),
                    ord.DATE_CREATED)
        END::DATE AS moving_original_rate_date,
        CASE
          WHEN ord.DATE_CREATED is null then i.BILLING_APPROVED_DATE
            WHEN DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25 < 1 THEN DATEADD(year,1,ord.DATE_CREATED)
          ELSE
            DATEADD(year,
                    CEIL(DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25),
                    ord.DATE_CREATED)
        END::DATE AS next_moving_original_rate_date,
        -- Step 3: rate_lock_date (truncated to first of the month, at least three months before the next order date anniversary)
        CASE
          WHEN ord.DATE_CREATED is null then i.BILLING_APPROVED_DATE
            WHEN DATEDIFF(day, ord.DATE_CREATED, i.BILLING_APPROVED_DATE) / 365.25 < 1 THEN original_rate_date
        ELSE DATE_TRUNC('month', DATEADD(month, -3, moving_original_rate_date)) end::DATE as rate_lock_date,
        DATE_TRUNC('month', DATEADD(month, 9, moving_original_rate_date)) as next_rate_lock_date
        FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON li.INVOICE_ID = i.INVOICE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS r ON r.RENTAL_ID = li.RENTAL_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS ord on ord.ORDER_ID = r.ORDER_ID
        left join QUOTES.QUOTES.QUOTE q on q.ORDER_ID = ord.ORDER_ID
        ),

--admin team is working to add a start date and remove the auto voiding of rates so that we can add rates in october to start the beginning of the following year and it won't void the current rates
company_rental_rates as (
                    SELECT
                        COMPANY_ID,
                        EQUIPMENT_CLASS_ID,
                        DATE_CREATED,
                        DATE_VOIDED,
                        END_DATE,
                        -- if rate is voided, use the voided date (unless it's voided after the original end date, then use the original end date)
                           IFF(DATE_CREATED<END_DATE AND DATE_VOIDED>END_DATE, END_DATE,
                               IFNULL(DATE_VOIDED,IFNULL(END_DATE,'9999-12-31')))::DATE AS RATE_END_DATE_v1,
                        -- rates will only be good for a max of 18 months. If created in the first half of the year, then default end date at the end of that year.
                        -- If created in the second half of the year, default end date to end of the following year.
                        CASE
                          WHEN DATEDIFF(day, DATE_CREATED, RATE_END_DATE_v1) > 548 THEN
                            CASE
                              WHEN EXTRACT(MONTH FROM DATE_CREATED) <= 6 THEN
                                TO_DATE(TO_CHAR(DATE_CREATED, 'YYYY') || '-12-31')
                              ELSE
                                TO_DATE(TO_CHAR(DATE_CREATED + INTERVAL '1 YEAR', 'YYYY') || '-12-31')
                            END
                          ELSE RATE_END_DATE_v1
                        END::DATE AS RATE_END_DATE_v2
                    FROM ES_WAREHOUSE.PUBLIC.COMPANY_RENTAL_RATES
                    WHERE 1=1
                    and rental_RATE_TYPE_ID = 1
                    and DATE_CREATED <= END_DATE --rates have to be created before their end date to be valid
                    order by COMPANY_ID, EQUIPMENT_CLASS_ID, RATE_END_DATE_v2 desc, DATE_CREATED
                    ),

rental as (SELECT
    li.LINE_ITEM_ID,
    r.RENTAL_ID,
    li.INVOICE_ID,
                       li.line_item_type_id,
                       r.EQUIPMENT_CLASS_ID,
                       r.START_DATE as rental_start_date,
                       r.END_DATE as rental_end_date,
                       ecr.name as EQUIPMENT_CLASS_NAME,
                       ec.BUSINESS_SEGMENT_ID,
                       i.SHIP_FROM:branch_id as branch_id,
                       i.SALESPERSON_USER_ID                                                                       as Salesperson_ID,
                       concat(trim(u.FIRST_NAME), ' ', trim(u.LAST_NAME))                                          as Salesperson_Name,
                       u.EMAIL_ADDRESS as salesperson_email_address,
                       c.name as company_name,
                       i.BILLING_APPROVED_DATE,
                       li.amount,
                       li.PRICE_PER_UNIT,
                       li.NUMBER_OF_UNITS,
                       dl.quote_created_date,
                       ord.DATE_CREATED as ORDER_CREATED_DATE,
                       dl.original_rate_date,
                       dl.moving_original_rate_date,
                       dl.next_moving_original_rate_date,
                       dl.rate_lock_date,
                       dl.next_rate_lock_date,
                       crr.DATE_CREATED as customer_rental_rate_date_created,
                       crr.RATE_END_DATE_v2 as customer_rental_rate_end_date,
                       diff_order_n_billing_approved,
                       floor_diff_order_n_billing_approved,
                       year_added_floor_diff_order_n_billing_approved,
                       datediff(day, i.START_DATE, i.END_DATE)                            as cycle_length,
                       li.EXTENDED_DATA,
                       case
                           when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and r.PRICE_PER_DAY is not null
                               then true
                           else false end                                                 as DAILY_BILLING_FLAG,
                       case
                           when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
                           when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
                           else null end                                                  as BILLING_TYPE,
                        CAST(
                          CONCAT(
                            COALESCE('$' || TO_CHAR(ROUND(li.EXTENDED_DATA:rental:price_per_hour::number), 'FM999,999,990'), '-'),
                            ' / ',
                            COALESCE('$' || TO_CHAR(ROUND(li.EXTENDED_DATA:rental:price_per_day::number), 'FM999,999,990'), '-'),
                            ' / ',
                            COALESCE('$' || TO_CHAR(ROUND(li.EXTENDED_DATA:rental:price_per_week::number), 'FM999,999,990'), '-'),
                            ' / ',
                            COALESCE('$' || TO_CHAR(ROUND(COALESCE(li.EXTENDED_DATA:rental:price_per_four_weeks::number, li.EXTENDED_DATA:rental:price_per_month::number)), 'FM999,999,990'), '-')
                          ) AS STRING
                        ) AS invoiced_rates,


        case
                           when daily_billing_flag = true then (f.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * f.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * f.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * f.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * f.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (f.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  f.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  f.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  f.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  f.PRICE_PER_MONTH) end  as FLOOR_RATE,
                       case
                           when DAILY_BILLING_FLAG = true then (dr.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * f.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * f.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * f.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * dr.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (dr.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  f.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  f.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  f.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  dr.PRICE_PER_MONTH) end as DEAL_FLOOR,
                       case
                           when daily_billing_flag = true then (b.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * b.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * b.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * b.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * b.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (b.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  b.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  b.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  b.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  b.PRICE_PER_MONTH) end  as BENCHMARK_RATE,
                       case
                           when daily_billing_flag = true then (o.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * o.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * o.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * o.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * o.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (o.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  o.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  o.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  o.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  o.PRICE_PER_MONTH) end  as ONLINE_RATE,

                       case
                           when daily_billing_flag = true then (cf.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * cf.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * cf.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * cf.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * cf.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (cf.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  cf.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  cf.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  cf.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  cf.PRICE_PER_MONTH) end  as current_FLOOR_RATE,
                       case
                           when DAILY_BILLING_FLAG = true then (cdr.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * cf.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * cf.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * cf.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * cdr.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (cdr.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  cf.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  cf.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  cf.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  cdr.PRICE_PER_MONTH) end as current_DEAL_FLOOR,
                       case
                           when daily_billing_flag = true then (cb.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * cb.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * cb.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * cb.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * cb.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (cb.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  cb.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  cb.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  cb.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  cb.PRICE_PER_MONTH) end  as current_BENCHMARK_RATE,
                       case
                           when daily_billing_flag = true then (co.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * co.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * co.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * co.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * co.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (co.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  co.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  co.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  co.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  co.PRICE_PER_MONTH) end  as current_ONLINE_RATE,


                       case
                           when daily_billing_flag = true then (crrf.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * crrf.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * crrf.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * crrf.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * crrf.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (crrf.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  crrf.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  crrf.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  crrf.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  crrf.PRICE_PER_MONTH) end  as crr_created_date_FLOOR_RATE,
                       case
                           when daily_billing_flag = true then (crrb.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * crrb.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * crrb.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * crrb.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * crrb.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (crrb.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  crrb.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  crrb.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  crrb.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  crrb.PRICE_PER_MONTH) end  as crr_created_date_BENCHMARK_RATE,
                       case
                           when daily_billing_flag = true then (crro.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * crro.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * crro.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * crro.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * crro.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (crro.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  crro.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  crro.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  crro.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  crro.PRICE_PER_MONTH) end  as crr_created_date_ONLINE_RATE,
                        CASE
                            WHEN DEAL_FLOOR IS NOT NULL AND FLOOR_RATE is NOT NULL THEN LEAST(DEAL_FLOOR, FLOOR_RATE)
                            ELSE COALESCE(DEAL_FLOOR, FLOOR_RATE) end as least_deal_floor,

                      case
                          when ec.BUSINESS_SEGMENT_ID = 1 or ec.BUSINESS_SEGMENT_ID is null then
                              case
                                   when (li.AMOUNT = 0 or online_rate = 0) then 2
                                   when li.AMOUNT < least_deal_floor then 3
                                   when li.AMOUNT >= least_deal_floor and li.AMOUNT < online_rate then 2
                                   when li.AMOUNT >= online_rate then 1
                                   else 2 end
                          when ec.BUSINESS_SEGMENT_ID = 2 then
                              case
                                   when (li.AMOUNT = 0 or online_rate = 0) then 8
                                   when li.AMOUNT < least_deal_floor then 9
                                   when li.AMOUNT >= least_deal_floor and li.AMOUNT < online_rate then 8
                                   when li.AMOUNT >= online_rate then 7
                                   else 8 end
                          when ec.BUSINESS_SEGMENT_ID = 3 then
                              case
                                   when (li.AMOUNT = 0 or online_rate = 0) then 5
                                   when li.AMOUNT < least_deal_floor then 6
                                   when li.AMOUNT >= least_deal_floor and li.AMOUNT < online_rate then 5
                                   when li.AMOUNT >= online_rate then 4
                                   else 5 end
                        end                                                                               as RATE_TIER_ID,
                        CASE
                            WHEN current_DEAL_FLOOR IS NOT NULL AND current_FLOOR_RATE is NOT NULL THEN LEAST(current_DEAL_FLOOR, current_FLOOR_RATE)
                            ELSE COALESCE(current_DEAL_FLOOR, current_FLOOR_RATE) end as current_least_deal_floor,
                      case
                          when ec.BUSINESS_SEGMENT_ID = 1 or ec.BUSINESS_SEGMENT_ID is null then
                              case
                                   when (li.AMOUNT = 0 or current_online_rate = 0) then 2
                                   when li.AMOUNT < current_least_deal_floor then 3
                                   when li.AMOUNT >= current_least_deal_floor and li.AMOUNT < current_online_rate then 2
                                   when li.AMOUNT >= current_online_rate then 1
                                   else 2 end
                          when ec.BUSINESS_SEGMENT_ID = 2 then
                              case
                                   when (li.AMOUNT = 0 or current_online_rate = 0) then 8
                                   when li.AMOUNT < current_least_deal_floor then 9
                                   when li.AMOUNT >= current_least_deal_floor and li.AMOUNT < current_online_rate then 8
                                   when li.AMOUNT >= current_online_rate then 7
                                   else 8 end
                          when ec.BUSINESS_SEGMENT_ID = 3 then
                              case
                                   when (li.AMOUNT = 0 or current_online_rate = 0) then 5
                                   when li.AMOUNT < current_least_deal_floor then 6
                                   when li.AMOUNT >= current_least_deal_floor and li.AMOUNT < current_online_rate then 5
                                   when li.AMOUNT >= current_online_rate then 4
                                   else 5 end
                        end                                                                               as CURRENT_RATE_TIER_ID,

                      case when customer_rental_rate_date_created is not null THEN
                          CASE
                          when ec.BUSINESS_SEGMENT_ID = 1 or ec.BUSINESS_SEGMENT_ID is null then
                              case
                                   when (li.AMOUNT = 0 or crr_created_date_online_rate = 0) then 2
                                   when li.AMOUNT < crr_created_date_FLOOR_RATE then 3
                                   when li.AMOUNT >= crr_created_date_FLOOR_RATE and li.AMOUNT < crr_created_date_online_rate then 2
                                   when li.AMOUNT >= crr_created_date_online_rate then 1
                                   else 2 end
                          when ec.BUSINESS_SEGMENT_ID = 2 then
                              case
                                   when (li.AMOUNT = 0 or crr_created_date_online_rate = 0) then 8
                                   when li.AMOUNT < crr_created_date_FLOOR_RATE then 9
                                   when li.AMOUNT >= crr_created_date_FLOOR_RATE and li.AMOUNT < crr_created_date_online_rate then 8
                                   when li.AMOUNT >= crr_created_date_online_rate then 7
                                   else 8 end
                          when ec.BUSINESS_SEGMENT_ID = 3 then
                              case
                                   when (li.AMOUNT = 0 or crr_created_date_online_rate = 0) then 5
                                   when li.AMOUNT < crr_created_date_FLOOR_RATE then 6
                                   when li.AMOUNT >= crr_created_date_FLOOR_RATE and li.AMOUNT < crr_created_date_online_rate then 5
                                   when li.AMOUNT >= crr_created_date_online_rate then 4
                                   else 5 end
                        end
                        else null end as crr_created_date_RATE_TIER_ID,

                    --logic to get best rate tier ID
               CASE WHEN crr_created_date_RATE_TIER_ID is null then least(RATE_TIER_ID,CURRENT_RATE_TIER_ID)
                   else least(RATE_TIER_ID,CURRENT_RATE_TIER_ID,crr_created_date_RATE_TIER_ID) end as best_RATE_TIER_ID,
                    --customer rates for next rate lock date
               CASE
                                WHEN dr.PRICE_PER_MONTH IS NULL THEN cdr.PRICE_PER_MONTH
                                WHEN cdr.PRICE_PER_MONTH IS NULL THEN dr.PRICE_PER_MONTH
                                ELSE LEAST(dr.PRICE_PER_MONTH, cdr.PRICE_PER_MONTH) end as next_deal_rate,
                   CAST(
                      concat(
                        '$', TO_CHAR(ROUND(nf.PRICE_PER_HOUR), 'FM999,999,990'),
                          ' / $', TO_CHAR(ROUND(nf.PRICE_PER_DAY), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(nf.PRICE_PER_WEEK), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(COALESCE(cdr.PRICE_PER_MONTH,nf.PRICE_PER_MONTH)), 'FM999,999,990')
                      ) AS STRING) AS next_period_floor_rates,

                   CAST(
                      concat(
                        '$', TO_CHAR(ROUND(nb.PRICE_PER_HOUR), 'FM999,999,990'),
                          ' / $', TO_CHAR(ROUND(nb.PRICE_PER_DAY), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(nb.PRICE_PER_WEEK), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(nb.PRICE_PER_MONTH), 'FM999,999,990')
                      ) AS STRING) AS next_period_bench_rates,

                   CAST(
                      concat(
                        '$', TO_CHAR(ROUND(no.PRICE_PER_HOUR), 'FM999,999,990'),
                          ' / $', TO_CHAR(ROUND(no.PRICE_PER_DAY), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(no.PRICE_PER_WEEK), 'FM999,999,990'),
                        ' / $', TO_CHAR(ROUND(no.PRICE_PER_MONTH), 'FM999,999,990')
                      ) AS STRING) AS next_period_book_rates,

               case
               when daily_billing_flag = true then (nf.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * nf.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * nf.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * nf.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * nf.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (nf.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  nf.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  nf.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  nf.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  nf.PRICE_PER_MONTH) end  as NEXT_FLOOR_RATE,

                        case
                           when DAILY_BILLING_FLAG = true then (next_deal_rate / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * nf.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * nf.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * nf.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * next_deal_rate
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (dr.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  nf.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  nf.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  nf.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  next_deal_rate) end  as NEXT_DEAL_FLOOR,
                       case
                           when daily_billing_flag = true then (nb.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * nb.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * nb.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * nb.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * nb.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (nb.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  nb.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  nb.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  nb.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  nb.PRICE_PER_MONTH) end  as NEXT_BENCHMARK_RATE,
                       case
                           when daily_billing_flag = true then (no.PRICE_PER_MONTH / 28) * cycle_length
                           when BILLING_TYPE = 'four_week' then
                                       li.EXTENDED_DATA:rental:cheapest_period_hour_count * no.PRICE_PER_HOUR +
                                       li.EXTENDED_DATA:rental:cheapest_period_day_count * no.PRICE_PER_DAY +
                                       li.EXTENDED_DATA:rental:cheapest_period_week_count * no.PRICE_PER_WEEK +
                                       li.EXTENDED_DATA:rental:cheapest_period_four_week_count * no.PRICE_PER_MONTH
                           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                                                  (no.PRICE_PER_MONTH / 28) * cycle_length,
                                                                  li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                                                  no.PRICE_PER_HOUR +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                                                  no.PRICE_PER_DAY +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                                                  no.PRICE_PER_WEEK +
                                                                  li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                                  no.PRICE_PER_MONTH) end  as NEXT_ONLINE_RATE,


               case
                          when ec.BUSINESS_SEGMENT_ID = 1 or ec.BUSINESS_SEGMENT_ID is null then
                              case
                                   when (li.AMOUNT = 0 or NEXT_ONLINE_RATE = 0) then 2
                                   when li.AMOUNT < coalesce(next_deal_floor, NEXT_FLOOR_RATE) then 3
                                   when li.AMOUNT >= coalesce(next_deal_floor, NEXT_FLOOR_RATE) and li.AMOUNT < NEXT_ONLINE_RATE then 2
                                   when li.AMOUNT >= NEXT_ONLINE_RATE then 1
                                   else 2 end
                          when ec.BUSINESS_SEGMENT_ID = 2 then
                              case
                                   when (li.AMOUNT = 0 or NEXT_ONLINE_RATE = 0) then 8
                                   when li.AMOUNT < coalesce(next_deal_floor, NEXT_FLOOR_RATE) then 9
                                   when li.AMOUNT >= coalesce(next_deal_floor, NEXT_FLOOR_RATE) and li.AMOUNT < NEXT_ONLINE_RATE then 8
                                   when li.AMOUNT >= NEXT_ONLINE_RATE then 7
                                   else 8 end
                          when ec.BUSINESS_SEGMENT_ID = 3 then
                              case
                                   when (li.AMOUNT = 0 or NEXT_ONLINE_RATE = 0) then 5
                                   when li.AMOUNT < coalesce(next_deal_floor, NEXT_FLOOR_RATE) then 6
                                   when li.AMOUNT >= coalesce(next_deal_floor, NEXT_FLOOR_RATE) and li.AMOUNT < NEXT_ONLINE_RATE then 5
                                   when li.AMOUNT >= NEXT_ONLINE_RATE then 4
                                   else 5 end
                        end                                                                               as next_rate_lock_date_RATE_TIER_ID


                FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
                         JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON li.INVOICE_ID = i.INVOICE_ID
                         left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
                         left join date_lookup dl on dl.LINE_ITEM_ID = li.LINE_ITEM_ID
                         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa ON li.ASSET_ID = aa.ASSET_ID
                         LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                                   on aa.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                         LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS r ON r.RENTAL_ID = li.RENTAL_ID
                    LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ecr
                                   on r.EQUIPMENT_CLASS_ID = ecr.EQUIPMENT_CLASS_ID
                         LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS ord on ord.ORDER_ID = r.ORDER_ID
                         left join QUOTES.QUOTES.QUOTE q on q.ORDER_ID = ord.ORDER_ID
                         LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m on m.MARKET_ID = ord.MARKET_ID
                         LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on m.MARKET_ID = rr.MARKET_ID
                        left join ES_WAREHOUSE.PUBLIC.USERS u on i.SALESPERSON_USER_ID = u.USER_ID
                        --join to rate tables based on original rate date/moving original rate date
                        LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dr
                                   on dr.DISTRICT = rr.DISTRICT and dr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID and
                                      dr.DATE_CREATED <= dl.original_rate_date and
                                      (dl.original_rate_date <= dr.DATE_VOIDED or dr.DATE_VOIDED is null)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) o
                                   on r.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = o.BRANCH_ID and
                                      dl.rate_lock_date >= o.DATE_CREATED and dl.rate_lock_date <
                                                                                    coalesce(o.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (o.DATE_VOIDED IS NOT NULL OR o.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) b
                                   on r.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = b.BRANCH_ID and
                                      dl.rate_lock_date >= b.DATE_CREATED and dl.rate_lock_date <
                                                                                    coalesce(b.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (b.DATE_VOIDED IS NOT NULL OR b.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) f
                                   on r.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = f.BRANCH_ID and
                                      dl.rate_lock_date >= f.DATE_CREATED and dl.rate_lock_date <
                                                                                    coalesce(f.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (f.DATE_VOIDED IS NOT NULL OR f.ACTIVE)
                        --join to rate tables based on billing approved date
                         LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES cdr
                                   on cdr.DISTRICT = rr.DISTRICT and cdr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID and
                                      cdr.DATE_CREATED <= ord.DATE_CREATED and
                                      (ord.DATE_CREATED <= cdr.DATE_VOIDED or cdr.DATE_VOIDED is null)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) co
                                   on r.EQUIPMENT_CLASS_ID = co.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = co.BRANCH_ID and
                                      i.BILLING_APPROVED_DATE >= co.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                                    coalesce(co.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (co.DATE_VOIDED IS NOT NULL OR co.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) cb
                                   on r.EQUIPMENT_CLASS_ID = cb.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = cb.BRANCH_ID and
                                      i.BILLING_APPROVED_DATE >= cb.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                                    coalesce(cb.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (cb.DATE_VOIDED IS NOT NULL OR cb.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) cf
                                   on r.EQUIPMENT_CLASS_ID = cf.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = cf.BRANCH_ID and
                                      i.BILLING_APPROVED_DATE >= cf.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                                    coalesce(cf.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (cf.DATE_VOIDED IS NOT NULL OR cf.ACTIVE)


                        --join to rate tables based on next rate lock date to get rentals where RA could change
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) no
                                   on r.EQUIPMENT_CLASS_ID = no.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = no.BRANCH_ID and
                                      dl.next_rate_lock_date >= no.DATE_CREATED and dl.next_rate_lock_date <
                                                                                    coalesce(no.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (no.DATE_VOIDED IS NOT NULL OR no.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) nb
                                   on r.EQUIPMENT_CLASS_ID = nb.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = nb.BRANCH_ID and
                                      dl.next_rate_lock_date >= nb.DATE_CREATED and dl.next_rate_lock_date <
                                                                                    coalesce(nb.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (nb.DATE_VOIDED IS NOT NULL OR nb.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) nf
                                   on r.EQUIPMENT_CLASS_ID = nf.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = nf.BRANCH_ID and
                                      dl.next_rate_lock_date >= nf.DATE_CREATED and dl.next_rate_lock_date <
                                                                                    coalesce(nf.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (nf.DATE_VOIDED IS NOT NULL OR nf.ACTIVE)



                         --join to company rental rates and rates based on date created of customer rental rate
                         left join company_rental_rates crr on crr.COMPANY_ID = i.COMPANY_ID
                                    and crr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
                                    and i.BILLING_APPROVED_DATE >= crr.date_created
                                    and i.BILLING_APPROVED_DATE < crr.RATE_END_DATE_v2
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) crro
                                   on r.EQUIPMENT_CLASS_ID = crro.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = crro.BRANCH_ID and
                                      crr.DATE_CREATED >= crro.DATE_CREATED and crr.DATE_CREATED <
                                                                                    coalesce(crro.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (crro.DATE_VOIDED IS NOT NULL OR crro.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) crrb
                                   on r.EQUIPMENT_CLASS_ID = crrb.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = crrb.BRANCH_ID and
                                      crr.DATE_CREATED >= crrb.DATE_CREATED and crr.DATE_CREATED <
                                                                                    coalesce(crrb.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (crrb.DATE_VOIDED IS NOT NULL OR cb.ACTIVE)
                         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) crrf
                                   on r.EQUIPMENT_CLASS_ID = crrf.EQUIPMENT_CLASS_ID and
                                      i.SHIP_FROM:branch_id = crrf.BRANCH_ID and
                                      crr.DATE_CREATED >= crrf.DATE_CREATED and crr.DATE_CREATED <
                                                                                    coalesce(crrf.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                                      (crrf.DATE_VOIDED IS NOT NULL OR crrf.ACTIVE)


                where li.LINE_ITEM_TYPE_ID = 8
                  AND m.COMPANY_ID = 1854)

SELECT
    RENTAL_ID,
    INVOICE_ID,
    LINE_ITEM_ID,
    EQUIPMENT_CLASS_ID,
    EQUIPMENT_CLASS_NAME,
    branch_id,
    BUSINESS_SEGMENT_ID,
    Salesperson_ID,
    Salesperson_Name,
    salesperson_email_address,
    company_name,
    quote_created_date::DATE as quote_created_date,
    ORDER_CREATED_DATE::DATE as ORDER_CREATED_DATE,
    BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
    original_rate_date,
    moving_original_rate_date,
    next_moving_original_rate_date,
    rate_lock_date,
    next_rate_lock_date,
    customer_rental_rate_date_created,
    customer_rental_rate_end_date,
    r.rental_start_date,
    r.rental_end_date,
    CASE WHEN r.rental_end_date < next_rate_lock_date THEN 'Yes' ELSE 'No' end as rental_ends_before_next_rate_lock,
    amount,
    invoiced_rates,
    CAST(
  concat(
    '$', TO_CHAR(ROUND(COALESCE(CURRENT_DEAL_FLOOR, CURRENT_FLOOR_RATE)), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(CURRENT_BENCHMARK_RATE), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(CURRENT_ONLINE_RATE), 'FM999,999,990')
  ) AS STRING) AS rates_as_of_billing_approved_date,
CAST(
  concat(
    '$', TO_CHAR(ROUND(COALESCE(DEAL_FLOOR, FLOOR_RATE)), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(BENCHMARK_RATE), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(ONLINE_RATE), 'FM999,999,990')
  ) AS STRING) AS rates_as_of_rate_lookup_date,
CAST(
  concat(
    '$', TO_CHAR(ROUND(crr_created_date_FLOOR_RATE), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(crr_created_date_BENCHMARK_RATE), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(crr_created_date_ONLINE_RATE), 'FM999,999,990')
  ) AS STRING) AS rates_as_of_crr_created_date,
CAST(
  concat(
    '$', TO_CHAR(ROUND(COALESCE(NEXT_DEAL_FLOOR, NEXT_FLOOR_RATE)), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(NEXT_BENCHMARK_RATE), 'FM999,999,990'),
    ' / $', TO_CHAR(ROUND(NEXT_ONLINE_RATE), 'FM999,999,990')
  ) AS STRING) AS rates_as_of_next_rate_lock_date,
    next_period_floor_rates,
    next_period_bench_rates,
    next_period_book_rates,
    r.RATE_TIER_ID as quote_order_RATE_TIER_ID,
    ocrt.COMMISSION_PERCENTAGE as quote_order_COMMISSION_PERCENTAGE,
    ROUND(quote_order_COMMISSION_PERCENTAGE*amount,2) as quote_order_commission_amount,
    CURRENT_RATE_TIER_ID,
    ccrt.COMMISSION_PERCENTAGE as CURRENT_COMMISSION_PERCENTAGE,
    ROUND(CURRENT_COMMISSION_PERCENTAGE*amount,2) as current_commission_amount,
    crr_created_date_RATE_TIER_ID,
    ccrcrt.COMMISSION_PERCENTAGE as crr_created_date_COMMISSION_PERCENTAGE,
    ROUND(crr_created_date_COMMISSION_PERCENTAGE*amount,2) as crr_created_date_commission_amount,
    r.best_RATE_TIER_ID,
    crt.COMMISSION_PERCENTAGE as BEST_COMMISSION_PERCENTAGE,
    ROUND(BEST_COMMISSION_PERCENTAGE*amount,2) as best_commission_amount,
    CASE WHEN BEST_COMMISSION_PERCENTAGE = CURRENT_COMMISSION_PERCENTAGE THEN 'No' ELSE 'Yes' end as different_commission_current_vs_new,
    CASE
        WHEN best_commission_amount = crr_created_date_commission_amount
             THEN 'Customer Rate Created Date'
        WHEN best_commission_amount = quote_order_commission_amount
             THEN 'Quote/Order Date'
        WHEN best_commission_amount = current_commission_amount
             THEN 'Billing Approved Date'
    ELSE 'Unknown'
    END AS best_commission_rate_source,
    CASE
        WHEN best_commission_amount = crr_created_date_commission_amount
             THEN customer_rental_rate_date_created
        WHEN best_commission_amount = quote_order_commission_amount
             THEN rate_lock_date
        WHEN best_commission_amount = current_commission_amount
             THEN BILLING_APPROVED_DATE
    ELSE 'Unknown'
    END AS best_commission_rate_date,
    CASE
        WHEN best_commission_amount = crr_created_date_commission_amount
             THEN rates_as_of_crr_created_date
        WHEN best_commission_amount = quote_order_commission_amount
             THEN rates_as_of_rate_lookup_date
        WHEN best_commission_amount = current_commission_amount
             THEN rates_as_of_billing_approved_date
    ELSE 'Unknown'
    END AS best_commission_rates,
        next_rate_lock_date_RATE_TIER_ID,
    ncrt.COMMISSION_PERCENTAGE as next_rate_lock_date_COMMISSION_PERCENTAGE,
    ROUND(next_rate_lock_date_COMMISSION_PERCENTAGE*amount,2) as next_rate_lock_date_commission_amount,
    CASE
        -- Scenario A: Customer rate ends AFTER the next rate change window begins
        WHEN customer_rental_rate_end_date IS NOT NULL AND customer_rental_rate_end_date >= next_moving_original_rate_date THEN
            CASE
                -- Customer rate gives BETTER commission => use it until it ends
                WHEN crr_created_date_commission_amount > next_rate_lock_date_commission_amount THEN customer_rental_rate_end_date

                -- If customer and rate lock give SAME commission => wait until both expire
                WHEN crr_created_date_commission_amount = next_rate_lock_date_commission_amount THEN
                    GREATEST(customer_rental_rate_end_date, next_rate_lock_date)

                -- Rate lock gives better commission => use rate lock date as trigger
                ELSE next_moving_original_rate_date
            END
        -- Scenario B: Customer rate ends BEFORE the next rate change window begins
        WHEN customer_rental_rate_end_date IS NOT NULL AND customer_rental_rate_end_date < next_moving_original_rate_date THEN
            -- Customer rate won’t be in effect at time of change, use rate lock
            next_moving_original_rate_date
        -- Scenario C: No customer rate set at all, use next moving original rate date
        WHEN customer_rental_rate_end_date IS NULL THEN next_moving_original_rate_date
        ELSE NULL
    END AS next_rate_achievement_change_date,
    DATE_TRUNC('month', DATEADD(month, -3, next_rate_achievement_change_date))::DATE as next_rate_achievement_change_reminder_date,
    CASE WHEN customer_rental_rate_end_date IS NOT NULL AND customer_rental_rate_end_date >= next_moving_original_rate_date THEN crr_created_date_RATE_TIER_ID
        end as NEXT_CRR_RATE_TIER_ID,
    CASE WHEN customer_rental_rate_end_date IS NOT NULL AND customer_rental_rate_end_date >= next_moving_original_rate_date THEN crr_created_date_COMMISSION_PERCENTAGE
        end as NEXT_CRR_COMMISSION_PERCENTAGE,
    CASE WHEN customer_rental_rate_end_date IS NOT NULL AND customer_rental_rate_end_date >= next_moving_original_rate_date THEN crr_created_date_COMMISSION_AMOUNT
        end as NEXT_CRR_COMMISSION_AMOUNT,
        CASE
        WHEN next_rate_lock_date_commission_amount <= NEXT_CRR_COMMISSION_AMOUNT
             THEN 'Customer Rate Created Date'
        ELSE 'Order Date Anniversary'
    END AS next_best_commission_rate_source,
        CASE
            WHEN next_rate_lock_date_commission_amount <= NEXT_CRR_COMMISSION_AMOUNT
             THEN customer_rental_rate_date_created
        ELSE next_rate_lock_date
    END AS next_best_commission_date,
    CASE
            WHEN next_rate_lock_date_commission_amount <= NEXT_CRR_COMMISSION_AMOUNT
             THEN rates_as_of_crr_created_date
        ELSE rates_as_of_next_rate_lock_date
    END AS next_best_commission_rates,
    CASE WHEN next_best_commission_rate_source = 'Customer Rate Created Date' THEN NEXT_CRR_RATE_TIER_ID ELSE next_rate_lock_date_RATE_TIER_ID END AS NEXT_BEST_RATE_TIER_ID,
    CASE WHEN next_best_commission_rate_source = 'Customer Rate Created Date' THEN NEXT_CRR_COMMISSION_PERCENTAGE ELSE next_rate_lock_date_COMMISSION_PERCENTAGE END AS NEXT_BEST_COMMISSION_PERCENTAGE,
    CASE WHEN next_best_commission_rate_source = 'Customer Rate Created Date' THEN NEXT_CRR_COMMISSION_AMOUNT ELSE next_rate_lock_date_commission_amount END AS NEXT_BEST_commission_amount,
    CASE WHEN CURRENT_DATE() >= next_rate_achievement_change_date AND CURRENT_DATE() <= next_rate_achievement_change_date THEN 'Yes' ELSE 'No' end as upcoming_rate_achievement_changes,
    NEXT_BEST_commission_amount - best_commission_amount as next_commissions_impact,
    ROW_NUMBER() OVER (PARTITION BY rental_id ORDER BY BILLING_APPROVED_DATE desc) AS invoice_row_number,
    CASE WHEN BEST_COMMISSION_amount = NEXT_BEST_commission_amount THEN 'No' ELSE 'Yes' end as different_commission_new_vs_next
    FROM rental r
    left join ANALYTICS.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS crt on crt.RATE_TIER_ID = r.best_RATE_TIER_ID --join to get best rate tier %s
    left join ANALYTICS.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS ocrt on ocrt.RATE_TIER_ID = r.RATE_TIER_ID --join to get quote/order date rate tier %s
    left join ANALYTICS.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS ccrt on ccrt.RATE_TIER_ID = r.CURRENT_RATE_TIER_ID --join to get current rate tier %s
    left join ANALYTICS.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS ccrcrt on ccrcrt.RATE_TIER_ID = r.crr_created_date_RATE_TIER_ID --join to get ccr rate tier %s
    left join ANALYTICS.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS ncrt on ncrt.RATE_TIER_ID = r.next_rate_lock_date_RATE_TIER_ID --join to get next rate tier %s
    WHERE BILLING_APPROVED_DATE::date >= '2025-01-01'

  ;;
}
  dimension: amount {
    type: number
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: best_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."BEST_COMMISSION_AMOUNT" ;;
  }
  dimension: best_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."BEST_COMMISSION_PERCENTAGE" ;;
  }
  dimension: best_rate_tier_id {
    type: number
    sql: ${TABLE}."BEST_RATE_TIER_ID" ;;
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }
  dimension: crr_created_date_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."CRR_CREATED_DATE_COMMISSION_AMOUNT" ;;
  }
  dimension: crr_created_date_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."CRR_CREATED_DATE_COMMISSION_PERCENTAGE" ;;
  }
  dimension: crr_created_date_rate_tier_id {
    type: number
    sql: ${TABLE}."CRR_CREATED_DATE_RATE_TIER_ID" ;;
  }
  dimension: current_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."CURRENT_COMMISSION_AMOUNT" ;;
  }
  dimension: current_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."CURRENT_COMMISSION_PERCENTAGE" ;;
  }
  dimension: current_rate_tier_id {
    type: number
    sql: ${TABLE}."CURRENT_RATE_TIER_ID" ;;
  }
  dimension: invoice_row_number {
    type: number
    sql: ${TABLE}."INVOICE_ROW_NUMBER" ;;
  }
  dimension: next_best_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_BEST_COMMISSION_AMOUNT" ;;
  }
  dimension: next_best_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."NEXT_BEST_COMMISSION_PERCENTAGE" ;;
  }
  dimension: next_best_rate_tier_id {
    type: number
    sql: ${TABLE}."NEXT_BEST_RATE_TIER_ID" ;;
  }
  dimension: next_rate_lock_date_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_RATE_LOCK_DATE_COMMISSION_AMOUNT" ;;
  }
  dimension: next_rate_lock_date_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."NEXT_RATE_LOCK_DATE_COMMISSION_PERCENTAGE" ;;
  }
  dimension: next_rate_lock_date_rate_tier_id {
    type: number
    sql: ${TABLE}."NEXT_RATE_LOCK_DATE_RATE_TIER_ID" ;;
  }
  dimension: next_crr_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_CRR_COMMISSION_AMOUNT" ;;
  }
  dimension: next_crr_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."NEXT_CRR_COMMISSION_PERCENTAGE" ;;
  }
  dimension: next_crr_rate_tier_id {
    type: number
    sql: ${TABLE}."NEXT_CRR_RATE_TIER_ID" ;;
  }
  dimension: best_commission_rate_source {
    type: string
    sql: ${TABLE}."BEST_COMMISSION_RATE_SOURCE" ;;
  }
  dimension: next_best_commission_rate_source {
    type: string
    sql: ${TABLE}."NEXT_BEST_COMMISSION_RATE_SOURCE" ;;
  }
  dimension: upcoming_rate_achievement_changes {
    type: string
    sql: ${TABLE}."UPCOMING_RATE_ACHIEVEMENT_CHANGES" ;;
  }
  dimension: next_commissions_impact {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_COMMISSIONS_IMPACT" ;;
  }

  dimension_group: next_rate_achievement_change {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEXT_RATE_ACHIEVEMENT_CHANGE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: next_best_commission {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEXT_BEST_COMMISSION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: next_best_commission_rates {
    type: string
    sql: ${TABLE}."NEXT_BEST_COMMISSION_RATES" ;;
  }
  dimension_group: next_rate_achievement_change_reminder {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEXT_RATE_ACHIEVEMENT_CHANGE_REMINDER_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: customer_rental_rate_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CUSTOMER_RENTAL_RATE_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: customer_rental_rate_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CUSTOMER_RENTAL_RATE_END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: salesperson_id {
    type: string
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }
  dimension: salesperson_email_address {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension_group: rental_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }
  dimension_group: moving_original_rate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MOVING_ORIGINAL_RATE_DATE" ;;
  }
  dimension_group: next_moving_original_rate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEXT_MOVING_ORIGINAL_RATE_DATE" ;;
  }
  dimension_group: next_rate_lock {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEXT_RATE_LOCK_DATE" ;;
  }
  dimension_group: order_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
  }
  dimension_group: original_rate {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ORIGINAL_RATE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: quote_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."QUOTE_CREATED_DATE" ;;
  }
  dimension: quote_order_commission_amount {
    type: number
    value_format: "$0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."QUOTE_ORDER_COMMISSION_AMOUNT" ;;
  }
  dimension: quote_order_commission_percentage {
    type: string
    value_format: "0%"
    sql: ${TABLE}."QUOTE_ORDER_COMMISSION_PERCENTAGE" ;;
  }
  dimension: quote_order_rate_tier_id {
    type: number
    sql: ${TABLE}."QUOTE_ORDER_RATE_TIER_ID" ;;
  }
  dimension_group: rate_lock {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RATE_LOCK_DATE" ;;
  }
  dimension: rates_as_of_billing_approved_date {
    type: string
    sql: ${TABLE}."RATES_AS_OF_BILLING_APPROVED_DATE" ;;
  }
  dimension: rates_as_of_crr_created_date {
    type: string
    sql: ${TABLE}."RATES_AS_OF_CRR_CREATED_DATE" ;;
  }
  dimension: rates_as_of_rate_lookup_date {
    type: string
    sql: ${TABLE}."RATES_AS_OF_RATE_LOOKUP_DATE" ;;
  }
  dimension: rates_as_of_next_rate_lock_date {
    type: string
    sql: ${TABLE}."RATES_AS_OF_NEXT_RATE_LOCK_DATE" ;;
  }
  dimension: best_commission_rates {
    type: string
    sql: ${TABLE}."BEST_COMMISSION_RATES" ;;
  }
  dimension_group: best_commission_rate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BEST_COMMISSION_RATE_DATE" ;;
  }
  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: rental_ends_before_next_rate_lock {
    type: string
    sql: ${TABLE}."RENTAL_ENDS_BEFORE_NEXT_RATE_LOCK" ;;
  }
  dimension: different_commission_current_vs_new {
    type: string
    sql: ${TABLE}."DIFFERENT_COMMISSION_CURRENT_VS_NEW" ;;
  }
  dimension: different_commission_new_vs_next {
    type: string
    sql: ${TABLE}."DIFFERENT_COMMISSION_NEW_VS_NEXT" ;;
  }

  dimension: invoiced_rates {
    type: string
    sql: ${TABLE}."INVOICED_RATES" ;;
  }
  dimension: next_period_floor_rates {
    type: string
    sql: ${TABLE}."NEXT_PERIOD_FLOOR_RATES" ;;
  }
  dimension: next_period_bench_rates {
    type: string
    sql: ${TABLE}."NEXT_PERIOD_BENCH_RATES" ;;
  }
  dimension: next_period_book_rates {
    type: string
    sql: ${TABLE}."NEXT_PERIOD_BOOK_RATES" ;;
  }

  # dimension: current_commissions {
  #   type:  string
  #   sql: CONCAT( ${rates_as_of_billing_approved_date} , '\n', ${current_commission_percentage} , '\n', ${current_commission_amount}) ;;
  # }

  # dimension: current_commissions {
  #   label: "Current Commission Details"
  #   html:
  #   <font style="color: #000000; text-align: left;">Date: {{billing_approved_date._rendered_value}}</font>
  #   <br />
  #   <font style="color: #000000; text-align: left;">Rates: {{rates_as_of_billing_approved_date._rendered_value}}</font>
  #   <br />
  #   <font style="color: #000000; text-align: left;">Commission %: {{current_commission_percentage._rendered_value}}</font>
  #   <br />
  #   <font style="color: #8C8C8C; text-align: left;">Commission Amount: {{current_commission_amount._value}}</font>
  # ;;
  # }



  # dimension: invoice {
  #   html: <font style="color: #000000; text-align: right;">{{invoice_id._rendered_value}} </font>
  #         <br />
  #         <font style="color: #8C8C8C; text-align: right;">ID: {{line_item_id._rendered_value}} </font>
  #         ;;
  # }



  # dimension: current_commissions {
  #   type: string
  #   sql: CONCAT( ${rates_as_of_billing_approved_date} , '\n', ${current_commission_percentage} , '\n', ${current_commission_amount}) ;;
  #   html: "{{ value }}" ;;
  # }

  # dimension: quote_order_date_commissions {
  #   type:  string
  #   sql:  ${rates_as_of_rate_lookup_date} || '\n' || ${quote_order_commission_percentage} || '\n' || ${quote_order_commission_amount} ;;
  # }

  # dimension: crr_created_date_commissions {
  #   type:  string
  #   sql:  ${rates_as_of_crr_created_date} || '\n' || ${crr_created_date_commission_percentage} || '\n' || ${crr_created_date_commission_amount} ;;
  # }

  measure: best_commission_total {
    type: sum
    value_format: "$#,##0.00"          # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."BEST_COMMISSION_AMOUNT" ;;
  }
  measure: current_commission_total {
    type: sum
    value_format: "$#,##0.00"          # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."CURRENT_COMMISSION_AMOUNT" ;;
  }
  measure: crr_created_date_commission_total {
    type: sum
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."CRR_CREATED_DATE_COMMISSION_AMOUNT" ;;
  }
  measure: quote_order_commission_total {
    type: sum
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."QUOTE_ORDER_COMMISSION_AMOUNT" ;;
  }
  measure: next_best_commission_total {
    type: sum
    value_format: "$#,##0.00"          # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_BEST_COMMISSION_AMOUNT" ;;
  }
  measure: next_commissions_impact_total {
    type: sum
    value_format: "$#,##0.00"          # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."NEXT_COMMISSIONS_IMPACT" ;;
  }
  measure: count {
    type: count
    drill_fields: [invoice_id,equipment_class_name]
  }
}
