view: company_and_user_sessions {
  derived_table: {
    sql: with top_users_by_company as (
      select
          u.company_name,
          u.user_name,
          count(*) as total_sessions
      from
          heap_t3_platform_production.heap.users u
          {% if application._parameter_value == "'Analytics'" %}
        join heap_t3_platform_production.heap.ANALYTICS_BROWSER_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'CostCapture'" %}
        join heap_t3_platform_production.heap.costcapture_browser_load_app s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'E-logs Browser'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'E-logs Mobile'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Fleet'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_BROWSER_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Fleet Mobile'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Inventory'" %}
        join heap_t3_platform_production.heap.inventory_browser_load_app s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Link App'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Rent App'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTAPP_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'RentOps'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTOPS_BROWSER_LOAD_APP s on s.user_id = u.user_id
        {% elsif application._parameter_value == "'Time Tracking'" %}
        join heap_t3_platform_production.heap.time_tracking_browser_load_app s on s.user_id = u.user_id
        {% else %}
        join heap_t3_platform_production.heap.ANALYTICS_BROWSER_LOAD_APP s on s.user_id = u.user_id
        {%  endif %}
      where
          {% if application._parameter_value == "'Analytics'" %}
          _app_name = 'Analytics'
          {% else %}
          (app_name is null or app_name is not null)
          {%  endif %}
          AND u.mimic_user = 'No'
          {% if timeframe._parameter_value == "'7 Days'" %}
          AND time >= dateadd(days,-7,current_date)
          {% elsif timeframe._parameter_value == "'14 Days'" %}
          AND time >= dateadd(days,-14,current_date)
          {% elsif timeframe._parameter_value == "'30 Days'" %}
          AND time >= dateadd(days,-30,current_date)
          {% elsif timeframe._parameter_value == "'60 Days'" %}
          AND time >= dateadd(days,-60,current_date)
          {% elsif timeframe._parameter_value == "'90 Days'" %}
          AND time >= dateadd(days,-90,current_date)
          {% else %}
          AND time >= dateadd(days,-90,current_date)
          {%  endif %}
          --AND time >= dateadd(days,-90,current_date)
          AND u.company_id not in ('1854','6302','420')
      group by
          u.company_name,
          u.user_name
      )
      , comparsion_usage as (
      select
          u.company_name,
          u.user_name,
          count(*) as total_sessions
      from
          heap_t3_platform_production.heap.users u
          {% if application._parameter_value == "'Analytics'" %}
          join heap_t3_platform_production.heap.ANALYTICS_BROWSER_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'CostCapture'" %}
          join heap_t3_platform_production.heap.costcapture_browser_load_app s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'E-logs Browser'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'E-logs Mobile'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Fleet'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_BROWSER_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Fleet Mobile'" %}
        join HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Inventory'" %}
          join heap_t3_platform_production.heap.inventory_browser_load_app s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Link App'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Rent App'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTAPP_MOBILE_APP_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'RentOps'" %}
          join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTOPS_BROWSER_LOAD_APP s on s.user_id = u.user_id
          {% elsif application._parameter_value == "'Time Tracking'" %}
          join heap_t3_platform_production.heap.time_tracking_browser_load_app s on s.user_id = u.user_id
          {% else %}
          join heap_t3_platform_production.heap.ANALYTICS_BROWSER_LOAD_APP s on s.user_id = u.user_id
          {%  endif %}
      where
          {% if application._parameter_value == "'Analytics'" %}
          _app_name = 'Analytics'
          {% else %}
          (app_name is null or app_name is not null)
          {%  endif %}
          AND u.mimic_user = 'No'
          --AND time BETWEEN dateadd(days,-180,current_date) AND dateadd(days,-91,current_date)
          AND u.company_id not in ('1854','6302','420')
          {% if timeframe._parameter_value == "'7 Days'" %}
          AND time BETWEEN dateadd(days,-14,current_date) AND dateadd(days,-8,current_date)
          {% elsif timeframe._parameter_value == "'14 Days'" %}
          AND time BETWEEN dateadd(days,-30,current_date) AND dateadd(days,-15,current_date)
          {% elsif timeframe._parameter_value == "'30 Days'" %}
          AND time BETWEEN dateadd(days,-90,current_date) AND dateadd(days,-31,current_date)
          {% elsif timeframe._parameter_value == "'60 Days'" %}
          AND time BETWEEN dateadd(days,-120,current_date) AND dateadd(days,-61,current_date)
          {% elsif timeframe._parameter_value == "'90 Days'" %}
          AND time BETWEEN dateadd(days,-180,current_date) AND dateadd(days,-91,current_date)
          {% else %}
          AND time BETWEEN dateadd(days,-180,current_date) AND dateadd(days,-91,current_date)
          {%  endif %}
      group by
          u.company_name,
          u.user_name
      )
      select
          c.company_name,
          c.user_name,
          c.total_sessions as last_90_sessions,
          coalesce(cu.total_sessions,0) as previous_90_day_sessions,
          (last_90_sessions - previous_90_day_sessions) as sessions_delta
      from
          top_users_by_company c
          left join comparsion_usage cu on c.company_name = cu.company_name AND c.user_name = cu.user_name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: last_90_sessions {
    type: number
    sql: ${TABLE}."LAST_90_SESSIONS" ;;
  }

  dimension: previous_90_day_sessions {
    type: number
    sql: ${TABLE}."PREVIOUS_90_DAY_SESSIONS" ;;
  }

  dimension: sessions_delta {
    type: number
    sql: ${TABLE}."SESSIONS_DELTA" ;;
  }

  measure: total_sessions_last_90_days {
    label: "Total App Loads Last 90 Days"
    type: sum
    sql: ${last_90_sessions} ;;
  }

  measure: total_sessions_previous_90_days {
    label: "Total App Loads Previous 90 Days"
    type: sum
    sql: ${previous_90_day_sessions} ;;
  }

  parameter: application {
    type: string
    allowed_value: { value: "Analytics"}
    allowed_value: { value: "CostCapture"}
    allowed_value: { value: "E-logs Browser"}
    allowed_value: { value: "E-logs Mobile"}
    allowed_value: { value: "Fleet"}
    allowed_value: { value: "Fleet Mobile"}
    allowed_value: { value: "Inventory"}
    allowed_value: { value: "Link App"}
    allowed_value: { value: "Rent App"}
    allowed_value: { value: "RentOps"}
    allowed_value: { value: "Time Tracking"}
  }

  parameter: view_by {
    type: string
    allowed_value: { value: "Company"}
    allowed_value: { value: "User"}
  }

  parameter: timeframe {
    type: string
    allowed_value: { value: "7 Days"}
    allowed_value: { value: "14 Days"}
    allowed_value: { value: "30 Days"}
    allowed_value: { value: "60 Days"}
    allowed_value: { value: "90 Days"}
  }

  measure: total_users {
    type: count
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  measure: top_companies_by_user_last_90_days {
    type: count_distinct
    sql: ${user_name} ;;
  }

  measure: session_comparsion {
    label: "App Load Comparsion"
    type: number
    sql: ${total_sessions_last_90_days} - ${total_sessions_previous_90_days} ;;
    html:
    {% if value > 0 %}
      <font color="#00CB86">▴ {{ rendered_value }}</font>
    {% elsif value < 0 %}
      <font color="#DA344D">▾ {{ rendered_value }}</font>
    {% else %}
      <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: view_company_detail {
    group_label: "Formatted Company Name"
    label: "Company Name"
    type: string
    sql: ${company_name} ;;
    drill_fields: [company_detail*]
  }

  dimension: dynamic_view_by_selection {
    label_from_parameter: view_by
    sql:{% if view_by._parameter_value == "'Company'" %}
      ${company_name}
    {% elsif view_by._parameter_value == "'User'" %}
      concat(${user_name},' - ',${company_name})
    {% else %}
      NULL
    {% endif %} ;;
  }

  set: detail {
    fields: [company_name, user_name, total_sessions_last_90_days, total_sessions_previous_90_days, session_comparsion]
  }

  set: company_detail {
    fields: [company_name, new_companies_current_week.first_visit_date, company_information.rental_revenue, company_information.current_rentals,company_information.total_owned_assets]
  }
}
