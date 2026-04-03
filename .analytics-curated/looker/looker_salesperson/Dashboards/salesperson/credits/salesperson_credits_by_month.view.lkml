
view: salesperson_credits_by_month {
  derived_table: {
    sql:
    with credit_cte AS (
    SELECT
          dte as date,
          mrx.MARKET_NAME,
          mrx.REGION_NAME,
          cd.full_name,
          cd.invoice_id,
          cd.invoice_no,
          cd.line_item_type,
          cd.company_id,
          cd.company_name,
          cd.class,
          cd.commission_month,
          cd.employee_id,
          cd.user_id,
          IFF(date_trunc('month',CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)=cd.commission_month::date,TRUE,FALSE) as current_month_flag,
          IFF(date_trunc('month',dateadd('months',-1,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE))=cd.commission_month::date,TRUE,FALSE) as previous_month_flag,
          sum(LINE_ITEM_AMOUNT) as credit_amount
      from
          analytics.commission.commission_details cd
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on cd.BRANCH_ID = mrx.MARKET_ID
      where
          transaction_type = 'credit'
          AND dte BETWEEN date_trunc(month,dateadd(month,-2,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AND CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE
          and salesperson_type = 1
      group by
          dte,
          mrx.MARKET_NAME,
          mrx.REGION_NAME,
          cd.full_name,
          cd.invoice_id,
          cd.invoice_no,
          cd.line_item_type,
          cd.company_id,
          cd.company_name,
          cd.class,
          cd.commission_month,
          cd.employee_id,
          cd.user_id )

    , tam_manager_manager_info AS (
    SELECT
      t1.employee_id AS id_1
    , t1.work_email AS tam_email
    , CASE WHEN position(' ',COALESCE(t1.nickname,t1.first_name)) = 0 THEN initcap(concat(COALESCE(t1.nickname,t1.first_name), ' ', t1.last_name))
                ELSE initcap(concat(COALESCE(t1.nickname,concat(t1.first_name, ' ',t1.last_name)))) END AS tam_name
    , t1.direct_manager_employee_id AS m_id_1
    , t2.employee_id AS id_2
    , t2.work_email AS manager_email_present
    , concat(t2.first_name, ' ', t2.last_name) AS manager_name_present
    , t2.direct_manager_employee_id AS m_id_2
    , t3.employee_id AS id_3
    , t3.work_email AS managers_manager_email_present
    , concat(t3.first_name, ' ', t3.last_name) AS managxxers_manager_name_present
    , t3.direct_manager_employee_id AS m_id_3
    FROM analytics.payroll.company_directory t1
    LEFT JOIN analytics.payroll.company_directory t2 ON t1.direct_manager_employee_id = t2.employee_id
    LEFT JOIN analytics.payroll.company_directory t3 ON t2.direct_manager_employee_id = t3.employee_id

)

, final_tam_manager_info AS (

    SELECT
      tmmi.tam_name
    , tmmi.tam_email
    , u1.user_id AS tam_user_id
    , u2.user_id AS manager_user_id_present
    ,    CASE WHEN position(' ',coalesce(cd2.nickname,cd2.first_name)) = 0 then initcap(concat(coalesce(cd2.nickname,cd2.first_name), ' ', cd2.last_name))
                ELSE initcap(concat(coalesce(cd2.nickname,concat(cd2.first_name, ' ',cd2.last_name)))) END as manager_name_present
    , tmmi.manager_email_present
    , u3.user_id AS managers_manager_user_id_present
    ,    CASE WHEN position(' ',coalesce(cd3.nickname,cd3.first_name)) = 0 then initcap(concat(coalesce(cd3.nickname,cd2.first_name), ' ', cd3.last_name))
                ELSE initcap(concat(coalesce(cd3.nickname,concat(cd3.first_name, ' ',cd3.last_name)))) END as managers_manager_name_present
    , tmmi.managers_manager_email_present

    FROM tam_manager_manager_info tmmi
    LEFT JOIN es_warehouse.public.users u1 ON lower(u1.email_address) = lower(tmmi.tam_email)
    LEFT JOIN es_warehouse.public.users u2 ON lower(u2.email_address) = lower(tmmi.manager_email_present)
    LEFT JOIN analytics.payroll.company_directory cd2 ON lower(u2.email_address) = lower(cd2.work_email)
    LEFT JOIN es_warehouse.public.users u3 ON lower(u3.email_address) = lower(tmmi.managers_manager_email_present)
    LEFT JOIN analytics.payroll.company_directory cd3 ON lower(u3.email_address) = lower(cd3.work_email)

)

  SELECT cc.*,
  CASE WHEN dateadd(month, '6', start_date.sp_start_date) > current_date() THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current
, ftmi.tam_email
, ftmi.manager_user_id_present
, ftmi.manager_name_present
, ftmi.manager_email_present
, ftmi.managers_manager_user_id_present
, ftmi.managers_manager_name_present,
  FROM credit_cte cc
  LEFT JOIN (SELECT user_id, MIN(record_effective_date) AS sp_start_date FROM analytics.bi_ops.salesperson_info GROUP BY user_id) start_date ON start_date.user_id = cc.user_id
  LEFT JOIN final_tam_manager_info ftmi ON ftmi.tam_user_id = cc.user_id



;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  dimension: direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MANAGER_NAME_PRESENT" ;;
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

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: commission_month {
    type: time
    sql: ${TABLE}."COMMISSION_MONTH" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: current_month_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH_FLAG" ;;
  }

  dimension: previous_month_flag {
    type: yesno
    sql: ${TABLE}."PREVIOUS_MONTH_FLAG" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  measure: total_credit_amount {
    group_label: "Total Credit Amount"
    label: "Credit Amount"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
  }

  measure: current_month_total_credits {
    label: "Current Month Credits Amount"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
    filters: [current_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: previous_month_total_credits {
    label: "Prior Month Credits Amount"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
    filters: [previous_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: current_month_total_credits_kpi {
    group_label: "Total Credits Single KPI"
    label: "Current Month Credits Amount"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
    filters: [current_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
  }

  measure: previous_month_total_credits_kpi {
    group_label: "Total Credits Single KPI"
    label: "Prior Month Credits Amount"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
    filters: [previous_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "Rep"
    type: string
    sql: ${full_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{salesperson_filter_values._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{ current_rep_home_market.market_name._rendered_value }} </font>
    ;;
  }

  dimension: salesperson_filter_values {
    group_label: "Sales Person Info"
    label: "Rep - Home Market"
    type: string
    sql: concat(${full_name},' - ',${current_rep_home_market.market_name});;
  }

  dimension: credit_date_formatted {
    group_label: "HTML Formatted Date"
    label: "Credit Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: admin_link_to_invoice {
    label: "Invoice Number"
    type: string
    html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">{{invoice_no._rendered_value}} ➔ </a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  measure: current_month_credit_count {
    type: count_distinct
    sql: ${invoice_id} ;;
    filters: [current_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
  }

  measure: prior_month_credit_count {
    type: count_distinct
    sql: ${invoice_id} ;;
    filters: [previous_month_flag: "YES"]
    drill_fields: [rep_credit_detail*]
  }

  dimension: company_name_formatted {
    group_label: "Company Name Formatted"
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{rendered_value}}&Company+ID="target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
    </td>;;
  }

  set: detail {
    fields: [
        date_time,
  market_name,
  region_name,
  full_name,
  invoice_id,
  commission_month_time,
  employee_id,
  user_id,
  current_month_flag,
  previous_month_flag,
  credit_amount
    ]
  }

  set: rep_credit_detail {
    fields: [
      credit_date_formatted,
      market_name,
      salesperson,
      company_name_formatted,
      class,
      line_item_type,
      admin_link_to_invoice,
      total_credit_amount
    ]
  }
}
