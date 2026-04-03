view: live_payroll_trend {
  derived_table: {
    sql:
      WITH date_cte as (select _es_update_timestamp,
                         ROW_NUMBER() OVER (PARTITION BY YEAR(_es_update_timestamp), MONTH(_es_update_timestamp) ORDER BY Day(_es_update_timestamp) DESC) rn
                  from analytics.payroll.company_directory_vault),
     month_end as (select *
                   from date_cte
                   where rn = 1
                     and _es_update_timestamp >= '2022-10-01'),

     employees as (select cdv._es_update_timestamp, employee_status, market_id
                   from analytics.payroll.company_directory_vault cdv
                            join month_end me
                                 on cdv._es_update_timestamp = me._es_update_timestamp
                   where employee_status = 'Active'
                   and DEFAULT_COST_CENTERS_FULL_PATH ilike '%admin%'),

     employee_month_count as (select count(*)                                                   as head_count,
                                     e.MARKET_ID,
                                     _es_update_timestamp,
                                     date_trunc(month, dateadd(MONTH, 1, _es_update_timestamp)) as month_begin,
                                     month(month_begin)                                         as month,
                                     year(month_begin)                                          as year,
                                     concat(month, year)                                        as month_year_emp
                              from employees e
                              where e.market_id is not null
                              group by _es_update_timestamp, e.market_id
                              order by e.market_id, _es_update_timestamp),

     trending_payroll as (select market_id,
                             market_name,
                             account_name,
                             account_number,
                             description,
                             gl_date,
                             amount,
                             concat(month(GL_DATE), year(GL_DATE)) as month_year,
                             is_payroll_expense
                      from analytics.BRANCH_EARNINGS.INT_LIVE_BRANCH_EARNINGS_LOOKER
                      where account_name ilike '%pay%'
                        and description ilike '%Payroll Wages%'
                        and GL_DATE >= '2023-01-01'
                      order by market_id, gl_date),

     grouped_payroll as (select tp.market_id,
                                market_name,
                                cast(gl_date as date) as gl_date,
                                account_name,
                                account_number,
                                description,
                                sum(amount)              as amount,
                                head_count,
                                month_begin
                         from trending_payroll tp
                                  left join employee_month_count emc
                                            on tp.market_ID = emc.market_id and tp.month_year = emc.month_year_emp
                         where head_count is not null
                           and description not ilike '%Correction%'
                           and description not ilike '%Revers%'
                           and is_payroll_expense = 'true'
                          and account_name not ilike '%overtime%'
                         group by tp.market_id, market_name, account_name, account_number, description, gl_date, month_year, head_count, month_begin
                         order by market_name, GL_DATE)

select original.*,
       round(median(window.amount), 2)                                            as rolling_median,
       concat(monthname(original.GL_DATE), ' ', year(original.GL_DATE))        as period,
       round(((original.amount - rolling_median) / rolling_median), 2) as pct_variation_from_median,
       case when pct_variation_from_median > 20 then 1 else 0 end as abnormal_flag
from grouped_payroll as original
         left join grouped_payroll as window
                   on original.market_id = window.market_id
                  and original.account_number = window.account_number
                       and datediff(days, original.gl_date, window.gl_date) between -91 and -1
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
order by original.market_id, gl_date



      ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    link: {
      label: "Detail View"
      url: "@{lk_live_payroll_trend_detail}?f[live_bi_weekly_payroll_wages.mkt_id]={{live_payroll_trend.mkt_id._value}}&f[live_bi_weekly_payroll_wages.gl_acct]={{ _filters['live_payroll_trend.gl_acct']}}&toggle=fil"
    }
  }
  dimension: gl_acct {
    label: "GL Account"
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: descr {
    label: "Description"
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }
  dimension: amt {
    label: "Amount"
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: head_count {
    label: "Head Count"
    type: number
    sql: ${TABLE}."HEAD_COUNT" ;;
  }

  dimension: period {
    label: "Period"
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }
  dimension: rolling_median {
    label: "Median Bi-Weekly Expense"
    type: number
    sql: ${TABLE}."ROLLING_MEDIAN" ;;
  }
  dimension: pct_variation {
    label: "Variation from Median Expense"
    type: number
    sql: ${TABLE}."PCT_VARIATION_FROM_MEDIAN" ;;
  }
  dimension: mkt_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
}
