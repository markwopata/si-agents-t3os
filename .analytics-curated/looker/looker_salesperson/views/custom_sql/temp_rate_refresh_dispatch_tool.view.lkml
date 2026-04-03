view: temp_rate_refresh_dispatch_tool {
  derived_table: {
    sql:
with line_items as (select o.ORDER_ID,
                           li.LINE_ITEM_ID,
                           li.LINE_ITEM_TYPE_ID,
                           r.EQUIPMENT_CLASS_ID,
                          ec.name as equipment_class,
                           r.RENTAL_STATUS_ID,
                           rs.name as rental_status_name,
                           r.START_DATE as rental_start_date,
                           r.END_DATE as rental_end_date,
                           COALESCE(ec.BUSINESS_SEGMENT_ID, aa.business_segment_id) as BUSINESS_SEGMENT_ID,
                           r.RENTAL_ID,
                           o.COMPANY_ID,
                          c.name as company,
                           i.SHIP_TO:location_id::number                                                            as location_id,
                           rr.market_id as branch_id,
                          rr.market_name,
                           rr.DISTRICT,
                           rr.REGION_NAME,
                           cd.WORK_EMAIL as SALESPERSON_EMAIL,
                           CONCAT(TRIM(u.FIRST_NAME), ' ', TRIM(u.LAST_NAME)) AS SALESPERSON_NAME,
                           o.DATE_CREATED                                                                           as order_created_date,
                           i.BILLING_APPROVED_DATE,
                           li.AMOUNT,
                           li.PRICE_PER_UNIT,
                           li.NUMBER_OF_UNITS,
                           li.EXTENDED_DATA:rental:cheapest_period_hour_count                                       as hours,
                           li.EXTENDED_DATA:rental:cheapest_period_day_count                                        as days,
                           li.EXTENDED_DATA:rental:cheapest_period_week_count                                       as weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_four_week_count                                  as four_weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_month_count                                      as months,
                           li.EXTENDED_DATA:rental:cheapest_period_cycle_max_count                                  as cycles,
                           datediff(day, i.START_DATE, i.END_DATE)                                                  as cycle_length,
                           r.price_per_month as rental_price_per_month,
                           li.EXTENDED_DATA:rental:price_per_four_weeks::number as invoice_price_per_four_weeks,
                           li.EXTENDED_DATA:rental:price_per_month::number as invoice_price_per_month,
                           COALESCE(invoice_price_per_four_weeks, invoice_price_per_month, rental_price_per_month, ROUND(r.PRICE_PER_DAY*28,2)) as final_price_per_four_weeks,
                           case
                               when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and
                                    r.PRICE_PER_DAY is not null then true
                               else false end                                                                       as DAILY_BILLING_FLAG,
                           case
                               when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
                               when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
                               else null end                                                                        as BILLING_TYPE,
                            bcp.prefs:four_week_billing_date::timestamptz as four_week_billing_date,
                            bcp.RENTAL_BILLING_CYCLE_STRATEGY,
                            COALESCE(q.CREATED_DATE, o.DATE_CREATED) as order_date_created,
                            CASE
                               WHEN four_week_billing_date is not null then four_week_billing_date
                               WHEN RENTAL_BILLING_CYCLE_STRATEGY = 'first_of_month' or RENTAL_BILLING_CYCLE_STRATEGY = 'thirty_day_cycle' THEN null
                               WHEN RENTAL_BILLING_CYCLE_STRATEGY = 'twenty_eight_day_cycle' THEN '2024-11-05'
                               WHEN RENTAL_BILLING_CYCLE_STRATEGY is null then '2024-11-05' --added
                            END as cutover_date,
                            CASE
                               WHEN cutover_date is null then 'cycle_max'
                               WHEN order_date_created < cutover_date THEN 'cycle_max'
                               ELSE 'four_week_prorated'
                            END AS billing_type_extended
                    from ES_WAREHOUSE.PUBLIC.RENTALS r
                            left join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li on li.RENTAL_ID = r.RENTAL_ID
                             left join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
                             left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on li.ASSET_ID = aa.ASSET_ID
                             left join ES_WAREHOUSE.PUBLIC.ORDERS o on r.ORDER_ID = o.ORDER_ID
                            left join es_warehouse.public.companies c on c.company_id = o.company_id
                             left join FLEET_OPTIMIZATION.GOLD.DIM_ORDERS_FLEET_OPT do on do.ORDER_ID = o.ORDER_ID
                             LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u ON do.PRIMARY_SALESPERSON_USER_ID = u.USER_ID
                             LEFT JOIN PAYROLL.COMPANY_DIRECTORY cd ON cd.WORK_EMAIL = u.EMAIL_ADDRESS AND cd.EMPLOYEE_STATUS = 'Active'
                             left join ES_WAREHOUSE.PUBLIC.MARKETS m on o.MARKET_ID = m.MARKET_ID
                             left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                                       on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                             left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on COALESCE(li.BRANCH_ID, m.MARKET_ID) = rr.MARKET_ID
                             left join ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES bcp
                                       on bcp.COMPANY_ID = i.COMPANY_ID --added
                             left join quotes.quotes.quote q on q.ORDER_ID = o.ORDER_ID
                    left join es_warehouse.PUBLIC.RENTAL_STATUSES rs on rs.RENTAL_STATUS_ID = r.RENTAL_STATUS_ID
                    where (li.LINE_ITEM_TYPE_ID = 8 or li.LINE_ITEM_TYPE_ID is null)
                      and m.COMPANY_ID = 1854
                      and rs.RENTAL_STATUS_ID in (5)
                    and ec.BUSINESS_SEGMENT_ID = 1
                    and (ec.EQUIPMENT_CLASS_ID, COALESCE(li.BRANCH_ID, m.MARKET_ID)) in (SELECT EQUIPMENT_CLASS_ID, BRANCH_ID FROM ANALYTICS.RATE_ACHIEVEMENT.TEMP_RATES)
                    qualify ROW_NUMBER() OVER(PARTITION BY r.RENTAL_ID ORDER BY i.BILLING_APPROVED_DATE desc nulls last) = 1
                    ORDER BY line_item_id desc nulls first
                    ),
     company_rates as (select li.rental_id,
                              crr.RATE_ACHIEVEMENT_EXPIRATION_DATE,
                              co.PRICE_PER_MONTH as company_online_month,
                              co.PRICE_PER_WEEK  as company_online_week,
                              co.PRICE_PER_DAY   as company_online_day,
                              co.PRICE_PER_HOUR  as company_online_hour,
                              cb.PRICE_PER_MONTH as company_bench_month,
                              cb.PRICE_PER_WEEK  as company_bench_week,
                              cb.PRICE_PER_DAY   as company_bench_day,
                              cb.PRICE_PER_HOUR  as company_bench_hour,
                              cf.PRICE_PER_MONTH as company_floor_month,
                              cf.PRICE_PER_WEEK  as company_floor_week,
                              cf.PRICE_PER_DAY   as company_floor_day,
                              cf.PRICE_PER_HOUR  as company_floor_hour
                       from line_items li
                                left join ANALYTICS.RATE_ACHIEVEMENT.COMPANY_RENTAL_RATES crr
                                          on li.EQUIPMENT_CLASS_ID = crr.EQUIPMENT_CLASS_ID and
                                             li.COMPANY_ID = crr.COMPANY_ID and
                                             COALESCE(li.BILLING_APPROVED_DATE, '2026-03-31') between crr.EFFECTIVE_START_DATE and crr.RATE_ACHIEVEMENT_EXPIRATION_DATE
                                left join (select *
                                           from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                           where RATE_TYPE_ID = 1) co on li.EQUIPMENT_CLASS_ID = co.EQUIPMENT_CLASS_ID and
                                                                        li.BRANCH_ID = co.BRANCH_ID and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE >=
                                                                        co.DATE_CREATED and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE <
                                                                        coalesce(co.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                left join (select *
                                           from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                           where RATE_TYPE_ID = 2) cb on li.EQUIPMENT_CLASS_ID = cb.EQUIPMENT_CLASS_ID and
                                                                        li.BRANCH_ID = cb.BRANCH_ID and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE >=
                                                                        cb.DATE_CREATED and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE <
                                                                        coalesce(cb.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                left join (select *
                                           from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                           where RATE_TYPE_ID = 3) cf on li.EQUIPMENT_CLASS_ID = cf.EQUIPMENT_CLASS_ID and
                                                                        li.BRANCH_ID = cf.BRANCH_ID and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE >=
                                                                        cf.DATE_CREATED and
                                                                        crr.EFFECTIVE_AGREED_UPON_DATE <
                                                                        coalesce(cf.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                       where crr.PRICE_PER_MONTH is not null
                       and COALESCE(li.BILLING_APPROVED_DATE, '2026-03-31') >= '2025-08-15'
                       qualify ROW_NUMBER() OVER(PARTITION BY li.rental_id ORDER BY crr.DATE_CREATED desc nulls last) = 1),
     location_rates as (select li.rental_id,
                               lrr.RATE_ACHIEVEMENT_EXPIRATION_DATE,
                               lo.PRICE_PER_MONTH as location_online_month,
                               lo.PRICE_PER_WEEK  as location_online_week,
                               lo.PRICE_PER_DAY   as location_online_day,
                               lo.PRICE_PER_HOUR  as location_online_hour,
                               lb.PRICE_PER_MONTH as location_bench_month,
                               lb.PRICE_PER_WEEK  as location_bench_week,
                               lb.PRICE_PER_DAY   as location_bench_day,
                               lb.PRICE_PER_HOUR  as location_bench_hour,
                               lf.PRICE_PER_MONTH as location_floor_month,
                               lf.PRICE_PER_WEEK  as location_floor_week,
                               lf.PRICE_PER_DAY   as location_floor_day,
                               lf.PRICE_PER_HOUR  as location_floor_hour
                        from line_items li
                                 left join ANALYTICS.RATE_ACHIEVEMENT.LOCATION_RENTAL_RATES lrr
                                           on li.EQUIPMENT_CLASS_ID = lrr.EQUIPMENT_CLASS_ID and
                                              li.location_id = lrr.LOCATION_ID and
                                              COALESCE(li.BILLING_APPROVED_DATE, '2026-03-31') between lrr.EFFECTIVE_START_DATE and lrr.RATE_ACHIEVEMENT_EXPIRATION_DATE
                                 left join (select *
                                            from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                            where RATE_TYPE_ID = 1) lo
                                           on li.EQUIPMENT_CLASS_ID = lo.EQUIPMENT_CLASS_ID and
                                              li.BRANCH_ID = lo.BRANCH_ID and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE >= lo.DATE_CREATED and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE <
                                              coalesce(lo.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                 left join (select *
                                            from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                            where RATE_TYPE_ID = 2) lb
                                           on li.EQUIPMENT_CLASS_ID = lb.EQUIPMENT_CLASS_ID and
                                              li.BRANCH_ID = lb.BRANCH_ID and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE >= lb.DATE_CREATED and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE <
                                              coalesce(lb.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                 left join (select *
                                            from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                                            where RATE_TYPE_ID = 3) lf
                                           on li.EQUIPMENT_CLASS_ID = lf.EQUIPMENT_CLASS_ID and
                                              li.BRANCH_ID = lf.BRANCH_ID and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE >= lf.DATE_CREATED and
                                              lrr.EFFECTIVE_AGREED_UPON_DATE <
                                              coalesce(lf.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
                        where lrr.PRICE_PER_MONTH is not null
                        and COALESCE(li.BILLING_APPROVED_DATE, '2026-03-31') >= '2025-08-15'
                        qualify ROW_NUMBER() OVER(PARTITION BY li.rental_id ORDER BY lrr.DATE_CREATED desc nulls last) = 1 --only one line_item_id
),
     rental as (
     select li.*,
            cr.rate_achievement_expiration_date as crr_rate_achievement_expiration_date,
            lr.rate_achievement_expiration_date as lrr_rate_achievement_expiration_date,
                   case when cr.company_bench_month is not null then True else False end as                                                                      company_rate_flag,
                   case when lr.location_bench_month is not null then True else False end as                                                                     location_rate_flag,
                    floor(dr.PRICE_PER_MONTH) as deal_floor_rate,
                    floor(cf.PRICE_PER_MONTH) as current_floor_rate,
                    floor(cb.PRICE_PER_MONTH) as current_benchmark_rate,
                    floor(co.PRICE_PER_MONTH) as current_online_rate,
                    floor(COALESCE(f.PRICE_PER_MONTH, cf.PRICE_PER_MONTH)) as new_floor_rate,
                    floor(COALESCE(b.PRICE_PER_MONTH, cb.PRICE_PER_MONTH)) as new_benchmark_rate,
                    floor(COALESCE(o.PRICE_PER_MONTH, co.PRICE_PER_MONTH)) as new_online_rate,

                    floor(cr.company_floor_month) as company_floor_rate,
                    floor(cr.company_bench_month) as company_benchmark_rate,
                    floor(cr.company_online_month) as company_online_rate,
                    floor(lr.location_floor_month) as location_floor_rate,
                    floor(lr.location_bench_month) as location_benchmark_rate,
                    floor(lr.location_online_month) as location_online_rate,

                       case
                           when deal_floor_rate is not null and current_floor_rate is not null
                               then least(deal_floor_rate, current_floor_rate)
                           else coalesce(deal_floor_rate, current_floor_rate) end as                                                                                 current_least_deal_floor,
                       case
                           when deal_floor_rate is not null and new_floor_rate is not null
                               then least(deal_floor_rate, new_floor_rate)
                           else coalesce(deal_floor_rate, new_floor_rate) end as                                                                                 new_least_deal_floor,
                       case
                           when li.BUSINESS_SEGMENT_ID = 1 or li.BUSINESS_SEGMENT_ID is null then case
                                                                                                      when (final_price_per_four_weeks = 0 or current_online_rate = 0)
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks < current_least_deal_floor
                                                                                                          then 3
                                                                                                      when final_price_per_four_weeks >= current_least_deal_floor and final_price_per_four_weeks < current_online_rate
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks >= current_online_rate
                                                                                                          then 1
                                                                                                      else 2 end end as                                                                                CURRENT_RATE_TIER_ID,
                       case
                           when li.BUSINESS_SEGMENT_ID = 1 or li.BUSINESS_SEGMENT_ID is null then case
                                                                                                      when (final_price_per_four_weeks = 0 or new_online_rate = 0)
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks < new_least_deal_floor
                                                                                                          then 3
                                                                                                      when final_price_per_four_weeks >= new_least_deal_floor and final_price_per_four_weeks < new_online_rate
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks >= new_online_rate
                                                                                                          then 1
                                                                                                      else 2 end end as                                                                                NEW_RATE_TIER_ID,
                       case
                           when company_benchmark_rate IS NULL THEN null
                           when li.BUSINESS_SEGMENT_ID = 1 or li.BUSINESS_SEGMENT_ID is null then case
                                                                                                      when (final_price_per_four_weeks = 0 or company_online_rate = 0)
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks < company_floor_rate
                                                                                                          then 3
                                                                                                      when final_price_per_four_weeks >= company_floor_rate and final_price_per_four_weeks < company_online_rate
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks >= company_online_rate
                                                                                                          then 1
                                                                                                      else 2 end end as                                                                                COMPANY_RATE_TIER_ID,
                       case
                           when location_benchmark_rate IS NULL THEN null
                           when li.BUSINESS_SEGMENT_ID = 1 or li.BUSINESS_SEGMENT_ID is null then case
                                                                                                      when (final_price_per_four_weeks = 0 or location_online_rate = 0)
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks < location_floor_rate
                                                                                                          then 3
                                                                                                      when final_price_per_four_weeks >= location_floor_rate and final_price_per_four_weeks < location_online_rate
                                                                                                          then 2
                                                                                                      when final_price_per_four_weeks >= location_online_rate
                                                                                                          then 1
                                                                                                      else 2 end end as                                                                                location_rate_tier_id,
                       least(coalesce(company_rate_tier_id, 100), coalesce(location_rate_tier_id, 100),
                             coalesce(current_rate_tier_id, 100)) as                                                                                                 rate_tier_id,
                        least(coalesce(company_rate_tier_id, 100), coalesce(location_rate_tier_id, 100),
                             coalesce(new_rate_tier_id, 100)) as                                                                                                 new_rate_tier_id_full,
                       CAST(ARRAY_MIN(
                              ARRAY_CONSTRUCT_COMPACT(
                                 IFF(current_rate_tier_id  = rate_tier_id, current_floor_rate,  NULL),
                                 IFF(location_rate_tier_id = rate_tier_id, location_floor_rate, NULL),
                                 IFF(company_rate_tier_id  = rate_tier_id, company_floor_rate,  NULL)
                              )
                            ) AS NUMBER(10,2)) AS floor_rate,
                       CAST(ARRAY_MIN(
                              ARRAY_CONSTRUCT_COMPACT(
                                 IFF(current_rate_tier_id  = rate_tier_id, current_benchmark_rate,  NULL),
                                 IFF(location_rate_tier_id = rate_tier_id, location_benchmark_rate, NULL),
                                 IFF(company_rate_tier_id  = rate_tier_id, company_benchmark_rate,  NULL)
                              )
                            ) AS NUMBER(10,2)) AS benchmark_rate,
                       CAST(ARRAY_MIN(
                              ARRAY_CONSTRUCT_COMPACT(
                                 IFF(current_rate_tier_id  = rate_tier_id, current_online_rate,  NULL),
                                 IFF(location_rate_tier_id = rate_tier_id, location_online_rate, NULL),
                                 IFF(company_rate_tier_id  = rate_tier_id, company_online_rate,  NULL)
                              )
                            ) AS NUMBER(10,2)) AS online_rate
                from line_items li
                         left join company_rates cr on li.RENTAL_ID = cr.RENTAL_ID
                         left join location_rates lr on li.RENTAL_ID = lr.RENTAL_ID
                         left join ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dr
                                   on dr.DISTRICT = li.DISTRICT and dr.EQUIPMENT_CLASS_ID = li.EQUIPMENT_CLASS_ID and
                                      dr.DATE_CREATED <= li.order_created_date and
                                      (li.order_created_date <= dr.DATE_VOIDED or dr.DATE_VOIDED is null)
                         left join (select * from ANALYTICS.RATE_ACHIEVEMENT.TEMP_RATES where RATE_TYPE_ID = 1) o
                                   on li.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID and li.BRANCH_ID = o.BRANCH_ID
                         left join (select * from ANALYTICS.RATE_ACHIEVEMENT.TEMP_RATES where RATE_TYPE_ID = 2) b
                                   on li.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and li.BRANCH_ID = b.BRANCH_ID
                         left join (select * from ANALYTICS.RATE_ACHIEVEMENT.TEMP_RATES where RATE_TYPE_ID = 3) f
                                   on li.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and li.BRANCH_ID = f.BRANCH_ID
                        left join (select * FROM ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where date_created <= '2026-03-31'::timestamp_ntz
                                  and '2026-03-31'::timestamp_ntz < coalesce(DATE_VOIDED::timestamp_ntz, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                    and RATE_TYPE_ID = 1) co on li.EQUIPMENT_CLASS_ID = co.EQUIPMENT_CLASS_ID and li.BRANCH_ID = co.BRANCH_ID
                        left join (select * FROM ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where date_created <= '2026-03-31'::timestamp_ntz
                                  and '2026-03-31'::timestamp_ntz < coalesce(DATE_VOIDED::timestamp_ntz, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                    and RATE_TYPE_ID = 2) cb on li.EQUIPMENT_CLASS_ID = cb.EQUIPMENT_CLASS_ID and li.BRANCH_ID = cb.BRANCH_ID
                        left join (select * FROM ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where date_created <= '2026-03-31'::timestamp_ntz
                                  and '2026-03-31'::timestamp_ntz < coalesce(DATE_VOIDED::timestamp_ntz, '2099-12-31 23:59:59.999'::timestamp_ntz)
                                    and RATE_TYPE_ID = 3) cf on li.EQUIPMENT_CLASS_ID = cf.EQUIPMENT_CLASS_ID and li.BRANCH_ID = cf.BRANCH_ID

    )




SELECT
    distinct
    concat('https://admin.equipmentshare.com/#/home/orders/', ORDER_ID)                      as link,
    Rental_ID,
    company,
    branch_id as market_id,
    market_name,
    district,
    REGION_NAME,
    equipment_class,
    rental_start_date,
    rental_end_date,
    SALESPERSON_NAME,
    SALESPERSON_EMAIL,
    crr_rate_achievement_expiration_date,
    lrr_rate_achievement_expiration_date,
    final_price_per_four_weeks as rental_price_per_four_weeks,
   -- concat('$', round(floor_rate), ' / $', round(benchmark_rate), ' / $', round(online_rate)) as current_four_week_rates,
    floor_rate,
    benchmark_rate,
    online_rate,
   -- concat('$', round(new_floor_rate), ' / $', round(new_benchmark_rate), ' / $', round(new_online_rate)) as new_four_week_rates,
    new_floor_rate,
    new_benchmark_rate,
    new_online_rate,
    company_floor_rate,
    company_benchmark_rate,
    company_online_rate,
    location_floor_rate,
    location_benchmark_rate,
    location_online_rate,
    rate_tier_id,
    NEW_RATE_TIER_ID,
    NEW_RATE_TIER_ID_FULL,
    CASE WHEN NEW_RATE_TIER_ID > rate_tier_id then true else false end as could_impact_rate_achievement_flag,
    CASE WHEN NEW_RATE_TIER_ID_FULL > rate_tier_id then true else false end as impacts_rate_achievement_flag,
    CASE WHEN NEW_RATE_TIER_ID_FULL = 3 and rate_tier_id = 2 then round(-.03*final_price_per_four_weeks)
      WHEN NEW_RATE_TIER_ID_FULL = 2 and rate_tier_id = 1 then round(-.04*final_price_per_four_weeks)
      WHEN NEW_RATE_TIER_ID_FULL = 3 and rate_tier_id = 1 then round(-.07*final_price_per_four_weeks)
      else 0 end as monthy_commissions_impact,
 CASE
  WHEN NEW_RATE_TIER_ID = 3 AND rate_tier_id = 2
    THEN (new_floor_rate - final_price_per_four_weeks) / final_price_per_four_weeks
  WHEN NEW_RATE_TIER_ID = 2 AND rate_tier_id = 1
    THEN (new_online_rate - final_price_per_four_weeks) / final_price_per_four_weeks
  ELSE 0
END AS rate_difference
FROM rental

    ;;
  }

  dimension: link {
    type: string
    sql: ${TABLE}."LINK";;
    link: {
      label: "Link to Admin"
      url: "{{ value }}"
    }
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: salesperson_review_flag {
    type: yesno
    sql: CASE WHEN ${TABLE}.could_impact_rate_achievement_flag = TRUE and ${TABLE}.impacts_rate_achievement_flag = FALSE THEN TRUE ELSE FALSE END ;;
  }

  dimension: impacts_rate_achievement_flag {
    type: yesno
    sql: ${TABLE}.impacts_rate_achievement_flag ;;
  }

  dimension: rental_price_per_four_weeks {
    type: number
    sql: ${TABLE}.rental_price_per_four_weeks ;;
  }

  dimension: monthy_commissions_impact {
    type: number
    sql: ${TABLE}.monthy_commissions_impact ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: crr_rate_achievement_expiration_date {
    type: date
    sql: ${TABLE}.crr_rate_achievement_expiration_date ;;
  }

  dimension: lrr_rate_achievement_expiration_date {
    type: date
    sql: ${TABLE}.lrr_rate_achievement_expiration_date ;;
  }


  dimension: salesperson_email {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }


  dimension: floor_rate {

    type: number
    sql: ${TABLE}.floor_rate ;;
    value_format_name: usd_0
  }
  dimension: benchmark_rate {

    type: number
    sql: ${TABLE}.benchmark_rate ;;
    value_format_name: usd_0
  }


  dimension: online_rate {

    type: number
    sql: ${TABLE}.online_rate ;;
    value_format_name: usd_0
  }
  dimension: new_floor_rate {

    type: number
    sql: ${TABLE}.new_floor_rate ;;
    value_format_name: usd_0
  }
  dimension: new_benchmark_rate {

    type: number
    sql: ${TABLE}.new_benchmark_rate ;;
    value_format_name: usd_0


  }


  dimension: new_online_rate {

    type: number
    sql: ${TABLE}.new_online_rate ;;
    value_format_name: usd_0
  }
  dimension: current_four_week_rates {
    type: string
    sql:
    '$' || TO_VARCHAR(${floor_rate}, 'FM999,999,999') || '/' ||
    '$' || TO_VARCHAR(${benchmark_rate}, 'FM999,999,999') || '/' ||
    '$' || TO_VARCHAR(${online_rate}, 'FM999,999,999') ;;
  }

  dimension: new_four_week_rates {
    type: string
    sql:
    '$' || TO_VARCHAR(${new_floor_rate}, 'FM999,999,999') || '/' ||
    '$' || TO_VARCHAR(${new_benchmark_rate}, 'FM999,999,999') || '/' ||
    '$' || TO_VARCHAR(${new_online_rate}, 'FM999,999,999') ;;
  }

  # dimension: current_four_week_rates {
  #   type: string
  #   sql: concat('$', round(${floor_rate}), '/', '$', round(${benchmark_rate}), '/', '$', round(${online_rate})) ;;
  # }

  # dimension: new_four_week_rates {
  #   type: string
  #   sql: concat('$', round(${new_floor_rate}), '/', '$', round(${new_benchmark_rate}), '/', '$', round(${new_online_rate})) ;;
  # }

  dimension: percent_increase {
    type: string
    sql: ${TABLE}."PERCENT_INCREASE" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}."DISTRICT" in ({{ _user_attributes['district'] }}) OR ${TABLE}."REGION_NAME" in ({{ _user_attributes['region'] }}) OR ${TABLE}."MARKET_ID" in ({{ _user_attributes['market_id'] }}) ;;
  }
  dimension: rate_difference {

    type: number
    sql: ${TABLE}.rate_difference;;
    value_format_name: percent_1

  }
}









# with rentals as (select concat('https://admin.equipmentshare.com/#/home/orders/', r.ORDER_ID)                      as link,
#                         r.RENTAL_ID,
#                         r.START_DATE                                                                               as rental_start_date,
#                         r.END_DATE                                                                                 as rental_end_date,
#                         rr.MARKET_ID,
#                         rr.MARKET_NAME,
#                         rr.DISTRICT,
#                         rr.REGION_NAME,
#                         c.NAME                                                                                     as company,
#                         concat(u.FIRST_NAME, ' ', u.LAST_NAME)                                                     as salesperson,
#                         ec.NAME                                                                                    as equipment_class,
#                         case
#                             when r.PRICE_PER_MONTH is null and r.PRICE_PER_WEEK is null and r.PRICE_PER_DAY is not null
#                                 then r.PRICE_PER_DAY * 28
#                             else coalesce(li.EXTENDED_DATA:rental:price_per_four_weeks::number,
#                                           li.EXTENDED_DATA:rental:price_per_month::number) end                     as current_monthly_rate,
#                         r.PRICE_PER_WEEK                                                                           as current_weekly_rate,
#                         r.PRICE_PER_DAY                                                                            as current_daily_rate,
#                         f.floor_month,
#                         f.floor_week,
#                         f.floor_day,
#                         concat('$', round(f.floor_day), ' / $', round(f.floor_week), ' / $',
#                               round(f.floor_month))                                                               as floor_rates,
#                         concat('$', round(r.PRICE_PER_DAY), ' / $', round(r.PRICE_PER_WEEK), ' / $',
#                               round(r.PRICE_PER_MONTH))                                                           as current_rates,
#                         (floor_month - current_monthly_rate) / current_monthly_rate                                as percent_increase_month,
#                         (floor_week - current_weekly_rate) / current_weekly_rate                                   as percent_increase_week,
#                         (floor_day - current_daily_rate) / current_daily_rate                                      as percent_increase_day,
#                         concat(round(percent_increase_day * 100, 2), '% / ', round(percent_increase_week * 100, 2),
#                               '% / ', round(percent_increase_month * 100, 2),
#                               '%')                                                                                as percent_increase
#                 from ES_WAREHOUSE.PUBLIC.RENTALS r
#                           join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
#                           join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li on r.RENTAL_ID = li.RENTAL_ID
#                           join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
#                           join ES_WAREHOUSE.PUBLIC.USERS u on i.SALESPERSON_USER_ID = u.USER_ID
#                           left join RATE_ACHIEVEMENT.RATE_REGIONS rr on li.BRANCH_ID = rr.MARKET_ID
#                           join (select REGION,
#                                       EQUIPMENT_CLASS_ID,
#                                       mode(brr.PRICE_PER_MONTH) as floor_month,
#                                       mode(brr.PRICE_PER_WEEK)  as floor_week,
#                                       mode(brr.PRICE_PER_DAY)   as floor_day
#                                 from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr
#                                         join RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
#                                 where ACTIVE
#                                   and RATE_TYPE_ID = 3
#                                 group by 1, 2) f on f.REGION = rr.REGION and f.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
#                           join RATE_ACHIEVEMENT.RATE_REFRESH_2025Q2 re
#                               on re.REGION = rr.REGION and re.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
#                           left join RATE_ACHIEVEMENT.COMPANY_RENTAL_RATES crr on crr.COMPANY_ID = i.COMPANY_ID and
#                                                                                 crr.EQUIPMENT_CLASS_ID =
#                                                                                 r.EQUIPMENT_CLASS_ID and
#                                                                                 crr.RATE_ACHIEVEMENT_EXPIRATION_DATE >
#                                                                                 '2025-10-01'
#                           join ES_WAREHOUSE.PUBLIC.COMPANIES c on i.COMPANY_ID = c.COMPANY_ID
#                           join ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS ea
#                               on r.ASSET_ID = ea.ASSET_ID and r.RENTAL_ID = ea.RENTAL_ID and
#                                   (ea.END_DATE > current_date or ea.END_DATE is null) and ea.START_DATE <= current_date

#                 where li.LINE_ITEM_TYPE_ID = 8
#                   and (r.PRICE_PER_MONTH < floor_month or (28 * r.PRICE_PER_DAY < floor_month / 28))
#                   and crr.EQUIPMENT_CLASS_ID is null)
# select distinct link,
#                 RENTAL_ID,
#                 rental_start_date,
#                 rental_end_date,
#                 salesperson,
#                 company,
#                 MARKET_ID,
#                 MARKET_NAME,
#                 DISTRICT,
#                 REGION_NAME,
#                 equipment_class,
#                 current_rates,
#                 floor_rates,
#                 percent_increase
# from rentals
