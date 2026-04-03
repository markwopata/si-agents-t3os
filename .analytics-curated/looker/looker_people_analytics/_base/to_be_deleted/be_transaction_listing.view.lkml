view: be_transaction_listing {
  derived_table: {
    sql:  select *
          from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP
          {% if report_month._parameter_value == "''" %}
          where date_part(month, GL_DATE) = {% parameter report_month %}
              and date_part(year, GL_DATE) = {% parameter report_year %}
          {% endif %}
;;
  }

  parameter: bucket_select {
    label: "Transaction type"
    type: string
    # default_value: null
    allowed_value: {
      label: "Rental Revenues"
      value: "REVrent"
    }
    allowed_value: {
      label: "Sales Revenues"
      value: "REVsale"
    }
    allowed_value: {
      label: "Delivery Revenues"
      value: "REVdel"
    }
    allowed_value: {
      label: "Service Revenues"
      value: "REVserv"
    }
    allowed_value: {
      label: "Miscellaneous Revenues"
      value: "REVmisc"
    }
    allowed_value: {
      label: "Bad Debt"
      value: "EXPdebt"
    }
    allowed_value: {
      label: "Cost of Rental Revenues"
      value: "EXPrent"
    }
    allowed_value: {
      label: "Cost of Sales Revenues"
      value: "EXPsale"
    }
    allowed_value: {
      label: "Cost of Delivery Revenues"
      value: "EXPdel"
    }
    allowed_value: {
      label: "Cost of Service Revenues"
      value: "EXPserv"
    }
    allowed_value: {
      label: "Cost of Miscellaneous Revenues"
      value: "EXPmisc"
    }
    allowed_value: {
      label: "Employee Benefits Expenses"
      value: "EXPemp"
    }
    allowed_value: {
      label: "Facilities Expenses"
      value: "EXPfac"
    }
    allowed_value: {
      label: "General Expenses"
      value: "EXPgen"
    }
    allowed_value: {
      label: "Overhead Expenses"
      value: "EXPover"
    }
    allowed_value: {
      label: "Intercompany Transactions"
      value: "interco"
    }
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
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ code | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
    }
    sql: coalesce(round(${amt},2), 0) ;;
  }

  measure: amt_sum_revenue {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: case when ${revexp} = 'Revenues' then coalesce(round(${amt},2), 0) else 0 end ;;
  }

  measure: amt_sum2 {
    label: "Total no links"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${amt} ;;
  }

  measure: amt_sum3 {
    label: "Activity GL links"
    type: sum
    value_format: "#,##0;(#,##0);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/159?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
    }
    sql: coalesce(round(${amt},2), 0) ;;
  }

  measure: amt_sum4 {
    label: "Activity donut bucket links"
    type: sum
    value_format: "#,##0;(#,##0);-"
    # link: {
    #   label: "Detail View"
    #   url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ _filters['mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ revexp2._value }}{{ dept2._value }}&toggle=det"
    # }
    sql: coalesce(round(case when ${revexp}='Expenses' then -1 else 1 end*${amt},2), 0) ;;
  }

  measure: amt_sum5 {
    label: "Total P&L link"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${amt} ;;
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/157?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det"
    }
  }

  dimension: mkt_id {
    type: string
    label: "Market ID"
    sql: ${TABLE}."MKT_ID" ;;
    suggest_explore: market_region_xwalk
    suggest_dimension: market_region_xwalk.market_id
  }

  dimension: mkt_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk
    suggest_dimension: market_region_xwalk.market_name
  }

  dimension: type {
    type: string
    label: "Type"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ code | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
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

  dimension: revexp2 {
    type: string
    hidden: yes
    sql: ${TABLE}."REVEXP" ;;
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

  dimension: dept2 {
    type: string
    hidden: yes
    sql: ${TABLE}."DEPT" ;;
  }

  dimension: pr_type {
    label: "Payroll Type"
    type: string
    sql: ${TABLE}."PR_TYPE" ;;
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
      url: "https://equipmentshare.looker.com/looks/159?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension: gl_acctno {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
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

  dimension: descr {
    label: "Description"
    type: string
    sql: coalesce(${TABLE}."DESCR", '') ;;
    html:
      {% if value contains 'AP Accrual' or value contains 'AP accrual'  %}
        <a style="color:blue; text-decoration:underline" href="https://equipmentshare.looker.com/dashboards/494?GL+Code={{ _filters['gl_acctno'] | url_encode }}&Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&GL+Account={{ be_transaction_listing.gl_acct._filterable_value | url_encode }}&toggle=det" target="_blank">{{value}}</a>
      {% elsif gl_acctno._value == 'IBAB' %}
        <a style="color:blue; text-decoration:underline" href="https://equipmentshare.looker.com/dashboards-next/531?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'Central CC' or value contains 'AMEX' or value contains 'Central Bank allocation' or value contains 'Fuel CC' or value contains 'Citi CC' or value contains 'Citi Bank' %}
        <a style="color:blue; text-decoration:underline" href="https://equipmentshare.looker.com/looks/345?f[credit_card_transactions.gl_code]={{ _filters['gl_acctno'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['region_district'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['region_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">{{value}}</a>
      {% else %}
        {{value}}
      {% endif %};;
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

  dimension: doc_no {
    label: "Document #"
    type: string
    sql: coalesce(${TABLE}."DOC_NO", '') ;;
  }

  dimension: pk {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: url_sage {
    label: "Intacct"
    type: string
    # hidden: yes
    html: {% if value == null %}
          <font style="bold ">Pending</font>
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_SAGE" ;;
  }

  dimension: url_yooz {
    label: "Concur"
    type: string
    # hidden: yes
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Concur Link</a></u></font>
          {% endif %};;
    sql: case when ${TABLE}."URL_YOOZ" ilike '%yooz%' then null else ${TABLE}."URL_YOOZ" end;;
  }

  dimension: url_admin {
    label: "Admin"
    type: string
    # hidden: yes
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Admin Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: url_track {
    label: "Track"
    type: string
    # hidden: yes
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Track Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_TRACK" ;;
  }

  dimension: link_agg {
    label: "Links"
    sql: coalesce(/*${TABLE}."URL_SAGE",*/${TABLE}."URL_ADMIN",${TABLE}."URL_TRACK",${TABLE}."URL_YOOZ", case when ${TABLE}."ACCTNO" = 'IBAB' or ${TABLE}."ACCTNO" = 'HFAH' or ${TABLE}."ACCTNO" = 'HFAI' or ${TABLE}."DESCR" like '%Asset ID: %' or ${TABLE}."DESCR" like '%Central CC' or ${TABLE}."DESCR" like '%AMEX%' then 'a' end) ;;
    html:
    {% if gl_acctno._value == 'IBAB' %}
      <a href = "https://equipmentshare.looker.com/dashboards-next/531?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['mkt_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
        <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'Central CC' or descr._value contains 'AMEX' or descr._value contains 'Central Bank allocation' or descr._value contains 'Fuel CC' or descr._value contains 'Citi CC' or descr._value contains 'Citi Bank' %}
      <a href="https://equipmentshare.looker.com/looks/345?f[credit_card_transactions.gl_code]={{ _filters['gl_acctno'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['mkt_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['region_district'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['region_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
        <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.url_admin._value != null %}
      <a href = "{{ be_transaction_listing.url_admin._value }}" target="_blank">
        <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.url_track._value != null %}
      <a href = "{{ be_transaction_listing.url_track._value }}" target="_blank">
        <img src="https://unav.equipmentshare.com/fleet.svg" width="16" height="16"> Track</a>
      &nbsp;
    {% endif %}
        {% if be_transaction_listing.url_yooz._value != null %}
      <a href = "{{ be_transaction_listing.url_yooz._value }}" target="_blank">
        <img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Concur</a>
      &nbsp;
    {% endif %}
    {% if gl_acctno._value == 'HFAH' %}
      <a href = "https://equipmentshare.looker.com/dashboards-next/816?Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
        <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
      &nbsp;
    {% endif %}
    {% if gl_acctno._value == 'HFAI' %}
      <a href = "https://equipmentshare.looker.com/dashboards-next/825?Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
        <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
      &nbsp;
    {% endif %}

      ;;
    # {% if be_transaction_listing.url_sage._value != null and be_transaction_listing.descr._value contains 'AP Accrual' %}
    #   <a href = "https://equipmentshare.looker.com/dashboards/494?GL+Code={{ _filters['gl_acctno'] | url_encode }}&Market+Name={{ _filters['mkt_name'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&toggle=det" target="_blank">
    #     <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
    #   &nbsp;
    # {% endif %}
    # {% if be_transaction_listing.url_sage._value != null %}
    #   <a href = "{{ be_transaction_listing.url_sage._value }}" target="_blank">
    #     <img src="https://www.sageintacct.com/favicon.ico" width="16" height="16"> Intacct</a>
    #   &nbsp;
    # {% endif %}
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

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1 ;;
  }
  # sql: datediff(months, ${revmodel_market_rollout_conservative.market_start_month_raw}, ${plexi_periods.trunc})+1 ;;

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  set: detail {
    fields: [
      gl_acct,
      gl_date,
      descr,
      doc_no,
      amt,
      link_agg
    ]
  }

  dimension_group: gl_date_test {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql: ${TABLE}.gl_date ;;

  }
}
