view: payment_forecast {
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
,pmts as (
    select PHOENIX_ID, round(NEGATIVECF,2) as loan_pmt, round(PRINCIPAL,2) as principal, round(INTEREST,2) as interest, date as ACH_date
    from ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT,
         min_dt,
         max_dt
    where CURRENT_VERSION = 'Yes'
    and GAAP_NON_GAAP = 'Non-GAAP'
    and CUSTOMTYPE = 'Payment'
    and date between min_dt and max_dt
)
,add_pit as (
    select a.phoenix_id, b.FINANCIAL_SCHEDULE_ID, b.SAGE_LOAN_ID, b.LENDER, b.schedule, a.loan_pmt, a.principal, a.interest, a.ACH_date
    from
        pmts a
    left join
            ANALYTICS.DEBT.PHOENIX_ID_TYPES b
    on a.PHOENIX_ID = b.PHOENIX_ID
)
/*,loan_lvl_pmts as (
    select PHOENIX_ID, sum(loan_pmt) as loan_pmt, sum(principal) as principal, sum(interest) as interest
    from pmts
    --where PHOENIX_ID = 1079
    group by PHOENIX_ID
)*/
,total_pmts as (
    select sum(loan_pmt) as total_pmts, sum(principal) as total_principal, sum(interest) as total_interest
    from pmts
)
   select b.*, a.*
from total_pmts a,
     add_pit b;;
  }

  dimension: phoenix_id {
    description: "Phoenix ID"
    type: number
    sql: ${TABLE}.phoenix_id ;;
    link: {
      label: "Go to Amortization Schedule!"
      url:"https://equipmentshare.looker.com/dashboards-next/379?Tval%20Loan%20Name=&Phoenix%20ID={{ value }}"
    }
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: loan_pmt {
    type: number
    sql: ${TABLE}.loan_pmt ;;
  }
  dimension: principal {
    type: number
    sql: ${TABLE}.principal ;;
  }
  dimension: interest {
    type: number
    sql: ${TABLE}.interest ;;
  }
  dimension: ach_date {
    type: date
    sql: ${TABLE}.ach_date ;;
  }
  dimension: total_pmts {
    type: number
    sql: ${TABLE}.total_pmts ;;
  }
  dimension: total_principal {
    type: number
    sql: ${TABLE}.total_principal ;;
  }
  dimension: total_interest {
    type: number
    sql: ${TABLE}.total_interest ;;
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
