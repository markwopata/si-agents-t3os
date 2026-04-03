view: price_volume_mix_analysis {
  derived_table: {
    sql:
    with date_params as(
    select {% parameter prior_period_start %}::date as prior_period_start
         , {% parameter prior_period_end %}::date as prior_period_end
         , {% parameter current_period_start %}::date as current_period_start
         , {% parameter current_period_end %}::date as current_period_end)

      , prior_period as(
      select m.region_name as region
      , m.district as district
      , m.market_name as market
      , m.market_type
      , iah.category as equipment_category
      , iah.equipment_class
      , sum(iah.units_on_rent) as days_rented
      from analytics.assets.int_asset_historical iah
      join analytics.branch_earnings.market m on iah.market_id = m.child_market_id
      where iah.daily_timestamp::date between (select prior_period_start from date_params) and (select prior_period_end from date_params)
      group by all)

      , prior_period_rev as(
      select m.market_name as market
      , ia.category as equipment_category
      , ia.equipment_class
      , sum(i.amount) as rental_rev
      from analytics.INTACCT_MODELS.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL i
      join analytics.branch_earnings.market m on i.market_id = m.CHILD_MARKET_ID
      left join analytics.assets.int_assets ia on i.asset_id = ia.asset_id
      where i.gl_date::date between (select prior_period_start from date_params) and (select prior_period_end from date_params)
      and i.is_rental_revenue = true
      and i.is_billing_approved = true
      and i.is_intercompany = false
      group by all)

      , current_period as(
      select m.region_name as region
      , m.district as district
      , m.market_name as market
      , m.market_type
      , iah.category as equipment_category
      , iah.equipment_class
      , sum(iah.units_on_rent) as days_rented
      from analytics.assets.int_asset_historical iah
      join analytics.branch_earnings.market m on iah.market_id = m.child_market_id
      where iah.daily_timestamp::date between (select current_period_start from date_params) and (select current_period_end from date_params)
      group by all)

      , current_period_rev as(
      select m.market_name as market
      , ia.category as equipment_category
      , ia.equipment_class
      , sum(i.amount) as rental_rev
      from analytics.INTACCT_MODELS.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL i
      join analytics.branch_earnings.market m on i.market_id = m.CHILD_MARKET_ID
      left join analytics.assets.int_assets ia on i.asset_id = ia.asset_id
      where i.gl_date::date between (select current_period_start from date_params) and (select current_period_end from date_params)
      and i.is_rental_revenue = true
      and i.is_billing_approved = true
      and i.is_intercompany = false
      group by all)

      select 'Company' as company
      , coalesce(pp.region,cp.region) as region
      , coalesce(pp.district,cp.district) as district
      , coalesce(pp.market,cp.market) as market
      , coalesce(pp.market_type,cp.market_type) as market_type
      , coalesce(pp.equipment_category,cp.equipment_category) as equipment_category
      , coalesce(pp.equipment_class,cp.equipment_class) as equipment_class
      , coalesce(pp.days_rented,0) as prior_days_rented
      , coalesce(ppr.rental_rev,0) as prior_rental_rev
      , coalesce(cp.days_rented,0) as curr_days_rented
      , coalesce(cpr.rental_rev,0) as curr_rental_rev
      from prior_period pp
      full outer join current_period cp on pp.market = cp.market and pp.equipment_category = cp.equipment_category and pp.equipment_class = cp.equipment_class
      left join prior_period_rev ppr on pp.market = ppr.market and pp.equipment_category = ppr.equipment_category and pp.equipment_class = ppr.equipment_class
      left join current_period_rev cpr on cp.market = cpr.market and cp.equipment_category = cpr.equipment_category and cp.equipment_class = cpr.equipment_class
      ;;
  }

  parameter: prior_period_start {
    type: date
    default_value: "2025-10-01"
  }

  parameter: prior_period_end {
    type: date
    default_value: "2025-10-31"
  }

  parameter: current_period_start {
    type: date
    default_value: "2025-11-01"
  }

  parameter: current_period_end {
    type: date
    default_value: "2025-11-30"
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  measure: prior_avg_daily_rate {
    type: number
    value_format_name: decimal_2
    sql: zeroifnull(sum(${TABLE}."PRIOR_RENTAL_REV")/sum(nullifzero(${TABLE}."PRIOR_DAYS_RENTED"))) ;;
  }

  measure: prior_days_rented {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."PRIOR_DAYS_RENTED" ;;
  }

  measure: prior_rental_rev {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."PRIOR_RENTAL_REV" ;;
  }

  measure: curr_avg_daily_rate {
    type: number
    value_format_name: decimal_2
    sql: zeroifnull(sum(${TABLE}."CURR_RENTAL_REV")/sum(nullifzero(${TABLE}."CURR_DAYS_RENTED"))) ;;
  }

  measure: curr_days_rented {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."CURR_DAYS_RENTED" ;;
  }

  measure: curr_rental_rev {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."CURR_RENTAL_REV" ;;
  }

  measure: rev_change {
    type: number
    value_format_name: decimal_2
    sql: sum(${TABLE}."CURR_RENTAL_REV") - sum(${TABLE}."PRIOR_RENTAL_REV") ;;
  }

  measure: rev_change_pct {
    type: number
    value_format_name: percent_2
    sql: (sum(${TABLE}."CURR_RENTAL_REV") - sum(${TABLE}."PRIOR_RENTAL_REV"))/nullifzero(sum(${TABLE}."PRIOR_RENTAL_REV")) ;;
  }

  measure: rate_change {
    type: number
    value_format_name: decimal_2
    sql: ${curr_avg_daily_rate} - ${prior_avg_daily_rate} ;;
  }

  measure: rate_impact {
    type: number
    value_format_name: decimal_2
    sql: ${prior_days_rented} * ${rate_change} ;;
  }

  measure: rate_impact_pct {
    type: number
    value_format_name: percent_2
    sql: (${prior_days_rented} * ${rate_change})/nullifzero(${prior_rental_rev}) ;;
  }

  measure: vol_change {
    type: number
    value_format_name: decimal_2
    sql: sum(${TABLE}."CURR_DAYS_RENTED") - sum(${TABLE}."PRIOR_DAYS_RENTED") ;;
  }

  measure: vol_impact {
    label: "Vol Impact (Excl Mix)"
    type: number
    value_format_name: decimal_2
    sql: ${curr_avg_daily_rate} * ${vol_change} ;;
  }

}
