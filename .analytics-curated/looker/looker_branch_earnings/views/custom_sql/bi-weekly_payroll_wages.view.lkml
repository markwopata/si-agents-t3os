view: bi_weekly_payroll_wages {
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
                                     MARKET_ID,
                                     _es_update_timestamp,
                                     date_trunc(month, dateadd(MONTH, 1, _es_update_timestamp)) as month_begin,
                                     month(month_begin)                                         as month,
                                     year(month_begin)                                          as year,
                                     concat(month, year)                                        as month_year_emp
                              from employees
                              where market_id is not null
                              group by _es_update_timestamp, market_id
                              order by market_id, _es_update_timestamp),

     snap_payroll as (select mkt_id,
                             mkt_name,
                             gl_acct,
                             acctno,
                             descr,
                             gl_date,
                             amt,
                             concat(month(GL_DATE), year(GL_DATE)) as month_year
                      from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds
                      where gl_acct ilike '%admin%pay%'
                        and descr ilike '%Payroll Wages%'
                        and gl_date >= dateadd(month, -6, current_date)
                        and acctno = 7700
                      order by mkt_id, gl_date),

     final_payroll as (select sp.*, emc.head_count
    from snap_payroll sp
    left join employee_month_count emc
        on sp.mkt_id = emc.MARKET_ID and sp.month_year = emc.month_year_emp)

select mkt_id, mkt_name, gl_acct, acctno,descr,gl_date,amt, head_count
from final_payroll
order by gl_date



      ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
  }
  dimension: gl_acct {
    label: "GL Account"
    type: string
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension: descr {
    label: "Description"
    type: string
    sql: ${TABLE}."DESCR" ;;
  }
  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }
  dimension: amt {
    label: "Amount"
    type: number
    sql: ${TABLE}."AMT" ;;
  }
  dimension: gl_code {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: mkt_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }
  dimension: head_count {
    label: "Head Count"
    type: number
    sql: ${TABLE}."HEAD_COUNT" ;;
  }

}
