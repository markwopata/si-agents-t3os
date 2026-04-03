view: commissions_time_series {
  derived_table: {
    sql:
      with
      base as (
        select
          date_trunc('month', commission_month) as month_start, -- revenue month and commission month are the same
          year(month_start) as year,
          sum(amount) as total_revenue,
          sum(commission_amount) as total_commission,
          sum(commission_amount) / sum(amount) as commission_to_revenue
        from ANALYTICS.COMMISSION_DBT.COMMISSION_FINAL_ALL
        group by 1, 2
      ),

      guarantee_base as (
      select
      mg.period,
      count(case when mg.guarantee_amount > 0 then 1 end) as user_count,
      sum(mg.guarantee_amount) as total_guarantee,
      sum(mg.guarantee_amount) / nullif(max(b.total_revenue),0) as guarantee_to_revenue,
      sum(mg.guarantee_amount) / nullif(count(case when mg.guarantee_amount > 0 then 1 end), 0) as avg_guarantee
      from analytics.commission.monthly_guarantees mg
      inner join base b on b.month_start = mg.period
      group by 1
      ),

      prev_month as (
      select
      dateadd(month, 1, b.month_start) as month_start,
      b.total_revenue as prev_month_revenue,
      b.total_commission as prev_month_commission,
      b.commission_to_revenue as prev_month_commission_to_revenue,
      gb.guarantee_to_revenue as prev_month_guarantee_to_revenue,
      gb.avg_guarantee as prev_month_avg_guarantee
      from base b
      left join guarantee_base gb on b.month_start = gb.period  -- Use LEFT JOIN to retain all months
      ),

      prev_year as (
      select
      dateadd(year, 1, b.month_start) as month_start,
      b.total_revenue as prev_year_revenue,
      b.total_commission as prev_year_commission,
      b.commission_to_revenue as prev_year_commission_to_revenue,
      gb.guarantee_to_revenue as prev_year_guarantee_to_revenue,
      gb.avg_guarantee as prev_year_avg_guarantee
      from base b
      left join guarantee_base gb on b.month_start = gb.period  -- Use LEFT JOIN to retain all months
      )

      select
      b.month_start,
      b.year,

      b.total_revenue,
      pm.prev_month_revenue,
      py.prev_year_revenue,
      (b.total_revenue - pm.prev_month_revenue) / nullif(pm.prev_month_revenue, 0) as mom_revenue_change,
      (b.total_revenue - py.prev_year_revenue) / nullif(py.prev_year_revenue, 0) as yoy_revenue_change,

      b.total_commission,
      pm.prev_month_commission,
      py.prev_year_commission,
      (b.total_commission - pm.prev_month_commission) / nullif(pm.prev_month_commission, 0) as mom_commission_change,
      (b.total_commission - py.prev_year_commission) / nullif(py.prev_year_commission, 0) as yoy_commission_change,

      gb.total_guarantee,

      b.commission_to_revenue,
      pm.prev_month_commission_to_revenue,
      py.prev_year_commission_to_revenue,
      (b.commission_to_revenue - pm.prev_month_commission_to_revenue) as mom_commission_to_revenue_change,
      (b.commission_to_revenue - py.prev_year_commission_to_revenue) as yoy_commission_to_revenue_change,

      gb.guarantee_to_revenue,
      pm.prev_month_guarantee_to_revenue,
      py.prev_year_guarantee_to_revenue,
      (gb.guarantee_to_revenue - pm.prev_month_guarantee_to_revenue) as mom_gurantee_to_revenue_change,
      (gb.guarantee_to_revenue - py.prev_year_guarantee_to_revenue) as yoy_guarantee_to_revenue_change,

      gb.avg_guarantee,
      pm.prev_month_avg_guarantee,
      py.prev_year_avg_guarantee,
      (gb.avg_guarantee - pm.prev_month_avg_guarantee) as mom_avg_guarantee_change,
      (gb.avg_guarantee - py.prev_year_avg_guarantee) as yoy_avg_guarantee_change


      from base b
      left join prev_month pm on b.month_start = pm.month_start
      left join prev_year py on b.month_start = py.month_start
      left join guarantee_base gb on b.month_start = gb.period
      order by b.month_start desc
      ;;
  }

  dimension: month_start {
    type: date
    sql: ${TABLE}."month_start" ;;
  }

  dimension: year {
    type: date
    sql: ${TABLE}."year" ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."total_revenue" ;;
  }

  dimension: prev_month_revenue {
    type: number
    sql: ${TABLE}."prev_month_revenue" ;;
  }

  dimension: prev_year_revenue {
    type: number
    sql: ${TABLE}."prev_year_revenue" ;;
  }

  dimension: mom_revenue_change {
    type: number
    sql: ${TABLE}."mom_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: yoy_revenue_change {
    type: number
    sql: ${TABLE}."yoy_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: total_commission {
    type: number
    sql: ${TABLE}."total_commission" ;;
  }

  dimension: prev_month_commission {
    type: number
    sql: ${TABLE}."prev_month_commission" ;;
  }

  dimension: prev_year_commission {
    type: number
    sql: ${TABLE}."prev_year_commission" ;;
  }

  dimension: mom_commission_change {
    type: number
    sql: ${TABLE}."mom_commission_change" ;;
    value_format: "0.00%"
  }

  dimension: yoy_commission_change {
    type: number
    sql: ${TABLE}."yoy_commission_change" ;;
    value_format: "0.00%"
  }

  dimension: total_guarantee {
    type: number
    sql: ${TABLE}."total_guarantee" ;;
  }

  dimension: commissions_to_revenue {
    type: number
    sql: ${TABLE}."commissions_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: prev_month_commissions_to_revenue {
    type: number
    sql: ${TABLE}."prev_month_commissions_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: prev_year_commissions_to_revenue {
    type: number
    sql: ${TABLE}."prev_year_commissions_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: mom_commission_to_revenue_change {
    type: number
    sql: ${TABLE}."mom_commission_to_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: yoy_commission_to_revenue_change {
    type: number
    sql: ${TABLE}."yoy_commission_to_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: guarantee_to_revenue {
    type: number
    sql: ${TABLE}."guarantee_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: prev_month_guarantee_to_revenue {
    type: number
    sql: ${TABLE}."prev_month_guarantee_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: prev_year_guarantee_to_revenue {
    type: number
    sql: ${TABLE}."prev_year_guarantee_to_revenue" ;;
    value_format: "0.00%"
  }

  dimension: mom_guarantee_to_revenue_change {
    type: number
    sql: ${TABLE}."mom_guarantee_to_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: yoy_guarantee_to_revenue_change {
    type: number
    sql: ${TABLE}."yoy_guarantee_to_revenue_change" ;;
    value_format: "0.00%"
  }

  dimension: avg_guarantee {
    type: number
    sql: ${TABLE}."avg_guarantee" ;;
  }

  dimension: prev_month_avg_guarantee {
    type: number
    sql: ${TABLE}."prev_month_avg_guarantee" ;;
  }

  dimension: prev_year_avg_guarantee {
    type: number
    sql: ${TABLE}."prev_year_avg_guarantee" ;;
  }

  dimension: mom_avg_guarantee_change {
    type: number
    sql: ${TABLE}."mom_avg_guarantee_change" ;;
  }

  dimension: yoy_avg_guarantee_change {
    type: number
    sql: ${TABLE}."yoy_avg_guarantee_change" ;;
  }

}
