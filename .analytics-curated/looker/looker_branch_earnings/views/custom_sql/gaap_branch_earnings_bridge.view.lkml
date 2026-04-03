view: gaap_branch_earnings_bridge {
  derived_table: {
    sql:
      with be_raw as (
          select
              mkt_id,
              mkt_name,
              type,
              acctno,
              gl_acct,
              descr,
              gl_date,
              amt
          from analytics.public.branch_earnings_dds_snap
          where acctno is not null
            and acctno <> 'nan'
      ),
      be_numbered as (
          select
              mkt_id,
              acctno,
              gl_date,
              amt,
              row_number() over (
                  partition by mkt_id, acctno, gl_date, amt
                  order by gl_acct, descr
              ) as rn
          from be_raw
      ),
      gl_numbered as (
          select
              market_id,
              market_name,
              account_number,
              account_name,
              entry_date,
              amount,
              row_number() over (
                  partition by market_id, account_number, entry_date, amount
                  order by account_name
              ) as rn
          from analytics.intacct_models.gl_detail gl
          where account_type = 'incomestatement'
      ),
      gl_changed_or_removed as (
          select
              gl.market_id,
              gl.market_name,
              gl.account_number,
              gl.account_name,
              gl.entry_date,
              gl.amount
          from gl_numbered gl
          left join be_numbered be
            on gl.market_id = be.mkt_id
           and gl.account_number = be.acctno
           and gl.entry_date = be.gl_date
           and gl.amount = be.amt
           and gl.rn = be.rn
          where be.acctno is null
      ),
      be_mapped_detail as (
          select
              mkt_id,
              mkt_name,
              type,
              acctno,
              gl_acct,
              descr,
              gl_date,
              amt,
              case
                  when acctno = 'BFEB' then '1541'
                  when acctno = 'FBAA' then '5100'
                  when acctno = 'FBBA' then '5101'
                  when acctno = 'FBCA' then '5211'
                  when acctno = 'FCAA' then '5200'
                  when acctno = 'FCBA' then '5210'
                  when acctno = 'FCCA' then '5220'
                  when acctno = 'GAAG' then '6006'
                  when acctno = 'GBAA' then '6100'
                  when acctno = 'GBCA' then '6202'
                  when acctno = 'GCAA' then '6200'
                  when acctno = 'GCBA' then '6210'
                  when acctno = 'GCCA' then '6220'
                  when acctno = 'HFAH' then '7507'
                  when acctno = 'HFAI' then '7508'
                  when acctno = 'HGAD' then '7603'
                  when acctno = 'HIAB' then '7801'
                  when acctno = 'TBAB' then '8101'
                  when acctno = 'IBAA' and gl_acct = 'Depreciation - Leasehold Improvements' then '8104'
                  when acctno = 'IBAA' and gl_acct = 'Depreciation' then '8100'
                  when length(acctno) = 4 then translate(acctno, 'ABCDEFGHIJ', '0123456789')
                  else acctno
              end as acct_no
          from be_raw
          where try_cast(acctno as number) is null
      ),
      be_summary as (
          select
              mkt_id,
              mkt_name,
              type,
              acctno,
              acct_no,
              gl_acct,
              gl_date,
              sum(amt) as be_amt
          from be_mapped_detail
          where acctno <> acct_no
          group by mkt_id, mkt_name, type, acctno, acct_no, gl_acct, gl_date
      ),
      gl_summary as (
          select
              market_id,
              market_name,
              account_number,
              account_name,
              entry_date,
              sum(amount) as gl_amt
          from gl_changed_or_removed
          group by market_id, market_name, account_number, account_name, entry_date
      )
      select
          cast(round(coalesce(be.mkt_id, gl.market_id), 0) as string) as market_id,
          coalesce(be.mkt_name, gl.market_name) as market_name,
          be.acctno as be_acctno,
          cast(coalesce(be.acct_no, gl.account_number) as string) as account_number,
          coalesce(be.gl_acct, gl.account_name) as account_name,
          coalesce(be.gl_date, gl.entry_date) as recon_date,
          be.be_amt,
          gl.gl_amt,
          coalesce(gl.gl_amt, 0) - coalesce(be.be_amt, 0) as variance,
          case
            when coalesce(gl.gl_amt, 0) <> 0
              then (coalesce(gl.gl_amt, 0) - coalesce(be.be_amt, 0)) / gl.gl_amt
            else 0
          end as variance_pct
      from be_summary be
      full outer join gl_summary gl
        on cast(be.mkt_id as string) = cast(gl.market_id as string)
       and cast(be.acct_no as string) = cast(gl.account_number as string)
       and be.gl_date = gl.entry_date
      where coalesce(be.mkt_name, gl.market_name) not ilike '%DO NOT USE%'
      and round(variance, 2) <> 0
    ;;
  }

  dimension: row_key {
    primary_key: yes
    hidden: yes
    sql: concat(
      coalesce(${TABLE}.market_id, 'NA'),
      '|',
      coalesce(${TABLE}.account_number, 'NA'),
      '|',
      coalesce(cast(${TABLE}.recon_date as string), 'NA'),
      '|',
      coalesce(${TABLE}.be_acctno, 'NA')
    ) ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: be_acctno {
    label: "BE Acct No"
    type: string
    sql: ${TABLE}.be_acctno ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension_group: recon_date {
    label: "Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    sql: ${TABLE}.recon_date ;;
  }

  measure: be_amt {
    label: "BE Amount"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.be_amt ;;
  }

  measure: gl_amt {
    label: "GL Amount"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.gl_amt ;;
  }

  measure: variance {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.variance ;;
  }

  measure: variance_pct {
    label: "Variance %"
    type: number
    value_format_name: percent_2
    sql: ${variance} / nullif(${gl_amt}, 0) ;;
  }

  measure: row_count {
    type: count
  }

  dimension: has_variance {
    type: yesno
    sql: coalesce(${TABLE}.variance, 0) <> 0 ;;
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      be_acctno,
      account_number,
      account_name,
      recon_date_date,
      be_amt,
      gl_amt,
      variance,
      variance_pct
    ]
  }
}
