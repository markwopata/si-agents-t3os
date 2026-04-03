
view: rep_assets_on_rent_insights {
  derived_table: {
    sql: with
      user_access as (
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
      ,current_rep_assets_on_rent_month as (
      --Pull in all assets on rent for the current month
      select
          salesperson_user_id,
          date,
          sum(assets_on_rent) as ttl_assets_on_rent
      from
          analytics.bi_ops.daily_sp_market_rollup
      where
          MTD = '1'
          AND employee_status_present = 'Active'
      group by
          salesperson_user_id,
          date
      )
      , current_rep_avg_assets_on_rent as (
      --Pull in all assets on rent for all months and get the average
      select
          salesperson_user_id,
          date_trunc('month',date) as month,
          avg(ttl_assets_on_rent) as avg_assets_on_rent
      from
          current_rep_assets_on_rent_month
      group by
          salesperson_user_id,
          month
      )
      , rep_historical_assets_on_rent as (
      --Pull in all assets on rent for all days that are not in the current month
      select
          salesperson_user_id,
          date,
          sum(assets_on_rent) as ttl_assets_on_rent
      from
          analytics.bi_ops.daily_sp_market_rollup
      where
          MTD = '0'
          AND employee_status_present = 'Active'
      group by
          salesperson_user_id,
          date
      )
      , rep_historical_avg_assets_on_rent as (
      --Pull in all assets on rent for all months and get the average
      select
          salesperson_user_id,
          date_trunc('month',date) as month,
          avg(ttl_assets_on_rent) as avg_assets_on_rent
      from
          rep_historical_assets_on_rent
      group by
          salesperson_user_id,
          month
      )

      ,aor_avg_date_comparsion AS (
      -- Anchor: start with today
      SELECT
          salesperson_user_id,
          month,
          aor.avg_assets_on_rent as avg_assets_on_rent,
          month AS start_date,
          avg_assets_on_rent AS start_value
      FROM
          current_rep_avg_assets_on_rent aor
      where
          avg_assets_on_rent is not null
          AND salesperson_user_id is not null
      UNION ALL
      -- Recursive: check if the previous months value is larger
      SELECT
          dv.salesperson_user_id,
          dv.month,
          dv.avg_assets_on_rent as value,
          vc.start_date,
          vc.start_value
      FROM
          aor_avg_date_comparsion vc
          JOIN rep_historical_avg_assets_on_rent dv ON dv.salesperson_user_id = vc.salesperson_user_id AND dv.month = vc.month - INTERVAL '1 month'
      WHERE
          dv.avg_assets_on_rent > vc.avg_assets_on_rent
      )
      , avg_aor_rep_summary as (
      --Determine value decrease and how many months down
      SELECT
          *,
          datediff('month',month,start_date) as months_down,
          (avg_assets_on_rent - start_value) as aor_avg_diff
      FROM
          aor_avg_date_comparsion
      )
      , avg_aor_rep_insights_summary as (
      --Pull all metrics together for month by rep
      select
          salesperson_user_id,
          start_value as todays_value,
          max(months_down) as total_months_down,
          max(aor_avg_diff) as total_units_down_in_those_months,
          max(avg_assets_on_rent) as avg_assets_on_rent_high_value,
          ((todays_value - avg_assets_on_rent_high_value) / avg_assets_on_rent_high_value) * 100 as percent_change
      from
          avg_aor_rep_summary
      group by
          salesperson_user_id,
          start_value
      having
          max(aor_avg_diff) > 0
      )
      , current_rep_assets_on_rent as (
      --Pull in all assets on rent for current day
      select
          salesperson_user_id,
          date,
          sum(assets_on_rent) as ttl_assets_on_rent
      from
          analytics.bi_ops.daily_sp_market_rollup
      where
          today_flag = '1'
          AND employee_status_present = 'Active'
      group by
          salesperson_user_id,
          date
      )
      ,rep_assets_on_rent as (
      --Pull in all assets on rent by day
      select
          salesperson_user_id,
          date,
          sum(assets_on_rent) as ttl_assets_on_rent
      from
          analytics.bi_ops.daily_sp_market_rollup
      where
          employee_status_present = 'Active'
      group by
          salesperson_user_id,
          date
      )
      ,aor_date_comparsion AS (
      -- Anchor: start with the first day
      SELECT
          salesperson_user_id,
          date,
          ttl_assets_on_rent as assets_on_rent,
          date AS start_date,
          ttl_assets_on_rent AS start_value
      FROM
          current_rep_assets_on_rent aor
      where
          ttl_assets_on_rent is not null
          AND salesperson_user_id is not null
      UNION ALL
      -- Recursive: check if the previous days value is larger
      SELECT
          dv.salesperson_user_id,
          dv.date,
          ttl_assets_on_rent as value,
          vc.start_date,
          vc.start_value
      FROM
          aor_date_comparsion vc
          JOIN rep_assets_on_rent dv ON dv.salesperson_user_id = vc.salesperson_user_id AND dv.date = vc.date - INTERVAL '1 day'
      WHERE
          dv.ttl_assets_on_rent > vc.assets_on_rent
      )
      , aor_rep_summary as (
      --Determine value decrease and days down
      SELECT
          *,
          datediff('days',date,start_date) as days_down,
          (assets_on_rent - start_value) as aor_diff
      FROM
          aor_date_comparsion
      )
      , aor_rep_insights_summary as (
      --Pull all metrics together
      select
          salesperson_user_id,
          start_value as todays_value,
          max(days_down) as total_days_down,
          max(aor_diff) as total_units_down_in_those_days,
          max(assets_on_rent) as assets_on_rent_high_value,
          ((todays_value - assets_on_rent_high_value) / assets_on_rent_high_value) * 100 as percent_change
      from
          aor_rep_summary
      group by
          salesperson_user_id,
          start_value
      having
          max(aor_diff) > 0
      )
      , rep_month_duration as (
      --Determine months as a TAM
      select
      user_id,
      ROUND(months_between(current_date, first_date_as_tam ), 0) as months_as_TAM
      from analytics.bi_ops.salesperson_info
      where record_ineffective_date IS NULL and employee_title_dated IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager')
      )
      --Combine all data from day and month then use metric flag to split/show data
      --Qualifers are purely from Michael B looking at the data in the insights summary CTEs to determine what are the thresholds
      select
          'assets_on_rent' as metric,
          salesperson_user_id,
          ua.rep,
          ua.employee_location,
          ua.district,
          ua.manager_name,
          rmd.months_as_TAM,
          total_days_down,
          round(total_units_down_in_those_days,0) as total_units_down_in_those_days,
          round(todays_value,0) as todays_value,
          round(assets_on_rent_high_value,0) as assets_on_rent_high_value,
          round(percent_change,1) as percent_change
      from
          aor_rep_insights_summary aor
          join user_access ua on ua.employee_user_id = aor.salesperson_user_id
          left join rep_month_duration rmd on rmd.user_id = aor.salesperson_user_id
      where
          (total_days_down >= 2 AND percent_change <= -10)
          OR (total_days_down <= 2 AND percent_change <= -50 AND assets_on_rent_high_value > 2)
          OR (total_days_down = 1 AND percent_change <= -20 AND assets_on_rent_high_value > 10)
      UNION
      select
          'avg_assets_on_rent' as metric,
          salesperson_user_id,
          ua.rep,
          ua.employee_location,
          ua.district,
          ua.manager_name,
          rmd.months_as_TAM,
          total_months_down,
          round(total_units_down_in_those_months,0) as total_units_down_in_those_months,
          round(todays_value,0) as todays_value,
          round(avg_assets_on_rent_high_value,0) as avg_assets_on_rent_high_value,
          round(percent_change,1) as percent_change
      from
          avg_aor_rep_insights_summary aor
          join user_access ua on ua.employee_user_id = aor.salesperson_user_id
          left join rep_month_duration rmd on rmd.user_id = aor.salesperson_user_id
      where
          (total_months_down >= 3 AND percent_change <= -10)
          OR (total_months_down <= 2 AND percent_change <= -10 AND avg_assets_on_rent_high_value >= 5 AND total_units_down_in_those_months >= 5) ;;
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

  dimension: total_units_down_in_those_days {
    type: number
    sql: ${TABLE}."TOTAL_UNITS_DOWN_IN_THOSE_DAYS" ;;
  }

  dimension: todays_value {
    type: number
    sql: ${TABLE}."TODAYS_VALUE" ;;
  }

  dimension: assets_on_rent_high_value {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT_HIGH_VALUE" ;;
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

  measure: current_value_avg_aor {
    group_label: "Avg AOR"
    label: "Current Value"
    type: max
    sql: ${todays_value} ;;
    filters: [metric: "avg_assets_on_rent"]
  }

  measure: current_value_daily_aor {
    group_label: "Daily AOR"
    label: "Current Value"
    type: max
    sql: ${todays_value} ;;
    filters: [metric: "assets_on_rent"]
  }

  measure: percent_change_avg_aor {
    group_label: "Avg AOR"
    label: "Percent Change"
    type: max
    sql: ${percent_change} ;;
    filters: [metric: "avg_assets_on_rent"]
    html: {{rendered_value}}% ;;
  }

  measure: percent_change_daily_aor {
    group_label: "Daily AOR"
    label: "Percent Change"
    type: max
    sql: ${percent_change} ;;
    filters: [metric: "assets_on_rent"]
    html: {{rendered_value}}% ;;
  }

  measure: starting_value_avg_aor {
    group_label: "Avg AOR"
    label: "Last Peak"
    type: max
    sql: ${assets_on_rent_high_value} ;;
    filters: [metric: "avg_assets_on_rent"]
  }

  measure: starting_value_daily_aor {
    group_label: "Daily AOR"
    label: "Last Peak"
    type: max
    sql: ${assets_on_rent_high_value} ;;
    filters: [metric: "assets_on_rent"]
  }

  measure: total_months_down_avg_aor {
    group_label: "Avg AOR"
    label: "Months Down"
    type: max
    sql: ${total_days_down} ;;
    filters: [metric: "avg_assets_on_rent"]
    html: {{rendered_value}} ;;
  }

  measure: total_months_down_daily_aor {
    group_label: "Daily AOR"
    label: "Days Down"
    type: max
    sql: ${total_days_down} ;;
    filters: [metric: "assets_on_rent"]
    html: {{rendered_value}} ;;
  }

  measure: value_difference_avg_aor {
    group_label: "Avg AOR"
    label: "Value Change"
    type: max
    sql: ${total_units_down_in_those_days}*-1 ;;
    filters: [metric: "avg_assets_on_rent"]
    html: <font color="#DA344D"><b>{{rendered_value}}</b></font> ;;
  }

  measure: value_difference_daily_aor {
    group_label: "Daily AOR"
    label: "Value Change"
    type: max
    sql: ${total_units_down_in_those_days}*-1 ;;
    filters: [metric: "assets_on_rent"]
    html: <font color="#DA344D"><b>{{rendered_value}}</b></font> ;;
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

  dimension: average_assets_on_rent {
    group_label: "DSM Version"
    label: "Average Monthly Assets on Rent"
    type: string
    sql: ${rep} ;;
    html:
    TAM: <b>{{ rep._rendered_value}}</b><br />
    Decrease Timeframe: <b>{{ total_days_down._rendered_value }} months</b><br />
    Percent Change: <font color="#DA344D"><b>{{ percent_change._rendered_value }}%</b></font><br />
    Current Value: <b>{{ todays_value._rendered_value }}</b><br />
    Value Before Decrease: <b>{{ assets_on_rent_high_value._rendered_value }}</b><br />
    Total Assets On Rent Lost: <b><font color="#DA344D">{{ total_units_down_in_those_days._rendered_value }}</font></b><br />
    <font color="#0063f3"><u><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{ rep_home_market._filterable_value }}" target="_blank">View Performance Dashboard ➔</a></font></u>
    ;;
  }

  dimension: average_assets_on_rent_regional_manager {
    group_label: "RM Version"
    label: "Average Monthly Assets On Rent"
    type: string
    sql: ${rep} ;;
    html:
    TAM: <b>{{ rep._rendered_value}}</b><br />
    Decrease Timeframe: <b>{{ total_days_down._rendered_value }} months</b><br />
    Percent Change: <font color="#DA344D"><b>{{ percent_change._rendered_value }}%</b></font><br />
    Current Value: <b>{{ todays_value._rendered_value }}</b><br />
    Value Before Decrease: <b>{{ assets_on_rent_high_value._rendered_value }}</b><br />
    Total Assets On Rent Lost: <b><font color="#DA344D">{{ total_units_down_in_those_days._rendered_value }}</font></b><br />
    Direct Manager: <b>{{ manager_name._rendered_value }}</b><br />
    <font color="#0063f3"><u><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{ rep_home_market._filterable_value }}" target="_blank">View Performance Dashboard ➔</a></font></u>
    ;;
  }

  dimension: daily_assets_on_rent {
    group_label: "DSM Version"
    label: "Daily Assets on Rent"
    type: string
    sql: ${rep} ;;
    html:
    TAM: <b>{{ rep._rendered_value}}</b><br />
    Decrease Timeframe: <b>{{ total_days_down._rendered_value }} days in a row</b><br />
    Percent Change: <font color="#DA344D"><b>{{ percent_change._rendered_value }}%</b></font><br />
    Current Value: <b>{{ todays_value._rendered_value }}</b><br />
    Value Before Decrease: <b>{{ assets_on_rent_high_value._rendered_value }}\</b><br />
    Total Assets On Rent Lost: <b><font color="#DA344D">{{ total_units_down_in_those_days._rendered_value }}</font></b><br />
    <font color="#0063f3"><u><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{ rep_home_market._filterable_value }}" target="_blank">View Performance Dashboard ➔</a></font></u>
    ;;
  }

  dimension: daily_assets_on_rent_regional_manager {
    group_label: "RM Version"
    label: "Daily Assets On Rent"
    type: string
    sql: ${rep} ;;
    html:
    TAM: <b>{{ rep._rendered_value}}</b><br />
    Decrease Timeframe: <b>{{ total_days_down._rendered_value }} days in a row</b><br />
    Percent Change: <font color="#DA344D"><b>{{ percent_change._rendered_value }}%</b></font><br />
    Current Value: <b>{{ todays_value._rendered_value }}</b><br />
    Value Before Decrease: <b>{{ assets_on_rent_high_value._rendered_value }}</b><br />
    Total Assets On Rent Lost: <b><font color="#DA344D">{{ total_units_down_in_those_days._rendered_value }}</font></b><br />
    Direct Manager: <b>{{ manager_name._rendered_value }}</b><br />
    <font color="#0063f3"><u><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{ rep_home_market._filterable_value }}" target="_blank">View Performance Dashboard ➔</a></font></u>
    ;;
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
  total_units_down_in_those_days,
  todays_value,
  assets_on_rent_high_value,
  percent_change
    ]
  }
}
