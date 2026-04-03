view: debt_table_loan_balances {
parameter: as_of_date {
  type: date
}
derived_table: {
  sql: --this code produces the current balances of all loans and capital leases
   with filter_date as (
  select {% parameter as_of_date %}::date as filter_date
)
,closest_dt as
(
    select
      phoenix_id, max(date) as closest_dt
    from
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT txdt,
         filter_date
    where
      txdt.gaap_non_gaap = 'Non-GAAP'
    and txdt.CUSTOMTYPE = 'MonthTotal'
    and current_version = 'Yes'
      and date <=
      last_day(filter_date)
    group by
      phoenix_id
)
,get_cur_bal as
(
   select
          b.phoenix_id,
          b.balance as balance,
          b.OEC,
          b.ENTITY,
          b.FINANCING_FACILITY_TYPE,
          b.commencement_date
   from
      closest_dt a
   left join
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT b
   on
        a.phoenix_id = b.phoenix_id
        and a.closest_dt = b.date
    where
          b.gaap_non_gaap = 'Non-GAAP'
      and b.CUSTOMTYPE = 'MonthTotal'
      and b.current_version = 'Yes'
)
select b.SCHEDULE, b.SAGE_ACCOUNT_NUMBER, b.lender, b.sage_loan_id, b.financial_schedule_id, a.*
from get_cur_bal a
left join
    ANALYTICS.DEBT.PHOENIX_ID_TYPES b
on a.PHOENIX_ID = b.PHOENIX_ID;;
}
dimension: phoenix_id {
  description: "Phoenix ID"
  type: number
  sql: ${TABLE}.phoenix_id ;;
}
dimension: entity {
  description: "Entity"
  type: string
  sql: ${TABLE}.entity ;;
}
dimension: financing_facility_type {
  description: "Loan, Capital Lease, or Operating Lease?"
  type: string
  sql: ${TABLE}.financing_facility_type ;;
}
dimension: balance {
  description: "Balance according to the debt table"
  type: number
  value_format_name: usd
  sql: ${TABLE}.balance ;;
}
dimension: schedule {
  description: "Loan name in debt table (From TVAL)"
  type: string
  sql: ${TABLE}.schedule ;;
}
dimension: lender {
  type: string
  sql: ${TABLE}.lender ;;
}
dimension: sage_loan_id {
  type: string
  sql: ${TABLE}.sage_loan_id ;;
}
dimension: financial_schedule_id {
  description: "ID in ESTrack"
  type: number
  sql: ${TABLE}.financial_schedule_id ;;
}
dimension: commencement_date {
  description: "Commencement date"
  type: date
  sql: ${TABLE}.commencement_date ;;
}
measure: display_as_of_date {
  description: "Balance as of this date"
  label: "Balance as of this date"
  type: date
  label_from_parameter: as_of_date
  sql:  {% parameter as_of_date %}
          --(date (date (date_trunc('month', {% parameter as_of_date %})) + interval '1 year') - interval '1 day')::date
          ;;
}
}
