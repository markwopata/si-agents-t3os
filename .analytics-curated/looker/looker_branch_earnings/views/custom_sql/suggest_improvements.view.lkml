view: suggest_improvements {
  derived_table: {
    sql: with final_cte as (
        with data_cte as (
          SELECT  MKT_ID AS market_id
                  , x.MARKET_NAME AS mkt_name
                  , datediff(month, RO.MARKET_START_MONTH, date_trunc(month, GL_DATE)) AS market_age
                  , XW.REGION_NAME AS rgn_name
                  , XW.DISTRICT AS dist
                  , TYPE AS bucket
                  , ACCTNO
                  , GL_ACCT AS acctname
                  , 'Actual' AS ty
                  , ' ' AS cat
                  , ' ' AS descr
                  , date_trunc(month, GL_DATE) AS gl_mo
                  , sum(AMT) AS amount

          from    ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP BE
                      INNER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK x
                          ON BE.MKT_ID = x.MARKET_ID
                      INNER JOIN ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE RO
                          ON IFF(BE.MKT_ID = '15967', '33163', BE.MKT_ID) = RO.MARKET_ID::varchar
                      LEFT OUTER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW
                          ON IFF(BE.MKT_ID = '15967', '33163', BE.MKT_ID) = XW.MARKET_ID::varchar

          group by    MKT_ID
                      , x.MARKET_NAME
                      , market_age
                      , XW.REGION_NAME
                      , XW.DISTRICT
                      , TYPE
                      , ACCTNO
                      , GL_ACCT
                      , gl_mo
      ),

      sugg_cte as (
          select        -- Global rate increase
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                    as ty,
              'Financial Utilization'         as cat,
              'Increase All Rates by 1.5%'    as descr,
              gl_mo,
              round(amount * 0.015, 2)        as amount
          from data_cte
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Day/Week volume
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                            as ty,
              'Financial Utilization'                 as cat,
              'Increase Day/Week Volume by 5%'        as descr,
              gl_mo,
              round(amount * 0.12 * 1.4 * 0.05, 2)    as amount
          from data_cte
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Day/week rates
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                        as ty,
              'Financial Utilization'             as cat,
              'Increase Day/Week Rates by 15%'    as descr,
              gl_mo,
              round(amount * 0.12 * 0.15, 2)      as amount
          from data_cte
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Move unused fleet
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Financial Utilization'                             as cat,
              'Move 5% of Under-Utilized Fleet to Another Yard'   as descr,
              gl_mo,
              round(amount * -0.05, 2)                            as amount
          from data_cte
          where acctno = 'IBAB'

          union all

          select        -- Increase dealer sales
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Equipment, Parts, and Tool Sales'                  as cat,
              'Increase Dealer Sales to 15% of Rent Charge Revenue' as descr,
              gl_mo,
              round(((amount * 0.15) - coalesce(S.sales, 0)) * 0.1, 2) as amount
          from data_cte         D
          left join (select BRANCH_ID,
                        date_trunc(month, INVOICE_DATE::date) inv_mo,
                        sum(AMOUNT) sales
                     from ES_WAREHOUSE.PUBLIC.LINE_ITEMS IT
                     join ES_WAREHOUSE.PUBLIC.INVOICES   IV
                         on IT.INVOICE_ID = IV.INVOICE_ID
                     where LINE_ITEM_TYPE_ID = 81
                         and BRANCH_ID != 13481
                     group by BRANCH_ID, inv_mo) S
            on D.market_id = S.BRANCH_ID
            and D.gl_mo = S.inv_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Increase used sales
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Equipment, Parts, and Tool Sales'                  as cat,
              'Increase Used Sales to 15% of Rent Charge Revenue' as descr,
              gl_mo,
              round(((amount * 0.15) - coalesce(S.sales, 0)) * 0.18, 2) as amount
          from data_cte         D
          left join (select BRANCH_ID,
                        date_trunc(month, INVOICE_DATE::date) inv_mo,
                        sum(AMOUNT) sales
                     from ES_WAREHOUSE.PUBLIC.LINE_ITEMS IT
                     join ES_WAREHOUSE.PUBLIC.INVOICES   IV
                         on IT.INVOICE_ID = IV.INVOICE_ID
                     where LINE_ITEM_TYPE_ID = 80
                         and BRANCH_ID != 13481
                     group by BRANCH_ID, inv_mo) S
            on D.market_id = S.BRANCH_ID
            and D.gl_mo = S.inv_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Achieve finance subsidy
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Equipment, Parts, and Tool Sales'                  as cat,
              'Achieve 2% Finance Subsidy on Equipment Sales'     as descr,
              gl_mo,
              round(amount * (0.15 + 0.15) * 0.02, 2)             as amount
          from data_cte         D
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Increase small tools sales
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Equipment, Parts, and Tool Sales'                  as cat,
              'Increase Small Tools Sales to 5% of Rent Charge Revenue' as descr,
              gl_mo,
              round(((amount * 0.05) - coalesce(S.sales, 0)) * 0.4, 2) as amount
          from data_cte         D
          left join (select BRANCH_ID,
                        date_trunc(month, INVOICE_DATE::date) inv_mo,
                        sum(AMOUNT) sales
                     from ES_WAREHOUSE.PUBLIC.LINE_ITEMS IT
                     join ES_WAREHOUSE.PUBLIC.INVOICES   IV
                         on IT.INVOICE_ID = IV.INVOICE_ID
                     where LINE_ITEM_TYPE_ID = 28
                         and BRANCH_ID != 13481
                     group by BRANCH_ID, inv_mo) S
            on D.market_id = S.BRANCH_ID
            and D.gl_mo = S.inv_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Increase parts sales
              market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Equipment, Parts, and Tool Sales'                  as cat,
              'Increase Parts Sales to 5% of Rent Charge Revenue' as descr,
              gl_mo,
              round(((amount * 0.05) - coalesce(S.sales, 0)) * 0.2, 2) as amount
          from data_cte         D
          left join (select BRANCH_ID,
                        date_trunc(month, INVOICE_DATE::date) inv_mo,
                        sum(AMOUNT) sales
                     from ES_WAREHOUSE.PUBLIC.LINE_ITEMS IT
                     join ES_WAREHOUSE.PUBLIC.INVOICES   IV
                         on IT.INVOICE_ID = IV.INVOICE_ID
                     where LINE_ITEM_TYPE_ID = 49
                         and BRANCH_ID != 13481
                     group by BRANCH_ID, inv_mo) S
            on D.market_id = S.BRANCH_ID
            and D.gl_mo = S.inv_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Reduce outside hauling
              D.market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Outside Hauling'                                   as cat,
              'Reduce Outside Hauling to Target (<2% of Rent Charge Revenue)' as descr,
              D.gl_mo,
              case when amount = 0 then 0
                 else round(-amount * ((coalesce(J.ttl, 0) / amount) - 0.1) * 0.35, 2)
                 end                                              as amount
          from data_cte         D
          left join (select market_id,
                            gl_mo,
                            sum(amount) ttl
                    from data_cte
                    where acctno in ('6014', '6031')
                    group by market_id, gl_mo) J
            on D.market_id = J.market_id
            and D.gl_mo = J.gl_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Reduce overtime
              D.market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Payroll'                                           as cat,
              'Reduce Overtime to Target (<10% of Total Wages)'   as descr,
              D.gl_mo,
              round(amount * ((ot_ttl / pr_ttl) - 0.1) * 0.25, 2) as amount
          from data_cte         D
          join (select market_id,
                    gl_mo,
                    sum(case when lower(acctname) like '%payroll%' then amount
                         when lower(acctname) like '%overtime%' then amount
                         else 0                     end)        pr_ttl,
                    sum(case when lower(acctname) like '%overtime%' then amount
                         else 0                     end)        ot_ttl
                from data_cte
                group by market_id, gl_mo
                having pr_ttl != 0) J
            on D.market_id = J.market_id
            and D.gl_mo = J.gl_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Increase outside Service
              D.market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Service Revenue'                                   as cat,
              'Increase Outside Service to 5% of Rent Charge Revenue' as descr,
              D.gl_mo,
              round(((amount * 0.05) - coalesce(J.ttl,0)) * 0.4, 2) as amount
          from data_cte         D
          left join (select market_id,
                            gl_mo,
                            sum(amount) ttl
                    from data_cte
                    where acctno = '5306'
                    group by market_id, gl_mo) J
            on D.market_id = J.market_id
            and D.gl_mo = J.gl_mo
          where acctno in ('FAAA','TAIR','5000')

          union all

          select        -- Collect unbilled rental overages
              D.market_id,
              mkt_name,
              market_age,
              rgn_name,
              dist,
              bucket,
              acctno,
              acctname,
              'Suggestion'                                        as ty,
              'Billing and Collections'                           as cat,
              'Fully Charge Unbilled Overage Hours'               as descr,
              D.gl_mo,
              os_overage as amount
          from data_cte         D
          join (select
                    MARKET_ID,
                    date_trunc(month, RENTAL_END_DATE::date)                     eff_date,
                    round(sum(OVERAGE_SURCHARGE)-coalesce(billed_overage,0),2)   os_overage
                from ANALYTICS.PUBLIC.ASSET_OVERAGE_HOURS AOH
                left join (select INVOICE_ID, sum(AMOUNT) billed_overage
                    from ES_WAREHOUSE.PUBLIC.LINE_ITEMS
                    where LINE_ITEM_TYPE_ID = 6
                    group by INVOICE_ID) LI
                on AOH.INVOICE_ID = LI.INVOICE_ID -- update to use invoice_id and exclude not yet invoiced (invoice_id = 0)
                where AOH.INVOICE_ID <> 0
                group by MARKET_ID, eff_date, billed_overage
                having os_overage != 0) J
            on D.market_id = J.market_id
            and D.gl_mo = J.eff_date
          where acctno in ('FAAA','TAIR','5000')
              and D.market_id not in (
                                    select MARKET_ID
                                    from ES_WAREHOUSE.PUBLIC.MARKETS
                                    where name like '%Pump & Power'
                                    )
      )

      select * from data_cte
      union all
      select * from sugg_cte
      where amount > 0
      )
      select
        row_number() over (order by fc.market_id) as pk,
        fc.*
      from final_cte as fc
       ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: amt {
    type: sum
    label: "Amount"
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: market_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."MARKET_ID" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_id
  }

  dimension: mkt_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_name
  }

  dimension: market_age {
    type: number
    label: "Market Age"
    sql: ${TABLE}."MARKET_AGE" ;;
  }

  dimension: rgn_name {
    type: string
    label: "Region Name"
    sql: ${TABLE}."RGN_NAME" ;;
  }

  dimension: dist {
    type: string
    label: "District"
    sql: ${TABLE}."DIST" ;;
  }

  dimension: bucket {
    type: string
    label: "Bucket code"
    order_by_field: bucket_order
    sql: ${TABLE}."BUCKET" ;;
  }

  dimension: acctno {
    type: string
    label: "Account Number"
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: acctname {
    type: string
    label: "Account Name"
    sql: ${TABLE}."ACCTNAME" ;;
  }

  dimension: ty {
    type: string
    label: "Type"
    sql: ${TABLE}."TY" ;;
  }

  dimension: cat {
    type: string
    label: "Suggestion Category"
    sql: ${TABLE}."CAT" ;;
  }

  dimension: descr {
    type: string
    label: "Description"
    sql: ${TABLE}."DESCR" ;;
  }

  dimension: gl_mo {
    type: date
    label: "Month"
    convert_tz: no
    sql: ${TABLE}."GL_MO" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: bucket_order {
    type: number
    sql: case when ${bucket} = 'Rental Revenues'                    then 1
              when ${bucket} = 'Sales Revenues'                     then 2
              when ${bucket} = 'Delivery Revenues'                  then 3
              when ${bucket} = 'Service Revenues'                   then 4
              when ${bucket} = 'Miscellaneous Revenues'             then 5
              when ${bucket} = 'Bad Debt'                           then 6
              when ${bucket} = 'Cost of Rental Revenues'            then 7
              when ${bucket} = 'Cost of Sales Revenues'             then 8
              when ${bucket} = 'Cost of Delivery Revenues'          then 9
              when ${bucket} = 'Cost of Service Revenues'           then 10
              when ${bucket} = 'Cost of Miscellaneous Revenues'     then 11
              when ${bucket} = 'Employee Benefits Expenses'         then 12
              when ${bucket} = 'Facilities Expenses'                then 13
              when ${bucket} = 'General Expenses'                   then 14
              when ${bucket} = 'Overhead Expenses'                  then 15
              when ${bucket} = 'Intercompany Transactions'          then 16
              end ;;
  }

  set: detail {
    fields: []
  }
}
