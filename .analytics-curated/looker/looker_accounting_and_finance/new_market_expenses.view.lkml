 view: new_market_expenses {
   derived_table: {
     sql: with gl_summary as (SELECT date_trunc('month', gl.entry_date::DATe)::Date as month_
                         , department
                         , coalesce(try_to_number(DEPARTMENT), 0)         as market_id
                         , gl.RECORDNO
                         , title                                          as account
                         , gl.accountno
                         , ram.internal_is_grouping
                         , ram.normalbalance
                         , ram.cost_revenue
                         , sum(coalesce(abs(ap.amount::numeric(20)), abs(glr.amount), gl.amount) *
                               gl.tr_type::numeric(20) * -1::numeric)     as amount
                    FROM analytics.INTACCT.GLENTRY gl
                             LEFT JOIN analytics.revmodel.ACCOUNT_MAPPING3 ram
                                       on gl.accountno = ram.accountno::text
                             LEFT JOIN analytics.INTACCT.GLRESOLVE glr
                                       on glr.glentrykey = gl.recordno
                             LEFT JOIN analytics.INTACCT.APDETAIL ap
                                       on ap.recordno = glr.prentrykey
                             LEFT JOIN analytics.INTACCT.APRECORD apr
                                       on ap.recordkey::int = apr.recordno::int
                    where accounttype = 'incomestatement'
                      and gl.entry_date > '2018-12-31'
                      and gl.state = 'Posted'
                    group by month_
                           , market_id
                           , department
                           , account
                           , gl.accountno
                           , gl.RECORDNO
                           , ram.internal_is_grouping
                           , ram.normalbalance
                           , ram.cost_revenue)
--
   , prep_current_for_stack as (select gl.month_::Date     as month_
                                     , gl.account          as account
                                     , gl.RECORDNO
                                     , case
                                           when gl.market_id in
                                                (0, 7521, 9999, 15980, 15967, 32199, 32198, 32200, 32197)
                                               then 'Corporate'
                                           else m.name end as market_name
                                     , gl.market_id
                                     , case
                                           when gl.market_id in
                                                (0, 7521, 9999, 15980, 15967, 32199, 32198, 32200, 32197) or
                                                r.market_id is null then 'Y'
                                           else 'N' end    as corporate_y_n
                                     , gl.cost_revenue
                                     , case
                                           when gl.normalbalance = 'debit' then amount * -1
                                           else amount
                                        end           as amount
                                     , accountno::Char(10) as accountno
                                from gl_summary gl
                                         left join analytics.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE r
                                                   on gl.market_id = r.market_id
                                         left join ES_WAREHOUSE.public.markets m
                                                   on gl.market_id = m.market_id)
-----
select g.month_::Date as gl_entry_month
     , g.market_id as market_id
     , m.market_name as market_name
     , g.accountno as account
     , g.account as account_desc
     , g.RECORDNO as recordno
     , m.market_start_month::Date as market_start
     , sum(g.amount) as amount
from prep_current_for_stack g
         left join analytics.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE m
                   on g.market_id = m.market_id
         left join analytics.GS.REVMODEL_ACCOUNT_MAPPING am
                   on g.account = am.title
                       and am.accounttype = 'incomestatement'
where am.cost_revenue = 'C'
  and am.internal_is_grouping not in ('Interest Expense', 'Depreciation')
  and g.market_id not in (0, 7521, 9999, 15980, 15967, 32199, 32198, 32200, 32197)
  and m.market_start_month >= g.month_
  and g.accountno not in ('6010')
  and am.amortization_y_n <> 'Y'
group by g.month_
       , g.market_id
       , m.market_name
       , g.accountno
       , g.account
       , market_start_month
       , g.RECORDNO
order by market_name, gl_entry_month ;;
   }


#
#   # Define your dimensions and measures here, like this:
   dimension: gl_entry_month {
     description: "GL Entry Month from GLENTRY table"
     type: date_month
     sql: ${TABLE}.gl_entry_month ;;
   }

  dimension: market_id {
    description: "Unique ID for each market"
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    description: "Market Name"
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: account {
    description: "Account Number"
    type: string
    sql: ${TABLE}.account ;;
  }

  dimension: account_desc {
    description: "Account Description"
    type: string
    sql: ${TABLE}.account_desc ;;
  }

  dimension: recordno {
    description: "Record Number fro GLENTRY table"
    type: string
    primary_key: yes
    sql: ${TABLE}.recordno ;;
  }

  dimension: market_start {
    description: "Market Start from analytics.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE"
    type: date_month
    sql: ${TABLE}.market_start ;;
  }

  dimension: amount {
    description: "Amount"
    type: number
    sql: ${TABLE}.amount ;;
  }

 }
