view: ies_amort_asset_level {
  derived_table: {
    sql: select c.NAME, aa.*
from ANALYTICS.DEBT.IES_ASSET_AMORTIZATION aa
left join
    ANALYTICS.DEBT.IES_DEALER_ASSETS ida
on aa.ASSET_ID = ida.ASSET_ID
left join
    ES_WAREHOUSE.PUBLIC.COMPANIES c
on ida.DEALER_COMPANY_ID = c.COMPANY_ID
where aa.INTEREST_RATE <> 0
order by ASSET_ID, date
            ;;
  }
  dimension: dealer_name {
    type: string
    sql: ${TABLE}.name ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }
  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }
  dimension: interest_rate {
    type: number
    sql: ${TABLE}.interest_rate ;;
  }
  dimension: index_rate_date {
    type: date
    sql: ${TABLE}.index_rate_date ;;
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
