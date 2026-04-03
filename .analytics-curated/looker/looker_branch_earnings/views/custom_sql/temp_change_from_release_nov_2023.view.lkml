view: temp_change_from_release_nov_2023 {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: with old as (select round(sum(amt), 2) amount, mkt_id, acctno, gl_acct
             from analytics.public.BRANCH_EARNINGS_DDS_SNAP at (timestamp => '2023-12-22 12:00:00'::timestamp_ntz)
             where 1 = 1
               and gl_date >= '2023-11-01'
             and gl_date < '2023-12-01'
             group by mkt_id, acctno, gl_acct),
     new as (select round(sum(amt), 2) amount, mkt_id, acctno, gl_acct
             from analytics.public.BRANCH_EARNINGS_DDS_SNAP
             where 1 = 1
               and gl_date >= '2023-11-01'
               and gl_date < '2023-12-01'
             group by mkt_id, acctno, gl_acct),
     data as (select old.amount                             previous_amount,
                     new.amount                             new_amount,
                     round(new_amount - previous_amount, 2) delta,
                     old.mkt_id,
                     old.acctno account_number,
                     old.GL_ACCT account_name
              from old
                       join new
                            on old.MKT_ID = new.MKT_ID
                            and old.acctno = new.acctno
                            and old.gl_acct = new.gl_acct
              order by delta)
        select *
        from data
      ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.mkt_id ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  measure: previous_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.previous_amount ;;
  }

  measure: new_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.new_amount ;;
  }

  measure: change {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.delta ;;
  }
}
