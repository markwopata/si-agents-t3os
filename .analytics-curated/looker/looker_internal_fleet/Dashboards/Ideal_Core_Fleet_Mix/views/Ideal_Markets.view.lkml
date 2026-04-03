view: ideal_markets {
    derived_table: {
      sql:
      with branch_monthly as (
      select
      mrx.market_id,
      mrx.market_name,
      datediff(months, market_start_month, current_date)+1 months_open,
      date_trunc(month, gl_date) as month,
      sum(amt) net_income

      from analytics.public.branch_earnings_dds_snap snp

      join analytics.public.market_region_xwalk mrx
      on snp.mkt_id = mrx.market_id
      and mrx.market_type = 'Core Solutions'

      left join analytics.gs.revmodel_market_rollout_conservative rmc
      on mrx.market_id = rmc.market_id

      where date_trunc(month, gl_date) >= dateadd(month, -13, current_date)
      and months_open >= 12
      and mrx.market_id not in (85717, 85323, 61105, 77478, 57245, 86328, 44836, 44834)
      group by mrx.market_id, mrx.market_name, months_open, month
      order by mrx.market_name, month
      )

      ,market_rank as(
      select
      market_id,
      market_name,
      sum(net_income) ttm_net_income,
      rank() OVER (order by sum(net_income) desc) as rank
      from branch_monthly
      group by market_id, market_name
      )

      select
      market_id,
      market_name,
      ttm_net_income
      from market_rank
      where rank <= 20
      ;;}


  dimension: market_id {
    primary_key: yes
    type: number
    value_format: "0"
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: ttm_net_income {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}."TTM_NET_INCOME" ;;
  }

  }
