view: ar_footnote {

  derived_table: {
    sql:
SELECT
  accountno,
  accounttitle,
  periodenddate,
  endbal
FROM analytics.intacct.glaccountbalance
WHERE TRY_TO_NUMBER(accountno) IN (
  1103,1200,1204,1211,1212,1214,1216,1217,1223,1230,1604,
  1205,1206,1232
)
    ;;
  }

  dimension: accountno {
    type: number
    sql: ${TABLE}.accountno ;;
  }

  dimension: accounttitle {
    type: string
    sql: ${TABLE}.accounttitle ;;
  }

  dimension_group: period_end {
    type: time
    timeframes: [raw, date, month, year]
    sql: ${TABLE}.periodenddate ;;
  }

  dimension: ending_balance {
    type: number
    sql: ${TABLE}.endbal ;;
    value_format_name: decimal_0  # or remove if you want full precision
  }

  dimension: footnote_category {
    type: string
    sql:
      CASE
        WHEN ${accountno} IN (1103,1200,1230) THEN 'Rental and Non Rental'
        WHEN ${accountno} IN (1204,1211,1212,1214,1223,1604) THEN 'Non Rental'
        WHEN ${accountno} = 1216 THEN 'OEM Reimbursement'
        WHEN ${accountno} IN (1205,1206) THEN 'AR allowance'
        WHEN ${accountno} = 1232 THEN 'Rental and Non Rental'
        ELSE NULL
      END
    ;;
  }

  dimension: footnote_section {
    type: string
    sql:
      CASE
        WHEN ${accountno} IN (1205,1206,1232) THEN 'Allowance for Doubtful Accounts'
        ELSE 'Accounts Receivable'
      END
    ;;
  }

  measure: ending_balance_total {
    type: sum
    sql: ${ending_balance} ;;
    value_format_name: decimal_0
  }
}
