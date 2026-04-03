view: int_live_branch_earnings_looker {
  sql_table_name: "BRANCH_EARNINGS"."INT_LIVE_BRANCH_EARNINGS_LOOKER" ;;

  dimension: pk_id {
    type: string
    sql: ${TABLE}."PK_ID" ;;
    primary_key: yes
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
    order_by_field: category_sort_order
  }

  dimension: account_category_id {
    type: number
    sql: ${TABLE}."ACCOUNT_CATEGORY_ID" ;;
    order_by_field: category_sort_order
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: category_sort_order {
    type: number
    sql: ${TABLE}."CATEGORY_SORT_ORDER" ;;
  }

  dimension: market_greater_than_12_months {
    type: yesno
    sql: ${TABLE}."MARKET_GREATER_THAN_12_MONTHS" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension_group: gl_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    sql:${TABLE}."GL_DATE" ;;
  }

  dimension: gl_month {
    type: string
    sql: ${TABLE}."GL_MONTH" ;;
  }

  measure: inventory_bulk_part_expense_to_rental_revenue_ratio{
    type: number
    sql: case when ${total_rental_revenue} != 0
            then abs(${total_inventory_bulk_part_expense}) / ${total_rental_revenue}
            else 0 end;;
  }

  dimension: is_overtime_wage {
    type: yesno
    sql: ${TABLE}."IS_OVERTIME_WAGE" ;;
  }

  dimension: admin_only_data {
    type: yesno
    sql: ${TABLE}."ADMIN_ONLY_DATA" ;;
  }

  measure: total_overtime_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_OVERTIME_WAGE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }

  dimension: is_payroll_expense {
    type: yesno
    sql: ${TABLE}."IS_PAYROLL_EXPENSE" ;;
  }

  measure: total_payroll_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_PAYROLL_EXPENSE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }

  measure: overtime_to_payroll_ratio {
    type: number
    sql: case when ${total_payroll_expense} != 0
            then abs(${total_overtime_expense}) / abs(${total_payroll_expense})
            else 0 end;;
  }

  dimension: is_paid_delivery_revenue {
    type: yesno
    sql: ${TABLE}."IS_PAID_DELIVERY_REVENUE" ;;
  }

  measure: total_delivery_revenue {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_PAID_DELIVERY_REVENUE" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }

  dimension: is_delivery_expense_account {
    type: yesno
    sql: ${TABLE}."IS_DELIVERY_EXPENSE_ACCOUNT" ;;
  }

  measure: total_delivery_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."IS_DELIVERY_EXPENSE_ACCOUNT" = true THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }

  measure: delivery_ratio {
    type: number
    sql: case when ${total_delivery_expense} != 0
            then ${total_delivery_revenue} / abs(${total_delivery_expense})
            else 0 end;;
  }

  dimension: filter_month {
    type: string
    sql: ${TABLE}."FILTER_MONTH" ;;
    order_by_field: gl_month
    suggest_persist_for: "5 minutes"
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}.district in ({{ _user_attributes['district'] }}) OR ${TABLE}.region_name in ({{ _user_attributes['region'] }}) OR ${TABLE}.market_id in ({{ _user_attributes['market_id'] }}) ;;
  }

  dimension: raw_url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: raw_url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }

  dimension: raw_url_sage {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
  }

  dimension: raw_url_concur {
    type: string
    sql: ${TABLE}."URL_CONCUR" ;;
  }

  dimension: raw_url_gitlab {
    type: string
    sql: ${TABLE}."URL_GITLAB" ;;
  }

  dimension: user_department {
    type: string
    sql: {{_user_attributes['department']}} ;;
  }

  dimension: links {
    type: string
    sql: concat(coalesce(${raw_url_admin}, ''), coalesce(${raw_url_t3},''), coalesce(${raw_url_concur},''), coalesce(${raw_url_sage},'')) ;;
    html: {% if raw_url_admin._value != null and raw_url_admin._value != '' %}
            <a href="{{ raw_url_admin._value }}" target="_blank">
            <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
          {% endif %}
          {% if raw_url_t3._value != null and raw_url_t3._value != '' %}
            <a href="{{ raw_url_t3._value }}" target="_blank">
            <img src="https://app.estrack.com/favicons/fleet.png" width="16" height="16"> T3</a>
          {% endif %}
          {% if raw_url_sage._value != null and raw_url_sage._value != '' and (user_department._value == 'developer' or user_department._value == 'admin') %}
            <a href="{{ raw_url_sage._value }}" target="_blank">
            <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> Sage</a>
          {% endif %}
          {% if raw_url_gitlab._value != null and raw_url_gitlab._value != '' and (user_department._value == 'developer' or user_department._value == 'admin') %}
            <a href="{{ raw_url_gitlab._value }}" target="_blank">
            <img src="https://www.gitlab.com/favicon.ico" width="16" height="16"> Gitlab</a>
          {% endif %}
          {% if raw_url_concur._value != null and raw_url_concur._value != '' %}
            <a href="{{ raw_url_concur._value }}" target="_blank">
            <img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Concur</a>
          {% endif %}
          ;;
  }
