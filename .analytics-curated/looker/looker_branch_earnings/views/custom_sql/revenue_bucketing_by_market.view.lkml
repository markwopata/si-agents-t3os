view: revenue_bucketing_by_market {
  derived_table: {
    sql:
-- Purpose: select each market's age at a given month end with its respective OEC amount
with market_age_and_oec as (select m.market_id                                                       as market_id,
                                   m.market_name                                                     as market_name,
                                   hlf.oec,
                                   hlf.gl_date,
                                   datediff(month, rev.branch_earnings_start_month, hlf.gl_date) + 1 as months_open,
                                   iff(datediff(month, rev.branch_earnings_start_month, hlf.gl_date) + 1 > 12, true,
                                       false)                                                        as is_market_over_12
                            from analytics.branch_earnings.high_level_financials hlf
                                     join analytics.branch_earnings.market m
                                          on hlf.market_id = m.child_market_id
                                     join analytics.gs.revmodel_market_rollout_conservative rev
                                          on m.child_market_id = rev.market_id
--                             only select markets that have started in branch earnings
                            where datediff(month, rev.branch_earnings_start_month, hlf.gl_date) >= -1)
--      get p&ls per branch per month, combining both trending and snap models
   , trending_and_snap_be as (select xw.market_id                 as market_id,
                                     xw.market_name               as market_name,
                                     xw.market_type               as market_type,
                                     type                         as account_type,
                                     acctno                       as account_number,
                                     gl_acct                      as account_name,
                                     date_trunc('month', gl_date) as gl_month,
                                     'BE_SNAP'                    as be_model,
                                     sum(amt)                     as total_amount
                              from analytics.public.branch_earnings_dds_snap beds
                                       join analytics.gs.plexi_periods pp
                                            on date_trunc('month', beds.gl_date)::date = pp.trunc::date
                                                and pp.period_published = 'published'
                                  --joining by parent market to group child and parent market together
                                       left join analytics.branch_earnings.parent_market pm
                                                 on pm.market_id = beds.mkt_id
                                                     and
                                                    date_trunc(month, pm.start_date) <= date_trunc(month, beds.gl_date)
                                                     and coalesce(date_trunc(month, pm.end_date), '2099-12-31') >=
                                                         date_trunc(month, beds.gl_date)
                                  -- selecting parent market id for analysises
                                       join analytics.public.market_region_xwalk xw
                                            on coalesce(pm.parent_market_id, beds.mkt_id) = xw.market_id
                              group by all
                              union all
                              select xw.market_id     as market_id,
                                     xw.market_name   as market_name,
                                     xw.market_type   as market_type,
                                     account_category as account_type,
                                     account_number   as account_number,
                                     account_name     as account_name,
                                     gl_month         as gl_month,
                                     'BE_TRENDING'    as be_model,
                                     sum(amount)      as total_amount
                              from analytics.branch_earnings.int_live_branch_earnings_looker lbel
                                       join analytics.gs.plexi_periods pp
                                            on lbel.gl_month = pp.trunc::date
                                                -- filtering for periods that haven't been published yet
                                                and pp.period_published is null
                                                -- only selecting months past and current months, not future months
                                                and pp.trunc::date <= current_date
                                  --joining by parent market to group child and parent market together
                                       left join analytics.branch_earnings.parent_market pm
                                                 on pm.market_id = lbel.market_id
                                                     and
                                                    date_trunc(month, pm.start_date) <= date_trunc(month, lbel.gl_date)
                                                     and coalesce(date_trunc(month, pm.end_date), '2099-12-31') >=
                                                         date_trunc(month, lbel.gl_date)
                                  -- selecting parent market id for analysises
                                       join analytics.public.market_region_xwalk xw
                                            on coalesce(pm.parent_market_id, lbel.market_id) = xw.market_id
                              group by all)
--      get total monthly rental revenue with its respective market age and oec
   , monthly_rental_revenue as (select be_total.market_id
                                     , be_total.market_name
                                     , be_total.account_type
                                     , be_total.market_type
                                     , be_total.gl_month
                                     , mao.is_market_over_12
                                     , mao.months_open
                                     , mao.oec
                                     , sum(be_total.total_amount) as total_rental_revenue
                                from trending_and_snap_be be_total
                                         join market_age_and_oec mao
                                              on be_total.market_id = mao.market_id and be_total.gl_month = mao.gl_date
                                where account_type = 'Rental Revenues'
                                group by all)

--    bucket markets into tertiles based on rental revenue per market type, market age, and gl_month
   , bucketing as (select *
                        , ntile(3)
                                over (partition by market_type
                                    , is_market_over_12
                                    , gl_month order by total_rental_revenue) as revenue_bucket
                   from monthly_rental_revenue)
      select *
      from bucketing
      where gl_month in (
      select trunc::date
      from analytics.gs.plexi_periods
      where {% condition period_name %} display {% endcondition %}
      )
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

  dimension: gl_month {
    label: "Revenue Month"
    type: date
    sql: ${TABLE}."GL_MONTH" ;;
  }

  dimension: is_market_over_12 {
    label: "Is market over 12"
    type: yesno
    sql: ${TABLE}."IS_MARKET_OVER_12" ;;
  }

  dimension: revenue_bucket {
    label: "Revenue Bucket"
    type: string
    sql: ${TABLE}."REVENUE_BUCKET" ;;
  }

  dimension: months_open {
    label: "Total Months Open"
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  measure: oec {
    label: "Average OEC (USD$)"
    type: average
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: total_rental_revenue {
    label: "Average Rental Revenue (USD$)"
    type: average
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_RENTAL_REVENUE" ;;
  }


}
