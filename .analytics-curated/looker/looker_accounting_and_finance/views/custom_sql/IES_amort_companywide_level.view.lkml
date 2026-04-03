view: ies_amort_companywide_level {
  derived_table: {
    sql: --ES company wide
select 'ES - company wide' as NAME, aa.date,
       sum(aa.DAILY_INT_AMT) as DAILY_INT_AMT, sum(aa.ACCRUED_INT) as ACCRUED_INT,
       sum(aa.INT_PMT) as INT_PMT, sum(aa.PRINCIPAL_PMT) as PRINCIPAL_PMT,
       sum(aa.BALANCE) as BALANCE
from ANALYTICS.DEBT.IES_ASSET_AMORTIZATION aa
left join
    ANALYTICS.DEBT.IES_DEALER_ASSETS ida
on aa.ASSET_ID = ida.ASSET_ID
left join
    ES_WAREHOUSE.PUBLIC.COMPANIES c
on ida.DEALER_COMPANY_ID = c.COMPANY_ID
where aa.INTEREST_RATE <> 0 or aa.BALANCE <> 0
group by aa.date
order by aa.date
                        ;;
  }
  dimension: dealer_name {
    type: string
    sql: ${TABLE}.name ;;
  }
  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }
  dimension: daily_int_amt {
    type: number
    sql: ${TABLE}.daily_int_amt ;;
  }
  dimension: accrued_int {
    type: number
    sql: ${TABLE}.accrued_int ;;
  }
  dimension: int_pmt {
    type: number
    sql: ${TABLE}.int_pmt ;;
  }
  dimension: principal_pmt {
    type: number
    sql: ${TABLE}.principal_pmt ;;
  }
  dimension: balance {
    type: number
    sql: ${TABLE}.balance ;;
  }
}