# "@{db_oec_detail}?Market+Name={{ _filters['market_name'] | url_encode }}&Region+Name={{ _filters['region_name'] | url_encode }}&District+Number={{ _filters['district'] | url_encode }}&Period={{ _filters['filter_month'] | url_encode }}"
  # dimension: help_link {
  #   type: string
  #   sql: 'Help Link' ;;
  #       html: <a href="https://equipmentshare-dev.retool-hosted.com/form/6026170f-7bc4-46a0-85e4-b8b58911fb6c#user_region={{ _user_attributes['region'] | url_encode}}&user={{ _user_attributes['name'] | url_encode}}
  #                       &user_email={{ _user_attributes['email'] | url_encode}}&user_district={{ _user_attributes['district'] | url_encode}}&user_market_id={{ _user_attributes['market_id'] | url_encode}}
  #                       &account_number={{account_number._value | url_encode}}&account_name={{account_name._value | url_encode}}&pk_id={{pk_id._value}}&looker_url=@{db_live_branch_earnings_detail}?Region%20Name={{ _filters['region_name'] | url_encode }}&Period={{ _filters['filter_month'] | url_encode }}&Account%20Number={{ account_number | url_encode }}&Account%20Category={{ account_category | url_encode }}&Market%20Name={{ _filters['market_name'] | url_encode }}&Market+Greater+Than+12+Months+%28Yes+%2F+No%29={{ _filters['market_greater_than_12_months'] | url_encode }}&District={{ _filters['district'] | url_encode }}" target="_blank">
  #           <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Help Request</a>
  #         ;;
  #         }

    dimension: help_link {
      type: string
      sql: 'Help Link' ;;
      html:
            {% assign region_name_filter = _filters['region_name'] %}
            {% assign period_filter = _filters['filter_month'] | url_encode %}
            {% assign account_number_filter = account_number._value | url_encode %}
            {% assign account_category_filter = _filters['account_category'] | url_encode %}
            {% assign market_name_filter = _filters['market_name'] | url_encode %}
            {% assign market_greater_than_12_months_filter = _filters['market_greater_than_12_months'] | url_encode %}
            {% assign district_filter = _filters['district'] | url_encode %}

            {% assign looker_url = '@{db_live_branch_earnings_detail}' %}

        {% if region_name_filter %}
        {% assign looker_url = looker_url | append: '?Region%20Name=' | append: region_name_filter %}
        {% endif %}
        {% if period_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&Period=' | append: period_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?Period=' | append: period_filter %}
        {% endif %}
        {% endif %}
        {% if account_number_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&Account%20Number=' | append: account_number_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?Account%20Number=' | append: account_number_filter %}
        {% endif %}
        {% endif %}
        {% if account_category_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&Account%20Category=' | append: account_category_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?Account%20Category=' | append: account_category_filter %}
        {% endif %}
        {% endif %}
        {% if market_name_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&Market%20Name=' | append: market_name_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?Market%20Name=' | append: market_name_filter %}
        {% endif %}
        {% endif %}
        {% if market_greater_than_12_months_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&Market+Greater+Than+12+Months+%28Yes+%2F+No%29=' | append: market_greater_than_12_months_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?Market+Greater+Than+12+Months+%28Yes+%2F+No%29=' | append: market_greater_than_12_months_filter %}
        {% endif %}
        {% endif %}
        {% if district_filter %}
        {% if looker_url contains '?' %}
        {% assign looker_url = looker_url | append: '&District=' | append: district_filter %}
        {% else %}
        {% assign looker_url = looker_url | append: '?District=' | append: district_filter %}
        {% endif %}
        {% endif %}

        {% assign encoded_looker_url = looker_url | url_encode %}

        <a href="https://equipmentshare-dev.retool-hosted.com/form/6026170f-7bc4-46a0-85e4-b8b58911fb6c#user_region={{ _user_attributes['region'] | url_encode}}&user={{ _user_attributes['name'] | url_encode}}
        &user_email={{ _user_attributes['email'] | url_encode}}&user_district={{ _user_attributes['district'] | url_encode}}&user_market_id={{ _user_attributes['market_id'] | url_encode}}
        &account_number={{account_number._value | url_encode}}&account_name={{account_name._value | url_encode}}&pk_id={{pk_id._value}}&looker_url={{ encoded_looker_url }}" target="_blank">
        <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Help Request</a>
        ;;
    }

    # html: <a href="https://forms.monday.com/forms/465f93609bac5d4cbad2772f9732633d?r=use1&short_text__1={{ _user_attributes['email'] }}" target="_blank">
    #         <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Help Request</a>
    #       ;;




  # dimension: link_agg {
  #   label: "Links"
  #   sql: coalesce(${TABLE}."URL_SAGE",${TABLE}."URL_ADMIN",${TABLE}."URL_T3",${TABLE}."URL_CONCUR", case when ${TABLE}."ACCOUNT_NUMBER" = 'IBAB' or ${TABLE}."ACCOUNT_NUMBER" = 'HFAH' or ${TABLE}."ACCOUNT_NUMBER" = 'HFAI' or ${TABLE}."DESCRIPTION" like '%Asset ID: %' or ${TABLE}."DESCRIPTION" like '%Central CC' or ${TABLE}."DESCRIPTION" like '%AMEX%' or ${TABLE}."DESCRIPTION" ilike '%AP Accrual%'
  #         or ${TABLE}."DESCRIPTION" ilike '%INITIAL LIVE ACCRUAL ENTRY%' or ${TABLE}."DESCRIPTION" ilike '%ADJUSTMENT FOR CONVERTED NON RECEIPTS%'
  #         or ${TABLE}."DESCRIPTION" ilike '%PAYROLL WAGES%' then 'a' end) ;;
  #   html:
  #   {% if account_number._value == 'IBAB' %}
  #   <a href = "@{db_oec_detail}?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['mkt_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if description._value contains 'Central CC' or description._value contains 'AMEX' or description._value contains 'Central Bank allocation' or description._value contains 'Fuel CC' or description._value contains 'Citi CC' or description._value contains 'Citi Bank' %}
  #   <a href="@{lk_be_credit_card_transactions}?f[credit_card_transactions.gl_code]={{ _filters['account_number'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['mkt_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['region_district'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['region_name'] | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if be_transaction_listing.url_admin._value != null %}
  #   <a href = "{{ be_transaction_listing.url_admin._value }}" target="_blank">
  #   <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if be_transaction_listing.url_track._value != null %}
  #   <a href = "{{ be_transaction_listing.url_track._value }}" target="_blank">
  #   <img src="https://unav.equipmentshare.com/fleet.svg" width="16" height="16"> Track</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if be_transaction_listing.url_yooz._value != null %}
  #   <a href = "{{ be_transaction_listing.url_yooz._value }}" target="_blank">
  #   <img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Concur</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if account_number._value == 'HFAH' %}
  #   <a href = "@{db_dashboard_816}?Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if account_number._value == 'HFAI' %}
  #   <a href = "@{db_dashboard_825}?Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> Dashboard</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if description._value contains 'AP Accrual' %}
  #   <a href = "@{db_ap_accruals}?Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&GL+Code={{ _filters['account_number'] | url_encode }}&GL+Account={{ _filters['gl_acct'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> AP Accruals</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if description._value contains 'INITIAL LIVE ACCRUAL ENTRY' %}
  #   <a href = "@{db_ap_accruals}?Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&GL+Code={{ _filters['account_number'] | url_encode }}&GL+Account={{ _filters['gl_acct'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> AP Accruals</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if description._value contains 'ADJUSTMENT FOR CONVERTED NON RECEIPTS' %}
  #   <a href = "@{db_ap_accruals}?Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&GL+Code={{ _filters['account_number'] | url_encode }}&GL+Account={{ _filters['gl_acct'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> AP Accruals</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if description._value contains 'Payroll Wages' %}
  #   <a href = "@{db_payroll_detail}?Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&GL+Code={{ _filters['account_number'] | url_encode }}&Period={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">
  #   <img src="/images/favicon.ico" width="16" height="16"> Payroll</a>
  #   &nbsp;
  #   {% endif %}
  #   {% if be_transaction_listing.url_sage._value != null and _user_attributes['department'] contains 'developer' %}
  #   <a href = "{{ be_transaction_listing.url_sage._value }}" target="_blank">
  #   <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> Sage</a>
  #   &nbsp;
  #   {% endif %}
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_persist_for: "5 minutes"
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
    suggest_persist_for: "5 minutes"
  }
  measure: original_equipment_cost {
    type: sum
    sql:  ${TABLE}."ORIGINAL_EQUIPMENT_COST" ;;
    value_format_name: usd_0
  }
  measure: rental_revenue_to_oec_ratio{
    type: number
    sql: case when ${original_equipment_cost} != 0
            then ${total_rental_revenue} / ${original_equipment_cost}
            else 0 end;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    suggest_persist_for: "5 minutes"
  }
  measure: payroll_to_rental_revenue_ratio{
    type: number
    sql: case when ${total_rental_revenue} != 0
            then abs(${total_payroll_expense}) / ${total_rental_revenue}
            else 0 end;;
  }
  dimension: revenue_expense {
    type: string
    sql: ${TABLE}."REVENUE_EXPENSE" ;;
  }
  dimension: segment {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: source_model {
    type: string
    sql: ${TABLE}."SOURCE_MODEL" ;;
  }
  measure: previous_month_total_amount {
    type: sum
    sql:  ${TABLE}."PREVIOUS_MONTH_AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: static_same_month_total_amount {
    type: sum
    sql:  ${TABLE}."STATIC_SAME_MONTH_AMOUNT" ;;
    value_format_name: usd_0
    drill_fields: [region_name, market_name]
  }
  measure: total_amount {
    type: sum
    sql:  ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: total_rental_revenue {
    type: sum
    sql: CASE WHEN ${TABLE}."ACCOUNT_CATEGORY_ID" = 1 THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  measure: total_inventory_bulk_part_expense {
    type: sum
    sql: CASE WHEN ${TABLE}."ACCOUNT_NUMBER" in ('6330', 'GDDA') THEN ${TABLE}."AMOUNT" ELSE 0 END ;;
  }
  dimension: additional_data {
    type: string
    sql: ${TABLE}."ADDITIONAL_DATA" ;;
  }

  dimension: dealership_invoice_no {
    type: string
    sql: case
          when ${TABLE}."ACCOUNT_NUMBER" in('FBAA','FBBA','GBAA','GBBA','6101') then regexp_substr(${TABLE}."DESCRIPTION", 'Invoice #: ([0-9]*)',1,1,'e') || '-000'
          else ''
         end
         ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION";;
    html:
      {% if (account_number._value contains 'FBAA'
          or account_number._value contains 'FBBA'
          or account_number._value contains 'GBAA'
          or account_number._value contains 'GBBA'
          or account_number._value contains '6101')
          and description._value contains 'Invoice #'%}
        <a style="color:blue; text-decoration:underline" href="@{db_dealership_sales_invoice_detail}?Market+Name={{ market_name._filterable_value | url_encode }}&amp;Invoice+No={{ dealership_invoice_no._filterable_value | url_encode }}&amp;Region={{ region_name._filterable_value | url_encode }}&amp;District={{ district._filterable_value | url_encode }}&amp;Period={{ filter_month._filterable_value | url_encode }}&toggle=det" target="_blank">{{value}}</a>
      {% endif %};;
  }
  dimension: transaction_number_format {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER_FORMAT" ;;
  }
  dimension: transaction_number {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER" ;;
  }
}
