
view: rep_actively_renting_customers_insights {
  derived_table: {
    sql: with user_access as (
      select
          case
          when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
          else
          concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,
          employee_title,
          location as employee_location,
          u.user_id as employee_user_id,
          mn.manager_name,
          IFF(manager_email = IFF('{{ _user_attributes['email'] }}' = 'bobbi.malone@equipmentshare.com','jay.mitchell@equipmentshare.com','{{ _user_attributes['email'] }}'),TRUE,FALSE) as direct_report,
          mrx.district
      from
          analytics.payroll.pa_employee_access ca
          join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
          join
          (
          select
            distinct EMPLOYEE_ID as manager_id,
              case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
                   else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
              direct_manager_employee_id,
              work_email as manager_email
          from
            analytics.PAYROLL.COMPANY_DIRECTORY
          where
            employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
          ) mn on mn.manager_id = cd.direct_manager_employee_id
          join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)
          left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id
      where
          (
          employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
          (
          (contains(ca.manager_access_emails,IFF('{{ _user_attributes['email'] }}' = 'bobbi.malone@equipmentshare.com','jay.mitchell@equipmentshare.com','{{ _user_attributes['email'] }}')))
          )
          AND employee_title = 'Territory Account Manager'
          )
          OR
          ({{ _user_attributes['job_role'] }} = 'developer')
          )
      , combo as (
      --Pulling in historical info in. Used 9 months assuming no one is down longer than that
      select
          *
      from
          analytics.bi_ops.rep_company_oec_aor_historical
      where
          date >= dateadd(month, '-9', CURRENT_DATE)
      union
      select
          *
      from
          analytics.bi_ops.rep_company_oec_aor_current
      )
      , day_arc as (
      SELECT
          date,
          IFF(date = current_date,1,0) as today_flag,
          salesperson_user_id,
          count(distinct(company_id)) as unique_renting_companies
      FROM
          combo c
      group by
          date,
          today_flag,
          salesperson_user_id
      )
      , current_rep_avg_actively_renting_customers as (
      --Get current month actively renting customers
      select
          salesperson_user_id,
          date_trunc('month',date) as month,
          avg(unique_renting_companies) as avg_actively_renting_customers
      from
          day_arc
      where
          month = date_trunc('month',current_date)
      group by
          salesperson_user_id,
          month
      )
      , rep_historical_actively_renting_customers as (
      --Get historical months actively renting customers
      select
          salesperson_user_id,
          date,
          unique_renting_companies as ttl_actively_renting_customers
      from
          day_arc
      where
          date_trunc('month',date) <> date_trunc('month',current_date)
      )
      , rep_historical_avg_actively_renting_customers as (
      select
          salesperson_user_id,
          date_trunc('month',date) as month,
          avg(ttl_actively_renting_customers) as avg_actively_renting_customers
      from
          rep_historical_actively_renting_customers
      group by
          salesperson_user_id,
          month
      )

      ,aor_avg_date_comparsion AS (
      -- Anchor: start with the first month
      SELECT
          salesperson_user_id,
          month,
          aor.avg_actively_renting_customers as avg_actively_renting_customers,
          month AS start_date,
          avg_actively_renting_customers AS start_value
      FROM
          current_rep_avg_actively_renting_customers aor
      where
          avg_actively_renting_customers is not null
          AND salesperson_user_id is not null
      UNION ALL
      -- Recursive: check if the previous months value is larger; i.e. avg customer count is going down over time
      SELECT
          dv.salesperson_user_id,
          dv.month,
          dv.avg_actively_renting_customers as value,
          vc.start_date,
          vc.start_value
      FROM
          aor_avg_date_comparsion vc
          JOIN rep_historical_avg_actively_renting_customers dv ON dv.salesperson_user_id = vc.salesperson_user_id AND dv.month = vc.month - INTERVAL '1 month'
      WHERE
          dv.avg_actively_renting_customers > vc.avg_actively_renting_customers
      )
      , avg_aor_rep_summary as (
      --Months diff and down for value
      SELECT
          *,
          datediff('month',month,start_date) as months_down,
          (avg_actively_renting_customers - start_value) as aor_avg_diff
      FROM
          aor_avg_date_comparsion
      )
      , avg_aor_rep_insights_summary as (
      --Calcs for days and metrics per rep
      select
          salesperson_user_id,
          start_value as todays_value,
          max(months_down) as total_months_down,
          max(aor_avg_diff) as total_customers_down_in_those_months,
          max(avg_actively_renting_customers) as avg_actively_renting_customers_high_value,
          ((todays_value - avg_actively_renting_customers_high_value) / avg_actively_renting_customers_high_value) * 100 as percent_change
      from
          avg_aor_rep_summary
      group by
          salesperson_user_id,
          start_value
      having --removes anchor data, therefore ensuring only reps with downed months are returned
          max(aor_avg_diff) > 0
      )
      , current_rep_arc as (
      -- Get current rep actively renting customers for current day
      select
          salesperson_user_id,
          date,
          unique_renting_companies as current_ttl_actively_renting_customers
      from
          day_arc
      where
          today_flag = '1'
      )
      ,rep_arc as (
      -- Get historical days by rep for actively renting customers
      select
          salesperson_user_id,
          date,
          unique_renting_companies as ttl_actively_renting_customers
      from
          day_arc
      where
          today_flag = '0'
      )
      ,arc_date_comparsion AS (
      -- Anchor: start with today
      SELECT
          salesperson_user_id,
          date,
          current_ttl_actively_renting_customers as current_actively_renting_customers,
          date AS start_date,
          current_ttl_actively_renting_customers AS start_value
      FROM
          current_rep_arc
      where
          current_ttl_actively_renting_customers is not null
          AND salesperson_user_id is not null

      UNION ALL
      -- Recursive: check if the previous day's value is larger; i.e. getting smaller as time progresses forward
      SELECT
          dv.salesperson_user_id,
          dv.date,
          ttl_actively_renting_customers as value,
          vc.start_date,
          vc.start_value
      FROM
          arc_date_comparsion vc
          JOIN rep_arc dv ON dv.salesperson_user_id = vc.salesperson_user_id AND dv.date = vc.date - INTERVAL '1 day'
      WHERE
          dv.ttl_actively_renting_customers > vc.current_actively_renting_customers
      )
      , arc_rep_summary as (
      --Days diff and down for value
      SELECT
          *,
          datediff('days',date,start_date) as days_down,
          (current_actively_renting_customers - start_value) as arc_diff
      FROM
          arc_date_comparsion
      )
      , arc_rep_insights_summary as (
      --Calcs for days and metrics per rep
      select
          salesperson_user_id,
          start_value as todays_value,
          max(days_down) as total_days_down,
          max(arc_diff) as total_customers_down_in_those_days,
          max(current_actively_renting_customers) as actively_renting_customers_high_value,
          ((todays_value - actively_renting_customers_high_value) / actively_renting_customers_high_value) * 100 as percent_change
      from
          arc_rep_summary
      group by
          salesperson_user_id,
          start_value
      having --removes anchor data, therefore ensuring only reps with downed days are returned
          max(arc_diff) > 0
      )
      , rep_month_duration as (
      --Getting how long a user has been a TAM in months
      select
      user_id,
      ROUND(months_between(current_date, first_date_as_tam ), 0) as months_as_TAM
      from analytics.bi_ops.salesperson_info
      where record_ineffective_date IS NULL and employee_title_dated IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager')
      )
      --Combine all data from day and month then use metric flag to split/show data
      --Qualifiers are purely from Michael B looking at the data in the insights summary CTEs to determine what are the thresholds
      select
          'actively_renting_customers' as metric,
          salesperson_user_id,
          ua.rep,
          ua.employee_location,
          ua.district,
          ua.manager_name,
          rmd.months_as_TAM,
          total_days_down,
          round(total_customers_down_in_those_days,0) as total_customers_down_in_those_days,
          round(todays_value,0) as todays_value,
          round(actively_renting_customers_high_value,0) as actively_renting_customers_high_value,
          round(percent_change,1) as percent_change
      from
          arc_rep_insights_summary arc
          join user_access ua on ua.employee_user_id = arc.salesperson_user_id
          left join rep_month_duration rmd on rmd.user_id = arc.salesperson_user_id
      where
          (total_days_down >= 3 AND percent_change <= -2)
          OR (total_days_down <= 2 AND percent_change <= -8 AND actively_renting_customers_high_value >= 10 AND total_customers_down_in_those_days >= 2)
      UNION
      select
          'avg_actively_renting_customers' as metric,
          salesperson_user_id,
          ua.rep,
          ua.employee_location,
          ua.district,
          ua.manager_name,
          rmd.months_as_TAM,
          total_months_down,
          round(total_customers_down_in_those_months,0) as total_customers_down_in_those_months,
          round(todays_value,0) as todays_value,
          round(avg_actively_renting_customers_high_value,0) as avg_actively_renting_customers_high_value,
          round(percent_change,1) as percent_change
      from
          avg_aor_rep_insights_summary aor
          join user_access ua on ua.employee_user_id = aor.salesperson_user_id
          left join rep_month_duration rmd on rmd.user_id = aor.salesperson_user_id
      where
          (total_months_down >= 3 AND percent_change <= -4)
          OR (total_months_down <= 2 AND percent_change <= -10 AND avg_actively_renting_customers_high_value >= 8 AND total_customers_down_in_those_months >= 4) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: rep {
    type: string
    sql: ${TABLE}."REP" ;;
  }

  dimension: employee_location {
    type: string
    sql: ${TABLE}."EMPLOYEE_LOCATION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}."MANAGER_NAME" ;;
  }

  dimension: months_as_tam {
    type: number
    sql: ${TABLE}."MONTHS_AS_TAM" ;;
  }

  dimension: total_days_down {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_DOWN" ;;
  }

  dimension: total_customers_down_in_those_days {
    type: number
    sql: ${TABLE}."TOTAL_CUSTOMERS_DOWN_IN_THOSE_DAYS" ;;
  }

  dimension: todays_value {
    type: number
    sql: ${TABLE}."TODAYS_VALUE" ;;
  }

  dimension: actively_renting_customers_high_value {
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS_HIGH_VALUE" ;;
  }

  dimension: percent_change {
    type: number
    sql: ${TABLE}."PERCENT_CHANGE" ;;
  }

  dimension: rep_home_market {
    type: string
    sql: concat(${rep},' - ',${employee_location}) ;;
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "TAM"
    type: string
    sql: ${rep} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{rep_home_market._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{employee_location._rendered_value }} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Months As TAM: {{total_months_as_tam._rendered_value }} </font>
    ;;
  }

  dimension: direct_manager_with_link {
    group_label: "Link to Sales Manager"
    label: "Direct Manager"
    sql: ${manager_name} ;;
    html: <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1472?Direct%20Manager={{ manager_name._filterable_value}}"target="_blank">{{rendered_value}} ➔</a> ;;
  }

  measure: total_months_as_tam {
    group_label: "Sales Person Info"
    label: "Months As TAM"
    type: max
    sql: ${months_as_tam} ;;
    html: {{rendered_value}} ;;
  }

  measure: current_value_avg_arc {
    group_label: "Avg ARC"
    label: "Current Value"
    type: max
    sql: ${todays_value} ;;
    filters: [metric: "avg_actively_renting_customers"]
  }

  measure: current_value_daily_aor {
    group_label: "Daily ARC"
    label: "Current Value"
    type: max
    sql: ${todays_value} ;;
    filters: [metric: "actively_renting_customers"]
  }

  measure: percent_change_avg_aor {
    group_label: "Avg ARC"
    label: "Percent Change"
    type: max
    sql: ${percent_change} ;;
    filters: [metric: "avg_actively_renting_customers"]
    html: {{rendered_value}}% ;;
  }

  measure: percent_change_daily_aor {
    group_label: "Daily ARC"
    label: "Percent Change"
    type: max
    sql: ${percent_change} ;;
    filters: [metric: "actively_renting_customers"]
    html: {{rendered_value}}% ;;
  }

  measure: starting_value_avg_aor {
    group_label: "Avg ARC"
    label: "Last Peak"
    type: max
    sql: ${actively_renting_customers_high_value} ;;
    filters: [metric: "avg_actively_renting_customers"]
  }

  measure: starting_value_daily_aor {
    group_label: "Daily ARC"
    label: "Last Peak"
    type: max
    sql: ${actively_renting_customers_high_value} ;;
    filters: [metric: "actively_renting_customers"]
  }

  measure: total_months_down_avg_aor {
    group_label: "Avg ARC"
    label: "Months Down"
    type: max
    sql: ${total_days_down} ;;
    filters: [metric: "avg_actively_renting_customers"]
    html: {{rendered_value}} ;;
  }

  measure: total_months_down_daily_aor {
    group_label: "Daily ARC"
    label: "Days Down"
    type: max
    sql: ${total_days_down} ;;
    filters: [metric: "actively_renting_customers"]
    html: {{rendered_value}} ;;
  }

  measure: value_difference_avg_aor {
    group_label: "Avg ARC"
    label: "Value Change"
    type: max
    sql: ${total_customers_down_in_those_days}*-1 ;;
    filters: [metric: "avg_actively_renting_customers"]
    html: <font color="#DA344D"><b>{{rendered_value}}</b></font> ;;
  }

  measure: value_difference_daily_aor {
    group_label: "Daily ARC"
    label: "Value Change"
    type: max
    sql: ${total_customers_down_in_those_days}*-1 ;;
    filters: [metric: "actively_renting_customers"]
    html: <font color="#DA344D"><b>{{rendered_value}}</b></font> ;;
  }

  set: detail {
    fields: [
        metric,
  salesperson_user_id,
  rep,
  employee_location,
  district,
  manager_name,
  total_days_down,
  total_customers_down_in_those_days,
  todays_value,
  actively_renting_customers_high_value,
  percent_change
    ]
  }
}
