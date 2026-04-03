view: be_snap_comparison_to_py {
  derived_table: {
    sql:
        with be_snap_and_trending as (
                        select  mkt_id,
                                mkt_name,
                                type,
                                code,
                                revexp,
                                dept,
                                gl_acct,
                                acctno,
                                gl_date::date as gl_date,
                                amt
                         from analytics.public.branch_earnings_dds_snap beds
                                  join analytics.gs.plexi_periods pp
                                        on date_trunc(month,beds.gl_date::date) = pp.trunc::date
                                        --only include published periods
                                        and pp.period_published = 'published'

                          union all

                          select lbe.market_id::varchar    as mkt_id
                                  , lbe.market_name           as mkt_name
                                  , pbm.display_name          as type
                                  , pbm."GROUP"               as code
                                  , pbm.revexp                as revexp
                                  , substring(pbm."GROUP", 4) as dept
                                  , lbe.account_name          as gl_acct
                                  , lbe.account_number        as acctno
                                  , lbe.gl_date::date         as gl_date
                                  , lbe.amount                as amt
                             from analytics.branch_earnings.int_live_branch_earnings_looker lbe
                                      -- get the code, type, and department
                                      left join analytics.gs.plexi_bucket_mapping pbm
                                                on lbe.account_number = pbm.sage_gl
                                      join analytics.gs.plexi_periods pp
                                           on lbe.gl_month = pp.trunc::date
                                               --only include periods not published yet
                                               and period_published is null)
        select mkt_id
             , mkt_name
             , type
             , code
             , revexp
             , dept
             , gl_acct
             , acctno
             , gl_date
             , amt
        from be_snap_and_trending
      ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: mkt_id {
    type: string
    label: "Market ID"
    sql: ${TABLE}."MKT_ID" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.market_id
  }

  dimension: mkt_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk.market_name
  }

  dimension: gl_date {
    label: "Date"
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: type {
    type: string
    label: "Type"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.code]={{ code | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."TYPE" ;;
    order_by_field: bucket_order
  }

  dimension: code {
    type: string
    label: "Group Code"
    sql: ${TABLE}."CODE" ;;
  }

  dimension: revexp {
    type: string
    label: "Revenue/Expense"
    sql: case when ${TABLE}."REVEXP" = 'REV' then 'Revenues'
              when ${TABLE}."REVEXP" = 'EXP' then 'Expenses'
         end;;
  }

  dimension: bucket_order {
    type: number
    sql: case when ${type} = 'Rental Revenues'                    then 1
              when ${type} = 'Retail Revenues'                    then 2
              when ${type} = 'Sales Revenues'                     then 3
              when ${type} = 'Delivery Revenues'                  then 4
              when ${type} = 'Service Revenues'                   then 5
              when ${type} = 'Miscellaneous Revenues'             then 6
              when ${type} = 'Bad Debt'                           then 7
              when ${type} = 'Cost of Rental Revenues'            then 8
              when ${type} = 'Cost of Retail Revenues'            then 9
              when ${type} = 'Cost of Sales Revenues'             then 10
              when ${type} = 'Cost of Delivery Revenues'          then 11
              when ${type} = 'Cost of Service Revenues'           then 12
              when ${type} = 'Cost of Miscellaneous Revenues'     then 13
              when ${type} = 'Employee Benefits Expenses'         then 14
              when ${type} = 'Facilities Expenses'                then 15
              when ${type} = 'General Expenses'                   then 16
              when ${type} = 'Overhead Expenses'                  then 17
              when ${type} = 'Intercompany Transactions'          then 18
              end ;;
  }

  dimension: dept {
    type: string
    label: "Department"
    suggestions: ["Rental", "Retail", "Sales", "Delivery", "Service", "Miscellaneous"]
    order_by_field: dept_order
    sql: case when ${TABLE}."DEPT" = 'debt' then 'Bad Debt'
              when ${TABLE}."DEPT" = 'del' then 'Delivery'
              when ${TABLE}."DEPT" = 'emp' then 'Employee Benefits'
              when ${TABLE}."DEPT" = 'fac' then 'Facilities'
              when ${TABLE}."DEPT" = 'gen' then 'General Administrative'
              when ${TABLE}."DEPT" = 'interco' then 'Intercompany'
              when ${TABLE}."DEPT" = 'misc' then 'Miscellaneous'
              when ${TABLE}."DEPT" = 'over' then 'Overhead'
              when ${TABLE}."DEPT" = 'rent' then 'Rental'
              when ${TABLE}."DEPT" = 'sale' then 'Sales'
              when ${TABLE}."DEPT" = 'serv' then 'Service'
              when ${TABLE}."DEPT" = 'reta' then 'Retail'
         end ;;
  }

  dimension: dept_order {
    type: number
    sql: case when ${dept} = 'Rental'                   then 1
              when ${dept} = 'Retail'                   then 2
              when ${dept} = 'Sales'                    then 3
              when ${dept} = 'Delivery'                 then 4
              when ${dept} = 'Service'                  then 5
              when ${dept} = 'Miscellaneous'            then 6
              when ${dept} = 'Bad Debt'                 then 7
              when ${dept} = 'Employee Benefits'        then 8
              when ${dept} = 'Facilities'               then 9
              when ${dept} = 'General Administrative'   then 10
              when ${dept} = 'Overhead'                 then 11
         end ;;
  }

  dimension: gl_acctno {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: gl_acct {
    label: "GL Name"
    type: string
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension: acctno_join {
    type: string
    hidden: yes
    sql: case
            when ${TABLE}."ACCTNO" = 'TAFR' then 'FAAJ'
            when ${TABLE}."ACCTNO" = 'TAIR' then 'FAAA'
            when ${TABLE}."ACCTNO" = 'TAJR' then 'FAAD'
            when ${TABLE}."ACCTNO" = 'TBBR' then 'FDAB'
            when ${TABLE}."ACCTNO" = 'TBDR' then 'FDAA'
            when ${TABLE}."ACCTNO" = 'TBCR' then 'FDAF'
            when ${TABLE}."ACCTNO" = 'GAAG' then '6006'
            when ${TABLE}."ACCTNO" = 'HIAC' then '7802'
            else ${TABLE}."ACCTNO" end
    ;;
  }

  measure: total_cy {
    label: "Activity GL links CY"
    type: sum
    value_format: "$#,##0;$(#,##0);-"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['be_snap_comparison_to_py.period_name'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
    }
    sql: case
                   when date_trunc('month', gl_date::date) in (select trunc::date
                                                         from analytics.gs.plexi_periods
                                                         where {% condition period_name %} display {% endcondition %})
                       then ${TABLE}."AMT"
                   else 0 end;;
  }


  measure: total_py {
    label: "Activity GL links PY"
    type: sum
    value_format: "$#,##0;$(#,##0);-"
    sql: case
                   when date_trunc('month', gl_date::date) in (select dateadd(year, -1, trunc::date)
                                                         from analytics.gs.plexi_periods
                                                         where {% condition period_name %} display {% endcondition %})
                       then ${TABLE}."AMT"
                   else 0 end ;;
  }

  measure: variance_to_pu {
    label: "Variance to Prior Year"
    type: number
    sql: abs(${total_cy}-${total_py});;
  }

  measure: count {
    type: count
    drill_fields: [mkt_name]
  }
}
