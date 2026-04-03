view: be_snap_trailing_12_months {
  derived_table: {
    sql:
with be_snap as (select mkt_id,
                        mkt_name,
                        -- hard code outside hauling expenses to their respective delivery and rental costs
                        case
                            when acctno = '6014'
                                then 'Cost of Delivery Revenues'
                            when acctno = '6031'
                                then 'Cost of Rental Revenues'
                            else type end as type,
                        case
                            when acctno = '6014'
                                then 'EXPdel'
                            when acctno = '6031'
                                then 'EXPrent'
                            else code end as code,
                        revexp,
                        case
                            when acctno = '6014'
                                then 'del'
                            when acctno = '6031'
                                then 'rent'
                            else dept end as dept,
                        gl_acct,
                        acctno,
                        gl_date::date     as gl_date,
                        amt
                 from analytics.public.branch_earnings_dds_snap)
   , be_trending as (select lbe.market_id::varchar    as mkt_id
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
   , be_snap_and_trending as (select *
                              from be_snap
                              union all
                              select *
                              from be_trending)
select mkt_id
     , mkt_name
     , type
     , code
     , revexp
     , dept
     , gl_acct
     , acctno
     , gl_date
     , date_trunc(month, gl_date)::date as gl_date_trunc
     , amt
from be_snap_and_trending
where date_trunc('month', gl_date) between
          date_trunc('month',
                     dateadd(
                             month, -11,
                             (select min(trunc::date)
                              from analytics.gs.plexi_periods
                              where {% condition period_name %} display {% endcondition %})
                     )
          )
          and
          date_trunc(
                  'month',
                  (select max(trunc::date)
                   from analytics.gs.plexi_periods
                   where {% condition period_name %} display {% endcondition %})
          )
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
    suggest_dimension: market_region_xwalk_suggestion.market_id
  }

  dimension: mkt_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_name
  }

  dimension_group: gl_date {
    type: time
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: formatted_date_gl {
    group_label: "GL HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${gl_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month_gl {
    group_label: "GL HTML Formatted Date"
    label: "Month Date"
    type: date
    sql: ${gl_date_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month_gl {
    group_label: "GL HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${gl_date_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: ordered_revenue_types {
    description: "Ordered categories for revenue types to be used in formatting."
    type: string
    sql:
      CASE
        WHEN ${gl_acctno} = '5009' THEN '1'
        WHEN ${gl_acctno} = '6014' THEN '2'
        WHEN ${gl_acctno} = '6031' THEN '3'
        WHEN ${gl_acctno} = '6019' THEN '4'
        WHEN ${gl_acctno} = '6020' THEN '5'
        WHEN ${gl_acctno} = '6016' THEN '6'
        WHEN ${gl_acctno} = '6032' THEN '7'
        WHEN ${gl_acctno} = '6901' THEN '8'
        WHEN ${gl_acctno} = '6015' THEN '9'
        ELSE '10 - Unknown'
      END ;;
  }

  dimension: delivery_recovery_split {
    description: "DR Revenue vs Cost Split"
    type: string
    sql:
    CASE
    WHEN ${gl_acctno} = '5009' THEN 'Revenue'
    WHEN ${gl_acctno} IN ('6014', '6015', '6019', '6020', '6031') THEN 'Costs'
    ELSE 'Other'
    END ;;
  }

  dimension: type {
    type: string
    label: "Type"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
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

  measure: total_amt {
    label: "Total AMT"
    type: sum
    value_format: "$#,##0;$(#,##0);-"
    link: {
      label: "Detail View"
      url:"@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ plexi_periods.display._filterable_value }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."AMT";;
  }

  measure: amount_sum {
    label: "Revenue Total"
    type: sum
    sql: COALESCE(${TABLE}."AMT",0);;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: delivery_recovery_perc {
    label: "Delivery Recovery %"
    type: number
    sql: COALESCE(
          SUM(CASE WHEN ${gl_acctno} = '5009' THEN COALESCE(${TABLE}.amt,0) ELSE 0 END)
          /
          NULLIF(SUM(CASE WHEN ${gl_acctno} IN ('6014','6015','6016','6019','6020','6031')
                          THEN COALESCE(${TABLE}.amt,0) ELSE 0 END),0),
          0
       ) ;;
    value_format: "0.0%"
  }

  measure: delivery_revenue {
    label: "Delivery Revenue"
    type: number
    sql: SUM(CASE WHEN ${gl_acctno} = '5009' THEN COALESCE(${TABLE}.amt,0) ELSE 0 END);;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: delivery_expense {
    label: "Delivery Expense"
    type: number
    sql: SUM(CASE WHEN ${gl_acctno} IN ('6014','6015','6016','6019','6020','6031')
                          THEN COALESCE(${TABLE}.amt,0) ELSE 0 END);;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: fuel_revenue {
    label: "Fuel Revenue"
    type: number
    sql: SUM(CASE WHEN ${gl_acctno} in ('5010','5020') THEN COALESCE(${TABLE}.amt,0) ELSE 0 END);;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: fuel_expense {
    label: "Fuel Expense"
    type: number
    sql: SUM(CASE WHEN ${gl_acctno} IN ('6007','5021')
      THEN COALESCE(${TABLE}.amt,0) ELSE 0 END);;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: payroll_compensation_expense {
    label: "Total Payroll Expense"
    type: sum
    sql: case when ${gl_acct} ilike '%overtime%' or ${gl_acct} ilike '%commission%' or ${gl_acct} ilike '%payroll%' then ${TABLE}."AMT"
          ELSE 0
        END ;;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: payroll_overtime_expense {
    label: "OverTime Expense"
    type: sum
    sql: case when ${gl_acct} ilike '%overtime%' then ${TABLE}."AMT"
    ELSE 0
    END ;;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: abs_payroll_compensation_expense {
    label: "Absolute Total Payroll Expense"
    type: number
    sql: ABS(${payroll_compensation_expense});;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: abs_payroll_overtime_expense {
    label: "Absolute OverTime Expense"
    type: number
    sql: ABS(${payroll_overtime_expense});;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: abs_ot_to_total_wages {
    label: "OT to Total Wages"
    type: number
    sql: case when ${abs_payroll_overtime_expense} = 0 then 0
          else ${abs_payroll_overtime_expense}/${abs_payroll_compensation_expense}
          end;;
    value_format: "0.0%"
  }

  measure: maintenance_expenses{
    label: "Maintenance Expense"
    type: sum
    sql: case when ${type} = 'Cost of Service Revenues' then ${TABLE}."AMT"
          ELSE 0
          END;;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: maintenance_revenue{
    label: "Maintenance Revenue"
    type: sum
    sql: case when ${type} = 'Service Revenues' then ${TABLE}."AMT"
          ELSE 0
          END;;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: rent_revenue {
    label: "Rent Revenue"
    type: sum
    sql: case when ${type} = 'Rental Revenues' then ${TABLE}."AMT"
          ELSE 0
          END;;
    value_format: "$#,##0;$(#,##0);-"
  }

  measure: maintenance_to_rent_revenue {
    label: "Maintenance to Rent Revenue"
    type: number
    sql: ${maintenance_expenses}/${rent_revenue};;
  }

  measure: count {
    type: count
    drill_fields: [mkt_name]
  }

}
