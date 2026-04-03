view: bad_debt_to_rev {
  derived_table: {
    sql:
    with periods as (
    select
    date_trunc(month, trunc::date) as month_year,
    period_published,
    display
    from analytics.gs.plexi_periods
    ),

    selected_period as (
    select max(date_trunc(month, trunc::date)) as selected_month
    from analytics.gs.plexi_periods
    where {% condition period_name %} display {% endcondition %}
    ),

    published_bad_debt as (
    select
    m.market_id,
    date_trunc(month, beds.gl_date) as month_year,
    p.display as period,
    sum(beds.amt) as bad_debt
    from analytics.public.branch_earnings_dds_snap beds
    join analytics.branch_earnings.market m
    on m.child_market_id = beds.mkt_id
    join periods p
    on date_trunc(month, beds.gl_date) = p.month_year
    where beds.acctno = 'IAAA'
    and p.period_published = 'published'
    and beds.descr not ilike '%write-off%'
    group by m.market_id, date_trunc(month, beds.gl_date), p.display
    ),

    trending_bad_debt as (
    select
    m.market_id,
    date_trunc(month, tbe.gl_date) as month_year,
    p.display as period,
    sum(tbe.amount) as bad_debt
    from analytics.branch_earnings.INT_LIVE_BRANCH_EARNINGS_LOOKER tbe
    join analytics.branch_earnings.market m
    on m.child_market_id = tbe.market_id
    join periods p
    on date_trunc(month, tbe.gl_date) = p.month_year
    where tbe.account_number = 'IAAA'
    and p.period_published is null
    and tbe.description not ilike '%write-off%'
    group by m.market_id, date_trunc(month, tbe.gl_date), p.display
    ),

    combined_bad_debt as (
    select * from published_bad_debt
    union all
    select * from trending_bad_debt
    ),

    rental_rev as (
    select
    market_id,
    date_trunc(month, gl_date) as month_year,
    rental_revenue
    from analytics.branch_earnings.high_level_financials
    )

    select
    m.market_id,
    m.market_name,
    m.region_name,
    m.region_district as district,
    m.market_type,
    bd.month_year,
    bd.period,
    rr.rental_revenue as rental_revenue_9_months_prior,
    bd.bad_debt
    from combined_bad_debt bd
    join analytics.branch_earnings.market m
    on bd.market_id = m.market_id
    and m.child_market_id = m.market_id
    left join rental_rev rr
    on bd.market_id = rr.market_id
    and rr.month_year = dateadd(month, -9, bd.month_year)
    cross join selected_period sp
    where bd.month_year between dateadd(month, -12, sp.selected_month) and sp.selected_month
    order by m.market_name, bd.month_year
    ;;
  }
  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: bad_debt_month {
    label: "Month"
    type: date
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  measure: rental_revenue_9_months_prior {
    label: "Rental Revenue 9 Months Prior"
    type: sum
    sql: ${TABLE}."RENTAL_REVENUE_9_MONTHS_PRIOR" ;;
  }

  measure: bad_debt {
    label: "Bad Debt"
    type: sum
    sql: -1 * ${TABLE}."BAD_DEBT" ;;
    value_format_name: usd_0
  }

  measure: bad_debt_pct_of_rev_9_months_prior {
    label: "Bad Debt % of Rental Revenue (9 Months Prior)"
    type: number
    sql:${bad_debt} / nullif(${rental_revenue_9_months_prior}, 0) ;;
    value_format_name: percent_2
  }

  }
