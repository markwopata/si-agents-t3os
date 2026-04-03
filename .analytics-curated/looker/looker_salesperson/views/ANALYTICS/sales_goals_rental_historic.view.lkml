view: sales_goals_rental_historic {
  derived_table: {
    sql: WITH current_and_historic AS(
        select
          year,
          month,
          concat(year, '-', LPAD(month, 2, '0'),'-01' )::DATE as month_date,
          tam_user_id,
          territory_account_manager,
          tam_email,
          tam_district,
          monthly_rental_revenue,
          tam_goal_id,
          date_goal_created,
          revenue_goal,
          last_six_months,
          last_two_calendar_years
        from analytics.bi_ops.tam_goals_historic
      UNION
        select
          year,
          month,
          concat(year, '-', LPAD(month, 2, '0'),'-01' )::DATE as month_date,
          tam_user_id,
          territory_account_manager,
          tam_email,
          tam_district,
          monthly_rental_revenue,
          tam_goal_id,
          date_goal_created,
          revenue_goal,
          'Y' AS last_six_months,
          'Y' AS last_two_calendar_years
        from analytics.bi_ops.tam_goals_current
      ),
      tam_detail AS(
      SELECT
        cd.work_email,
        COALESCE(cd.date_rehired, cd.date_hired) as tam_start_date,
        COALESCE(m.name, '') as tam_market
      FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
      LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON cd.market_id = m.market_id
      QUALIFY ROW_NUMBER() OVER(partition by cd.work_email ORDER BY IFF(cd.employee_status = 'Active', 0, 1)) = 1
      )
      , tam_most_recent AS (
      SELECT g.year,
        g.month,
        g.tam_goal_id,
        g.date_created as date_goal_created,
        g.tam_user_id,
        g.revenue_goal,
        concat(g.year, '-', LPAD(g.month, 2, '0'),'-01' )::DATE as month_goal_assigned_to
      FROM analytics.bi_ops.tam_goals g
        WHERE concat(g.year, '-', LPAD(g.month, 2, '0'),'-01' )::DATE <= current_date()
        QUALIFY ROW_NUMBER() OVER(PARTITION BY g.tam_user_id ORDER BY g.date_created desc) = 1
      )
      SELECT
          ch.year,
          ch.month,
          concat(ch.year, '-', LPAD(ch.month, 2, '0'),'-01' )::DATE as month_date,
          ch.tam_user_id,
          ch.territory_account_manager,
          ch.tam_email,
          ch.tam_district,
          ch.monthly_rental_revenue,
          COALESCE(ch.tam_goal_id, tmr.tam_goal_id) as tam_goal_id,
          ch.date_goal_created,
          COALESCE(ch.revenue_goal, tmr.revenue_goal) as revenue_goal,
          IFF(ch.revenue_goal IS NULL ,tmr.month_goal_assigned_to, ch.month_date ) as month_goal_assigned_to,
          ch.last_six_months,
          ch.last_two_calendar_years,
          td.tam_start_date,
          td.tam_market
      FROM current_and_historic ch
      LEFT JOIN tam_detail td ON td.work_email = ch.tam_email
      LEFT JOIN tam_most_recent tmr ON tmr.tam_user_id = ch.tam_user_id AND tmr.month_goal_assigned_to <= ch.month_date
      WHERE
          (
            ('salesperson' = {{ _user_attributes['department'] }} AND tam_email ILIKE '{{ _user_attributes['email'] }}')
           )
           OR
           (
            ('salesperson' != {{ _user_attributes['department'] }}
             AND
             ('developer' = {{ _user_attributes['department'] }}
              OR 'god view' = {{ _user_attributes['department'] }}
              OR 'managers' = {{ _user_attributes['department'] }}
              OR 'finance' = {{ _user_attributes['department'] }}
              OR 'collectors' = {{ _user_attributes['department'] }}
              OR 'legal' = {{ _user_attributes['job_role'] }}
             )
            )
           )
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql: CONCAT(${tam_user_id},'-',${year},'-',${month});;
  }

  dimension: tgc_id {
    type: number
    sql: ${TABLE}."TGC_ID" ;;
  }

  dimension: tam_goal_id {
    type: number
    sql: ${TABLE}."TAM_GOAL_ID" ;;
  }

  dimension_group: date_goal_created {
    type: time
    sql: ${TABLE}."DATE_GOAL_CREATED" ;;
  }

  dimension: month_goal_assigned_to {
    type: date
    sql:${TABLE}."MONTH_GOAL_ASSIGNED_TO" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_date {
    type: date
    sql: ${TABLE}."MONTH_DATE" ;;
  }

  dimension: tam_user_id {
    type: number
    sql: ${TABLE}."TAM_USER_ID" ;;
  }

  dimension: territory_account_manager {
    type: string
    sql: ${TABLE}."TERRITORY_ACCOUNT_MANAGER" ;;
  }

  dimension: tam_name_user_id {
    type: string
    sql:  CONCAT(LEFT(${territory_account_manager}, LEN(${territory_account_manager}) - CHARINDEX('-', REVERSE(${territory_account_manager}))), '- ', ${tam_user_id});;
  }

  dimension: tam_email {
    type: string
    sql: ${TABLE}."TAM_EMAIL" ;;
  }

  dimension: revenue_goal {
    type: number
    sql: ${TABLE}."REVENUE_GOAL" ;;
  }

  dimension: tam_district {
    type: string
    sql: ${TABLE}."TAM_DISTRICT";;
  }

  dimension: monthly_rental_revenue {
    type: number
    sql: ${TABLE}."MONTHLY_RENTAL_REVENUE" ;;
  }

  dimension: last_six_months {
    type: string
    sql: ${TABLE}."LAST_SIX_MONTHS" ;;
  }

  dimension: last_two_calendar_years {
    type: string
    sql: ${TABLE}."LAST_TWO_CALENDAR_YEARS" ;;
  }

  dimension: month_year {
    type: string
    sql: DATEFROMPARTS(${year}, ${month}, 1);;
    html: {{rendered_value | date: "%b %Y"}} ;;
  }

  dimension: tam_start_date {
    type: string
    sql: ${TABLE}."TAM_START_DATE" ;;
  }

  dimension: tam_market {
    type: string
    sql: ${TABLE}."TAM_MARKET" ;;
  }

  measure: goal {
    type: sum
    value_format_name: usd_0
    sql: ${revenue_goal} ;;
  }

  measure: rental_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${monthly_rental_revenue} ;;
    drill_fields: [company_detail*]
  }

  measure: remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${goal} - ${rental_revenue} < 0 then null
      else ${goal} - ${rental_revenue} end;;
  }

  measure: current_month_remaining_to_goal_abr {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # sql: CASE WHEN ${current_month} AND (${goal} - ${rental_revenue}) < 0 then 0
    #         WHEN ${current_month} THEN (${goal} - ${rental_revenue}) ELSE NULL end;;
    sql: CASE
    WHEN ${current_month} THEN (${goal} - ${rental_revenue})
    ELSE NULL
    END ;;
  }

  measure: current_month_remaining_to_goal_display_abr {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: CASE
        WHEN ${current_month} THEN ABS(${goal} - ${rental_revenue})
        ELSE NULL
       END ;;
  }

  measure: rental_revenue_goal_met {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${rental_revenue} <= 0 then ${rental_revenue}
                 else null end;;
    drill_fields: [company_detail*]
  }

  measure: rental_revenue_goal_unmet {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${rental_revenue} > 0 then ${rental_revenue}
                 else null end;;
    drill_fields: [company_detail*]
  }

  measure: rental_revenue_no_goal {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${rental_revenue}
      else null end ;;
    drill_fields: [company_detail*]
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

  dimension: current_month {
    type: yesno
    sql: ${month_date}::DATE = DATE_TRUNC(month, current_date) ;;
  }

  dimension: current_year {
    type: yesno
    sql: year(current_date) = year(${month_date}::DATE) ;;
  }

  dimension: current_six_calendar_year {
    type: yesno
    sql: ${year} >= year(current_date() - INTERVAL '5 YEAR') ;;
  }

  dimension: previous_year {
    type: yesno
    # sql: date_trunc('month',(dateadd(year,-1,current_date))) = ${month_year};;
    sql: YEAR(dateadd(year,-1,current_date)) = year(${month_date}::DATE) ;;
  }

  dimension: previous_year_month {
    type: yesno
    sql: MONTH(current_date) >= ${month};;
  }

  measure: current_month_revenue {
    type: sum
    sql: ${monthly_rental_revenue} ;;
    filters: [current_month: "Yes"]
    value_format_name: usd
    drill_fields: [company_detail*]
  }

  measure: current_month_revenue_abbreviated {
    type: number
    sql: ${current_month_revenue};;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: current_month_goal {
    type: sum
    sql: ${revenue_goal} ;;
    filters: [current_month: "Yes"]
    value_format_name: usd
  }

  measure: current_month_goal_abbreviated {
    type: number
    sql: ${current_month_goal};;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: current_year_revenue {
    type: sum
    sql: ${monthly_rental_revenue} ;;
    filters: [current_year: "Yes"]
    value_format_name: usd
    drill_fields: [company_detail_multi_month*]
  }

  measure: previous_month_year_revenue {
    # This is called last_YTD_revenue in new view
    type: sum
    sql: ${monthly_rental_revenue} ;;
    filters: [previous_year_month: "Yes", previous_year: "Yes"]
    value_format_name: usd
  }

  measure: yoy_revenue_comparsion{
    type: number
    sql: coalesce(${current_year_revenue},0) - coalesce(${previous_month_year_revenue},0) ;;
    value_format_name: usd
  }

  measure: rental_revenue_drilldown {
    type: sum
    sql: ${monthly_rental_revenue} ;;
    group_label: "drill down"
    label: "rental_revenue_by_company"
  }

  measure: max_monthly_revenue {
    type: max
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${monthly_rental_revenue} ;;
  }

  measure: current_year_revenue_abbreviated {
    type: sum
    sql: ${monthly_rental_revenue} ;;
    filters: [current_year: "Yes"]
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
        <p style="font-size: 2rem;">{{max_monthly_revenue._rendered_value}}</p>
      </div>
    </div>;;
    drill_fields: [company_detail_multi_month*]
  }

  measure: goal_count {
    type: sum
    sql: CASE WHEN ${revenue_goal} > 0 THEN 1
              ELSE 0 END;;
  }

  measure: goal_met_count {
    type: sum
    sql: CASE WHEN ${revenue_goal} > 0 AND ${monthly_rental_revenue} > ${revenue_goal} THEN 1
              ELSE 0 END;;
  }

  measure: goal_achievement {
    type: string
    sql: CASE WHEN ${goal_count} > 0 THEN CONCAT(CAST(ROUND(100*${goal_met_count}/${goal_count}, 0) as VARCHAR), '%')
              ELSE 'No Goals Set' END;;
    html:
    {% if sales_goals_rental_historic.territory_account_manager._is_filtered %}
    <div style="font-size: 1.25rem; line-height: 1;">
      <strong>Start Date:</strong><br/>
      {{tam_start_date._value}}<br/><br/>
      <strong>Home Market:</strong><br/>
      {{tam_market._value}}<br/><br/>
      <strong>Max Revenue:</strong><br/>
      {{max_monthly_revenue._rendered_value}}<br/><br/>
      <strong>Goal Achievement:</strong><br/>
      {{rendered_value}}<br/>
      {{goal_met_count._rendered_value}} / {{goal_count._rendered_value}}
    </div>
    {% else %}
    Select a Rep
    {% endif %}
    ;;
  }

  dimension: more_rental_revenue_history_hyperlink {
    type: string
    sql: 'g' ;;
    html:
    <div style="border-radius: 5px; height: 100%; text-align: center; ">
      <h3>
      <font color="#0063f3">

      <img src="https://i.ibb.co/3czBQcM/Gear-447.png" height="15" width="15">

      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory+Account+Manager={{territory_account_manager._filterable_value | url_encode}}&Month=" target="_blank">
      <u>
      Want to see more rental revenue history? Click here!
      </u>

      <img src="https://i.imgur.com/0fEVw1u.png" height="12" width = "14" style="padding-left: 5px;">
    </div>;;
  }

  measure: goal_kpi {
    type: number
    sql: ${current_month_goal_abbreviated};;
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
              {% if current_month_remaining_to_goal_abr._value <= 0 %}
                <font color="#00CB86">
                <strong>↑{{current_month_remaining_to_goal_display_abr._rendered_value}}</strong></font>
              {% else %}
                <font color="#DA344D">
                <strong>↓{{current_month_remaining_to_goal_abr._rendered_value}}</strong></font>
              {% endif %}
            </p>
        </div>
      </div>;;
  }

  set: detail {
    fields: [
      tgc_id,
      tam_goal_id,
      date_goal_created_time,
      year,
      month,
      tam_user_id,
      territory_account_manager,
      tam_email,
      tam_district,
      revenue_goal,
      monthly_rental_revenue
    ]
  }

set: company_detail {
  fields: [
    territory_account_manager,
    tam_monthly_rr_by_company.company,
    tam_monthly_rr_by_company.rental_revenue_by_company
  ]
}

set: company_detail_multi_month {
  fields: [
    territory_account_manager,
    tam_monthly_rr_by_company.company,
    tam_monthly_rr_by_company.rental_revenue_by_company,
    tam_monthly_rr_by_company.rental_revenue_by_company_month_drilldown
  ]
}

}
