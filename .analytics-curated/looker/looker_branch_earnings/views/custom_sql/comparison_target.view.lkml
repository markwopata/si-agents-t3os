view: comparison_target {
    derived_table: {
      sql:
select
    H.MARKET_ID,
    m.name MARKET_NAME,
    case
        when H.BUCKET='EXP' then 'Expense'
        when H.BUCKET='REV' then 'Revenue'
        else D.DISPLAY_NAME
    end type,
    iff(H.BUCKET='interco',H.BUCKET,right(H.BUCKET,length(H.BUCKET)-3)) dept,
    coalesce(B.SAGE_NAME, A.TITLE) gl_acct,
    H.ACCOUNTNO acctno,
    H.REPORT_MONTH gl_date,
    concat(H.MARKET_ID,H.ACCOUNTNO,H.REPORT_MONTH::string) pk,
    H.AMOUNT amt
from ANALYTICS.PUBLIC.BRANCH_EARNINGS_HIST H
join   (select MARKET_ID, ACCOUNTNO, REPORT_MONTH, max(DATE_UPDATED) newest
        from ANALYTICS.PUBLIC.BRANCH_EARNINGS_HIST
        group by MARKET_ID, ACCOUNTNO, REPORT_MONTH)  F
    on H.MARKET_ID = F.MARKET_ID
    and H.ACCOUNTNO = F.ACCOUNTNO
    and H.REPORT_MONTH = F.REPORT_MONTH
    and H.DATE_UPDATED = F.newest
left join ANALYTICS.GS.PLEXI_BUCKET_MAPPING B
    on H.ACCOUNTNO = B.SAGE_GL
left join  (select distinct "GROUP", DISPLAY_NAME
            from ANALYTICS.GS.PLEXI_BUCKET_MAPPING) D
    on H.BUCKET = D."GROUP"
left join ANALYTICS.PUBLIC.GLACCOUNT A
    on H.ACCOUNTNO = A.ACCOUNTNO
left join es_warehouse.public.markets m
    on H.MARKET_ID = m.MARKET_ID
where H.MARKET_ID in ('7328', '15962')
               ;;
    }

    parameter: report_month {
      label: "Month"
      type: number
      #default_value: "8"
      allowed_value: {
        label: "January"
        value: "1"
      }
      allowed_value: {
        label: "February"
        value: "2"
      }
      allowed_value: {
        label: "March"
        value: "3"
      }
      allowed_value: {
        label: "April"
        value: "4"
      }
      allowed_value: {
        label: "May"
        value: "5"
      }
      allowed_value: {
        label: "June"
        value: "6"
      }
      allowed_value: {
        label: "July"
        value: "7"
      }
      allowed_value: {
        label: "August"
        value: "8"
      }
      allowed_value: {
        label: "September"
        value: "9"
      }
      allowed_value: {
        label: "October"
        value: "10"
      }
      allowed_value: {
        label: "November"
        value: "11"
      }
      allowed_value: {
        label: "December"
        value: "12"
      }
    }

    parameter: report_year {
      label: "Year"
      type: number
      suggest_dimension: gl_year_sugg
      allowed_value: {value: "2019"}
      allowed_value: {value: "2020"}
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    measure: amt_sum {
      label: "Activity"
      type: sum
      value_format: "#,##0.00;(#,##0.00);-"
      # link: {
      #   label: "Detail View"
      #   url: "@{lk_be_transaction_detail}?f[be_transaction_listing.mkt_name]={{ _filters['mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
      # }
      sql: coalesce(round(${amt},2), 0) ;;
    }

    measure: amt_sum2 {
      label: "Total no links"
      type: sum
      value_format: "#,##0;(#,##0);-"
      sql: ${amt} ;;
    }

    measure: amt_sum3 {
      label: "Activity GL links"
      type: sum
      value_format: "#,##0;(#,##0);-"
      link: {
        label: "Detail View"
        url: "@{lk_be_transaction_detail}?f[be_transaction_listing.mkt_name]={{ _filters['mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
      }
      sql: coalesce(round(${amt},2), 0) ;;
    }

    measure: amt_sum4 {
      label: "Activity donut bucket links"
      type: sum
      value_format: "#,##0;(#,##0);-"
      sql: coalesce(round(${amt},2), 0) ;;
    }

    measure: amt_sum5 {
      label: "Total P&L link"
      type: sum
      value_format: "#,##0.00;(#,##0.00);-"
      sql: ${amt} ;;
      link: {
        label: "Detail View"
        url: "@{lk_be_pl_detail}?f[be_transaction_listing.mkt_name]={{ _filters['mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
      }
    }

    dimension: mkt_id {
      type: string
      label: "Market ID"
      sql: ${TABLE}."MARKET_ID" ;;
      suggestions: ["7328", "15962"]
    }

    dimension: mkt_name {
      type: string
      label: "Market Name"
      sql: ${TABLE}."MARKET_NAME" ;;
      suggestions: ["Denver, Colorado", "Salt Lake City, Utah"]
    }

    dimension: type {
      type: string
      label: "Type"
      sql: ${TABLE}."TYPE" ;;
      order_by_field: bucket_order
    }

    dimension: dept {
      type: string
      label: "Department"
      suggestions: ["Rental", "Sales", "Delivery", "Service", "Miscellaneous"]
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
         end ;;
    }

    dimension: gl_acct {
      label: "GL Name"
      type: string
      sql: ${TABLE}."GL_ACCT" ;;
    }

    dimension: gl_acct2 {
      label: "GL Name GL links"
      type: string
      link: {
        label: "Detail View"
        url: "@{lk_be_transaction_detail}?f[be_transaction_listing.mkt_name]={{ _filters['mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
      }
      sql: ${TABLE}."GL_ACCT" ;;
    }

    dimension: gl_acctno {
      label: "GL Code"
      type: string
      sql: ${TABLE}."ACCTNO" ;;
    }

    dimension: gl_date {
      label: "Date"
      type: date
      convert_tz: no
      sql: ${TABLE}."GL_DATE" ;;
    }

    dimension: gl_year_sugg {
      type: date_year
      convert_tz: no
      hidden: yes
      sql: ${gl_date};;
    }

  dimension: pk {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

    dimension: amt {
      label: "Amount"
      type: number
      value_format: "#,##0.00;(#,##0.00);-"
      sql: ${TABLE}."AMT" ;;
    }

    dimension: bucket_order {
      type: number
      sql: case when ${type} = 'Rental Revenues'                    then 1
              when ${type} = 'Sales Revenues'                     then 2
              when ${type} = 'Delivery Revenues'                  then 3
              when ${type} = 'Service Revenues'                   then 4
              when ${type} = 'Miscellaneous Revenues'             then 5
              when ${type} = 'Bad Debt'                           then 6
              when ${type} = 'Cost of Rental Revenues'            then 7
              when ${type} = 'Cost of Sales Revenues'             then 8
              when ${type} = 'Cost of Delivery Revenues'          then 9
              when ${type} = 'Cost of Service Revenues'           then 10
              when ${type} = 'Cost of Miscellaneous Revenues'     then 11
              when ${type} = 'Employee Benefits Expenses'         then 12
              when ${type} = 'Facilities Expenses'                then 13
              when ${type} = 'General Expenses'                   then 14
              when ${type} = 'Overhead Expenses'                  then 15
              when ${type} = 'Intercompany Transactions'          then 16
              end ;;
    }

    dimension: dept_order {
      type: number
      sql: case when ${dept} = 'Rental'                   then 1
              when ${dept} = 'Sales'                    then 2
              when ${dept} = 'Delivery'                 then 3
              when ${dept} = 'Service'                  then 4
              when ${dept} = 'Miscellaneous'            then 5
              when ${dept} = 'Bad Debt'                 then 6
              when ${dept} = 'Employee Benefits'        then 7
              when ${dept} = 'Facilities'               then 8
              when ${dept} = 'General Administrative'   then 9
              when ${dept} = 'Overhead'                 then 10
         end ;;
    }

    set: detail {
      fields: []
    }
  }
