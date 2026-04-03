view: ap_accrual_2014_subledger_total {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select gd.entry_date,
                 date_trunc(month, gd.entry_date) as month_,
                 gd.intacct_module,
                 gd.journal_type,
                 case
                     when pd.DOCUMENT_TYPE is not null then pd.document_type
                     when ad.PK_AP_DETAIL_ID is not null and pd_v.FK_PO_LINE_ID is null then 'direct ap bill'
                     when ad.PK_AP_DETAIL_ID is not null and pd_v.FK_PO_LINE_ID is not null then 'vendor invoice match'
                     when gd.INTACCT_MODULE = '2.GL' and gd.CREATED_BY_USERNAME = 'APA_TRUE_UP' then 'AP Variance Posted'
                     when gd.INTACCT_MODULE = '2.GL' then 'Other manual entry'
                     else 'unknown' end           as document_type,
                 gd.amount                        as amount,
                 gd.journal_transaction_number    as journal_number
          from analytics.INTACCT_MODELS.gl_detail gd
                   left join analytics.INTACCT_MODELS.po_detail pd
                             on gd.FK_SUBLEDGER_LINE_ID = pd.FK_PO_LINE_ID
                                 and gd.INTACCT_MODULE = '9.PO'
                   left join analytics.INTACCT_MODELS.AP_DETAIL AD
                             on gd.FK_SUBLEDGER_LINE_ID = ad.FK_AP_LINE_ID
                                 AND gd.INTACCT_MODULE = '3.AP'
                   left join analytics.INTACCT_MODELS.po_detail pd_v
                             on ad.SOURCE_DOCUMENT_NAME = pd_v.DOCUMENT_NAME
                                 and ad.LINE_NUMBER - 1 = pd_v.LINE_NUMBER
          where 1 = 1
            and gd.ACCOUNT_NUMBER = '2014'
          order by 1, 2, 3
      ;;
  }

  measure:  amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
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

  dimension: document_type {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE" ;;
  }

  dimension: string {
    type: string
    sql: ${TABLE}."JOURNAL_NUMBER" ;;
  }
}
