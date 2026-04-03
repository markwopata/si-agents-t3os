view: live_bi_weekly_payroll_wages {
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

      trending_payroll as (select market_id,
      market_name,
      account_name,
      account_number,
      description,
      gl_date,
      amount,
      concat(month(GL_DATE), year(GL_DATE)) as month_year,
      is_payroll_expense
      from analytics.BRANCH_EARNINGS.INT_LIVE_BRANCH_EARNINGS_LOOKER ilbel
      where account_name ilike '%pay%'
      and description ilike '%Payroll Wages%'
      and gl_date >= dateadd(month, -6, current_date)
      and is_payroll_expense = 'true'
      order by market_id, gl_date),

      final_payroll as (select tp.*, emc.head_count
      from trending_payroll tp
      left join employee_month_count emc
      on tp.market_id = emc.MARKET_ID and tp.month_year = emc.month_year_emp)

      select market_id, market_name, account_name, account_number,description,gl_date,amount, head_count
      from final_payroll
      order by gl_date



      ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
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
  dimension: gl_code {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: mkt_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: head_count {
    label: "Head Count"
    type: number
    sql: ${TABLE}."HEAD_COUNT" ;;
  }

}
