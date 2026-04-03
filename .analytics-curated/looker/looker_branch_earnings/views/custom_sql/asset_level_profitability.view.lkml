view: asset_level_profitability {
 derived_table: {
  sql:
      with branch_rates as (select br.branch_id,
                             mrx.region,
                             br.equipment_class_id,
                             (select ceil(sum(brr2.price_per_month))
                              from es_warehouse.public.BRANCH_RENTAL_RATES brr2
                              where brr2.branch_id = br.BRANCH_ID
                                and brr2.equipment_class_id = br.EQUIPMENT_CLASS_ID
                                and brr2.rate_type_id = 2
                                and brr2.active = true) AS benchmark_month_rate

                      from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES br

                               left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
                                         on br.BRANCH_ID = mrx.MARKET_ID
                               inner join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES EC
                                          on br.equipment_class_id = ec.equipment_class_id

                      where ec.COMPANY_ID = 1854
                        and ec.DELETED = 'FALSE'
                        and ec.RENTABLE = 'TRUE'
                        and mrx.market_id is not null
                      group by br.branch_id,
                               mrx.region,
                               br.equipment_class_id), on_rent as (
  select distinct
    rental_id,
    asset_id,
    price_per_month
  from es_warehouse.public.rentals
  where rental_status_id = 5
    and deleted = false
    and price_per_month is not null
)

, points_1 as (
  select
    rental_id,
    asset_id,
    market_id,
    equipment_class_id,
    equipment_class
  from analytics.public.rateachievement_points
  qualify row_number() over (
    partition by rental_id, asset_id
    order by rental_id
  ) = 1
)

, open_contract_rates_market as (
  select
    p.market_id,
    p.equipment_class_id,
    avg(r.price_per_month) as avg_price_per_month_market
  from on_rent r
  join points_1 p
    on r.rental_id = p.rental_id
   and r.asset_id  = p.asset_id
  group by 1,2
)

, open_contract_rates_company as (
  select
    p.equipment_class_id,
    avg(r.price_per_month) as avg_price_per_month_company
  from on_rent r
  join points_1 p
    on r.rental_id = p.rental_id
   and r.asset_id  = p.asset_id
  group by 1
),

     total_asset_revenue as (select asset_id, sum(amount) as ttm_revenue
                             from analytics.INTACCT_models.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL ld
                             where ld.ACCOUNT_NUMBER = '5000'
                               and ld.billing_approved_date >= dateadd(day, -364, current_date())
                             group by all),

     asset_revenue_by_branch as (select asset_id, market_id, sum(amount) as ttm_revenue
                                 from analytics.INTACCT_models.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL ld
                                 where ld.ACCOUNT_NUMBER = '5000'
                                   and ld.billing_approved_date >= dateadd(day, -364, current_date())
                                 group by all),

     days_at_branch as (select asset_id, rental_branch_id, count(*) as days_at_branch, sum(case when asset_inventory_status = 'On Rent' then 1 else 0 end) as days_on_rent
                        from analytics.assets.int_asset_historical_ownership iah
                        where iah.DAILY_TIMESTAMP >= dateadd(day, -364, current_date())
                        group by asset_id, rental_branch_id),

    maint_cost as (select
  asset_equipment_make_and_model,
  equipment_class_name,
  sum(labor_cost) as total_labor_cost,
  sum(parts_cost) as total_parts_cost,
  coalesce(sum(labor_cost) + sum(parts_cost), 0) as total_maintenance_cost,
  coalesce(sum(rental_revenue), 0) as total_rental_revenue,
  coalesce(
    (sum(labor_cost) + sum(parts_cost))
    / nullif(sum(rental_revenue), 0),
    0
  ) as maint_pct
from fleet_optimization.gold.v_total_cost_to_own_with_asset_attributes aa
where 1 = 1
group by asset_equipment_make_and_model, equipment_class_name
having total_rental_revenue > 1000000
order by maint_pct desc)

select
       m.market_name,
       m.market_id,
       ia.asset_id,
       ia.make,
       ia.model,
       ia.year,
       ia.equipment_class,
       ia.parent_category_name,
       ia.sub_category_name,
       coalesce(ia.oec, 0)                          as oec,
       coalesce(.014849 * ia.oec, 0)                as monthly_amortization,
       12 * coalesce(.014849 * ia.oec, 0)           as annual_amortization,
       -coalesce(ptr.MONTHLY_OEC_PERCENT, 0) * ia.oec as monthly_property_tax,
-12 * coalesce(ptr.MONTHLY_OEC_PERCENT, 0) * ia.oec as annual_property_tax,
       monthly_amortization + monthly_property_tax  as monthly_expenses,
       annual_property_tax + annual_amortization    as annual_expenses,
       br.benchmark_month_rate,
       annual_expenses / nullif(benchmark_month_rate, 0) / nullif(1 - coalesce(maint_pct, .2), 0) as breakeven_months_at_benchmark,
       coalesce(ar.ttm_revenue, 0)                  as ttm_revenue,
       coalesce(arb.ttm_revenue, 0)                 as ttm_revenue_at_branch,
       coalesce((arb.ttm_revenue * (1 - coalesce(maint_pct, .2))), 0) - (annual_expenses * days_at_branch / 365)     as ttm_profit_loss,
       dab.days_at_branch,
       coalesce(dab.days_on_rent, 0)                as days_on_rent,
       coalesce(mc.maint_pct, .2)                  as maint_pct,
       CASE
    WHEN dab.days_on_rent > 0
    THEN TTM_REVENUE_at_branch / dab.days_on_rent
    ELSE NULL
END AS rev_per_day,
   annual_expenses
/ NULLIF(
    rev_per_day * (1 - COALESCE(maint_pct, 0.2)),
    0
  ) AS breakeven_days,
       breakeven_days / 365 * 12 as breakeven_months,
    breakeven_months_at_benchmark / 12 as breakeven_on_rent_pct,
       ia.asset_inventory_status,
      dab.days_on_rent / nullif(days_at_branch, 0) as on_rent_pct,
      annual_expenses * (days_at_branch / 365) as prorated_expenses,
       coalesce(ocrm.avg_price_per_month_market, ocrc.avg_price_per_month_company)
    as avg_open_contract_price_per_month

, case
    when ocrm.avg_price_per_month_market is not null then 'Market'
    when ocrc.avg_price_per_month_company is not null then 'Company'
    else 'None'
  end as avg_open_contract_rate_source
  , annual_expenses
  / nullif(avg_open_contract_price_per_month, 0)
  / nullif(1 - coalesce(maint_pct, .2), 0)
  as breakeven_months_at_avg_open_rate

, breakeven_months_at_avg_open_rate / 12
  as breakeven_on_rent_pct_at_avg_open_rate
from analytics.assets.int_assets ia
         left join branch_rates br
                   on ia.rental_branch_id = br.branch_id
                       and ia.equipment_class_id = br.equipment_class_id
         left join total_asset_revenue ar
                   on ia.asset_id = ar.asset_id
         left join asset_revenue_by_branch arb
                   on ia.asset_id = arb.asset_id
                       and ia.rental_branch_id = arb.market_id
         left join days_at_branch dab
                   on dab.asset_id = ia.asset_id
                       and dab.rental_branch_id = ia.rental_branch_id
        left join maint_cost mc
            on concat(ia.MAKE, ' - ', ia.MODEL) = mc.asset_equipment_make_and_model
            join analytics.branch_earnings.market m
            on ia.rental_branch_id = m.child_market_id
       left join analytics.BRANCH_EARNINGS.PERSONAL_PROPERTY_TAX_RATES ptr
  on m.market_id = ptr.market_id
 and ptr.end_date is null
left join open_contract_rates_market ocrm
  on m.child_market_id = ocrm.market_id
 and ia.equipment_class_id = ocrm.equipment_class_id

left join open_contract_rates_company ocrc
  on ia.equipment_class_id = ocrc.equipment_class_id

where 1 = 1
  and oec > 0


    ;;
}

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: asset_id {
    label: "Asset ID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make {
    label: "Make"
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    label: "Model"
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: parent_category {
    label: "Parent Category"
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }
  dimension: sub_category {
    label: "Sub Category"
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }
  dimension: year {
    label: "Year"
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: equipment_class {
    label: "Equipment Class"
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }
  dimension: asset_inventory_status {
    label: "Inventory Status"
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  measure: oec {
    label: "OEC"
    type: sum
    sql: ${TABLE}."OEC" ;;
  }
  measure: monthly_expenses {
    label: "Monthly Expenses"
    type: sum
    sql: ${TABLE}."MONTHLY_EXPENSES" ;;
  }
  measure: annual_expenses {
    label: "Annual Expenses"
    type: sum
    sql: ${TABLE}."ANNUAL_EXPENSES" ;;
  }
  measure: prorated_expenses {
    label: "Prorated Expenses"
    type: sum
    sql: ${TABLE}."PRORATED_EXPENSES" ;;
  }
  dimension: benchmark_month_rate {
    label: "Benchmark Month Rate"
    type: number
    sql: ${TABLE}."BENCHMARK_MONTH_RATE" ;;
    value_format_name: "usd"  # optional
  }
  dimension: avg_open_contract_price_per_month {
    label: "Avg Monthly Rate (Open Contracts)"
    type: number
    sql: ${TABLE}."AVG_OPEN_CONTRACT_PRICE_PER_MONTH" ;;
    value_format_name: "usd"
  }

  dimension: avg_open_contract_rate_source {
    label: "Avg Open Contract Rate Source"
    type: string
    sql: ${TABLE}."AVG_OPEN_CONTRACT_RATE_SOURCE" ;;
  }
  dimension: breakeven_months_at_benchmark {
    label: "Breakeven Months on Rent at Benchmark"
    type: number
    sql: ${TABLE}."BREAKEVEN_MONTHS_AT_BENCHMARK" ;;
  }
  dimension: breakeven_months_at_avg_open_rate {
    label: "Breakeven Months on Rent at Avg Open Rate"
    type: number
    sql: ${TABLE}."BREAKEVEN_MONTHS_AT_AVG_OPEN_RATE" ;;
  }

  dimension: breakeven_on_rent_pct_at_avg_open_rate {
    label: "Breakeven On Rent % at Avg Open Rate"
    type: number
    sql: ${TABLE}."BREAKEVEN_ON_RENT_PCT_AT_AVG_OPEN_RATE" ;;
    value_format_name: "percent_1"
  }
  measure: ttm_rev_at_branch {
    label: "TTM Rev at Branch"
    type: sum
    sql: ${TABLE}."TTM_REVENUE_AT_BRANCH" ;;
  }
  measure: ttm_profit_loss {
    label: "TTM P/L"
    type: sum
    sql: ${TABLE}."TTM_PROFIT_LOSS" ;;
  }
  dimension: days_at_branch {
    label: "# Days at Branch"
    type: number
    sql: ${TABLE}."DAYS_AT_BRANCH" ;;
  }
  dimension: days_on_rent {
    label: "# Days on Rent"
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }
  dimension: maint_pct {
    label: "Maint % of RR"
    type: number
    sql: ${TABLE}."MAINT_PCT" ;;
    value_format_name: "percent_1"
  }
  measure: REV_PER_DAY {
    label: "Revenue Per Day on Rent"
    type: sum
    sql: ${TABLE}."REV_PER_DAY" ;;
  }
  measure: breakeven_days {
    label: "Breakeven Days on Rent"
    type: sum
    sql: ${TABLE}."BREAKEVEN_DAYS" ;;
  }
  measure: breakeven_months {
    label: "Breakeven Months on Rent"
    type: sum
    sql: ${TABLE}."BREAKEVEN_MONTHS" ;;
  }
  dimension: BREAKEVEN_ON_RENT_PCT {
    label: "Breakeven On Rent % at Benchmark"
    type: number
    sql: ${TABLE}."BREAKEVEN_ON_RENT_PCT" ;;
    value_format_name: "percent_1"
  }
  dimension: On_Rent_Pct {
    label: "On Rent %"
    type: number
    sql: ${TABLE}."ON_RENT_PCT" ;;
    value_format_name: "percent_1"
  }

}
