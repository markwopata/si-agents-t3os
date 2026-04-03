view: materials_branch_earnings {
  # # You can specify the table name if it's different from the view name:
  sql_table_name:analytics.materials.int_materials_branch_earnings_snap ;;

    # ---- Primary key ----
    dimension: pk {
      primary_key: yes
      type: string
      sql: ${TABLE}.PK ;;
    }

    # ---- Market fields ----
    dimension: mkt_id {
      type: number
      sql: ${TABLE}.MKT_ID ;;
    }

    dimension: mkt_name {
      type: string
      sql: ${TABLE}.MKT_NAME ;;
    }


    dimension: parent_market_id {
      type: number
      sql: ${TABLE}.PARENT_MARKET_ID ;;
    }

    dimension: parent_market_name {
      type: string
      sql: ${TABLE}.PARENT_MARKET_NAME ;;
    }

    # ---- GL / Accounting descriptors ----
    dimension: type {
      type: string
      sql: ${TABLE}.TYPE ;;
    }

    dimension: type2 {
      type: string
      sql: ${TABLE}.TYPE2 ;;
    }

    dimension: code {
      type: string
      sql: ${TABLE}.CODE ;;
    }

    dimension: revexp {
      type: string
      sql: ${TABLE}.REVEXP ;;
    }

    dimension: dept {
      type: string
      sql: ${TABLE}.DEPT ;;
    }

    dimension: pr_type {
      type: string
      sql: ${TABLE}.PR_TYPE ;;
    }

    dimension: ar_type {
      type: string
      sql: ${TABLE}.AR_TYPE ;;
    }

    dimension: gl_acct {
      type: string
      sql: ${TABLE}.GL_ACCT ;;
    }


    dimension: acctno {
      type: string
      sql: ${TABLE}.ACCTNO ;;
    }

    dimension: descr {
      type: string
      sql: ${TABLE}.DESCR ;;
    }

    dimension: doc_no {
      type: string
      sql: ${TABLE}.DOC_NO ;;
    }

    # ---- Dates ----
    dimension_group: gl_date {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      sql: ${TABLE}.GL_DATE ;;
    }

    dimension: branch_earnings_start_month {
      type: string
      sql: ${TABLE}.BRANCH_EARNINGS_START_MONTH ;;
    }

    # ---- URLs / metadata ----

  dimension: url_sage {
    label: "Intacct"
    type: string
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
          {% assign account_number = acctno._filterable_value | url_encode %}


        {% if acctno._value == 'IBAB' %}
        <a href="@{db_oec_detail}?Period={{ period_name }}&amp;Market+Name={{ market }}&amp;toggle=det" target="_blank">
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
        <a href="@{lk_be_credit_card_transactions}?f[credit_card_transactions.gl_code]={{ account_number }}&amp;f[market_region_xwalk.market_name]={{ market }}&amp;f[plexi_periods.display]={{ period_name }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
        &nbsp;
        {% endif %}
        {% if acctno._value == 'HFAH' %}
        <a href = "@{db_auto_accidents}?Period={{ period_name }}&amp;Market={{ market }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
        &nbsp;
        {% endif %}
        {% if acctno._value == 'HFAI' %}
        <a href = "@{db_work_comp_accidents}?Period={{ period_name }}&amp;Market={{ market }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
        &nbsp;
        {% endif %}
        {% if descr._value contains 'Dealership Equipment Sale' %}
        <a href="@{db_dealership_sales_margin}?Invoice+Number={{ dealership_invoice_no._filterable_value | url_encode }}&amp;Market+Name={{ market }}=&amp;Period={{ period_name }}&amp;toggle=det" target="_blank">
        @{looker_icon} Dashboard</a>
        &nbsp;
        {% endif %}
        {% if descr._value contains 'AP Accrual' %}
        <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
        &nbsp;
        {% endif %}
        {% if descr._value contains 'INITIAL LIVE ACCRUAL ENTRY' %}
        <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
        &nbsp;
        {% endif %}
        {% if descr._value contains 'ADJUSTMENT FOR CONVERTED NON RECEIPTS' %}
        <a href = "@{db_ap_accruals}?Market+Name={{ market }}&amp;GL+Code={{ account_number }}&amp;GL+Account={{ gl_acct }}&amp;Period={{ period_name }}&amp;toggle=det" target="_blank">
        @{looker_icon} AP Accruals</a>
        &nbsp;
        {% endif %}
        {% if descr._value contains 'Payroll Wages' %}
        <a href = "@{db_payroll_detail}?Market+Name={{ market }}&amp;GL+Account+Number={{ account_number }}&amp;Period={{ period_name }}&amp;Market+Type={{ market_type }}&amp;toggle=det" target="_blank">
        @{looker_icon} Payroll</a>
        &nbsp;
        {% endif %}
        {% if materials_branch_earnings.url_sage._value != null and (_user_attributes['department'] contains 'developer' or _user_attributes['email'] contains 'lacy.harris@equipmentshare.com') %}
        <a href = "{{ materials_branch_earnings.url_sage._value }}" target="_blank">
        @{sage_icon} Sage</a>
        &nbsp;
        {% endif %};;
    }

    dimension: metadata {
      type: string
      sql: ${TABLE}.METADATA ;;
    }

    # ---- Operational flags ----
    dimension: current_months_open {
      type: number
      sql: ${TABLE}.CURRENT_MONTHS_OPEN ;;
    }

    dimension: is_open_over_12_months {
      type: yesno
      sql: ${TABLE}.IS_OPEN_OVER_12_MONTHS ;;
    }

    measure: total_amount {
      type: sum
      value_format_name: usd
      value_format: "$0.00"
      sql: ${TABLE}.AMT ;;
    }

  dimension: pl_detail_link {
    type: string
    sql: 'P&L Detail' ;;
    html: <a style="color:rgb(26, 115, 232)"
   href="@{lk_materials_pl_detail}?f[market_region_xwalk.market_name]={{ _filters['materials_branch_earnings.mkt_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det"
   target="_blank">{{ value }}</a>;;

  }

  dimension: gl_detail_link {
    type: string
    sql: 'GL Detail' ;;
    html: <a style="color:rgb(26, 115, 232)" href="@{lk_materials_gl_detail}?f[materials_branch_earnings.mkt_name] = {{_filters['materials_branch_earnings.mkt_name'] | url_encode}}&f[plexi_periods.display]={{_filters['plexi_periods.display'] | url_encode}}&toggle=det" target="_blank">{{value}}</a> ;;

  }
  }
