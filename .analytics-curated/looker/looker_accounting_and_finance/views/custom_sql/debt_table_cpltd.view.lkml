view: debt_table_cpltd {
  derived_table: {
    sql:
with filter_date as (
--   select {% parameter as_of_date %}::date as filter_date
  select coalesce({% parameter as_of_date %}::date, dateadd(DAY,-1,date_trunc(MONTH,CURRENT_DATE()))::date) as filter_date
)
SELECT *
FROM ANALYTICS.DEBT.CPLTD_SNAPSHOT cs,
     filter_date fd
where cs.MONTH_END = fd.filter_date
 ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: pmt_schedule_id {
    type: number
    sql: ${TABLE}.pmt_schedule_id ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}.entity ;;
  }
  dimension: sage_id {
    type: string
    sql: ${TABLE}.sage_id ;;
  }
  dimension: sage_account_number {
    type: string
    sql: ${TABLE}.sage_account_number ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}.financing_facility_type ;;
  }
  dimension: balance_in_sage{
    type: number
    sql: ${TABLE}.current_balance ;;
  }
  dimension: debt_table_cpltd {
    description: "CPLTD according to the debt table"
    type: number
    sql: ${TABLE}.cpltd ;;
  }
  dimension: total_cpltd {
    type: number
    sql: ${TABLE}.total_cpltd ;;
  }
  dimension: total_sage_bal {
    type: number
    sql: ${TABLE}.total_sage_balance ;;
  }

  measure: display_as_of_date {
    description: "CPLTD as of this date"
    label: "CPLTD as of this date"
    type: date
    label_from_parameter: as_of_date
    sql:  select coalesce({% parameter as_of_date %}::date, dateadd(DAY,-1,date_trunc(MONTH,CURRENT_DATE()))::date)
          --(date (date (date_trunc('month', {% parameter as_of_date %})) + interval '1 year') - interval '1 day')::date
          ;;
  }
  parameter: as_of_date {
    type: date
  }
}
