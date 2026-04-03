view: target_market_colorado {
  derived_table: {
    sql:
      with target_as_mkt as (select acctno,
                                 GL_ACCT,
                                 type,
                                 round(sum(amt) / 36, 2)  as target_amount,
                                 target_amount / 11079129 as pct_oec_target,
                                 'Advanced Solutions' as market_type
                          from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP
                          where date_trunc(month, GL_DATE) >= '2024-07-01'
                            and date_trunc(month, GL_DATE) <= '2025-06-01'
                            and mkt_id in (102247,
109985,
78665,
95837
) group by all),
-- target_core_market
target_core_mkt as (select acctno,
                                 GL_ACCT,
                                 type,
                                 round(sum(amt) / 36, 2)  as target_amount,
                                 target_amount / 50394545 as pct_oec_target,
                                 'Core Solutions' as market_type
                          from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP
                          where date_trunc(month, GL_DATE) >= '2025-01-01'
                            and date_trunc(month, GL_DATE) <= '2025-12-01'
                            and mkt_id in (35789,
115753,
100031,
7328
)
                          group by all
),
all_targets as (
    select * from target_as_mkt
    union all
    select * from target_core_mkt
), example_market as (select m.MARKET_ID,
                               m.market_name,
                               mrx.MARKET_TYPE,
                               beds.acctno,
                               beds.gl_acct,
                               beds.type,
                               sum(amt)                        as actual,
                               hlfs.oec,
                               date_trunc(month, hlfs.GL_DATE) as month_year
                        from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP beds
                                 join analytics.BRANCH_EARNINGS.MARKET m
                                      on beds.mkt_id = m.CHILD_MARKET_ID
                                 join ANALYTICS.BRANCH_EARNINGS.HIGH_LEVEL_FINANCIALS hlfs
                                      on m.market_id = hlfs.MARKET_ID
                                          and date_trunc(month, beds.GL_DATE) = date_trunc(month, hlfs.GL_DATE)
                                 join analytics.public.MARKET_REGION_XWALK mrx
                                      on m.MARKET_ID = mrx.MARKET_ID
                        group by all)

      select em.market_id,
      em.market_name,
      at.acctno,
      at.gl_acct,
      at.type,
      coalesce(at.target_amount, 0) as target_amount,
      em.oec,
      em.month_year,
      at.pct_oec_target,
      case when at.acctno in ('IBAB','HGAD','JAAA','HIAB', 'HFAI','HIAC','6010','6050') then actual
      when at.acctno in ('7105', '7303') then least(0, at.pct_oec_target * oec)
      when at.acctno = '7700' THEN LEAST(-12000, GREATEST(-40000, at.pct_oec_target * oec))
      when at.acctno = '6008' then least(-9000, at.pct_oec_target * oec)
      when at.acctno = 'HFAB' then least(-3000, at.pct_oec_target * oec) else at.pct_oec_target * oec    end   as target_by_oec,
      coalesce(em.actual, 0)         as actual
      from all_targets at
      left outer join example_market em
      on at.acctno = em.acctno
      and at.gl_acct = em.gl_acct
      --and at.type = em.type
      and at.market_type = em.MARKET_TYPE
      where at.type not in ('Intercompany Transactions','Sales Revenues','Cost of Sales Revenues');;
  }

  dimension: acctno {
    label: "Account Number"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }
  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }


  dimension: month {
    label: "Month"
    type: date
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  measure: oec {
    label: "OEC"
    type: sum
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }
  measure: target_by_oec {
    label: "Adjusted Target"
    type: sum
    sql: ${TABLE}."TARGET_BY_OEC" ;;
    value_format_name: usd
  }
  measure: target_amount {
    label: "Target"
    type: sum
    sql: ${TABLE}."TARGET_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: gl_acct {
    label: "GL Acct"
    type: string
    sql: ${TABLE}."GL_ACCT" ;;
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?&f[market_region_xwalk.market_name]={{ _filters['target_market_colorado.market_name']}}&f[plexi_periods.display]={{ _filters['plexi_periods.display']}}&f[be_transaction_listing.gl_acctno]={{ target_market_colorado.acctno._value}}&toggle=fil"
    }
  }


  dimension: type {
    label: "Type"
    type: string
    sql: ${TABLE}."TYPE" ;;
    link: {
      label: "Detail View"
      url: "@{lk_be_bucket_detail}?&f[market_region_xwalk.market_name]={{ _filters['target_market_colorado.market_name']}}&f[plexi_periods.display]={{ _filters['plexi_periods.display']}}&f[be_transaction_listing.type]={{ target_market_colorado.type._value}}&toggle=fil"
    }
  }

  measure: pct_oec_target {
    label: "Ideal % of OEC"
    type: number
    sql: ${TABLE}."PCT_OEC_TARGET" ;;
    value_format_name: percent_4
  }
  measure: actual {
    label: "Actual"
    type: sum
    sql: ${TABLE}."ACTUAL" ;;
    value_format_name:usd
  }


}
