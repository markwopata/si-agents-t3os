view: payment_forecast_new {
  parameter: min_date {
    type: date
  }
  parameter: max_date {
    type: date
  }
  derived_table: {
    sql:with min_dt as (
          select {% parameter min_date %}::date as min_dt
      )
      ,max_dt as (
          select {% parameter max_date %}::date as max_dt
      )
,add_att as (
    select *
    from ANALYTICS.DEBT.LOAN_ATTRIBUTES
    where GAAP = false
    and PENDING = false
    and RECORD_STOP_DATE like '9999%'
)
,add_am as (
    select PMT_SCHEDULE_ID, sum(NEGATIVECF) as payment, sum(PRINCIPAL) as principal, sum(INTEREST) as interest
    from ANALYTICS.DEBT.LOAN_AMORTIZATION LAM,
         min_dt,
         max_dt
    WHERE DATE between min_dt and max_dt
      and (MEMO not ilike '%sold%'
               and MEMO not ilike '%payoff%'
               and MEMO not ilike '%asset%' or MEMO is null)
      --and PMT_SCHEDULE_ID = 2199
    group by PMT_SCHEDULE_ID
)
select a.FINANCIAL_SCHEDULE_ID,
       fs.CURRENT_SCHEDULE_NUMBER as schedule,
       fl.NAME as lender,
       a.ENTITY,
       a.FINANCING_FACILITY_TYPE,
       a.NOMINAL_RATE,
       a.APR,
       coalesce(b.payment,0) as payment,
       coalesce(b.principal,0) as principal,
       coalesce(b.interest,0) as interest
from
     add_att a
left join add_am b
on a.PMT_SCHEDULE_ID = b.PMT_SCHEDULE_ID
left join
    ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
on a.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
left join
    ES_WAREHOUSE.PUBLIC.FINANCIAL_LENDERS fl
on fs.ORIGINATING_LENDER_ID = fl.FINANCIAL_LENDER_ID
where  payment <> 0;;
  }

  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
    link: {
      label: "Go to Amortization Schedule!"
      url:"https://equipmentshare.looker.com/dashboards-next/379?Tval%20Loan%20Name=&Phoenix%20ID={{ value }}"
    }
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule;;
  }
  dimension: ENTITY {
    type: string
    sql: ${TABLE}.ENTITY;;
  }
  dimension: FINANCING_FACILITY_TYPE {
    type: string
    sql: ${TABLE}.FINANCING_FACILITY_TYPE;;
  }
  dimension: payment {
    type: number
    sql: ${TABLE}.payment ;;
  }
  dimension: NOMINAL_RATE {
    type: number
    sql: ${TABLE}.NOMINAL_RATE ;;
  }
  dimension: APR {
    type: number
    sql: ${TABLE}.APR ;;
  }
  dimension: principal {
    type: number
    sql: ${TABLE}.principal ;;
  }
  dimension: interest {
    type: number
    sql: ${TABLE}.interest ;;
  }

  measure: display_min_date {
    description: "First date in selected date range"
    label: "First date in selected date range"
    type: date
    label_from_parameter: min_date
    sql:  {% parameter min_date %}
      ;;
  }
  measure: display_max_date {
    description: "Last date in selected date range"
    label: "Last date in selected date range"
    type: date
    label_from_parameter: max_date
    sql:  {% parameter max_date %}
      ;;
  }
}
