view: be_transaction_listing {
  derived_table: {
    sql:  select
            row_number() over (order by sn.pk) as pk1,
            sn.*
          from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP as sn
          {% if report_month._parameter_value == "''" %}
          where date_part(month, GL_DATE) = {% parameter report_month %}
              and date_part(year, GL_DATE) = {% parameter report_year %}
          {% endif %}
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
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&toggle=det"
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
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&f[be_transaction_listing.gl_acct]={{ gl_acct | url_encode }}&toggle=det"
    }
    sql: coalesce(round(${amt},2), 0) ;;
  }

  measure: amt_sum4 {
    label: "Activity donut bucket links"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: coalesce(round(case when ${revexp}='Expenses' then -1 else 1 end*${amt},2), 0) ;;
  }

  measure: amt_sum5 {
    label: "Total P&L link"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${amt} ;;
    link: {
      label: "Detail View"
      url: "@{lk_be_pl_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[market_region_xwalk.market_type]={{ _filters['market_region_xwalk.market_type'] | url_encode }}&f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ _filters['be_transaction_listing.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
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

  dimension: type {
    type: string
    label: "Type"
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.type]={{ type | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."TYPE" ;;
    order_by_field: bucket_order
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_category
    suggest_persist_for: "6 hours"
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
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_name
    suggest_persist_for: "6 hours"
  }

  dimension: gl_acct2 {
    label: "GL Name GL links"
    type: string
    link: {
      label: "Detail View"
      url: "@{lk_be_transaction_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&f[be_transaction_listing.gl_acctno]={{ gl_acctno | url_encode }}&f[be_transaction_listing.gl_acct]={{ gl_acct | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension: gl_acctno {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCTNO" ;;
    suggest_explore: account_suggestions_be_snap
    suggest_dimension: account_suggestions_be_snap.account_number
    suggest_persist_for: "6 hours"
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
      {% assign period_name = _filters['plexi_periods.display'] | url_encode %}
      {% assign market = _filters['market_region_xwalk.market_name'] | url_encode %}
      {% assign district = _filters['market_region_xwalk.region_district'] | url_encode %}
      {% assign region = _filters['market_region_xwalk.region_name'] | url_encode %}
      {% assign account_number = _filters['be_transaction_listing.gl_acctno'] | url_encode %}
      {% assign market_type = _filters['market_region_xwalk.market_type'] | url_encode %}
      {% assign greater_twelve_months_open = _filters['be_transaction_listing.greater_twelve_months_open'] | url_encode %}
      {% assign account_name = be_transaction_listing.gl_acct._filterable_value | url_encode %}

      {% if value contains 'AP Accrual' or value contains 'AP accrual'  %}
        <a style="color:blue; text-decoration:underline" href="@{db_ap_accruals}?GL+Code={{ account_number }}&amp;Market+Name={{ market }}&amp;Period={{ period_name }}&amp;District+Number={{ district }}&amp;Region+Name={{ region }}&amp;GL+Account={{ account_name }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'INITIAL LIVE ACCRUAL ENTRY'  %}
        <a style="color:blue; text-decoration:underline" href="@{db_ap_accruals}?GL+Code={{ account_number }}&amp;Market+Name={{ market }}&amp;Period={{ period_name }}&amp;District+Number={{ district }}&amp;Region+Name={{ region }}&amp;GL+Account={{ account_name }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'ADJUSTMENT FOR CONVERTED NON RECEIPTS'  %}
        <a style="color:blue; text-decoration:underline" href="@{db_ap_accruals}?GL+Code={{ account_number }}&amp;Market+Name={{ market }}&amp;Period={{ period_name }}&amp;District+Number={{ district }}&amp;Region+Name={{ region }}&amp;GL+Account={{ account_name }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif gl_acctno._value == 'IBAB' %}
        <a style="color:blue; text-decoration:underline" href="@{db_oec_detail}?Period={{ period_name }}&amp;Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;Region+District={{ district }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'Central CC' or value contains 'AMEX' or value contains 'Citi CC'%}
        <a style="color:blue; text-decoration:underline" href="@{lk_be_credit_card_transactions}?f[credit_card_transactions.gl_code]={{ account_number }}&amp;f[market_region_xwalk.market_name]={{ market }}&amp;f[market_region_xwalk.region_district]={{ district }}&amp;f[market_region_xwalk.region_name]={{ region }}&amp;f[market_region_xwalk.market_type]={{ market_type }}&amp;f[plexi_periods.display]={{ period_name }}&amp;f[credit_card_transactions.greater_twelve_months_open]={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'Fuel CC Allocation' or value contains 'Navan Allocation' or value contains 'Citi Bank Allocation'%}
        <a style="color:blue; text-decoration:underline" href="@{lk_be_credit_card_transactions}?f[credit_card_transactions.gl_code]={{ account_number }}&amp;f[credit_card_transactions.gl_account]={{ account_name }}&amp;f[market_region_xwalk.market_name]={{ market }}&amp;f[market_region_xwalk.region_district]={{ district }}&amp;f[market_region_xwalk.region_name]={{ region }}&amp;f[market_region_xwalk.market_type]={{ market_type }}&amp;f[plexi_periods.display]={{ period_name }}&amp;f[credit_card_transactions.entry_name]={{ value | url_encode }}&amp;f[credit_card_transactions.greater_twelve_months_open]={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">{{value}}</a>
      {% elsif value contains 'Dealership Equipment Sale' %}
        <a style="color:blue; text-decoration:underline" href="@{db_dealership_sales_margin}?Period={{ period_name }}&amp;District={{ district }}&amp;Region={{ region }}&amp;AssetID=&amp;Invoice+Number={{ dealership_invoice_no._filterable_value | url_encode }}&amp;Market+Name={{ market }}" target="_blank">{{value}}</a>
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

  dimension_group: gl_date_grouped {
    label: "Date Grouped"
    type: time
    timeframes: [date,month,quarter,year]
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

  dimension: dealership_invoice_no {
    type: string
    sql: case
          when ${TABLE}."DESCR" ilike '%Dealership Equipment Sale%' then regexp_substr(${TABLE}."DESCR", ' Invoice #: ([0-9]+-[0-9]+)',1,1,'e')
          else ''
         end
         ;;
  }

  dimension: pk1 {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK1" ;;
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
          # sql: ${TABLE}."URL_SAGE" ;;
      sql:
          case when {{ _user_attributes['department'] }} != 'developer' then null else
          ${TABLE}."URL_SAGE" end ;;
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
    html: {% if value == null %}&nbsp;
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Admin Link</a></u></font>
          {% endif %};;
    sql: ${TABLE}."URL_ADMIN" ;;
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
    sql: ' ' ;; # Just generate sql always
    html:
    {% assign period_name = _filters['plexi_periods.display'] | url_encode %}
    {% assign market = _filters['market_region_xwalk.market_name'] | url_encode %}
    {% assign district = _filters['market_region_xwalk.region_district'] | url_encode %}
    {% assign region = _filters['market_region_xwalk.region_name'] | url_encode %}
    {% assign account_number = gl_acctno._filterable_value | url_encode %}
    {% assign market_type = _filters['market_region_xwalk.market_type'] | url_encode %}
    {% assign greater_twelve_months_open = greater_twelve_months_open._value | url_encode %}

    {% if gl_acctno._value == 'IBAB' %}
      <a href="@{db_oec_detail}?Period={{ period_name }}&amp;Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;Region+District={{ district }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'Central CC'
      or descr._value contains 'AMEX'
      or descr._value contains 'Central Bank allocation'
      or descr._value contains 'Fuel CC'
      or descr._value contains 'Citi CC'
      or descr._value contains 'Citi Bank'
      or descr._value contains 'Navan'
    %}
      <a href="@{lk_be_credit_card_transactions}?f[credit_card_transactions.gl_code]={{ account_number }}&amp;f[market_region_xwalk.market_name]={{ market }}&amp;f[market_region_xwalk.region_district]={{ district }}&amp;f[market_region_xwalk.region_name]={{ region }}&amp;f[plexi_periods.display]={{ period_name }}&amp;f[credit_card_transactions.greater_twelve_months_open]={{ greater_twelve_months_open }}&amp;f[market_region_xwalk.market_type]={{ market_type }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.url_admin._value != null %}
      <a href = "{{ be_transaction_listing.url_admin._value }}" target="_blank">
        @{admin_icon} Admin</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.url_track._value != null %}
      <a href = "{{ be_transaction_listing.url_track._value }}" target="_blank">
        @{t3_icon} T3</a>
      &nbsp;
    {% endif %}
        {% if be_transaction_listing.url_yooz._value != null %}
      <a href = "{{ be_transaction_listing.url_yooz._value }}" target="_blank">
        @{concur_icon} Concur</a>
      &nbsp;
    {% endif %}
    {% if gl_acctno._value == 'HFAH' %}
      <a href = "@{db_auto_accidents}?Period={{ period_name }}&amp;Market={{ market }}&amp;District={{ district }}&amp;Region={{ region }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
      &nbsp;
    {% endif %}
    {% if gl_acctno._value == 'HFAI' %}
      <a href = "@{db_work_comp_accidents}?Period={{ period_name }}&amp;Market={{ market }}&amp;Region={{ region }}&amp;District={{ district }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'Dealership Equipment Sale' %}
      <a href="@{db_dealership_sales_margin}?Invoice+Number={{ dealership_invoice_no._filterable_value | url_encode }}&amp;Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;District={{ district }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'AP Accrual' %}
      <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;District+Number={{ district }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'INITIAL LIVE ACCRUAL ENTRY' %}
      <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;District+Number={{ district }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'ADJUSTMENT FOR CONVERTED NON RECEIPTS' %}
      <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;District+Number={{ district }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;Market+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ greater_twelve_months_open }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
      &nbsp;
    {% endif %}
    {% if descr._value contains 'Payroll Wages' %}
      <a href = "@{db_payroll_detail}?Market+Name={{ market }}&amp;Region+Name={{ region }}&amp;District+Number={{ district }}&amp;GL+Account+Number={{ account_number }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;toggle=det" target="_blank">
        @{looker_icon} Payroll</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.url_sage._value != null and (_user_attributes['department'] contains 'developer' or _user_attributes['email'] contains 'lacy.harris@equipmentshare.com') %}
      <a href = "{{ be_transaction_listing.url_sage._value }}" target="_blank">
        @{sage_icon} Sage</a>
      &nbsp;
    {% endif %}
    {% if be_transaction_listing.related_po_receipt._value != null %}
      <a href="@{lk_be_transaction_detail}?f[be_transaction_listing.related_po_receipt]={{ be_transaction_listing.related_po_receipt._value | url_encode }}&amp;f[be_transaction_listing.mkt_name]=%22{{ be_transaction_listing.mkt_name._value | url_encode }}%22&amp;toggle=det" target="_blank">
        @{looker_icon} Linked Txns</a>
      &nbsp;
    {% endif %};;
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
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date}) + 1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

# related po receipt used to connect VI, CPO, APA TRUE UPS back to originating PO. ZL 10.16.25
  dimension: related_po_receipt {
    type: string
    sql: ${TABLE}.metadata:"receipt"::string ;;
  }

# related po document used to connect VI, CPO, APA TRUE UPS back to originating PO. ZL 10.16.25
  dimension: related_po_document_name {
    type: string
    sql: ${TABLE}.metadata:"document_name"::string ;;
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
