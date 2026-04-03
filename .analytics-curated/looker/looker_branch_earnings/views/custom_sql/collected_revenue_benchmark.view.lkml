view: collected_revenue_benchmark {
  derived_table: {
    sql:
with above_benchmarket as (
SELECT li.LINE_ITEM_ID,
       li.AMOUNT,
       li.ASSET_ID,
       aa.OEC,
       aa.MODEL,
       aa.CATEGORY,
       aa.SERIAL_NUMBER,
       r.EQUIPMENT_CLASS_ID,
       ec.NAME                                                                              as EQUIPMENT_CLASS,
       i.INVOICE_ID,
       i.INVOICE_NO,
       i.SHIP_FROM:branch_id                                                                as MARKET_ID,
       i.SALESPERSON_USER_ID,
       concat(trim(u.FIRST_NAME), ' ', trim(u.LAST_NAME))                                   as SALESPERSON,
       i.BILLING_APPROVED_DATE,
       i.PAID_DATE,
       i.DATE_CREATED,
       li.BRANCH_ID,
       i.COMPANY_ID,
       c.NAME                                                                               as COMPANY_NAME,
       case
           when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and r.PRICE_PER_DAY is not null then 1
           else 0 end                                                                       as DAILY_BILLING_FLAG,
       case
           when daily_billing_flag = 1 then r.PRICE_PER_DAY * datediff(day, i.START_DATE, i.END_DATE)
           else li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                coalesce(li.EXTENDED_DATA:rental:price_per_hour::number, 0) +
                li.EXTENDED_DATA:rental:cheapest_period_day_count *
                coalesce(li.EXTENDED_DATA:rental:price_per_day::number, 0) +
                li.EXTENDED_DATA:rental:cheapest_period_week_count *
                coalesce(li.EXTENDED_DATA:rental:price_per_week::number, 0) +
                li.EXTENDED_DATA:rental:cheapest_period_month_count *
                coalesce(li.EXTENDED_DATA:rental:price_per_month::number, 0) end            as ACTUAL_RATE,
       case
           when daily_billing_flag = 1 then (o.PRICE_PER_MONTH / 28) * datediff(day, i.START_DATE, i.END_DATE)
           else li.EXTENDED_DATA:rental:cheapest_period_hour_count * o.PRICE_PER_HOUR +
                li.EXTENDED_DATA:rental:cheapest_period_day_count * o.PRICE_PER_DAY +
                li.EXTENDED_DATA:rental:cheapest_period_week_count * o.PRICE_PER_WEEK +
                li.EXTENDED_DATA:rental:cheapest_period_month_count * o.PRICE_PER_MONTH end as ONLINE_RATE,
       case
           when daily_billing_flag = 1 then (b.PRICE_PER_MONTH / 28) * datediff(day, i.START_DATE, i.END_DATE)
           else li.EXTENDED_DATA:rental:cheapest_period_hour_count * b.PRICE_PER_HOUR +
                li.EXTENDED_DATA:rental:cheapest_period_day_count * b.PRICE_PER_DAY +
                li.EXTENDED_DATA:rental:cheapest_period_week_count * b.PRICE_PER_WEEK +
                li.EXTENDED_DATA:rental:cheapest_period_month_count * b.PRICE_PER_MONTH end as BENCHMARK_RATE,
       case
           when daily_billing_flag = 1 then (f.PRICE_PER_MONTH / 28) * datediff(day, i.START_DATE, i.END_DATE)
           else li.EXTENDED_DATA:rental:cheapest_period_hour_count * f.PRICE_PER_HOUR +
                li.EXTENDED_DATA:rental:cheapest_period_day_count * f.PRICE_PER_DAY +
                li.EXTENDED_DATA:rental:cheapest_period_week_count * f.PRICE_PER_WEEK +
                li.EXTENDED_DATA:rental:cheapest_period_month_count * f.PRICE_PER_MONTH end as FLOOR_RATE,
       case
           when online_rate is not null and online_rate != 0 then (1 - (actual_rate / online_rate))::numeric(20, 2)
           else null end                                                                    as PERCENT_DISCOUNT,
       case
           when actual_rate < floor_rate then 3
           when actual_rate >= floor_rate and actual_rate < online_rate then 2
           when actual_rate >= online_rate then 1
           else 2 end                                                                       as RATE_TIER,
       case when actual_rate < FLOOR_RATE then true else false end                          as IS_BELOW_FLOOR,
       case when actual_rate >= FLOOR_RATE
           and ACTUAL_RATE < BENCHMARK_RATE then true else false end                        as IS_BTWN_FLOOR_BENCH,
       case when actual_rate >= benchmark_rate then true else false end                     as IS_ABOVE_BENCH
FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
         JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON li.INVOICE_ID = i.INVOICE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa ON li.ASSET_ID = aa.ASSET_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on aa.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS r ON r.RENTAL_ID = li.RENTAL_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u on i.SALESPERSON_USER_ID = u.USER_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c on i.COMPANY_ID = c.COMPANY_ID
         LEFT JOIN (select BRANCH_ID,
                           EQUIPMENT_CLASS_ID,
                           PRICE_PER_HOUR,
                           PRICE_PER_DAY,
                           PRICE_PER_WEEK,
                           PRICE_PER_MONTH,
                           DATE_CREATED,
                           DATE_VOIDED,
                           ACTIVE
                    from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                    where RATE_TYPE_ID = 1) o
                   on r.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID and i.SHIP_FROM:branch_id = o.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= o.DATE_CREATED and
                      i.BILLING_APPROVED_DATE < coalesce(o.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (o.DATE_VOIDED IS NOT NULL OR o.ACTIVE)
         LEFT JOIN (select BRANCH_ID,
                           EQUIPMENT_CLASS_ID,
                           PRICE_PER_HOUR,
                           PRICE_PER_DAY,
                           PRICE_PER_WEEK,
                           PRICE_PER_MONTH,
                           DATE_CREATED,
                           DATE_VOIDED,
                           ACTIVE
                    from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                    where RATE_TYPE_ID = 2) b
                   on r.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and i.SHIP_FROM:branch_id = b.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= b.DATE_CREATED and
                      i.BILLING_APPROVED_DATE < coalesce(b.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (b.DATE_VOIDED IS NOT NULL OR b.ACTIVE)
         LEFT JOIN (select BRANCH_ID,
                           EQUIPMENT_CLASS_ID,
                           PRICE_PER_HOUR,
                           PRICE_PER_DAY,
                           PRICE_PER_WEEK,
                           PRICE_PER_MONTH,
                           DATE_CREATED,
                           DATE_VOIDED,
                           ACTIVE
                    from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
                    where RATE_TYPE_ID = 3) f
                   on r.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and i.SHIP_FROM:branch_id = f.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= f.DATE_CREATED and
                      i.BILLING_APPROVED_DATE < coalesce(f.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (f.DATE_VOIDED IS NOT NULL OR f.ACTIVE)
where li.LINE_ITEM_TYPE_ID in (6, 8, 108, 109) --Commissions Line Items
  and i.COMPANY_ID not in  (1854, 8151, 7201, 31113, 31175, 31177, 31180, 31293, 31294, 31295, 32149)
  AND I.BILLING_APPROVED_DATE IS NOT NULL
  --AND IS_ABOVE_BENCH = 'true'
  and datediff('hour', I.BILLING_APPROVED_DATE, I.PAID_DATE) / 24 < 120)
  select
         INVOICE_ID,
         INVOICE_NO,
         COMPANY_NAME,
         mrx.market_id as market_id,
         mrx.MARKET_NAME,
         mrx.REGION_DISTRICT as district,
         mrx.REGION,
         mrx.REGION_NAME,
         BILLING_APPROVED_DATE,
         sum(case when IS_ABOVE_BENCH = 'true' then amount else 0 end) as above_bench_collected_revenue,
         sum(case when IS_BTWN_FLOOR_BENCH = 'true' then amount else 0 end) as btwn_floor_bench_collected_revenue

  from above_benchmarket ab
  left join ANALYTICS.BRANCH_EARNINGS.PARENT_MARKET pm
    on pm.MARKET_ID = ab.BRANCH_ID
  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
    on coalesce(pm.PARENT_MARKET_ID, ab.BRANCH_ID) = mrx.MARKET_ID
  join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE rmr
    on mrx.MARKET_ID = rmr.MARKET_ID
  left join ANALYTICS.GS.PLEXI_PERIODS PP
    on date_trunc(month, TRUNC::date) = date_trunc(month, ab.BILLING_APPROVED_DATE::date)
--where DATE_TRUNC(month, ab.PAID_DATE) >= '2023-07-01 00:00:00.000' ----- Change to desired date
--and DATE_TRUNC(month, ab.PAID_DATE) < '2023-10-01 00:00:00.000'    ----- Change to desired date
Where date_trunc(month, ab.paid_date) in (select trunc::date from analytics.gs.plexi_periods
                    where {% condition display %} DISPLAY {% endcondition %})
and mrx.MARKET_TYPE != 'ITL'
and (datediff(month, date_trunc(month, rmr.BRANCH_EARNINGS_START_MONTH::date),
                                       date_trunc(month, ab.BILLING_APPROVED_DATE))+1 > 12
                                       or mrx.market_id = '86834')
and ab.PAID_DATE < '2025-01-01'
group by INVOICE_ID, INVOICE_NO, COMPANY_NAME, mrx.MARKET_ID, mrx.MARKET_NAME, mrx.REGION_DISTRICT, mrx.REGION, mrx.REGION_NAME, BILLING_APPROVED_DATE

union all

select
icr.INVOICE_ID as invoice_id,
icr.INVOICE_NUMBER as invoice_no,
icr.CUSTOMER_NAME as company_name,
mrx.MARKET_ID as market_id,
mrx.MARKET_NAME as market_name,
mrx.REGION_DISTRICT as district,
mrx.REGION as region,
mrx.REGION_NAME as region_name,
icr.BILLING_APPROVED_DATE as billing_approved_date,
sum(ABOVE_BENCH_COLLECTED_REVENUE) as above_bench_collected_revenue,
sum(BTWN_FLOOR_BENCH_COLLECTED_REVENUE) as btwn_floor_bench_collected_revenue
from ANALYTICS.INTACCT_MODELS.INT_COLLECTED_REVENUE icr
  left join ANALYTICS.BRANCH_EARNINGS.PARENT_MARKET pm
    on pm.MARKET_ID = icr.MARKET_ID
  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
    on coalesce(pm.PARENT_MARKET_ID, icr.MARKET_ID) = mrx.MARKET_ID
  join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE rmr
    on mrx.MARKET_ID = rmr.MARKET_ID
  left join ANALYTICS.GS.PLEXI_PERIODS PP
    on date_trunc(month, TRUNC::date) = date_trunc(month, icr.BILLING_APPROVED_DATE::date)
Where date_trunc(month, icr.paid_date) in (select trunc::date from analytics.gs.plexi_periods
                    where {% condition display %} DISPLAY {% endcondition %})
and mrx.MARKET_TYPE != 'ITL'
and (datediff(month, date_trunc(month, rmr.BRANCH_EARNINGS_START_MONTH::date),
                                       date_trunc(month, icr.BILLING_APPROVED_DATE))+1 > 12
                                       or mrx.MARKET_ID = '86834')
and icr.PAID_DATE >= '2025-01-01'
group by INVOICE_ID, INVOICE_NO, COMPANY_NAME, mrx.MARKET_ID, mrx.MARKET_NAME, mrx.REGION_DISTRICT, mrx.REGION, mrx.REGION_NAME, BILLING_APPROVED_DATE
;;
}

  filter: display {
    type: string
    suggestions: [
      "January 2021","February 2021","March 2021","April 2021","May 2021","June 2021","July 2021","August 2021","September 2021","October 2021","November 2021","December 2021",
      "January 2022","February 2022","March 2022","April 2022","May 2022","June 2022", "July 2022","August 2022","September 2022","October 2022","November 2022","December 2022",
      "January 2023","February 2023","March 2023","April 2023","May 2023","June 2023", "July 2023","August 2023","September 2023","October 2023","November 2023","December 2023",
      "January 2024","February 2024","March 2024","April 2024","May 2024","June 2024", "July 2024","August 2024","September 2024","October 2024","November 2024","December 2024",
      "January 2025","February 2025","March 2025","April 2025","May 2025","June 2025", "July 2025","August 2025","September 2025","October 2025","November 2025","December 2025"
    ]
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  parameter: report_period {
    #label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  parameter: report_month {
    label: "Month"
    type: number
    #default_value: "8"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: report_year {
    label: "Year"
    type: number
    allowed_value: {value: "2021"}
    allowed_value: {value: "2022"}
    allowed_value: {value: "2023"}
    allowed_value: {value: "2024"}
  }

  dimension: market_id {
    type: string
    #primary_key: yes
    label: "Market ID"
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    label: "District"
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: invoice_id {
    label: "Invoice ID"
    type: number
    primary_key: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <a style="color:rgb(26, 115, 232)" href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ collected_revenue_benchmark.invoice_no }}" target="_blank">{{value}}</a> ;;
  }

  # dimension: link_agg {
  #   label: "Links"
  #   html:
  #       {% if be_transaction_listing.url_admin._value != null %}
  #     <a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ collected_revenue.invoice_no._value }}" target="_blank">
  #       <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
  #     &nbsp;
  #   {% endif %}
  #   ;;
  # }

  dimension: company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: paid_date {
    label: "Paid Date"
    type: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: billing_approved_date {
    label: "Billing Approved Date"
    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: region_name {
    type: string
    label: "Region Name"
    sql: ${TABLE}."REGION_NAME";;
  }

  dimension: months_open {
    type: number
    label: "Months Open"
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: is_above_bench {
    label: "Above Benchmark Rate"
    type: string
    sql: ${TABLE}."IS_ABOVE_BENCH" ;;
  }

  dimension: is_btwn_floor_bench {
    label: "Between Floor and Benchmark Rate"
    type: string
    sql: ${TABLE}."IS_BTWN_FLOOR_BENCH" ;;
  }

  dimension: is_below_floor {
    label: "Below Floor Rate"
    type: string
    sql: ${TABLE}."IS_BELOW_FLOOR" ;;
  }

  dimension: collected_revenue {
    type: number
    label: "Collected Revenue"
    sql: ${TABLE}."COLLECTED_REVENUE" ;;
  }

  # measure: collected_revenue_sum {
  #   type: sum
  #   label: "Collected Revenue"
  #   sql: ${collected_revenue} ;;
  #   value_format: "$#,##0.00;($#,##0.00);-"
  #   link: {
  #     label: "Detail View"
  #     url: "@{lk_collected_revenue_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[collected_revenue_benchmark.display]={{ _filters['collected_revenue_benchmark.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
  #   }
  # }

  measure: above_bench_collected_revenue {
    type: sum
    label: "Above Benchmark Collected Revenue"
    sql: ${TABLE}.above_bench_collected_revenue ;;
    value_format: "$#,##0.00;($#,##0.00);-"
    link: {
      label: "Detail View"
      url: "@{lk_collected_revenue_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[collected_revenue_benchmark.display]={{ _filters['collected_revenue_benchmark.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
  }

  measure: btwn_floor_bench_collected_revenue {
    type: sum
    label: "Between Floor and Benchmark Collected Revenue"
    sql: ${TABLE}.btwn_floor_bench_collected_revenue ;;
    value_format: "$#,##0.00;($#,##0.00);-"
    link: {
      label: "Detail View"
      url: "@{lk_collected_revenue_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[collected_revenue_benchmark.display]={{ _filters['collected_revenue_benchmark.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
  }

  dimension: above_bench_flag {
    label: "Above Benchmark Rate?"
    type: yesno
    sql: ${TABLE}.above_bench_collected_revenue > 0;;
  }

  dimension: btwn_floor_bench_flag {
    label: "Between Floor and Benchmark Rate Flag"
    type: yesno
    sql: ${TABLE}.btwn_floor_bench_collected_revenue > 0 ;;
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      district,
      region_name
    ]
  }
}
