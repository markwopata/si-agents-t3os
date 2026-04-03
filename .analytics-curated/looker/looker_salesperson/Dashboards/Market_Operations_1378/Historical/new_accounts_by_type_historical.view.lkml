
view: new_accounts_by_type_historical {
  derived_table: {

    sql:

    SELECT nat.*
    , namc.current_status
    , namc.employee_title_dated
    , namc.current_home_market_id
    , namc.current_home_market as current_home_mrkt
    , namc.current_home_district
    , namc.district
    , namc.region
    , namc.region_name
    , COALESCE(current_home_mrkt, IFF(namc.current_home_district IS NOT NULL, concat('District ', namc.current_home_district), NULL), namc.region_name) as current_home_location


    FROM analytics.bi_ops.new_account_by_type_log nat

    LEFT JOIN analytics.bi_ops.new_account_monthly_counts namc ON namc.sp_user_id = nat.sp_user_id AND namc.date_month = DATE_TRUNC('month', nat.na_date)

    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql:  TRIM(${TABLE}."COMPANY_NAME") ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value | url_encode}}&Company+ID="target="_blank">{{rendered_value}} ➔</a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
    </td>;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  dimension: direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: REPLACE(${TABLE}."DIRECT_MANAGER_NAME",' Ii',' II')  -- this was added for Stephen Mitchell Chicola II
      ;;
  }

  dimension: direct_manager_user_id {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID" ;;
  }

  dimension: direct_manager_email {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL" ;;
  }

  dimension: managers_manager_user_id {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."MANAGERS_MANAGER_USER_ID" ;;
  }
  dimension: managers_manager_name {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."MANAGERS_MANAGER_NAME" ;;
  }
  dimension: managers_manager_email{
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."MANAGERS_MANAGER_EMAIL" ;;
  }

  dimension: current_status {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension: rep_terminated {
    group_label: "Sales Person Info"
    type: yesno
    sql: ${current_status} = 'Terminated';;
  }

  dimension: employee_title_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: current_home_market {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_HOME_MRKT" ;;
  }

  dimension: current_home_location {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_HOME_LOCATION" ;;
  }

  dimension: current_home_market_check {
    hidden:  no
    type: string
    sql: CASE WHEN ${current_home_market} IS NULL OR
      ${sp_user_id} NOT IN (SELECT user_id FROM analytics.bi_ops.salesperson_info WHERE record_ineffective_date IS NULL) THEN 'a' ELSE ${current_home_market} END
      --COALESCE(${current_home_market}, 'a')
      ;;



  }

  dimension: current_home_market_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET_ID" ;;
  }

  dimension: district {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }


  dimension_group: na_date {
    label: "New Account"
    type: time
    sql: ${TABLE}."NA_DATE" ;;
  }

  dimension: new_account_date {
    group_label: "Formatted Dates"
    type: date
    sql: ${na_date_date} ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  dimension: sp_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_NAME" ;;
    label: "Name"
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "Rep"
    type: string
    sql: ${sp_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{salesperson_filter_values._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{current_home_location._rendered_value }} </font>
    ;;
  }



  dimension: rep2 {
    group_label: "Sales Person Info"
    type: string
    sql: ${sp_name} ;;
    html:
    {% if  current_home_market_check._rendered_value == 'a' %}
    {{rendered_value}}
    {% else %}
    <font color="#0063f3">
    <a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{salesperson_filter_values._filterable_value | url_encode}}" target="_blank">
    {{rendered_value}} ➔
    </a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{current_home_location._rendered_value}}</font>
    </font>
    {% endif %}
    ;;
  }


  dimension: salesperson_filter_values {
    group_label: "Sales Person Info"
    label: "Rep - Home Market"
    type: string
    sql:concat(${sp_name},' - ',${current_home_location});;
  }

  dimension: sp_email_address {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}."APP_TYPE" ;;
    label: "Application Type"
  }

  dimension: source {
    type:  string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension_group: first_order {
    type: time
    sql: ${TABLE}."FIRST_ORDER" ;;
    label: "First Order"
  }

  dimension: first_order_date_f {
    group_label: "Formatted Dates"
    label: "First Order Date"
    type: date
    sql: ${first_order_date} ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  dimension_group: first_rental {
    type: time
    sql: ${TABLE}."FIRST_RENTAL" ;;
    label: "First Rental"
  }

  dimension: first_rental_date_f {
    group_label: "Formatted Dates"
    label: "First Rental Date"
    type: date
    sql: ${first_rental_date} ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  dimension: old_age_flag {
    type: yesno
    sql: ${TABLE}."OLD_AGE_FLAG" ;;
  }

  dimension: old_age_no_order_flag {
    type: yesno
    sql: ${TABLE}."OLD_AGE_NO_ORDER_FLAG" ;;
  }

  dimension: converted {
    type: number
    sql: ${TABLE}."CONVERTED" ;;
    label: "Conversion Status"
    html:
{% if converted._value == 2 %}
  <font color="#000000"><b>Pending</b></font>
{% elsif converted._value == 0 %}
  <font color="#DA344D"><b>Unconverted</b></font>
{% elsif converted._value == 1 %}
  <font color="#00ad73"><b>Converted ✓</b></font>
{% endif %};;
  }

  measure: converted_count{
    type: sum
    label: "Total Converted"
    sql: case when ${converted} = 1 THEN 1 ELSE 0 END;;
    description: "Count of new accounts created within past 90 days with a rental/order placed"
    drill_fields: [conversion_rate_drill*]
  }

  measure: unconverted_count{
    type: sum
    label: "Total Unconverted"
    sql: case when ${converted} = 0 THEN 1 ELSE 0 END;;
    description: "Count of new accounts created at least 45 days ago without a rental/order placed"
    drill_fields: [conversion_rate_drill*]
  }

  measure: pending_count{
    type: sum
    label: "Total Pending"
    description: "Count of new accounts created within the past 45 days without a rental/order placed"
    sql: case when ${converted} = 2 THEN 1 ELSE 0 END;;
    drill_fields: [conversion_rate_drill*]
  }

  measure: credit_count {
    type: count
    label: "Total Credit"
    filters: [app_type: "Credit"]
    drill_fields: [conversion_rate_drill*]
  }

  measure: COD_count {
    type: count
    label: "Total COD"
    filters: [app_type: "COD"]
    drill_fields: [conversion_rate_drill*]
  }

  measure: total_accounts {
    type: count
    drill_fields: [conversion_rate_drill*]
  }

  measure: converted_sum {
    type: sum
    description: "Created for conversion rate that isnt being used anymore"
    sql:  case when ${converted} <> 2 THEN ${converted} ELSE NULL END;;
  }



  measure: company_id_count_within_conversion {
    type: count_distinct
    description: "Created for conversion rate that isnt being used anymore"
    sql: CASE WHEN ${converted} <> 2 THEN ${company_id} ELSE NULL END;;
  }

  measure: conversion_rate {
    type: number
    sql:DIV0NULL(${converted_sum},${company_id_count_within_conversion})  ;;
    value_format_name: percent_1
    drill_fields: [conversion_rate_drill*]
    description: "Created for conversion rate that isnt being used anymore"
  }

  dimension:  na_terminated_employee_flag {
    type: yesno
    sql: ${TABLE}."NA_TERMINATED_EMPLOYEE_FLAG" ;;
  }

  measure: company_id_count {
    type: count_distinct
    label: "Total New Accounts"
    sql: ${company_id};;
    drill_fields: [total_new_accounts_drill*]
  }

  measure: new_company_id_count {
    type: sum
    sql: case when ${old_age_flag} = false then 1 else 0 end ;;
  }

  dimension: mtd {
    type: string
    sql: ${TABLE}."MTD" ;;
  }
  dimension: prev_mtd {
    type: string
    sql: ${TABLE}."PREV_MTD" ;;
  }
  dimension: prev_month {
    type: string
    sql: ${TABLE}."PREV_MONTH" ;;
  }

  measure: mtd_total_new_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [mtd: "1"]
    label: "Total MTD New Accts"
  }

  measure: mtd_total_COD_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [mtd: "1", app_type: "COD"]
    label: "MTD COD Accts"
  }

  measure: mtd_total_credit_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [mtd: "1", app_type: "Credit"]
    label: "MTD Credit Accts"
  }
  measure: lmtd_total_new_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [prev_mtd: "1"]
    label: "LMTD Total New Accts"
  }
  measure: lmtd_total_credit_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [prev_mtd: "1", app_type: "Credit"]
    label: "LMTD Credit Accts"
  }
  measure: lmtd_total_cod_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [prev_mtd: "1", app_type: "COD"]
    label: "LMTD COD Accts"
  }

  measure: prev_month_total_new_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [prev_month: "1"]
    drill_fields: [total_new_accounts_drill*]
    label: "Prior Month Total New Accts"
  }

  measure: prev_month_COD_new_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [prev_month: "1", app_type: "COD"]
    label: "Prior Month COD New Accts"
  }

  measure: prev_month_credit_new_accounts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [total_new_accounts_drill*]
    filters: [prev_month: "1", app_type: "Credit"]
    label: "Prior Month Credit New Accts"
  }


  measure: diff_mtd_lmtd_total_new_accounts {
    type: number
    sql: ${mtd_total_new_accounts}-${lmtd_total_new_accounts} ;;
    html:
{% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font>
{% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
{% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font>
{% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
{% endif %}
    ;;
  }

  dimension: days_until_incomplete {
    type: number
    sql: TIMESTAMPDIFF(day, CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP()), DATEADD(day, 45, ${na_date_time}));;
    html:
      {% if value < 15 %}
      <font color="#DA344D"><b>{{value}}</b></font>
      {% elsif value < 30 %}
      <font color="#000000"><b>{{value}}</b></font>
      {% else %}
      <font color="#00ad73"><b>{{value}}</b></font>
      {% endif %};;
  }

  dimension: days_since_incomplete {
    type: number
    sql: TIMESTAMPDIFF(day, DATEADD(day, 45, ${na_date_time}), CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP()));;
    html:
      {% if value > 15 %}
      <font color="#DA344D"><b>{{value}}</b></font>
      {% else %}
      <font color="#000000"><b>{{value}}</b></font>
      {% endif %};;
  }

  dimension: converted_status_tracker {
    type: string
    sql: ${days_until_incomplete} ;;
    html:
      {% if converted._value == 1%}
      <font color="#00ad73"><b>Converted</b></font>
      {% elsif value < 1%}
      <font color="#DA344D"><b>{{days_since_incomplete._value}} days at incomplete</b></font>
      {% elsif value < 15 %}
      <font color="#DA344D"><b>{{value}} days until incomplete</b></font>
      {% else %}
      <font color="#000000"><b>{{value}} days until incomplete</b></font>
      {% endif %}
      ;;
  }

  set: total_new_accounts_drill {
    fields: [na_date_date, sp_name, company_name, app_type, source, converted]
  }

  set: conversion_rate_drill {
    fields: [na_date_date, sp_name, company_name, app_type, source, first_rental_date, first_order_date, converted]
  }


  set: detail {
    fields: [
      company_id,
      sp_user_id,
      sp_name,
      app_type,
      old_age_flag,
      old_age_no_order_flag
    ]
  }
}
