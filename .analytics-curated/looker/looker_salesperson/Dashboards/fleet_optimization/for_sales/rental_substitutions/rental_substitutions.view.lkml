view: rental_substitutions {
  derived_table: {
    sql:
    WITH oec AS (
        SELECT
            ec.EQUIPMENT_CLASS_ID,
            ec.NAME,
            COUNT(aa.ASSET_ID) AS ASSET_COUNT,
            SUM(CASE WHEN (aa.OEC > 0 OR aa.OEC IS NOT NULL) THEN 1 ELSE 0 END) AS NONZERO_OEC_COUNT,
            SUM(aa.OEC) AS TOTAL_OEC,
            ROUND(SUM(aa.OEC) / NULLIF(SUM(CASE WHEN (aa.OEC > 0 OR aa.OEC IS NOT NULL) THEN 1 ELSE 0 END), 0)) AS avg_oec_clean
        FROM ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
        LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa ON ec.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID
        WHERE ec.COMPANY_ID = 1854 AND (DELETED = FALSE OR DELETED IS NULL)
        GROUP BY ec.EQUIPMENT_CLASS_ID, ec.NAME
    ),

      invoices AS (
      select
   i.COMPANY_ID,
   i.INVOICE_ID,
   li.RENTAL_ID,
   li.branch_ID,
   aa.ASSET_ID,
   i.INVOICE_DATE::DATE as INVOICE_DATE,
   i.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
   m.name as branch,
   dmfo.market_district,
   dafo.asset_inventory_status,
   r.EQUIPMENT_CLASS_ID as rental_class,
   ecr.name as rental_equipment_class_name,
   aa.EQUIPMENT_CLASS_ID as invoiced_class,
   eci.name as invoiced_equipment_class_name,
   case
       when rental_class <> invoiced_class then true
       else false
       end as is_sub,
   datediff(day, i.START_DATE, i.END_DATE)                            as cycle_length,
   case
       when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and r.PRICE_PER_DAY is not null
           then true
       else false
       end as DAILY_BILLING_FLAG,
   case
       when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
       when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
       else null
       end as BILLING_TYPE,
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
                                              f.PRICE_PER_MONTH) end  as FLOOR_RATE_r,
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
                                              dr.PRICE_PER_MONTH) end as DEAL_FLOOR_r,
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
                                              b.PRICE_PER_MONTH) end  as BENCHMARK_RATE_r,
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
                                              o.PRICE_PER_MONTH) end  as ONLINE_RATE_r,



    --rates for invoiced class
       case
       when daily_billing_flag = true then (fi.PRICE_PER_MONTH / 28) * cycle_length
       when BILLING_TYPE = 'four_week' then
                   li.EXTENDED_DATA:rental:cheapest_period_hour_count * fi.PRICE_PER_HOUR +
                   li.EXTENDED_DATA:rental:cheapest_period_day_count * fi.PRICE_PER_DAY +
                   li.EXTENDED_DATA:rental:cheapest_period_week_count * fi.PRICE_PER_WEEK +
                   li.EXTENDED_DATA:rental:cheapest_period_four_week_count * fi.PRICE_PER_MONTH
       when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                              (fi.PRICE_PER_MONTH / 28) * cycle_length,
                                              li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                              fi.PRICE_PER_HOUR +
                                              li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                              fi.PRICE_PER_DAY +
                                              li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                              fi.PRICE_PER_WEEK +
                                              li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                              fi.PRICE_PER_MONTH) end  as FLOOR_RATE_i,
   case
       when DAILY_BILLING_FLAG = true then (dri.PRICE_PER_MONTH / 28) * cycle_length
       when BILLING_TYPE = 'four_week' then
                   li.EXTENDED_DATA:rental:cheapest_period_hour_count * fi.PRICE_PER_HOUR +
                   li.EXTENDED_DATA:rental:cheapest_period_day_count * fi.PRICE_PER_DAY +
                   li.EXTENDED_DATA:rental:cheapest_period_week_count * fi.PRICE_PER_WEEK +
                   li.EXTENDED_DATA:rental:cheapest_period_four_week_count * dri.PRICE_PER_MONTH
       when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                              (dri.PRICE_PER_MONTH / 28) * cycle_length,
                                              li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                              fi.PRICE_PER_HOUR +
                                              li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                              fi.PRICE_PER_DAY +
                                              li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                              fi.PRICE_PER_WEEK +
                                              li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                              dri.PRICE_PER_MONTH) end as DEAL_FLOOR_i,
   case
       when daily_billing_flag = true then (bi.PRICE_PER_MONTH / 28) * cycle_length
       when BILLING_TYPE = 'four_week' then
                   li.EXTENDED_DATA:rental:cheapest_period_hour_count * bi.PRICE_PER_HOUR +
                   li.EXTENDED_DATA:rental:cheapest_period_day_count * bi.PRICE_PER_DAY +
                   li.EXTENDED_DATA:rental:cheapest_period_week_count * bi.PRICE_PER_WEEK +
                   li.EXTENDED_DATA:rental:cheapest_period_four_week_count * bi.PRICE_PER_MONTH
       when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                              (bi.PRICE_PER_MONTH / 28) * cycle_length,
                                              li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                              bi.PRICE_PER_HOUR +
                                              li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                              bi.PRICE_PER_DAY +
                                              li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                              bi.PRICE_PER_WEEK +
                                              li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                              bi.PRICE_PER_MONTH) end  as BENCHMARK_RATE_i,
   case
       when daily_billing_flag = true then (oi.PRICE_PER_MONTH / 28) * cycle_length
       when BILLING_TYPE = 'four_week' then
                   li.EXTENDED_DATA:rental:cheapest_period_hour_count * oi.PRICE_PER_HOUR +
                   li.EXTENDED_DATA:rental:cheapest_period_day_count * oi.PRICE_PER_DAY +
                   li.EXTENDED_DATA:rental:cheapest_period_week_count * oi.PRICE_PER_WEEK +
                   li.EXTENDED_DATA:rental:cheapest_period_four_week_count * oi.PRICE_PER_MONTH
       when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                              (oi.PRICE_PER_MONTH / 28) * cycle_length,
                                              li.EXTENDED_DATA:rental:cheapest_period_hour_count *
                                              oi.PRICE_PER_HOUR +
                                              li.EXTENDED_DATA:rental:cheapest_period_day_count *
                                              oi.PRICE_PER_DAY +
                                              li.EXTENDED_DATA:rental:cheapest_period_week_count *
                                              oi.PRICE_PER_WEEK +
                                              li.EXTENDED_DATA:rental:cheapest_period_month_count *
                                                  oi.PRICE_PER_MONTH) end  as ONLINE_RATE_i,
   concat('$', round(COALESCE(DEAL_FLOOR_r, FLOOR_RATE_r)), ' / $', round(BENCHMARK_RATE_r), ' / $', round(ONLINE_RATE_r)) as monthly_rental_class_rates,
   round(COALESCE(DEAL_FLOOR_r, FLOOR_RATE_r),2) as monthly_rental_floor_rate,
   round(BENCHMARK_RATE_r,2) as monthly_rental_bench_rate,
   round(ONLINE_RATE_r) as monthly_rental_online_rate,
   concat('$', round(COALESCE(DEAL_FLOOR_i, FLOOR_RATE_i)), ' / $', round(BENCHMARK_RATE_i), ' / $', round(ONLINE_RATE_i)) as monthly_invoiced_class_rates,
    round(COALESCE(DEAL_FLOOR_i, FLOOR_RATE_i),2) as monthly_invoiced_floor_rate,
    round(BENCHMARK_RATE_i, 2) as monthly_invoiced_bench_rate,
    round(ONLINE_RATE_i, 2) as monthly_invoiced_online_rate,
   case
       when DAILY_BILLING_FLAG = true then li.EXTENDED_DATA:rental:price_per_day * cycle_length
       when BILLING_TYPE = 'four_week' then li.EXTENDED_DATA:rental:price_per_four_weeks
       when BILLING_TYPE = 'monthly' then li.EXTENDED_DATA:rental:price_per_month::number end as current_monthly_rental_rate,
   round(li.AMOUNT,2) as actual_total,
   r.START_DATE,
   r.END_DATE,
   oer.avg_oec_clean as rental_class_OEC,
   oei.avg_oec_clean as invoiced_class_OEC
