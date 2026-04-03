view: class_level_fleet_profitability {
  derived_table: {
    sql:
      with branch_rates as (select m.child_market_id as branch_id,
                             m.region,
                             br.equipment_class_id,
                             (select ceil(sum(brr2.price_per_month))
                              from es_warehouse.public.BRANCH_RENTAL_RATES brr2
                              where brr2.branch_id = br.BRANCH_ID
                                and brr2.equipment_class_id = br.EQUIPMENT_CLASS_ID
                                and brr2.rate_type_id = 2
                                and brr2.active = true) AS benchmark_month_rate

                      from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES br
                               left join ANALYTICS.BRANCH_EARNINGS.MARKET m
                                         on br.BRANCH_ID = m.child_market_id
                               inner join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES EC
                                          on br.equipment_class_id = ec.equipment_class_id
                      where ec.COMPANY_ID = 1854
                        and ec.DELETED = 'FALSE'
                        and ec.RENTABLE = 'TRUE'
                        and m.market_id is not null
                      group by all),

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

     days_at_branch as (select iah.asset_id, iah.rental_branch_id,count(*) as days_at_branch, sum(case when iah.asset_inventory_status = 'On Rent' then 1 else 0 end) as days_on_rent,
                                ia.make,
       ia.model,
       ia.year,
       ia.equipment_class,
       ia.EQUIPMENT_CLASS_ID,
       ia.parent_category_name,
       ia.sub_category_name,
       coalesce(ia.oec, 0)                          as oec,
       coalesce(.014849 * ia.oec, 0)                as monthly_amortization,
       12 * coalesce(.014849 * ia.oec, 0)           as annual_amortization,
       coalesce(-ptr.MONTHLY_OEC_PERCENT * ia.oec, 0)          as monthly_property_tax,
       -12 * coalesce(ptr.MONTHLY_OEC_PERCENT *  ia.oec, 0)     as annual_property_tax,
       monthly_amortization + monthly_property_tax  as monthly_expenses,
       annual_property_tax + annual_amortization    as annual_expenses,
                        from analytics.assets.int_asset_historical_ownership iah
                        left join analytics.assets.int_assets ia
                            on iah.ASSET_ID = ia.asset_id
                        left join analytics.BRANCH_EARNINGS.PERSONAL_PROPERTY_TAX_RATES ptr
            on ia.RENTAL_BRANCH_ID = ptr.market_id
            and ptr.end_date is null
                        where iah.DAILY_TIMESTAMP >= dateadd(day, -364, current_date())
                        and ia.oec > 0
                        group by all),
  current_assignment as (
  select
    asset_id,
    rental_branch_id as current_rental_branch_id,
    oec as current_oec,
    asset_inventory_status as current_inventory_status
  from analytics.assets.int_assets
  where rental_branch_id is not null
),

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
       dab.asset_id,
       dab.make,
       dab.model,
       dab.year,
       dab.equipment_class,
       dab.parent_category_name,
       dab.sub_category_name,
       dab.oec                   as oec,
       dab.monthly_amortization               as monthly_amortization,
       dab.annual_amortization           as annual_amortization,
       dab.monthly_property_tax,
       dab.annual_property_tax,
       dab.monthly_expenses,
       dab.annual_expenses,
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
      dab.days_on_rent / nullif(days_at_branch, 0) as on_rent_pct,
      annual_expenses * (days_at_branch / 365) as prorated_expenses,
       case
    when ca.asset_id is not null
     and ca.current_rental_branch_id = dab.rental_branch_id
    then 1 else 0
  end as is_current_at_branch

, case
    when ca.asset_id is not null
     and ca.current_rental_branch_id = dab.rental_branch_id
    then dab.oec else 0
  end as current_oec_at_branch
  , case
    when ca.asset_id is not null
     and ca.current_rental_branch_id = dab.rental_branch_id
     and ca.current_inventory_status = 'On Rent'
    then 1 else 0
  end as is_current_on_rent_at_branch

, case
    when ca.asset_id is not null
     and ca.current_rental_branch_id = dab.rental_branch_id
     and ca.current_inventory_status = 'On Rent'
    then dab.oec else 0
  end as current_oec_on_rent_at_branch
from days_at_branch dab
         left join branch_rates br
                   on dab.rental_branch_id = br.branch_id
                       and dab.equipment_class_id = br.equipment_class_id
         left join total_asset_revenue ar
                   on dab.asset_id = ar.asset_id
         left join asset_revenue_by_branch arb
                   on dab.asset_id = arb.asset_id
                       and dab.RENTAL_BRANCH_ID = arb.market_id
        left join maint_cost mc
            on concat(dab.MAKE, ' - ', dab.MODEL) = mc.asset_equipment_make_and_model
        left join current_assignment ca
  on dab.asset_id = ca.asset_id
join analytics.branch_earnings.market m
            on dab.rental_branch_id = m.child_market_id
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

  dimension: is_current_at_branch {
    label: "Is Current at Branch"
    type: yesno
    sql: ${TABLE}."IS_CURRENT_AT_BRANCH" = 1 ;;
  }

  dimension: current_asset_flag {
    hidden: yes
    type: number
    sql: ${TABLE}."IS_CURRENT_AT_BRANCH" ;;
  }

  dimension: current_oec_at_branch {
    label: "Current OEC at Branch"
    type: number
    sql: ${TABLE}."CURRENT_OEC_AT_BRANCH" ;;
    value_format_name: "usd"
  }

  measure: asset_count {
    label: "Asset Count"
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: current_asset_count {
    label: "Current Asset Count"
    type: sum
    sql: ${current_asset_flag} ;;
    value_format_name: "decimal_0"
  }

  measure: current_oec {
    label: "Current OEC"
    type: sum
    sql: ${TABLE}."CURRENT_OEC_AT_BRANCH" ;;
    value_format_name: "usd"
  }

  dimension: make {
    label: "Make"
    type: string
    sql: ${TABLE}."MAKE" ;;

    link: {
      label: "Asset-Level Detail"
      url: "https://equipmentshare.looker.com/looks/1221?&f[asset_level_profitability.market_name]={{ _filters['class_level_fleet_profitability.market_name']}}&f[asset_level_profitability.make]={{ class_level_fleet_profitability.make._value}}&f[asset_level_profitability.parent_category]={{ _filters['class_level_fleet_profitability.parent_category']}}&f[asset_level_profitability.sub_category]={{ _filters['class_level_fleet_profitability.sub_category']}}&toggle=fil"
    }
  }
  dimension: model {
    label: "Model"
    type: string
    sql: ${TABLE}."MODEL" ;;

    link: {
      label: "Asset-Level Detail"
      url: "https://equipmentshare.looker.com/looks/1221?&f[asset_level_profitability.market_name]={{ _filters['class_level_fleet_profitability.market_name']}}&f[asset_level_profitability.model]={{ class_level_fleet_profitability.model._value}}&f[asset_level_profitability.parent_category]={{ _filters['class_level_fleet_profitability.parent_category']}}&f[asset_level_profitability.make]={{ class_level_fleet_profitability.make._value}}&f[asset_level_profitability.sub_category]={{ _filters['class_level_fleet_profitability.sub_category']}}&toggle=fil"
    }
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

    link: {
      label: "Asset-Level Detail"
      url: "https://equipmentshare.looker.com/looks/1221?toggle=fil
      &f[asset_level_profitability.market_name]={{ _filters['class_level_fleet_profitability.market_name'] | url_encode }}
      &f[asset_level_profitability.equipment_class]={{ '\"' | append: class_level_fleet_profitability.equipment_class._value | append: '\"' | url_encode }}"
    }
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
    label: "Fixed Expenses"
    type: sum
    sql: ${TABLE}."PRORATED_EXPENSES" ;;
  }
  dimension: benchmark_month_rate {
    label: "Benchmark Month Rate"
    type: number
    sql: ${TABLE}."BENCHMARK_MONTH_RATE" ;;
    value_format_name: "usd"  # optional
  }
  dimension: breakeven_months_at_benchmark {
    label: "Breakeven Months on Rent at Benchmark"
    type: number
    sql: ${TABLE}."BREAKEVEN_MONTHS_AT_BENCHMARK" ;;
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
  measure: days_at_branch {
    label: "# Days at Branch"
    type: sum
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

  measure: oec_days_at_branch {
    label: "OEC * Days at Branch"
    type: sum
    sql: ${TABLE}."OEC" * ${TABLE}."DAYS_AT_BRANCH" ;;
  }

  measure: oec_days_on_rent {
    label: "OEC * Days on Rent"
    type: sum
    sql: ${TABLE}."OEC" * ${TABLE}."DAYS_ON_RENT" ;;
  }

  measure: oec_on_rent_pct_weighted {
    label: "TTM OEC On Rent %"
    type: number
    sql: ${oec_days_on_rent} / NULLIF(${oec_days_at_branch}, 0) ;;
    value_format_name: "percent_1"
  }

  measure: maintenance_estimate {
    label: "Maintenance Estimate"
    type: sum
    sql: COALESCE(${TABLE}."TTM_REVENUE_AT_BRANCH", 0) * COALESCE(${TABLE}."MAINT_PCT", 0) ;;
    value_format_name: "usd"
  }

  measure: total_estimated_costs {
    label: "Total Estimated Costs"
    type: number
    sql: COALESCE(${prorated_expenses}, 0) + COALESCE(${maintenance_estimate}, 0) ;;
    value_format_name: "usd"
  }

  dimension: current_oec_on_rent_at_branch {
    label: "Current OEC On Rent at Branch"
    type: number
    sql: ${TABLE}."CURRENT_OEC_ON_RENT_AT_BRANCH" ;;
    value_format_name: "usd"
  }

  measure: current_oec_on_rent {
    label: "Current OEC On Rent"
    type: sum
    sql: ${TABLE}."CURRENT_OEC_ON_RENT_AT_BRANCH" ;;
    value_format_name: "usd"
  }

  measure: current_oec_on_rent_pct_today {
    label: "Current OEC On Rent %"
    type: number
    sql: ${current_oec_on_rent} / NULLIF(${current_oec}, 0) ;;
    value_format_name: "percent_1"
  }

}
