view: warranty_accounts {
  derived_table: {
    sql: with receivable as (select last_day(period_start_date,month) period_end,
sum(amount) receivable
from
analytics.intacct_models.balance_sheet_v
where account_number =1212
and year(period_start_date)>=2023
and period_end<current_date
                    and last_day(period_start_date,month)=last_day(period_start_date,month)
                   group by period_end)
--these are month close balances )
, revenue as ( select last_day(entry_date,month) period_end
, sum(amount) revenue
              from analytics.intacct_models.gl_detail
where account_number in ('5303','5304','5317','5318') --adding new rev accounts for previously denied/expired claims
                     and year(period_end)>=2023

group by period_end)
                    select r.period_end
                    , revenue
                    , receivable
                    from receivable r
                    join revenue v
                    on r.period_end =v.period_end ;;
  }
  dimension_group: month {
    type: time
    timeframes: [month]
    sql: ${TABLE}."PERIOD_END" ;;
  }

  measure: receivable { #cant be cumulative since it is receivable at a point in time
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."RECEIVABLE" ;;
  }

  measure: revenue {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."REVENUE" ;;
  }
 }
