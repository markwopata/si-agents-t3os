view: ap_accrual_ledger_vs_subledger {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select
                gle.entry_date,
                date_trunc(month, gle.entry_date) month_,
                 gle.recordno gle_recordno,
                 glb.MODULE                     intacct_module,
                 glb.journal                    journal_type,
                 -gle.tr_type * gle.amount      gle_amount,
                 sum(-gle.tr_type * coalesce(glr.amount, gle.amount)) glr_amount,
                glb.batchno journal_number
          from analytics.intacct.glentry gle
                   join analytics.intacct.glbatch glb
                        on gle.BATCHNO = glb.RECORDNO
                   left join analytics.intacct.glresolve glr
                             on gle.recordno = glr.GLENTRYKEY
          where gle.state = 'Posted'
            and gle.STATISTICAL = 'F'
            and gle.accountno = '2014'
          group by gle.entry_date,
                date_trunc(month, gle.entry_date), gle.recordno, -gle.tr_type * gle.amount, glb.module, glb.journal, glb.batchno
      ;;
  }

  dimension: gle_recordno {
    primary_key: yes
    sql: ${TABLE}."GLE_RECORDNO" ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}."ENTRY_DATE" ;;
    convert_tz: no
  }

  dimension: period_start_date {
    type: date
    sql: ${TABLE}."MONTH_" ;;
    convert_tz: no
  }

  dimension: intacct_module {
    type: string
    sql: ${TABLE}."INTACCT_MODULE" ;;
  }

  dimension: journal_type {
    type: string
    sql: ${TABLE}."JOURNAL_TYPE" ;;

  }

  dimension: journal_number {
    type: string
    sql: ${TABLE}."JOURNAL_NUMBER" ;;
  }

  measure: gle_amount {
    label: "Ledger Amount"
    type: sum
    sql: ${TABLE}."GLE_AMOUNT" ;;
    value_format_name: usd
  }

  measure: glr_amount {
    label: "Subledger Amount"
    type: sum
    sql: ${TABLE}."GLR_AMOUNT" ;;
    value_format_name: usd
  }
}
