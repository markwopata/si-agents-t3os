view: salesperson_goals_current {
  sql_table_name: "BI_OPS"."SALESPERSON_GOALS_CURRENT" ;;

  dimension_group: date_goal_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GOAL_CREATED" ;;
  }

  dimension: direct_manager_user_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: in_district_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."IN_DISTRICT_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: in_market_goal {
    type: number
    sql: ${TABLE}."IN_MARKET_GOAL" ;;
  }

  dimension: in_market_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."IN_MARKET_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: out_district_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."OUT_DISTRICT_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: out_market_goal {
    type: number
    sql: ${TABLE}."OUT_MARKET_GOAL" ;;
  }

  dimension: out_market_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."OUT_MARKET_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: revenue_goal {
    type: number
    sql: ${TABLE}."REVENUE_GOAL" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: sp_district_present {
    type: string
    sql: ${TABLE}."SP_DISTRICT_PRESENT" ;;
  }

  dimension_group: sp_hire {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SP_HIRE_DATE" ;;
  }

  dimension: sp_jurisdiction_present {
    type: string
    sql: ${TABLE}."SP_JURISDICTION_PRESENT" ;;
  }

  dimension: sp_market_id_present {
    type: string
    sql: ${TABLE}."SP_MARKET_ID_PRESENT" ;;
  }

  dimension: sp_market_present {
    type: string
    sql: ${TABLE}."SP_MARKET_PRESENT" ;;
  }

  dimension: rep_market {
    type: string
    label: "Rep - Market"
    sql: concat(${salesperson}, ' - ', ${sp_market_present}) ;;
  }

  dimension: sp_region_present {
    type: string
    sql: ${TABLE}."SP_REGION_PRESENT" ;;
  }

  dimension_group: start_date_as_sp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE_AS_SP" ;;
  }

  dimension: tam_goal_id {
    type: number
    sql: ${TABLE}."TAM_GOAL_ID" ;;
  }

  dimension: total_monthly_rental_revenue {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: month_name {
    type: string
    sql: ${month} ;;
    html: {% if value == 1 %}
      Jan
    {% elsif value == 2 %}
      Feb
    {% elsif value == 3 %}
      Mar
    {% elsif value == 4 %}
      Apr
    {% elsif value == 5 %}
      May
    {% elsif value == 6 %}
      Jun
    {% elsif value == 7 %}
      Jul
    {% elsif value == 8 %}
      Aug
    {% elsif value == 9 %}
      Sep
    {% elsif value == 10 %}
      Oct
    {% elsif value == 11 %}
      Nov
    {% elsif value == 12 %}
      Dec
    {% else %}
      Out of Range
    {% endif %};;
  }

  dimension: mmm_yyyy {
    type: date
    sql: DATEFROMPARTS(${year}, ${month}, 1);;
    html: {{rendered_value | date: "%b %Y"}} ;;
  }

  measure: total_monthly_rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${total_monthly_rental_revenue};;
  }

  measure: in_market_monthly_rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${in_market_monthly_rental_revenue};;
  }

  measure: out_market_monthly_rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${out_market_monthly_rental_revenue};;
  }

  measure: in_district_monthly_rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${in_district_monthly_rental_revenue};;
  }

  measure: out_district_monthly_rental_revenue_sum {
    type: sum
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${out_district_monthly_rental_revenue};;
  }

  measure: revenue_goal_sum {
    type: sum
    sql: ${revenue_goal};;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: in_market_goal_sum {
    type: sum
    sql: ${in_market_goal};;
  }

  measure: out_market_goal_sum {
    type: sum
    sql: ${out_market_goal};;
  }

  measure: total_remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${revenue_goal_sum} - ${total_monthly_rental_revenue_sum} < 0 then null
      else ${revenue_goal_sum} - ${total_monthly_rental_revenue_sum} end;;
  }

  measure: total_rental_revenue_goal_met {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${revenue_goal_sum} - ${total_monthly_rental_revenue_sum} <= 0 then ${total_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: total_rental_revenue_goal_unmet {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${revenue_goal_sum} - ${total_monthly_rental_revenue_sum} > 0 then ${total_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: total_rental_revenue_no_goal {
    type: number
    value_format_name: usd_0
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_monthly_rental_revenue_sum}
      else null end;;
  }

  measure: total_percent_of_goal {
    type: number
    value_format: "0.0%"
    sql: ${total_monthly_rental_revenue_sum} / ${revenue_goal_sum} ;;
  }

  measure: in_market_remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${in_market_goal_sum} - ${in_market_monthly_rental_revenue_sum} < 0 then null
      else ${in_market_goal_sum} - ${in_market_monthly_rental_revenue_sum} end;;
  }

  measure: in_market_rental_revenue_goal_met {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${in_market_goal}) IS NULL then null
                 when ${in_market_goal_sum} - ${in_market_monthly_rental_revenue_sum} <= 0 then ${in_market_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: in_market_rental_revenue_goal_unmet {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${in_market_goal}) IS NULL then null
                 when  ${in_market_goal_sum} - ${in_market_monthly_rental_revenue_sum} > 0 then ${in_market_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: in_market_rental_revenue_no_goal {
    type: number
    value_format_name: usd_0
    sql: case when SUM(${in_market_goal}) IS NULL then ${in_market_monthly_rental_revenue_sum}
      else null end;;
  }

  measure: in_market_percent_of_goal {
    type: number
    value_format: "0.0%"
    sql: ${in_market_monthly_rental_revenue_sum} / ${in_market_goal_sum} ;;
  }

  measure: out_market_remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${out_market_goal_sum} - ${out_market_monthly_rental_revenue_sum} < 0 then null
      else ${out_market_goal_sum} - ${out_market_monthly_rental_revenue_sum} end;;
  }

  measure: out_market_rental_revenue_goal_met {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${out_market_goal}) IS NULL then null
                 when ${out_market_goal_sum} - ${out_market_monthly_rental_revenue_sum} <= 0 then ${out_market_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: out_market_rental_revenue_goal_unmet {
    type: number
    value_format_name: usd_0
    sql:  case when SUM(${out_market_goal}) IS NULL then null
                 when  ${out_market_goal_sum} - ${out_market_monthly_rental_revenue_sum} > 0 then ${out_market_monthly_rental_revenue_sum}
                 else null end;;
  }

  measure: out_market_rental_revenue_no_goal {
    type: number
    value_format_name: usd_0
    sql: case when SUM(${out_market_goal}) IS NULL then ${out_market_monthly_rental_revenue_sum}
      else null end;;
  }

  measure: out_market_percent_of_goal {
    type: number
    value_format: "0.0%"
    sql: ${out_market_monthly_rental_revenue_sum} / ${out_market_goal_sum} ;;
  }

  measure: goal_diff {
    type: sum
    hidden: yes
    sql: ${total_monthly_rental_revenue} - ${revenue_goal};;
    filters: [current_month_flag: "Yes"]
    value_format: "$0"
  }

  measure: goal_diff_K {
    type: sum
    hidden: yes
    sql: ${total_monthly_rental_revenue} - ${revenue_goal};;
    filters: [current_month_flag: "Yes"]
    value_format: "$0.00,\" K\""
  }

  measure: goal_diff_M {
    type: sum
    hidden: yes
    sql: ${total_monthly_rental_revenue} - ${revenue_goal};;
    filters: [current_month_flag: "Yes"]
    value_format: "$0.00,,\" M\""
  }

  measure: goal_kpi {
    type: sum
    sql: ${revenue_goal};;
    filters: [current_month_flag: "Yes"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    html:
    <div style="border-radius: 5px;">
      <div style="display: inline-block; padding-bottom: 20px;">
        <p style="font-size: 1.25rem;">Rental Revenue Goal</p>
        <p style="font-size: 2rem;">{{rendered_value}}</p>
      </div>
      <div style="display: inline-block; border-left: .5px solid #DCDCDC; padding-left: 10px;">
        <p style="font-size: 1.25rem;">Revenue vs Goal</p>
        <p style="font-size: 2rem;">
          {% if goal_diff._value >= 1000000 %}
            <font color="#00CB86">
            <strong>↑{{goal_diff_M._rendered_value}}</strong></font>
          {% elsif goal_diff._value >= 1000 %}
            <font color="#00CB86">
            <strong>↑{{goal_diff_K._rendered_value}}</strong></font>
          {% elsif goal_diff._value >= 0 %}
            <font color="#00CB86">
            <strong>↑{{goal_diff._rendered_value}}</strong></font>
          {% elsif goal_diff._value <= -1000000 %}
            <font color="#DA344D">
            <strong>↓{{goal_diff_M._rendered_value}}</strong></font>
          {% elsif goal_diff._value <= -1000 %}
            <font color="#DA344D">
            <strong>↓{{goal_diff_K._rendered_value}}</strong></font>
          {% else %}
            <font color="#DA344D">
            <strong>↓{{goal_diff._rendered_value}}</strong></font>
          {% endif %}
        </p>
      </div>
    </div>;;
  }

  dimension: current_month_flag {
    type: yesno
    sql: date_trunc('month',(current_date)) = ${mmm_yyyy} ;;
  }

  dimension: current_year_flag {
    type: yesno
    sql: year(current_date) = ${year} ;;
  }

  dimension: previous_year_flag {
    type: yesno
    sql: YEAR(dateadd(year,-1,current_date)) = ${year} ;;
  }

  dimension: previous_YTD_flag {
    type: yesno
    sql:  ${mmm_yyyy} BETWEEN DATEFROMPARTS(YEAR(dateadd(year,-1,current_date)), 1, 1)
      AND DATEFROMPARTS(YEAR(dateadd(year,-1,current_date)), MONTH(current_date), 1);;
  }

  dimension: past_six_months_flag {
    type: yesno
    sql: ${mmm_yyyy} >= CURRENT_DATE("America/Chicago") - INTERVAL "5 Month") ;;
  }

  dimension: past_three_years_flag {
    type: yesno
    hidden: yes
    sql: ${mmm_yyyy} >= CURRENT_DATE("America/Chicago") - INTERVAL "2 Year") ;;
  }

  measure: total_current_month_revenue_sum {
    type: sum
    sql: ${total_monthly_rental_revenue} ;;
    filters: [current_month_flag: "Yes"]
    value_format_name: usd
    # drill_fields: [company_detail*]
  }

  measure: total_current_month_revenue_abbreviated {
    type: number
    sql: ${total_current_month_revenue_sum};;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: total_current_month_goal_sum {
    type: sum
    sql: ${revenue_goal} ;;
    filters: [current_month_flag: "Yes"]
    value_format_name: usd
  }

  measure: total_current_month_goal_abbreviated {
    type: number
    sql: ${total_current_month_goal_sum};;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: total_current_year_revenue_sum {
    type: sum
    sql: ${total_monthly_rental_revenue} ;;
    filters: [current_year_flag: "Yes"]
    value_format_name: usd
    # drill_fields: [company_detail_multi_month*]
  }

  measure: total_last_YTD_revenue_sum {
    type: sum
    sql: ${total_monthly_rental_revenue} ;;
    filters: [previous_YTD_flag: "Yes"]
    value_format_name: usd
  }

  measure: yoy_revenue_comparsion{
    type: number
    sql: coalesce(${total_current_year_revenue_sum},0) - coalesce(${total_last_YTD_revenue_sum},0) ;;
    value_format_name: usd
  }

  measure: max_total_monthly_revenue {
    type: max
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${total_monthly_rental_revenue} ;;
  }

  measure: current_year_revenue_abbreviated {
    type: sum
    sql: ${total_monthly_rental_revenue} ;;
    filters: [current_year_flag: "Yes"]
    description: "The filter only acts on monthly_rental_revenue--not max_monthly_revenue, which is called in the html."
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    html:
    <div style="border-radius: 5px;">
      <div style="display: inline-block; padding-bottom: 20px;"><a href="#drillmenu" target="_self"><font color="#000000">
        <p style="font-size: 1.25rem;">YTD Revenue</p>
        <p style="font-size: 2rem;">{{rendered_value}}</p>
      </a></div>
      <div style="display: inline-block; border-left: .5px solid #DCDCDC; padding-left: 10px;">
        <p style="font-size: 1.25rem;">Max Revenue All Time</p>
        <p style="font-size: 2rem;">{{max_total_monthly_revenue._rendered_value}}</p>
      </div>
    </div>;;
    # drill_fields: [company_detail_multi_month*]
  }

  measure: goal_count {
    type: sum
    sql: CASE WHEN ${revenue_goal} > 0 THEN 1
      ELSE 0 END;;
  }

  measure: goal_met_count {
    type: sum
    sql: CASE WHEN ${revenue_goal} > 0 AND ${total_monthly_rental_revenue} > ${revenue_goal} THEN 1
      ELSE 0 END;;
  }

  measure: goal_achievement {
    type: string
    sql: CASE WHEN ${goal_count} > 0 THEN CONCAT(CAST(ROUND(100*${goal_met_count}/${goal_count}, 0) as VARCHAR), '%')
      ELSE 'No Goals Set' END;;
    html:
    {% if sales_goals_rental_historic.territory_account_manager._is_filtered %}
    <div style="font-size: 1.25rem; line-height: 1;">
      <strong>Start Date as Salesperson:</strong><br/>
      {{start_date_as_sp._value}}<br/><br/>
      <strong>Home Market:</strong><br/>
      {{sp_market_present._value}}<br/><br/>
      <strong>Max Revenue:</strong><br/>
      {{max_total_monthly_revenue._rendered_value}}<br/><br/>
      <strong>Goal Achievement:</strong><br/>
      {{rendered_value}}<br/>
      {{goal_met_count._rendered_value}} / {{goal_count._rendered_value}}
    </div>
    {% else %}
    Select a Rep
    {% endif %}
    ;;
  }

  # dimension: more_rental_revenue_history_hyperlink {
  #   type: string
  #   sql: 'g' ;;
  #   html:
  #   <div style="border-radius: 5px; height: 100%; text-align: center; ">
  #     <h3>
  #     <font color="#0063f3">

  #     <img src="https://i.ibb.co/3czBQcM/Gear-447.png" height="15" width="15">

  #     <a href="https://equipmentshare.looker.com/dashboards/1134?Territory+Account+Manager={{salesperson_name_employee_id._filterable_value | url_encode}}&Month=" target="_blank">
  #     <u>
  #     Want to see more rental revenue history? Click here!
  #     </u>

  #     <img src="https://i.imgur.com/0fEVw1u.png" height="12" width = "14" style="padding-left: 5px;">
  #     </div>;;
  # }

  measure: count {
    type: count
  }
}