-- ROW_NUMBER() OVER (PARTITION BY r.RENTAL_ID, r.ASSET_ID ORDER BY INVOICE_DATE DESC) as row_num
from ES_WAREHOUSE.PUBLIC.INVOICES i
     join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
     join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
     LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS ord on ord.ORDER_ID = r.ORDER_ID
     join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on li.ASSET_ID = aa.ASSET_ID
     join es_warehouse.PUBLIC.MARKETS m on li.branch_ID = m.MARKET_ID
     join fleet_optimization.gold.dim_assets_fleet_opt dafo on dafo.asset_id = aa.asset_id
     join fleet_optimization.gold.dim_markets_fleet_opt dmfo on dmfo.market_id = m.market_id
    left join oec as oei on oei.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID
    left join oec as oer on oer.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
     LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on m.MARKET_ID = rr.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ecr on ecr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES eci on eci.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID
     LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dr
                   on dr.DISTRICT = rr.DISTRICT and dr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID and
                      dr.DATE_CREATED <= ord.DATE_CREATED and
                      (ord.DATE_CREATED <= dr.DATE_VOIDED or dr.DATE_VOIDED is null)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) o
                   on r.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = o.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= o.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(o.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (o.DATE_VOIDED IS NOT NULL OR o.ACTIVE)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) b
                   on r.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = b.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= b.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(b.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (b.DATE_VOIDED IS NOT NULL OR b.ACTIVE)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) f
                   on r.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = f.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= f.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(f.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (f.DATE_VOIDED IS NOT NULL OR f.ACTIVE)


         LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dri
                   on dri.DISTRICT = rr.DISTRICT and dri.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID and
                      dri.DATE_CREATED <= ord.DATE_CREATED and
                      (ord.DATE_CREATED <= dri.DATE_VOIDED or dri.DATE_VOIDED is null)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 1) oi
                   on aa.EQUIPMENT_CLASS_ID = oi.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = oi.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= oi.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(oi.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (o.DATE_VOIDED IS NOT NULL OR o.ACTIVE)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 2) bi
                   on aa.EQUIPMENT_CLASS_ID = bi.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = bi.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= bi.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(bi.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (b.DATE_VOIDED IS NOT NULL OR b.ACTIVE)
         LEFT JOIN (select * from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES where RATE_TYPE_ID = 3) fi
                   on aa.EQUIPMENT_CLASS_ID = fi.EQUIPMENT_CLASS_ID and
                      i.SHIP_FROM:branch_id = fi.BRANCH_ID and
                      i.BILLING_APPROVED_DATE >= fi.DATE_CREATED and i.BILLING_APPROVED_DATE <
                                                                    coalesce(fi.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz) and
                      (fi.DATE_VOIDED IS NOT NULL OR fi.ACTIVE)



where li.LINE_ITEM_TYPE_ID = 8
and m.COMPANY_ID = 1854
and is_sub = true
and monthly_rental_floor_rate is not null
and monthly_invoiced_floor_rate is not null
QUALIFY ROW_NUMBER() OVER (PARTITION BY r.RENTAL_ID, r.ASSET_ID ORDER BY INVOICE_DATE DESC) = 1
      ),

      available_assets_by_market as (
          select
            aa.equipment_class_id,
            dmfo.market_id,
            count(distinct aa.asset_id) as eligible_asset_count
          from es_warehouse.public.assets_aggregate aa
          join fleet_optimization.gold.dim_assets_fleet_opt dafo
            on aa.asset_id = dafo.asset_id
          join fleet_optimization.gold.dim_markets_fleet_opt dmfo
            on dafo.asset_market_id = dmfo.market_id
          where dafo.asset_inventory_status = 'Ready To Rent'
          group by aa.equipment_class_id, dmfo.market_id
        ),

        available_assets_by_district as (
          select
            aa.equipment_class_id,
            dmfo.market_district,
            count(distinct aa.asset_id) as eligible_asset_count
          from es_warehouse.public.assets_aggregate aa
          join fleet_optimization.gold.dim_assets_fleet_opt dafo
            on aa.asset_id = dafo.asset_id
          join fleet_optimization.gold.dim_markets_fleet_opt dmfo
            on dafo.asset_market_id = dmfo.market_id
          where dafo.asset_inventory_status = 'Ready To Rent'
          group by aa.equipment_class_id, dmfo.market_district
        ),

        available_assets_to_recommend as (
          select
            aa.asset_id,
            aa.equipment_class_id,
            ec.name as recommended_asset_class_name,
            dmfo.market_id,
            dmfo.market_district,
            aa.oec,
            dafo.asset_inventory_status
          from es_warehouse.public.assets_aggregate aa
          join fleet_optimization.gold.dim_assets_fleet_opt dafo
            on aa.asset_id = dafo.asset_id
          join fleet_optimization.gold.dim_markets_fleet_opt dmfo
            on dafo.asset_market_id = dmfo.market_id
          JOIN es_warehouse.public.equipment_classes ec
            ON aa.equipment_class_id = ec.equipment_class_id
          where dafo.asset_inventory_status = 'Ready To Rent'
        )

      SELECT
      i.branch,
      i.branch_id,
      i.asset_id as rented_asset_id,
      i.rental_id,
      i.INVOICE_ID,
      i.current_monthly_rental_rate,
      i.START_DATE::DATE AS rental_start_date,
      i.END_DATE::DATE AS rental_end_date,
      i.rental_equipment_class_name,
      i.rental_class_OEC,
      i.monthly_rental_class_rates,
      i.monthly_rental_floor_rate,
      i.monthly_rental_bench_rate,
      i.monthly_rental_online_rate,
      i.invoiced_equipment_class_name,
      i.invoiced_class_OEC,
      i.monthly_invoiced_class_rates,
      i.monthly_invoiced_floor_rate,
      i.monthly_invoiced_bench_rate,
      i.monthly_invoiced_online_rate,
      i.monthly_rental_floor_rate - i.monthly_invoiced_floor_rate AS monthly_floor_profit,
      i.monthly_rental_bench_rate - i.monthly_invoiced_bench_rate AS monthly_bench_profit,
      i.monthly_rental_online_rate - i.monthly_invoiced_online_rate AS monthly_online_profit,
      coalesce(mac.eligible_asset_count,0) as eligible_assets_in_market,
      coalesce(dac.eligible_asset_count,0) as eligible_assets_in_district,
      aar.asset_id as recommended_asset_id,
      aar.market_id as recommended_asset_market,
      round(aar.oec,2) as recommended_asset_oec,
      aar.asset_inventory_status as recommended_asset_status,
      aar.equipment_class_id as recommended_class_id,
      aar.recommended_asset_class_name
      FROM invoices i
      left join available_assets_by_market mac on i.rental_class = mac.equipment_class_id and i.branch_id = mac.market_id
      left join available_assets_by_district dac on i.rental_class = dac.equipment_class_id and i.market_district = dac.market_district
      left join available_assets_to_recommend aar
        on i.rental_class = aar.equipment_class_id
       and i.market_district = aar.market_district
      qualify row_number() over (
        partition by i.rental_id
        order by
          case when i.branch_id = aar.market_id then 0 else 1 end,
          aar.oec asc
      ) = 1
      order by RENTAL_ID, INVOICE_DATE desc
      ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}.branch ;;
    label: "Branch"
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.branch_id ;;
    value_format_name: id
  }

  dimension: rented_asset_id {
    type: number
    sql: ${TABLE}."RENTED_ASSET_ID" ;;
    value_format_name: id
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}.rental_id ;;
    label: "Rental ID"
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.invoice_id ;;
    label: "Invoice ID"
  }

  dimension_group: rental_start_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.rental_start_date ;;
    label: "Rental Start Date"
  }

  dimension_group: rental_end_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.rental_end_date ;;
    label: "Rental End Date"
  }


  dimension: rental_equipment_class_name {
    type: string
    sql: ${TABLE}.rental_equipment_class_name ;;
    label: "Rented Equipment Class"
  }

  dimension: invoiced_equipment_class_name {
    type: string
    sql: ${TABLE}.invoiced_equipment_class_name ;;
    label: "Invoiced Equipment Class"
  }

  dimension: monthly_rental_class_rates {
    type: string
    sql: ${TABLE}.monthly_rental_class_rates ;;
    label: "Monthly Rental Class Rate (F/D/O)"
  }

  dimension: monthly_invoiced_class_rates {
    type: string
    sql: ${TABLE}.monthly_invoiced_class_rates ;;
    label: "Monthly Invoiced Class Rate (F/D/O)"
  }

  dimension: monthly_floor_profit_dim {
    type: number
    sql: ${TABLE}."MONTHLY_FLOOR_PROFIT" ;;
  }

  dimension: eligible_assets_in_market {
    type: number
    sql: ${TABLE}.eligible_assets_in_market ;;
    label: "Eligible Assets in Market"
  }

  dimension: eligible_assets_in_district {
    type: number
    sql: ${TABLE}.eligible_assets_in_district ;;
    label: "Eligible Assets in District"
  }

  dimension: recommended_asset_id {
    type: string
    sql: ${TABLE}.recommended_asset_id ;;
    label: "Recommended Asset ID"
  }

  dimension: recommended_asset_market {
    type: string
    sql: ${TABLE}.recommended_asset_market ;;
    label: "Recommended Asset Market"
  }

  dimension: recommended_asset_oec {
    type: number
    sql: ${TABLE}.recommended_asset_oec ;;
    label: "Recommended Asset OEC"
    value_format_name: usd
  }

  dimension: recommended_asset_status {
    type: string
    sql: ${TABLE}.recommended_asset_status ;;
    label: "Recommended Asset Status"
  }

  dimension: recommended_asset_class_id {
    type: number
    sql: ${TABLE}."RECOMMENDED_ASSET_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: recommended_asset_class_name {
    type: string
    sql: ${TABLE}."RECOMMENDED_ASSET_CLASS_NAME" ;;
  }

  measure: current_monthly_rental_rate {
    type: average
    sql: ${TABLE}.current_monthly_rental_rate ;;
    label: "Avg. Current Monthly Rental Rate"
    value_format_name: usd
  }

  measure: rental_class_oec {
    type: average
    sql: ${TABLE}.rental_class_oec ;;
    label: "Avg. Rental Class OEC"
    value_format_name: usd
  }

  measure: invoiced_class_oec {
    type: average
    sql: ${TABLE}.invoiced_class_oec ;;
    label: "Avg. Invoiced Class OEC"
    value_format_name: usd
  }

  measure: monthly_rental_floor_rate {
    type: average
    sql: ${TABLE}.monthly_rental_floor_rate ;;
    label: "Avg. Rental Floor Rate"
    value_format_name: usd
  }

  measure: monthly_rental_bench_rate {
    type: average
    sql: ${TABLE}.monthly_rental_bench_rate ;;
    label: "Avg. Rental Benchmark Rate"
    value_format_name: usd
  }

  measure: monthly_rental_online_rate {
    type: average
    sql: ${TABLE}.monthly_rental_online_rate ;;
    label: "Avg. Rental Online Rate"
    value_format_name: usd
  }

  measure: monthly_invoiced_floor_rate {
    type: average
    sql: ${TABLE}.monthly_invoiced_floor_rate ;;
    label: "Avg. Invoiced Floor Rate"
    value_format_name: usd
  }

  measure: monthly_invoiced_bench_rate {
    type: average
    sql: ${TABLE}.monthly_invoiced_bench_rate ;;
    label: "Avg. Invoiced Benchmark Rate"
    value_format_name: usd
  }

  measure: monthly_invoiced_online_rate {
    type: average
    sql: ${TABLE}.monthly_invoiced_online_rate ;;
    label: "Avg. Invoiced Online Rate"
    value_format_name: usd
  }

  measure: monthly_floor_profit {
    type: average
    sql: ${TABLE}.monthly_rental_floor_rate - ${TABLE}.monthly_invoiced_floor_rate ;;
    label: "Avg. Monthly Floor Profit"
    value_format_name: usd
  }

  measure: monthly_bench_profit {
    type: average
    sql: ${TABLE}.monthly_rental_bench_rate - ${TABLE}.monthly_invoiced_bench_rate ;;
    label: "Avg. Monthly Benchmark Profit"
    value_format_name: usd
  }

  measure: monthly_online_profit {
    type: average
    sql: ${TABLE}.monthly_rental_online_rate - ${TABLE}.monthly_invoiced_online_rate ;;
    label: "Avg. Monthly Online Profit"
    value_format_name: usd
  }

  measure: total_current_monthly_rental_rate {
    type: sum
    sql: ${TABLE}.current_monthly_rental_rate ;;
    label: "Total Current Monthly Rental Rate"
    value_format_name: usd
  }

  measure: total_rental_class_oec {
    type: sum
    sql: ${TABLE}.rental_class_oec ;;
    label: "Total Rental Class OEC"
    value_format_name: usd
  }

  measure: total_invoiced_class_oec {
    type: sum
    sql: ${TABLE}.invoiced_class_oec ;;
    label: "Total Invoiced Class OEC"
    value_format_name: usd
  }

  measure: total_monthly_rental_floor_rate {
    type: sum
    sql: ${TABLE}.monthly_rental_floor_rate ;;
    label: "Total Rental Floor Rate"
    value_format_name: usd
  }

  measure: total_monthly_rental_bench_rate {
    type: sum
    sql: ${TABLE}.monthly_rental_bench_rate ;;
    label: "Total Rental Benchmark Rate"
    value_format_name: usd
  }

  measure: total_monthly_rental_online_rate {
    type: sum
    sql: ${TABLE}.monthly_rental_online_rate ;;
    label: "Total Rental Online Rate"
    value_format_name: usd
  }

  measure: total_monthly_invoiced_floor_rate {
    type: sum
    sql: ${TABLE}.monthly_invoiced_floor_rate ;;
    label: "Total Invoiced Floor Rate"
    value_format_name: usd
  }

  measure: total_monthly_invoiced_bench_rate {
    type: sum
    sql: ${TABLE}.monthly_invoiced_bench_rate ;;
    label: "Total Invoiced Benchmark Rate"
    value_format_name: usd
  }

  measure: total_monthly_invoiced_online_rate {
    type: sum
    sql: ${TABLE}.monthly_invoiced_online_rate ;;
    label: "Total Invoiced Online Rate"
    value_format_name: usd
  }

  measure: total_monthly_floor_profit {
    type: sum
    sql: ${TABLE}.monthly_rental_floor_rate - ${TABLE}.monthly_invoiced_floor_rate ;;
    label: "Total Monthly Floor Profit"
    value_format_name: usd
  }

  measure: total_monthly_bench_profit {
    type: sum
    sql: ${TABLE}.monthly_rental_bench_rate - ${TABLE}.monthly_invoiced_bench_rate ;;
    label: "Total Monthly Benchmark Profit"
    value_format_name: usd
  }

  measure: total_monthly_online_profit {
    type: sum
    sql: ${TABLE}.monthly_rental_online_rate - ${TABLE}.monthly_invoiced_online_rate ;;
    label: "Total Monthly Online Profit"
    value_format_name: usd
  }


}
