view: t3_revenue_support_all {
derived_table: {
  sql: WITH billed as (
    select REPORT_DATE, market_id, market_name, sum(tracker_charge_low) as billed_low,
           sum(tracker_charge_high) as billed_high
from ANALYTICS.ACCOUNTING.T3_REVENUE_SUPPORT_ALL
where tracker_installed_flag = 'Y'
and billed_unbilled_flag = 'Billed'
--   and market_id = 1
group by market_id, market_name, billed_unbilled_flag, REPORT_DATE
)
--      select count(distinct MARKET_ID) from billed;
,unbilled as (
    select REPORT_DATE, market_id, market_name, sum(tracker_charge_low) as unbilled_low,
           sum(tracker_charge_high) as unbilled_high
from ANALYTICS.ACCOUNTING.T3_REVENUE_SUPPORT_ALL
where tracker_installed_flag = 'Y'
and billed_unbilled_flag = 'Unbilled'
--   and market_id = 1
group by market_id, market_name, billed_unbilled_flag, REPORT_DATE
)
-- select count(distinct MARKET_ID) from unbilled;
select coalesce(b.market_id,u.market_id) as market_id,
       coalesce(b.market_name, u.market_name) as market_name,
       round(coalesce(b.billed_low,0),2) as billed_low,
       round(coalesce(u.unbilled_low, 0),2) as unbilled_low,
        round(coalesce(b.billed_high,0),2) as billed_high,
       round(coalesce(u.unbilled_high, 0),2) as unbilled_high,
       DATE_TRUNC(MONTH,coalesce(b.report_date,u.report_date)) AS REPORT_START_DATE,
    coalesce(b.report_date,u.report_date) AS REPORT_END_DATE
from billed b
full outer join
    unbilled u
on b.market_id = u.market_id and b.REPORT_DATE = u.REPORT_DATE
order by b.market_id
          ;;
}

dimension: market_id {
  type: number
  sql: ${TABLE}.market_id ;;
}
dimension: market_name {
  type: string
  sql: ${TABLE}.market_name ;;
}
dimension: billed_low {
  type: number
  sql: ${TABLE}.billed_low ;;
}
dimension: unbilled_low {
  type: number
  sql: ${TABLE}.unbilled_low ;;
}
  dimension: billed_high {
    type: number
    sql: ${TABLE}.billed_high ;;
  }
  dimension: unbilled_high {
    type: number
    sql: ${TABLE}.unbilled_high ;;
  }
dimension: report_start_date {
  type: date
  sql: ${TABLE}.report_start_date ;;
}
dimension: report_end_date {
  type: date
  sql: ${TABLE}.report_end_date ;;
}
}
