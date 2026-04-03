view: ap_accrual_journal_numbers {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
      select
        gd.JOURNAL_TRANSACTION_NUMBER journal_number,
        gd.entry_date
      from
        analytics.INTACCT_MODELS.gl_detail gd
      where
        gd.ACCOUNT_NUMBER = '2014'
      group by
        gd.JOURNAL_TRANSACTION_NUMBER, gd.entry_date
      ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}.entry_date ;;
    convert_tz: no
  }

  dimension: journal_number {
    type: string
    sql: ${TABLE}.journal_number ;;
  }
}
