
view: new_accounts_revenue_oec_rankings {
  sql_table_name: analytics.bi_ops.new_account_revenue_rankings ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_month {
    type: time
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: month_formatted {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month, ${date_month_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y" }};;
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat( TO_CHAR(${TABLE}."SP_USER_ID"), TO_CHAR(${TABLE}."TOTAL_REV"), TO_CHAR(${TABLE}."DAILY_OEC_ON_RENT"))  ;;
  }

  dimension: month_year {
    type: string
    sql: TO_CHAR(${TABLE}."DATE_MONTH", 'MMMM YYYY') ;;
  }
  dimension: current_month {
    type:  string
    sql:  ${TABLE}."CURRENT_MONTH" ;;
  }
  dimension: prev_month {
    type: string
    sql:  ${TABLE}."PREV_MONTH" ;;
  }

  dimension: sp_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
    label: "User Id"
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

  dimension: salesperson_no_link {
    group_label: "Sales Person Info"
    label: "Rep - Market"
    type: string
    sql: ${sp_name} ;;
    html:
       <font color="#000000 ">
       {{rendered_value}}
       <br />
       <font style="color: #8C8C8C; text-align: right;">Home: {{ current_home_location._rendered_value }} </font>
       </font>;;
  }


  dimension: salesperson_filter_values {
    group_label: "Sales Person Info"
    label: "Rep - Home Market"
    type: string
    sql:concat(${sp_name},' - ',${current_home_location});;
  }

  dimension: current_status {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }


  dimension: current_home_location {
    type: string
    sql:${TABLE}."CURRENT_HOME_MARKET" ;;
  }

  dimension: current_home_market_id {
    type: string
    sql:${TABLE}."CURRENT_HOME_MARKET_ID" ;;
  }

  dimension: employee_title {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: sp_email {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."TAM_EMAIL" ;;
  }

  dimension: direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MANAGER_NAME_PRESENT" ;;
  }

  dimension: current_manager_dsm_flag {
    group_label: "Sales Person Info"
    type: yesno
    sql: ${TABLE}."CURRENT_MANAGER_DSM_FLAG" ;;
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

  dimension: market_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: curr_market_id {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${market_id} ELSE NULL END ;;
  }

  dimension: market_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: curr_market_name {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${market_name} ELSE NULL END ;;
  }

  dimension: district {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: curr_district {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${district} ELSE NULL END ;;
  }

  dimension: region {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: curr_region {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${region} ELSE NULL END ;;
  }

  dimension: region_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: curr_region_name {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${region_name} ELSE NULL END ;;
  }


  dimension: market_type {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: curr_market_type {
    group_label: "Sales Person Info"
    type: string
    sql: CASE WHEN ${current_month} = 1 THEN ${market_type} ELSE NULL END ;;
  }

  dimension: first_date_as_TAM {
    group_label: "Sales Person Info"
    type: date
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  ######## Commissions and Guarantees #############################################################################

  dimension: commission_type {
    group_label: "Guarantee Info"
    type: string
    sql: ${TABLE}."CURRENT_COMMISSION_TYPE" ;;
  }

  dimension: guarantee_amount {
    group_label: "Guarantee Info"
    type: number
    sql: ${TABLE}."CURRENT_GUARANTEE_AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: first_comm_paycheck_info {
    type: string
    sql: CASE WHEN ${first_commission_paycheck.paycheck_date_date} IS NULL AND ${payroll_commission_start_date_date} < '2020-01-01' THEN 'Before Jan 2020'
        ELSE ${first_commission_paycheck.paycheck_date_date} END;;
  }

  dimension: last_guar_paycheck_info {
    type: string
    sql: CASE WHEN ${last_guarantee_paycheck.paycheck_date_date} IS NULL AND ${payroll_guarantee_end_date_date} < '2020-01-01' THEN 'Before Jan 2020'
      ELSE ${last_guarantee_paycheck.paycheck_date_date} END;;
  }

  dimension: current_guarantee_status {
    group_label: "Guarantee Info"
    type: string
    sql: ${TABLE}."CURRENT_GUARANTEE_STATUS" ;;
    html:
    {% if value == 'Commission' %}
    <font color="#000000 "> {{rendered_value}}
     {% elsif value == 'On Guarantee' %}
     <font color="#000000"><strong>{{rendered_value}}</strong></font>
    {% endif %}
    <br />
    <font style="color: #8C8C8C; text-align: right;">First Commission Paycheck Date: {{ first_comm_paycheck_info._rendered_value }} </font>
  ;;
  }

  dimension: guarantee_status {
    group_label: "Guarantee Info"
    type: string
    sql: ${TABLE}."CURRENT_GUARANTEE_STATUS" ;;
    html:
    {% if value == 'Commission' %}
    <font color="#000000 "> {{rendered_value}}
    {% elsif value == 'On Guarantee' %}
    <font color="#000000"><strong>{{rendered_value}}</strong></font>
    {% endif %};;
  }



  dimension: current_months_of_guarantee {
    group_label: "Guarantee Info"
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OF_GUARANTEE" ;;
  }

  measure: current_months_of_guarantee_tot {
    group_label: "Guarantee Info"
    type: sum
    sql: ${current_months_of_guarantee} ;;
  }

  dimension_group: guarantee_start_date {

    type: time
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }

  dimension_group: guarantee_end_date {

    type: time
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }

  dimension_group: commission_start_date {

    type: time
    sql: ${TABLE}."COMMISSION_START_DATE" ;;
  }

  dimension_group: commission_end_date {

    type: time
    sql: ${TABLE}."COMMISSION_END_DATE" ;;
  }

  dimension_group: payroll_guarantee_end_date {
    type: time
    sql: ${TABLE}."PAYROLL_GUARANTEE_END_DATE" ;;
  }

  dimension_group: payroll_commission_start_date {
    type: time
    sql: ${TABLE}."PAYROLL_COMMISSION_START_DATE" ;;
  }

  dimension: lifetime_guarantee_months {
    group_label: "Guarantee Info"
    type: number
    sql: ${TABLE}."LIFETIME_GUARANTEE_MONTHS" ;;
  }

  dimension: sp_first_name {
    hidden: yes
    sql: LEFT(${sp_name}, POSITION(' ' IN ${sp_name}) - 1);;
  }
  dimension: sp_last_name {
    hidden: yes
    sql: TRIM(SUBSTRING(${sp_name}, POSITION(' ' IN ${sp_name}) + 1)) ;;
  }
  dimension: make_change_request {
    type: number
    sql:  ${sp_user_id};;
    value_format_name: id
    html: <b><p style="color:#B32F37;"><a href="https://docs.google.com/forms/d/e/1FAIpQLSeRSBt1ErVeBVJlaYp3QMgEiCRI4rhnY9hWW5WmyIds0WVFyQ/viewform?usp=pp_url&entry.1214858295={{value}}&entry.749541817={{sp_first_name._value}}&entry.852149733={{sp_last_name._value}}&entry.691111867={{payroll_guarantee_end_date_date._value}}&entry.799768097={{guarantee_amount._value}}">Submit Change Request</a></p></b>;;
  }

  ######################################################################################################################

  dimension: tot_na_monthly {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."TOT_NA_MONTHLY" ;;
  }

  dimension: TAM_tenure_group {
    type: string
    sql:
    CASE
      -- Group TAMs who started within the last 6 months
      WHEN TIMESTAMPDIFF(MONTH, ${first_date_as_TAM}, CURRENT_DATE) <= 6 THEN '0-6 months'

      -- Group TAMs who started between 6 and 12 months ago
      WHEN TIMESTAMPDIFF(MONTH, ${first_date_as_TAM}, CURRENT_DATE) <= 12 THEN '6-12 months'

      -- Group TAMs who started more than 12 months ago
      ELSE '1+ year'
      END ;;
  }

  dimension: tenure_years {
    type: number
    sql: DATEDIFF('year', ${first_date_as_TAM}, CURRENT_DATE) ;;
  }

  dimension: tam_tenure_group_html {
    type: string
    sql: CAST(${first_date_as_TAM} AS STRING) ;;

    html:
      {% assign t = tenure_years._value %}
      {% assign hire = first_date_as_TAM._value | date: "%m/%d/%Y" %}

      {% if t < 1 %}
      <div style="line-height:1.2;">
      <div style="color:#d97706; font-weight:600;">0–1 year</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% elsif t < 2 %}
      <div style="line-height:1.2;">
      <div style="color:#2563eb; font-weight:600;">1–2 years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% elsif t < 3 %}
      <div style="line-height:1.2;">
      <div style="color:#16a34a; font-weight:600;">2–3 years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% else %}
      <div style="line-height:1.2;">
      <div style="color:#15803d; font-weight:600;">3+ years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% endif %}
      ;;
  }


  measure: tot_na_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_na_monthly} ;;
    label: "Total New Accts"
  }

  measure: curr_tot_na_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_na_monthly} ;;
    filters: [current_month: "1"]
    label: "Current Month Total New Accts"
  }



  measure: prev_tot_na_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_na_monthly} ;;
    filters: [prev_month: "1"]
  }


  measure: sp_curr_zero_count {
    type: count_distinct
    sql: ${sp_user_id};;
    filters: [current_month: "1", tot_na_monthly: "0", current_status: "Active"]
    drill_fields: [sp_curr_zero_count_drill*]
  }

  set: sp_curr_zero_count_drill {
    fields: [salesperson, prior_month_tot_na_sum, prior_month_tot_cod_sum, prior_month_tot_cred_sum,  curr_tot_na_sum]
  }


  dimension: lmtd_tot_cred {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."LMTD_TOT_CREDIT" ;;

  }

  measure: lmtd_tot_cred_sum {
    group_label: "New Account"
    type: sum
    sql: ${lmtd_tot_cred} ;;
    label: "LMTD New Credit Accts"
  }

  dimension: lmtd_tot_cod {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."LMTD_TOT_COD" ;;
  }

  measure: lmtd_tot_cod_sum {
    group_label: "New Account"
    type: sum
    sql: ${lmtd_tot_cod} ;;
    label: "LMTD New COD Accts"
  }

  dimension: lmtd_tot_na {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."LMTD_TOT_NA" ;;
  }

  measure: lmtd_tot_na_sum {
    group_label: "New Account"
    type: sum
    sql: ${lmtd_tot_na} ;;
    label: "LMTD Total New Accts"
  }

  measure: mtd_change_oec_on_rent_arrows {
    type: number
    sql: ${daily_oec_on_rent_today} - ${lmtd_oec_on_rent} ;;
    value_format_name: usd_0

    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{ rendered_value }}</strong> <!-- Up Arrow (Green) -->
    </font>
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- No Change (Gray) -->
    </font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{ rendered_value }}</strong> <!-- Down Arrow (Red) -->
    </font>
    {% else %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- Default (Gray) -->
    </font>
    {% endif %}
    ;;
  }


    measure: mtd_change_assets_on_rent_arrows {
    type: number
    sql: ${daily_assets_on_rent_today} - ${lmtd_assets_on_rent} ;;

    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{ rendered_value }}</strong> <!-- Up Arrow (Green) -->
    </font>
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- No Change (Gray) -->
    </font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{ rendered_value }}</strong> <!-- Down Arrow (Red) -->
    </font>
    {% else %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- Default (Gray) -->
    </font>
    {% endif %}
    ;;
  }

  measure: mtd_change_actively_renting_customers_arrows {
    type: number
    sql: ${daily_actively_renting_customers_today} - ${lmtd_actively_renting_customers} ;;

    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{ rendered_value }}</strong> <!-- Up Arrow (Green) -->
    </font>
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- No Change (Gray) -->
    </font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{ rendered_value }}</strong> <!-- Down Arrow (Red) -->
    </font>
    {% else %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong> <!-- Default (Gray) -->
    </font>
    {% endif %}
    ;;
  }


  measure: diff_tot_na_sum {
    group_label: "New Account"
    type: number
    sql: ${curr_tot_na_sum} - ${prev_tot_na_sum} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;

  }

  measure: diff_tot_na_sum_mtd_vs_lmtd {
    group_label: "New Account"
    type: number
    sql: ${curr_tot_na_sum} - ${lmtd_tot_na_sum} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;

  }

  measure: months_as_TAM {
    type: max
    sql: ROUND(months_between(current_date, CAST(${first_date_as_TAM} AS DATE)), 0);;
  }

  dimension: prior_month_tot_cod {
    group_label: "New Account"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_TOT_COD" ;;
  }

  measure: prior_month_tot_cod_max {
    group_label: "New Account"
    type: max
    sql:  ${prior_month_tot_cod} ;;
  }

  measure: prior_month_tot_cod_sum {
    group_label: "New Account"
    label: "Prior Month Total COD Accts"
    type: sum
    sql:  ${prior_month_tot_cod} ;;
  }

  dimension: prior_month_tot_cred {
    group_label: "New Account"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_TOT_CREDIT" ;;
  }

  measure: prior_month_tot_cred_max {
    group_label: "New Account"
    type: max
    sql:  ${prior_month_tot_cred} ;;
  }

  measure: prior_month_tot_cred_sum {
    group_label: "New Account"
    type: sum
    label: "Prior Month Total Credit Accts"
    sql:  ${prior_month_tot_cred} ;;
  }

  dimension: prior_month_tot_na {
    group_label: "New Account"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_TOT_NA" ;;}

  measure: prior_month_tot_na_max {
    group_label: "New Account"
    label: "Prior Month New Accts"
    type: max
    sql:  ${prior_month_tot_na} ;;
  }

  measure: prior_month_tot_na_sum {
    group_label: "New Account"
    label: "Prior Month Total New Accts"
    type: sum
    sql:  ${prior_month_tot_na} ;;
  }

  measure: prior_NA_under_count {
    group_label: "New Account"
    type: count_distinct
    sql:  ${sp_user_id};;
    filters: [prior_month_tot_na: "<5", current_status: "Active"]
    drill_fields: [prior_NA_under_drill*]
  }

  set: prior_NA_under_drill {
    fields: [salesperson, curr_tot_na_sum, prior_month_tot_na_max]
  }

  measure: sp_count_distinct {
    type: count_distinct
    sql: ${sp_user_id} ;;
  }

  measure: current_month_sp_count_distinct {
    type: count_distinct
    sql: ${sp_user_id} ;;
    filters: [current_month: "1"]
    drill_fields: [current_month_sp_count_drill*]
  }

  set: current_month_sp_count_drill {
    fields: [salesperson, current_guarantee_status, curr_total_rev_sum, daily_oec_on_rent_sum,  curr_tot_na_sum]
  }


  dimension: tot_cod_monthly {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."TOT_COD_MONTHLY" ;;
  }

  measure: tot_cod_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cod_monthly} ;;
  }

  measure: curr_tot_cod_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cod_monthly} ;;
    filters: [current_month: "1"]
  }

  measure: prev_tot_cod_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cod_monthly} ;;
    filters: [prev_month: "1"]
  }

  dimension: tot_cred_monthly {
    group_label: "New Account Monthly Totals"
    type: number
    sql: ${TABLE}."TOT_CRED_MONTHLY" ;;
  }

  measure: tot_cred_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cred_monthly} ;;
  }

  measure: curr_tot_cred_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cred_monthly} ;;
    filters: [current_month: "1"]
  }

  measure: prev_tot_cred_sum {
    group_label: "New Account"
    type: sum
    sql: ${tot_cred_monthly} ;;
    filters: [prev_month: "1"]
  }

  measure: curr_monthly_rank_na_es {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_ES" ELSE NULL END;;

  }

  measure: curr_monthly_rank_cred_es {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_ES" ELSE NULL END;;
  }

  measure: curr_monthly_rank_na_region {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_REGION" ELSE NULL END;;
  }

  measure: curr_monthly_rank_cred_region {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_REGION" ELSE NULL END;;
  }

  measure: curr_monthly_rank_na_district {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_DISTRICT" ELSE NULL END;;
  }

  measure: curr_monthly_rank_cred_district {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_DISTRICT" ELSE NULL END;;
  }

  measure: curr_monthly_rank_na_market {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_MARKET" ELSE NULL END ;;
  }

  measure:curr_monthly_rank_cred_market {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_MARKET" ELSE NULL END;;
  }

  measure: curr_monthly_rank_na_markettype {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_MARKETTYPE" ELSE NULL END;;
  }

  measure: curr_monthly_rank_cred_markettype {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_MARKETTYPE" ELSE NULL END;;
  }

  measure: prev_monthly_rank_na_es {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_ES" ELSE NULL END;;

  }

  measure: prev_monthly_rank_cred_es {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_ES" ELSE NULL END;;
  }

  measure: prev_monthly_rank_na_region {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_REGION" ELSE NULL END;;
  }

  measure: prev_monthly_rank_cred_region {
    group_label: "New Account Monthly Rank"
    type:max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_REGION" ELSE NULL END;;
  }

  measure: prev_monthly_rank_na_district {
    group_label: "New Account Monthly Rank"
    type:max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_DISTRICT" ELSE NULL END;;
  }

  measure: prev_monthly_rank_cred_district {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_DISTRICT" ELSE NULL END;;
  }

  measure: prev_monthly_rank_na_market {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_MARKET" ELSE NULL END ;;
  }

  measure: prev_monthly_rank_cred_market {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_MARKET" ELSE NULL END;;
  }

  measure: prev_monthly_rank_na_markettype {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_NA_MARKETTYPE" ELSE NULL END;;
  }

  measure: prev_monthly_rank_cred_markettype {
    group_label: "New Account Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_CRED_MARKETTYPE" ELSE NULL END;;
  }

  dimension: monthly_rank_na_es {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_ES";;

  }

  dimension: monthly_rank_cred_es {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_CRED_ES";;
  }

  dimension: monthly_rank_na_region {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_REGION";;
  }

  dimension: monthly_rank_cred_region {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_CRED_REGION";;
  }

  dimension: monthly_rank_na_district {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_DISTRICT" ;;
  }

  dimension: monthly_rank_cred_district {
    group_label: "New Account Monthly Rank"
    type: number
    sql:${TABLE}."MONTHLY_RANK_CRED_DISTRICT" ;;
  }

  dimension: monthly_rank_na_market {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_MARKET"  ;;
  }

  dimension: monthly_rank_cred_market {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_CRED_MARKET";;
  }

  dimension: monthly_rank_na_markettype {
    group_label: "New Account Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_NA_MARKETTYPE" ;;
  }

  dimension: monthly_rank_cred_markettype {
    group_label: "New Account Monthly Rank"
    type: number
    sql:  ${TABLE}."MONTHLY_RANK_CRED_MARKETTYPE" ;;
  }


  dimension: in_market_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."IN_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: in_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_rev} ;;
    value_format_name: usd_0
  }

  measure: curr_in_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_rev} ;;
    filters: [current_month: "1"]
    value_format_name: usd_0
  }


  dimension: out_market_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."OUT_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: out_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_rev} ;;
    value_format_name: usd_0
  }

  measure: curr_out_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_rev} ;;
    filters: [current_month: "1"]
    value_format_name: usd_0
  }

  dimension: total_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
    value_format_name: usd_0
  }

  measure: total_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
  }

  dimension: prior_month_total_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_TOTAL_REV" ;;
    value_format_name: usd_0
  }

  measure: prior_month_total_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${prior_month_total_rev} ;;
    value_format_name: usd_0
  }

  dimension: prior_month_in_market_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_IN_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: prior_month_in_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${prior_month_in_market_rev} ;;
    value_format_name: usd_0
  }

  dimension: prior_month_out_market_rev {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."PRIOR_MONTH_OUT_MARKET_REV" ;;
    value_format_name: usd_0
  }

  dimension: name_and_months_as_tam {
    group_label: "Sales Person Info"
    label: "Rep - Months as TAM"
    type: string
    sql: ${sp_name} ;;
    html:
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">Months As TAM: {{months_as_TAM._rendered_value }} </font>
    ;;
  }

  measure: prior_month_out_market_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${prior_month_out_market_rev} ;;
    value_format_name: usd_0
    label: "Prior Month Total Revenue"
  }

  measure: prior_rev_under_count {
    group_label: "Revenue"
    type: count_distinct
    sql:  ${sp_user_id};;
    filters: [prior_month_total_rev: "<125000", current_status: "Active"]
    drill_fields: [prior_rev_under_drill*]
  }

  set: prior_rev_under_drill {
    fields: [salesperson, curr_total_rev_sum, prior_month_total_rev_sum]
  }

  measure: curr_total_rev_sum {
    group_label: "Revenue"
    type: sum
    sql: ${total_rev} ;;
    filters: [current_month: "1"]
    value_format_name: usd_0
    label: "Current Month Total Revenue"
  }

  measure: prev_total_rev_sum {
    group_label: "Previous Month Metrics"
    type: sum
    sql: ${total_rev} ;;
    filters: [prev_month: "1"]
    value_format_name: usd_0
    label: "Prev Month Total Revenue"
  }

  measure: revenue_change_vs_last_month {
    type: number
    sql: ${curr_total_rev_sum} - ${prior_month_total_rev_sum} ;;
    value_format_name: usd
  }

  measure: revenue_pct_change_vs_last_month {
    type: number
    sql:
    CASE
      WHEN ${prior_month_total_rev_sum} = 0 AND ${curr_total_rev_sum} > 0 THEN 1
      WHEN ${prior_month_total_rev_sum} = 0 AND ${curr_total_rev_sum} = 0 THEN 0
      ELSE (${curr_total_rev_sum} - ${prior_month_total_rev_sum}) / NULLIF(${prior_month_total_rev_sum}, 0)
    END ;;
    value_format: "0.0%"
  }

  measure: revenue_change_display {
    type: string
    sql:
    CASE
      WHEN ${revenue_change_vs_last_month} > 0
        THEN CONCAT('Up ', ${revenue_change_vs_last_month})
      WHEN ${revenue_change_vs_last_month} < 0
        THEN CONCAT('Down ', ${revenue_change_vs_last_month})
      ELSE 'No Change'
    END ;;

    html:
    {% assign change = revenue_change_vs_last_month._value %}
    {% assign pct = revenue_pct_change_vs_last_month._rendered_value %}
    {% assign amt = revenue_change_vs_last_month._rendered_value %}

      {% if change > 0 %}
      <span style="color:#1a7f37; font-weight:600;">▲ {{ amt }}{% if pct != nil %} ({{ pct }}){% endif %}</span>
      {% elsif change < 0 %}
      <span style="color:#d1242f; font-weight:600;">▼ {{ amt | remove: '-' }}{% if pct != nil %} ({{ pct | remove: '-' }}){% endif %}</span>
      {% else %}
      <span style="color:#666;">{{ amt }}{% if pct != nil %} ({{ pct }}){% endif %}</span>
      {% endif %}
      ;;
  }

  measure: current_vs_prev_rental_revenue_html {
    type: string
    sql: concat(${curr_total_rev_sum}) ;;
    value_format_name: usd_0
    html:
    <font style="text-align: left;">
    Current: {{rendered_value}}
    <br />
    <font style="text-align: left;">
    Previous: {{prior_month_total_rev_sum._rendered_value }} </font>
    ;;
  }

  measure: curr_month_na_breakdown_html {
    type: string
    sql:  sum(${tot_na_monthly}) ;;
    html:
    Total: {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right; font-size: 10px;">
    CoD: {{curr_tot_cod_sum._rendered_value }} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right; font-size: 10px;">
    Credit: {{curr_tot_cred_sum._rendered_value }} </font>
    ;;
  }

  dimension: in_market_prct {
    group_label: "Revenue Monthly Totals"
    type: number
    sql: ${TABLE}."IN_MARKET_PRCT" ;;
    value_format: "0.00%"
  }

  measure: prev_month_na_breakdown_html {
    type: string
    sql: ${prior_month_tot_na_sum} ;;
    html:
    Total: {{ rendered_value }}
    <br />
    <font style="color: #8C8C8C; text-align: right; font-size: 10px;">
    CoD: {{ prior_month_tot_cod_sum }} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right; font-size: 10px;">
    Credit: {{ prior_month_tot_cred_sum }} </font>
  ;;
  }

  measure: curr_monthly_rank_in_market_rev_es {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_ES" ELSE NULL END ;;
  }

  measure: curr_monthly_rank_total_rev_es {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_ES" ELSE NULL END;;
  }

  measure: curr_monthly_rank_in_market_rev_region {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_REGION" ELSE NULL END;;
  }
  measure:curr_monthly_rank_total_rev_region {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_REGION" ELSE NULL END;;
  }

  measure: curr_monthly_rank_in_market_rev_district {
    group_label: "Revenue Monthly Rank"
    type:max
    sql:CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_DISTRICT" ELSE NULL END;;
  }

  measure: curr_monthly_rank_total_rev_district {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_DISTRICT" ELSE NULL END;;
  }

  measure: curr_monthly_rank_in_market_rev_market {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET" ELSE NULL END;;
  }

  measure: curr_monthly_rank_total_rev_market {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET" ELSE NULL END;;
  }

  measure: curr_monthly_rank_in_market_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type:max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET_TYPE" ELSE NULL END;;
  }

  measure: curr_monthly_rank_total_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET_TYPE" ELSE NULL END;;
  }



  measure: prev_monthly_rank_in_market_rev_es {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_ES" ELSE NULL END ;;
  }

  measure: prev_monthly_rank_total_rev_es {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_ES" ELSE NULL END;;
  }

  measure: prev_monthly_rank_in_market_rev_region {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_REGION" ELSE NULL END;;
  }

  measure:prev_monthly_rank_total_rev_region {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_REGION" ELSE NULL END;;
  }

  measure:prev_monthly_rank_in_market_rev_district {
    group_label: "Revenue Monthly Rank"
    type: max
    sql:CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_DISTRICT" ELSE NULL END;;
  }

  measure: prev_monthly_rank_total_rev_district {
    group_label: "Revenue Monthly Rank"
    type:max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_DISTRICT" ELSE NULL END;;
  }

  measure: prev_monthly_rank_in_market_rev_market {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET" ELSE NULL END;;
  }

  measure: prev_monthly_rank_total_rev_market {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET" ELSE NULL END;;
  }

  measure: prev_monthly_rank_in_market_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET_TYPE" ELSE NULL END;;
  }

  measure: prev_monthly_rank_total_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type: max
    sql: CASE WHEN ${prev_month} = 1 THEN ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET_TYPE" ELSE NULL END;;
  }


  dimension: monthly_rank_in_market_rev_es {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_ES"  ;;
  }

  dimension: monthly_rank_total_rev_es {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_ES" ;;
  }

  dimension: monthly_rank_in_market_rev_region {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_REGION";;
  }

  dimension: monthly_rank_total_rev_region {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_REGION" ;;
  }

  dimension: monthly_rank_in_market_rev_district {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_DISTRICT" ;;
  }

  dimension: monthly_rank_total_rev_district {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_DISTRICT" ;;
  }

  dimension: monthly_rank_in_market_rev_market {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET" ;;
  }

  dimension: monthly_rank_total_rev_market {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET" ;;
  }

  dimension: monthly_rank_in_market_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_IN_MARKET_REV_MARKET_TYPE" ;;
  }

  dimension: monthly_rank_total_rev_market_type {
    group_label: "Revenue Monthly Rank"
    type: number
    sql: ${TABLE}."MONTHLY_RANK_TOTAL_REV_MARKET_TYPE" ;;
  }


  dimension: monthly_avg_oec {
    group_label: "Avg OEC"
    type: number
    sql: ${TABLE}."MONTHLY_AVG_OEC" ;;
    value_format_name: usd_0
  }

  dimension: curr_monthly_avg_oec {
    group_label: "Avg OEC"
    type: number
    sql:  CASE WHEN ${current_month} = 1 THEN ${TABLE}."MONTHLY_AVG_OEC" ELSE 0 END ;;
    value_format_name: usd_0
  }

  measure: monthly_avg_oec_sum {
    type:  number
    drill_fields: [avg_oec_drill*]
    sql:  sum(${monthly_avg_oec})/count(${monthly_avg_oec}) ;;

    value_format_name: usd_0
  }

  dimension: daily_oec_on_rent {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."DAILY_OEC_ON_RENT" ;;
  }

  measure: daily_oec_on_rent_today {
    group_label: "Daily Metric"
    type: sum
    value_format_name: usd_0
    sql:${daily_oec_on_rent} ;;
    filters: [current_month: "1"]
  }

  measure: lmtd_oec_on_rent {
    group_label: "Daily Metric"

    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PREV_MONTH_OEC_ON_RENT" ;;
    filters: [current_month: "1"]
  }


  dimension: daily_assets_on_rent {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."DAILY_ASSETS_ON_RENT" ;;
  }

  measure: daily_assets_on_rent_today {
    group_label: "Daily Metric"
    type: sum
    sql:${daily_assets_on_rent} ;;
    filters: [current_month: "1"]
  }

  measure: daily_assets_on_rent_sum {
    group_label: "Daily Metric"
    label: "Current Date AOR"
    type: number
    hidden:  yes
    sql: sum(${daily_assets_on_rent}) ;;
  }

  measure: lmtd_assets_on_rent {
    group_label: "Daily Metric"
    type: sum
    sql: ${TABLE}."PREV_MONTH_ASSETS_ON_RENT" ;;
    filters: [current_month: "1"]
  }

  dimension: daily_actively_renting_customers {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."DAILY_ACTIVELY_RENTING_CUSTOMERS" ;;
  }
  measure: daily_actively_renting_customers_today {
    group_label: "Daily Metric"
    type: sum
    sql:${daily_actively_renting_customers} ;;
    filters: [current_month: "1"]
  }

  measure: daily_actively_renting_customers_sum {
    group_label: "Daily Metric"
    hidden:  yes
    label: "Current Date ARC"
    type: number
    sql: sum(${daily_actively_renting_customers}) ;;
  }

  measure: lmtd_actively_renting_customers {
    group_label: "Daily Metric"
    type: sum
    sql: ${TABLE}."PREV_MONTH_ACTIVELY_RENTING_CUSTOMERS" ;;
    filters: [current_month: "1"]
  }

  dimension: rolling_avg_percent_discount {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."ROLLING_AVG_PERCENT_DISCOUNT" ;;
    value_format_name: percent_1
  }
  measure: rolling_avg_percent_discount_today {
    group_label: "Daily Metric"
    type: sum
    sql:${rolling_avg_percent_discount} ;;
    filters: [current_month: "1"]
    value_format_name: percent_1
  }

  measure: total_invoices_last_28_days {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."ROLLING_AVG_PERCENT_DISCOUNT" ;;
  }

  measure: total_revenue_last_28_days {
    group_label: "Daily Metric"
    type: number
    sql: ${TABLE}."ROLLING_AVG_PERCENT_DISCOUNT" ;;
    value_format_name: usd_0
  }

  dimension: daily_OEC_date {
    group_label: "Daily OEC Rank"
    type: date
    sql: ${TABLE}."DAILY_METRIC_DATE" ;;
  }

  dimension: daily_metric_date {
    group_label: "Daily Metric"
    type: date
    sql: ${TABLE}."DAILY_METRIC_DATE" ;;
  }


  measure: daily_oec_on_rent_sum {
    label: "Current Date OEC On Rent"
    type: number

    sql: sum(${daily_oec_on_rent}) ;;
    value_format_name: usd_0
  }


    measure: curr_daily_rank_OEC_ES {
      group_label: "Current Daily OEC Rank"
      type: max
      sql: ${TABLE}."DAILY_RANK_OEC_ES";;
      filters: [current_month: "1"]
    }

    measure: curr_daily_rank_OEC_region {
      group_label: "Current Daily OEC Rank"
      type: max
      sql: ${TABLE}."DAILY_RANK_OEC_REGION";;
      filters: [current_month: "1"]
    }

    measure: curr_daily_rank_OEC_district {
      group_label: "Current Daily OEC Rank"
      type: max
      sql: ${TABLE}."DAILY_RANK_OEC_DISTRICT" ;;
      filters: [current_month: "1"]
    }

    measure:curr_daily_rank_OEC_market {
      group_label: "Current Daily OEC Rank"
      type: max
      sql: ${TABLE}."DAILY_RANK_OEC_MARKET" ;;
      filters: [current_month: "1"]
    }

    measure: curr_daily_rank_OEC_markettype {
      group_label: "Current Daily OEC Rank"
      type: max
      sql: ${TABLE}."DAILY_RANK_OEC_MARKETTYPE";;
      filters: [current_month: "1"]
    }

  measure: prev_daily_rank_OEC_ES {
    group_label: "Daily OEC Rank"
    type: sum
    sql: ${TABLE}."DAILY_RANK_OEC_ES" ;;
    filters: [prev_month: "1"]
  }

  measure: prev_daily_rank_OEC_region {
    group_label: "Daily OEC Rank"
    type:sum
    sql: ${TABLE}."DAILY_RANK_OEC_REGION";;
    filters: [prev_month: "1"]
  }

  measure: prev_daily_rank_OEC_district {
    group_label: "Daily OEC Rank"
    type: sum
    sql: ${TABLE}."DAILY_RANK_OEC_DISTRICT"  ;;
    filters: [prev_month: "1"]
  }

  measure: prev_daily_rank_OEC_market {
    group_label: "Daily OEC Rank"
    type: sum
    sql:${TABLE}."DAILY_RANK_OEC_MARKET";;
    filters: [prev_month: "1"]
  }

  measure: prev_daily_rank_OEC_markettype {
    group_label: "Daily OEC Rank"
    type: sum
    sql: ${TABLE}."DAILY_RANK_OEC_MARKETTYPE";;
    filters: [prev_month: "1"]
  }


  dimension: daily_rank_OEC_ES {
    group_label: "Daily OEC Rank"
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_ES";;
  }

  dimension: daily_rank_OEC_region {
    group_label: "Daily OEC Rank"
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_REGION";;
  }

  dimension: daily_rank_OEC_district {
    group_label: "Daily OEC Rank"
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_DISTRICT";;
  }

  dimension: daily_rank_OEC_market {
    group_label: "Daily OEC Rank"
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_MARKET";;
  }

  dimension: daily_rank_OEC_markettype {
    group_label: "Daily OEC Rank"
    type: number
    sql: ${TABLE}."DAILY_RANK_OEC_MARKETTYPE";;
  }


  set: avg_oec_drill {
    fields: [current_month_oec_by_rep_company.company_name, current_month_oec_by_rep_company.avg_oec_sum_month]
  }



  measure: curr_tot_NA_ES {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_NA_BY_ES_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_NA_region {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_NA_BY_REGION_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_NA_district {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_NA_BY_DISTRICT_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_NA_market_type {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_NA_BY_MARKET_TYPE_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: curr_tot_NA_market {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_NA_BY_MARKET_MONTH" ELSE NULL END ;;
    value_format_name: usd_0

  }


  measure: curr_tot_rev_ES {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_REV_BY_ES_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_rev_region {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_REV_BY_REGION_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: curr_tot_rev_district {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_REV_BY_DISTRICT_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: curr_tot_rev_market_type {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_REV_BY_MARKET_TYPE_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: curr_tot_rev_market {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_REV_BY_MARKET_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_OEC_ES {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_OEC_BY_ES_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_OEC_region {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_OEC_BY_REGION_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: curr_tot_OEC_district {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_OEC_BY_DISTRICT_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_OEC_market_type {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_OEC_BY_MARKET_TYPE_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: curr_tot_OEC_market {
    group_label: "Scope Totals"
    type: max
    sql: CASE WHEN ${current_month} = 1 THEN ${TABLE}."TOTAL_OEC_BY_MARKET_MONTH" ELSE NULL END ;;
    value_format_name: usd_0
  }

  dimension: dynamic_total {
    group_label: "Sales Person Info"
    label: "Rep - Market"
    type: string
    sql: ${sp_name} ;;
    html:
       <font color="#000000 ">
       {{rendered_value}}
       <br />
       <font style="color: #8C8C8C; text-align: right;">Home: {{ market_name._rendered_value }} </font>
       </font>;;
  }




  parameter: show_ranking_scope_options {
    type: string
    allowed_value: { value: "Overall"}
    allowed_value: { value: "Market Type"}
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  dimension: dynamic_total_type {
    hidden: yes
    sql:
    CASE
      WHEN {% parameter show_ranking_scope_options %} = 'Overall' THEN 'Overall'
      WHEN {% parameter show_ranking_scope_options %} = 'Market Type' THEN ${market_type}
      WHEN {% parameter show_ranking_scope_options %} = 'Region' THEN ${region_name}
      WHEN {% parameter show_ranking_scope_options %} = 'District' THEN concat('District ', ${district})
      WHEN {% parameter show_ranking_scope_options %} = 'Market' THEN ${market_name}
    END ;;
  }

  measure: dynamic_ranking_scope_rev {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_monthly_rank_total_rev_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_monthly_rank_total_rev_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_monthly_rank_total_rev_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_monthly_rank_total_rev_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_monthly_rank_total_rev_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_rev_prev {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${prev_monthly_rank_total_rev_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${prev_monthly_rank_total_rev_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${prev_monthly_rank_total_rev_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${prev_monthly_rank_total_rev_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${prev_monthly_rank_total_rev_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_rev_diff {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
        ${prev_monthly_rank_total_rev_es} - ${curr_monthly_rank_total_rev_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
        ${prev_monthly_rank_total_rev_market_type} - ${curr_monthly_rank_total_rev_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
        ${prev_monthly_rank_total_rev_region} - ${curr_monthly_rank_total_rev_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
        ${prev_monthly_rank_total_rev_district} - ${curr_monthly_rank_total_rev_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
         ${prev_monthly_rank_total_rev_market} - ${curr_monthly_rank_total_rev_market}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;

  }

  measure: dynamic_scope_rev {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_tot_rev_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_tot_rev_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_tot_rev_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_tot_rev_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_tot_rev_market}
    {% else %}
      NULL
    {% endif %} ;;

    html: <font color="#000000 ">
       {{rendered_value}}
       <br />
       <font style="color: #8C8C8C; text-align: right;"> {{dynamic_total_type}} TAM Total </font>
       </font>;;
      value_format_name: usd_0
  }


  measure: dynamic_ranking_scope_oec {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_daily_rank_OEC_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_daily_rank_OEC_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_daily_rank_OEC_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_daily_rank_OEC_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_daily_rank_OEC_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_oec_prev {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${prev_daily_rank_OEC_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${prev_daily_rank_OEC_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${prev_daily_rank_OEC_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${prev_daily_rank_OEC_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${prev_daily_rank_OEC_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_oec_diff {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
       ${prev_daily_rank_OEC_ES} - ${curr_daily_rank_OEC_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
       ${prev_daily_rank_OEC_markettype} - ${curr_daily_rank_OEC_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${prev_daily_rank_OEC_region} - ${curr_daily_rank_OEC_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${prev_daily_rank_OEC_district} - ${curr_daily_rank_OEC_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${prev_daily_rank_OEC_market} -  ${curr_daily_rank_OEC_market}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;
  }


  measure: dynamic_scope_oec {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_tot_OEC_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_tot_OEC_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_tot_OEC_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_tot_OEC_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_tot_OEC_market}
    {% else %}
      NULL
    {% endif %} ;;

    html: <font color="#000000 ">
       {{rendered_value}}
       <br />
       <font style="color: #8C8C8C; text-align: right;"> {{ dynamic_total_type }} Total </font>
       </font>;;
      value_format_name: usd_0
  }

  measure: dynamic_ranking_scope_na {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_monthly_rank_na_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_monthly_rank_na_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_monthly_rank_na_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_monthly_rank_na_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_monthly_rank_na_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_na_prev {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${prev_monthly_rank_na_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${prev_monthly_rank_na_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${prev_monthly_rank_na_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${prev_monthly_rank_na_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${prev_monthly_rank_na_market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_ranking_scope_na_diff {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
       ${prev_monthly_rank_na_es} -  ${curr_monthly_rank_na_es}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
        ${prev_monthly_rank_na_markettype} - ${curr_monthly_rank_na_markettype}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
        ${prev_monthly_rank_na_region} - ${curr_monthly_rank_na_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
       ${prev_monthly_rank_na_district} - ${curr_monthly_rank_na_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
        ${prev_monthly_rank_na_market} - ${curr_monthly_rank_na_market}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;
  }

   measure: dynamic_scope_na {
    label_from_parameter: show_ranking_scope_options
    type: number
    sql:{% if show_ranking_scope_options._parameter_value == "'Overall'" %}
      ${curr_tot_NA_ES}
    {% elsif show_ranking_scope_options._parameter_value == "'Market Type'" %}
      ${curr_tot_NA_market_type}
    {% elsif show_ranking_scope_options._parameter_value == "'Region'" %}
      ${curr_tot_NA_region}
    {% elsif show_ranking_scope_options._parameter_value == "'District'" %}
      ${curr_tot_NA_district}
    {% elsif show_ranking_scope_options._parameter_value == "'Market'" %}
      ${curr_tot_NA_market}
    {% else %}
      NULL
    {% endif %} ;;
    html: <font color="#000000 ">
       {{rendered_value}}
       <br />
       <font style="color: #8C8C8C; text-align: right;"> {{ dynamic_total_type }} TAM Total </font>
       </font>;;
  }

  measure: tot_na_change {
    type: number
    sql:${curr_tot_na_sum} - ${lmtd_tot_na_sum} ;;
  }



  measure: mtd_tot_na_percent_change {
    type:  number
    sql: CASE WHEN ${lmtd_tot_na_sum} = 0 AND ${curr_tot_na_sum} = 0 THEN 0
              WHEN ${lmtd_tot_na_sum} = 0 THEN 1
              ELSE ((${curr_tot_na_sum} - ${lmtd_tot_na_sum})/ NULLIFZERO(${lmtd_tot_na_sum})) END;;
    value_format_name: percent_1
  }


  measure: total_new_accounts_card {
    group_label: "Total New Accounts Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${curr_tot_na_sum} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Total New Accounts</td>
  </tr>


      {% if tot_na_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if tot_na_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td> Total New Accounts: </td>
      <td>
      {% if tot_na_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ curr_tot_na_sum._rendered_value }}</a>
      {% if tot_na_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD New Accounts: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ lmtd_tot_na_sum._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if tot_na_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if tot_na_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ tot_na_change._rendered_value }} </font><font size="2px;">({{ mtd_tot_na_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ tot_na_change._rendered_value }} </font><font size="2px;">({{ mtd_tot_na_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  set: detail {
    fields: [

  sp_user_id,
  sp_name,
  current_status,

  market_id,
  market_name,
  district,
  region,
  region_name,
  market_type,
  tot_na_monthly,
  tot_cod_monthly,
  tot_cred_monthly,
  monthly_rank_na_es,
  monthly_rank_cred_es,
  monthly_rank_na_region,
  monthly_rank_cred_region,
  monthly_rank_na_district,
  monthly_rank_cred_district,
  monthly_rank_na_market,
  monthly_rank_cred_market,
  monthly_rank_na_markettype,
  monthly_rank_cred_markettype,

  in_market_rev,
  out_market_rev,
  total_rev,

  monthly_rank_in_market_rev_es,
  monthly_rank_total_rev_es,
  monthly_rank_in_market_rev_region,
  monthly_rank_total_rev_region,
  monthly_rank_in_market_rev_district,
  monthly_rank_total_rev_district,
  monthly_rank_in_market_rev_market,
  monthly_rank_total_rev_market,
  monthly_rank_in_market_rev_market_type,
  monthly_rank_total_rev_market_type,

  monthly_avg_oec,
  daily_oec_on_rent,
  daily_rank_OEC_ES,
  daily_rank_OEC_region,
  daily_rank_OEC_district,
  daily_rank_OEC_market,
  daily_rank_OEC_markettype

    ]
  }
}
