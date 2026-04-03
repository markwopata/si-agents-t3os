view: dt_to_sage_compare_updated {
parameter: as_of_date {
  type: date
}
derived_table: {
  sql:
  with filter_date as (
      select
           case when {% parameter as_of_date %}::date is null then
                current_timestamp::date
            else
                {% parameter as_of_date %}::date end filter_date
  )
 ,get_cur_bal as
(
SELECT PMT_SCHEDULE_ID,
                  sum(LAM.POSITIVECF) -
           sum(LAM.PRINCIPAL) as balance
    FROM ANALYTICS.DEBT.LOAN_AMORTIZATION LAM,
         filter_date
    WHERE DATE <= filter_date
    GROUP BY PMT_SCHEDULE_ID
)
,add_lat as (
       select b.*, a.balance
       from get_cur_bal a
                left join
            ANALYTICS.DEBT.LOAN_ATTRIBUTES b
            on a.PMT_SCHEDULE_ID = b.PMT_SCHEDULE_ID
    WHERE B.GAAP = false
    and b.PENDING = false
    and b.RECORD_STOP_DATE like '%9999%'
   )
,get_sage_bal as (
    SELECT
           ul.name as sage_id,
           ul.LOAN_LENDOR_LOAN,
           -round(sum(gd.net_amount::float),2)
               as current_sage_balance
    FROM
         ANALYTICS.INTACCT.UD_LOAN ul
    LEFT JOIN
            ANALYTICS.INTACCT.VENDOR vd
    ON cast(vd.recordno as text) = ul.rvendor
    LEFT JOIN
             analytics.intacct_models.gl_detail gd
    ON ul.id = cast(gd.fk_ud_loan_id  as text),
        filter_date fd
    WHERE
     (gd.ACCOUNT_NUMBER = '2500' or gd.ACCOUNT_NUMBER = '2575')
        and gd.entry_date <= fd.filter_date
    group by ul.name
           , ul.LOAN_LENDOR_LOAN
    union
select   ul.name as sage_id,
           ul.LOAN_LENDOR_LOAN,
                 - round(sum(gd.net_amount::float),2)
               as current_sage_balance
from
ANALYTICS.INTACCT.UD_LOAN ul
    LEFT JOIN
             analytics.intacct_models.gl_detail gd
on substr(ul.LOAN_LENDOR_LOAN,0,4) = gd.ACCOUNT_NUMBER,
     filter_date
where substr(ul.LOAN_LENDOR_LOAN,0,4) not in ('2500', '8200','2575')
and gd.entry_date <= filter_date
group by ul.name,
           ul.LOAN_LENDOR_LOAN
)
,sum_by_sage_id as (
    select sage_id, LOAN_LENDOR_LOAN, sum(current_sage_balance) as current_sage_balance
    from get_sage_bal
    --where sage_id = '2500-01479'
    group by LOAN_LENDOR_LOAN, sage_id
)
,final as (
        select
              a.FINANCIAL_SCHEDULE_ID,
               b.sage_id,
               substr(b.LOAN_LENDOR_LOAN,0,4) as SAGE_ACCOUNT_NUMBER,
              a.ENTITY,
              a.FINANCING_FACILITY_TYPE,
               iff(abs(a.balance)<.5,0,a.balance) as current_dt_balance,
               b.current_sage_balance,
                round(coalesce(current_sage_balance,0) -
                      coalesce(current_dt_balance,0),2) as variance
               ,
               iff((FINANCING_FACILITY_TYPE = 'Operating' and
                   (current_sage_balance = 0 or current_sage_balance is null))
                       or
                   sage_id = '2500-99999'
                   ,
                   true,false) as eliminate,
               a.NOMINAL_RATE,
               a.APR,
               a.TVAL_FOLDER,
               a.PMT_SCHEDULE_ID
       from add_lat a
                full outer join
            sum_by_sage_id b
            on a.FINANCIAL_SCHEDULE_ID =
               (SUBSTR(LOAN_LENDOR_LOAN, 6, len(TRIM(LOAN_LENDOR_LOAN)) - 5))::NUMBER
   )
select
    f.FINANCIAL_SCHEDULE_ID,
       f.SAGE_ACCOUNT_NUMBER,
       f.sage_id,
       fl.NAME as lender,
       fs.CURRENT_SCHEDULE_NUMBER as schedule,
       f.FINANCING_FACILITY_TYPE,
       f.ENTITY,
       f.NOMINAL_RATE,
       f.APR,
       f.TVAL_FOLDER,
       f.current_dt_balance,
       f.current_sage_balance,
       f.variance
   from final f
left join
       ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
on f.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
left join
       ES_WAREHOUSE.PUBLIC.FINANCIAL_LENDERS fl
on fs.ORIGINATING_LENDER_ID = fl.FINANCIAL_LENDER_ID
where
  --    variance <> 0
  --and
  eliminate = false
  ;;
}
dimension: financial_schedule_id {
  description: "ID in ESTrack"
  type: number
  sql: ${TABLE}.financial_schedule_id ;;
}
dimension: sage_account_number {
  type: string
  sql: ${TABLE}.sage_account_number ;;
}
dimension: sage_id {
  type: string
  sql: ${TABLE}.sage_id ;;
}
dimension: lender {
  type: string
  sql: ${TABLE}.lender ;;
}
dimension: schedule {
  description: "Loan name in debt table (From TVAL)"
  type: string
  sql: ${TABLE}.schedule ;;
}
dimension: financing_facility_type {
  description: "Loan, Capital Lease, or Operating Lease?"
  type: string
  sql: ${TABLE}.financing_facility_type ;;
}
dimension: entity {
  description: "Entity"
  type: string
  sql: ${TABLE}.entity ;;
}
dimension: nominal_rate {
  type: number
  value_format_name: percent_2
  sql: ${TABLE}.nominal_rate/100 ;;
}
dimension: apr {
  type: number
  value_format_name: percent_2
  sql: ${TABLE}.apr/100 ;;
}
dimension: tval_folder {
  type: string
  sql: ${TABLE}.tval_folder ;;
}
dimension: current_dt_balance {
  description: "Balance according to the debt table"
  type: number
  value_format_name: usd
  sql: ${TABLE}.current_dt_balance ;;
}
dimension: current_sage_balance {
  description: "Balance according to sage"
  type: number
  value_format_name: usd
  sql: ${TABLE}.current_sage_balance ;;
}
dimension: variance {
  type: number
  sql: ${TABLE}.variance ;;
}
measure: display_as_of_date {
  description: "Balance as of this date"
  label: "Balance as of this date"
  type: date
  label_from_parameter: as_of_date
  sql:select
         case when {% parameter as_of_date %}::date is null then
              current_timestamp::date
          else
              {% parameter as_of_date %}::date end filter_date
          ;;
}
}
