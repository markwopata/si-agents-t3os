view: ap_accrual_2014_balance {
  derived_table: {
    sql: select
            -bsv.amount                                                                    current_balance,
           -lag(bsv.amount) over (partition by ACCOUNT_NUMBER order by PERIOD_START_DATE) prior_balance,
           current_balance - prior_balance                                                activity,
          bsv.period_start_date
        from analytics.INTACCT_MODELS.BALANCE_SHEET_V BSV
        where bsv.ACCOUNT_NUMBER = '2014'
      ;;
  }

  dimension: period_start_date {
    type: date
    sql: ${TABLE}."PERIOD_START_DATE" ;;
    convert_tz: no
  }

  dimension: current_balance {
    type: number
    sql: ${TABLE}."CURRENT_BALANCE" ;;
    value_format_name: usd
  }

  dimension: prior_balance {
    type: number
    sql: ${TABLE}."PRIOR_BALANCE" ;;
    value_format_name: usd
  }

  dimension: activity {
    type: number
    sql: ${TABLE}."ACTIVITY" ;;
    value_format_name: usd
  }
}
