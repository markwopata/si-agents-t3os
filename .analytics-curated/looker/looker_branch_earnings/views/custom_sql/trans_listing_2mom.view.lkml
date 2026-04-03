view: trans_listing_2mom {
  derived_table: {
    sql:
      select
             row_number() over (order by pk) as pk,
             mkt_id,
             type,
             code,
             revexp,
             dept,
             gl_acct,
             acctno,
             descr,
             date_trunc(month,gl_date) gl_date1,
             doc_no,
             url_sage,
             url_yooz,
             url_track,
             amt
      from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP snp
      where date_trunc(month,gl_date1) >= dateadd(month, -1, (select trunc from ANALYTICS.GS.PLEXI_PERIODS where DISPLAY = {% parameter report_period %}))
          and gl_date1 <= (select trunc from ANALYTICS.GS.PLEXI_PERIODS where DISPLAY = {% parameter report_period %})
      ;;
  }

  parameter:  report_period {
    label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: period_published {
    label: "Plexi Period Published"
    type: string
    sql: (select period_published from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
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
    #default_value: "2020"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: amt_sum {
    label: "Activity"
    type: sum
    value_format: "#,##0;(#,##0);-"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ report_period._parameter_value | remove: \"'\" | url_encode }}&f[be_transaction_listing.dept]={{ dept | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    sql: coalesce(round(${amt} ,2), 0) ;;
  }

  measure: amt_sum2 {
    label: "Activity GL links"
    type: sum
    value_format: "#,##0;(#,##0);-"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ report_period._parameter_value | remove: \"'\" | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno._filterable_value | url_encode }}&f[be_transaction_listing.gl_acct]={{ gl_acct._filterable_value | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    sql: coalesce(round(${amt} ,2), 0) ;;
  }

  dimension: mkt_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."MKT_ID" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_id
  }

  dimension: pk {
    type: number
    sql: ${TABLE}."PK" ;;
    primary_key: yes
  }

  dimension: type {
    type: string
    label: "Type"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ report_period._parameter_value | remove: \"'\" | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."TYPE" ;;
    order_by_field: bucket_order
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_category
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
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[be_transaction_listing.dept]={{ dept | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ report_period._parameter_value | remove: \"'\" | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
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
              when ${TABLE}."DEPT" = 'reta' then 'Retail Parts'
         end ;;
  }

  dimension: dept2 {
    type: string
    hidden: yes
    sql: ${TABLE}."DEPT" ;;
  }

  dimension: gl_acct {
    label: "GL Name"
    type: string
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&f[be_transaction_listing.gl_acct]={{ gl_acct | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."GL_ACCT" ;;
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_name
  }

  dimension: gl_acctno {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_number
  }

  dimension: descr {
    label: "Description"
    type: string
    sql: coalesce(${TABLE}."DESCR", '') ;;
  }

  # dimension: gl_date_main {
  #   label: "Month "
  #   type: date_month_name
  #   convert_tz: no
  #   sql: ${TABLE}."GL_DATE" ;;
  # }

  dimension: gl_date2 {
    label: "Date"
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE1" ;;
  }

  dimension: gl_date3 {
    label: "Month + Year"
    type: string
    order_by_field: gl_date2
    sql: to_varchar(${TABLE}."GL_DATE1", 'MMMM YYYY') ;;
  }

  dimension: doc_no {
    label: "Doc #"
    type: string
    sql: coalesce(${TABLE}."DOC_NO", '') ;;
  }

  dimension: url_sage {
    label: "Intacct"
    type: string
    html: {% if value == null %}
          <font style="bold ">Pending</font>
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_SAGE" ;;
  }

  dimension: url_yooz {
    label: "Yooz"
    type: string
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Yooz Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_YOOZ" ;;
  }

  dimension: url_track {
    label: "Track"
    type: string
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Track Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_TRACK" ;;
  }

  dimension: link_agg {
    label: "Links"
    sql: ${TABLE}."URL_SAGE" ;;
    html: {% if be_transaction_listing.url_sage._value != null %}
          <a href = "{{ be_transaction_listing.url_sage._value }}" target="_blank"><img src="https://www.sageintacct.com/favicon.ico" width="16" height="16"> Intacct</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if be_transaction_listing.url_yooz._value != null %}
          <a href = "{{ be_transaction_listing.url_yooz._value }}" target="_blank"><img src="https://www.getyooz.com/favicon.ico" width="16" height="16"> Yooz</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if be_transaction_listing.url_track._value != null %}
          <a href = "{{ be_transaction_listing.url_track._value }}" target="_blank"><img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Track</a>
          {% endif %}
          ;;
  }

  dimension: amt {
    label: "Amount"
    type: number
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}."AMT" ;;
  }

  dimension: bucket_order {
    type: number
    sql: case when ${type} = 'Rental Revenues'                    then 1
              when ${type} = 'Sales Revenues'                     then 2
              when ${type} = 'Delivery Revenues'                  then 3
              when ${type} = 'Service Revenues'                   then 4
              when ${type} = 'Retail Revenues'                    then 5
              when ${type} = 'Miscellaneous Revenues'             then 6
              when ${type} = 'Bad Debt'                           then 7
              when ${type} = 'Cost of Rental Revenues'            then 8
              when ${type} = 'Cost of Sales Revenues'             then 9
              when ${type} = 'Cost of Delivery Revenues'          then 10
              when ${type} = 'Cost of Service Revenues'           then 11
              when ${type} = 'Cost of Retail Revenues'            then 12
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

  dimension: period {
    type: string
    sql: (select display from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
  }

  dimension: trunc {
    type: string
    sql: (select trunc from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${trunc})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  set: detail {
    fields: [
      gl_acct,
      gl_date2,
      descr,
      doc_no,
      amt,
      link_agg
    ]
  }
}
