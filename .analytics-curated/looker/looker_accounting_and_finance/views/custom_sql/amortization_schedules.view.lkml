view: amortization_schedules {
    derived_table: {
      sql:with ammort_sched as
(select phoenix_id, CUSTOMTYPE ,date,NEGATIVECF as total_pmt,principal, interest, balance, commencement_date ,
    maturity_date
from
  ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT txdt
where
  --phoenix_id = 402
  --and
  (CUSTOMTYPE = 'Payment' or CUSTOMTYPE = 'Loan' or
      CUSTOMTYPE = 'Lease Payment' or CUSTOMTYPE = 'Lease')
  and
  gaap_non_gaap = 'Non-GAAP'
  and
  current_version = 'Yes'
order by
  phoenix_id, date, CUSTOMTYPE)
  , add_nm_and_sage_id as (
  select a.phoenix_id, b.FINANCIAL_SCHEDULE_ID, b.sage_loan_id, b.schedule as tval_loan_name,
    a.CUSTOMTYPE, a.date, a.total_pmt, a.principal, a.interest, a.balance,
      a.commencement_date, a.maturity_date
  from
    ammort_sched a
  left join
    ANALYTICS.DEBT.PHOENIX_ID_TYPES b
  on
    a.phoenix_id = b.phoenix_id
    order by phoenix_id, date, CUSTOMTYPE)
  select * from add_nm_and_sage_id;;
    }
    dimension: phoenix_id {
      type: number
      sql: ${TABLE}.phoenix_id ;;
    }
  dimension: FINANCIAL_SCHEDULE_ID {
    type: number
    sql: ${TABLE}.FINANCIAL_SCHEDULE_ID ;;
  }
    dimension: sage_loan_id {
      type: string
      sql: ${TABLE}.sage_loan_id ;;
    }
    dimension: tval_loan_name {
      type: string
      sql: ${TABLE}.tval_loan_name ;;
    }
    dimension: customType {
      type: string
      sql: ${TABLE}.CUSTOMTYPE;;
    }
    dimension: date {
      type: date
      sql: ${TABLE}.date;;
    }
    dimension: total_pmt {
      type: number
      sql: ${TABLE}.total_pmt ;;
    }
    dimension: principal {
      type: number
      sql: ${TABLE}.principal ;;
    }
    dimension: interest {
      type: number
      sql: ${TABLE}.interest ;;
    }
    dimension: balance {
      type: number
      sql: ${TABLE}.balance ;;
    }
    dimension: commencement_date {
      type: date
      sql: ${TABLE}.commencement_date;;
    }
    dimension: maturity_date {
      type: date
      sql: ${TABLE}.maturity_date;;
    }
}
