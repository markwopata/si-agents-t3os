view: visit_history_with_company_info {
  derived_table: {
    sql: with first_app_visit as (
      select
          --u.company_name as name,
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name as name,
          {% else %}
          concat(u.user_name,' - ',u.company_name) as name,
          {%  endif %}
          u.company_id,
          min(s.time)::date as first_visit
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
        AND u.company_id not in ('1854','6302','420','16184') --ES, Equipt, Demo, T3 Test Acct
      group by
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name,
          {% else %}
          concat(u.user_name,' - ',u.company_name),
          {%  endif %}
          u.company_id
      )
      , existing_visit as (
      select
          --u.company_name as name,
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name as name,
          {% else %}
          concat(u.user_name,' - ',u.company_name) as name,
          {%  endif %}
          u.company_id,
          s.time::date as visit_date,
          fv.first_visit,
          case when fv.first_visit = visit_date then 1 else 0 end as new_visit_flag
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
          left join first_app_visit fv on fv.name = u.company_name
      where
          {% if application._parameter_value == "'Analytics'" %}
          _app_name = 'Analytics'
          {% else %}
          (app_name is null or app_name is not null)
          {%  endif %}
          AND u.mimic_user = 'No'
          AND u.company_id not in ('1854','6302','420','16184')
          AND s.time >= dateadd(days,-89,current_date)::timestamp_tz
      )
      , date_series as (
        select
        series::date as day
        from table
        (generate_series(
          dateadd(days,-89,current_date)::timestamp_tz,
          current_date::timestamp_tz,
          'day'))
      )
      , total_own_assets as (
      select
          fv.company_id,
          count(*) as total_owned_assets
      from
          first_app_visit fv
          left join es_warehouse.public.assets a on a.company_id = fv.company_id
      group by
          fv.company_id
      )
      , rental_rev as (
      select
          c.company_id,
          sum(li.amount) as rental_revenue
      from
          ES_WAREHOUSE.PUBLIC.orders o
          join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
          join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
          join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
          join first_app_visit fv on fv.company_id = c.company_id
      where
          li.line_item_type_id in (6,8,108,109)
          AND li.gl_date_created::date >= dateadd(days,-90,current_date)
      group by
          c.company_id
      )
      , current_rentals as (
      select
          c.company_id,
          count(*) as current_rentals
      from
          es_warehouse.public.rentals r
          left join es_warehouse.public.equipment_assignments ea on r.rental_id = ea.rental_id
          left join es_warehouse.public.orders o on r.order_id = o.order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          join first_app_visit fv on fv.company_id = c.company_id
      where
          (
          (r.rental_status_id = 5 AND (ea.end_date >= current_timestamp() or ea.end_date is null))
          OR (ea.end_date >= current_timestamp AND ea.start_date <= current_timestamp)
          OR r.rental_status_id = 5 AND r.asset_id is null
          )
      group by
          c.company_id
      )
      select
          ds.day,
          ev.name,
          ev.company_id,
          ev.visit_date,
          ev.first_visit,
          case when week(ev.first_visit) = week(current_date) then 1 else 0 end as current_week,
          case when week(ev.first_visit) = week(dateadd(week,-1,current_date)) then 1 else 0 end as previous_week,
          ev.new_visit_flag,
          coalesce(total_owned_assets,0) as total_owned_assets,
          coalesce(rr.rental_revenue,0) as rental_revenue,
          coalesce(cr.current_rentals,0) as current_rentals
      from
          date_series ds
          join existing_visit ev on ev.visit_date = ds.day
          left join total_own_assets toa on toa.company_id = ev.company_id
          left join rental_rev rr on rr.company_id = ev.company_id
          left join current_rentals cr on cr.company_id = ev.company_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: visit_date {
    type: time
    sql: ${TABLE}."VISIT_DATE" ;;
    convert_tz: no
  }

  dimension: first_visit {
    type: date
    sql: ${TABLE}."FIRST_VISIT" ;;
    convert_tz: no
  }

  dimension: current_week {
    type: number
    sql: ${TABLE}."CURRENT_WEEK" ;;
  }

  dimension: previous_week {
    type: number
    sql: ${TABLE}."PREVIOUS_WEEK" ;;
  }

  dimension: new_visit_flag {
    type: number
    sql: ${TABLE}."NEW_VISIT_FLAG" ;;
  }

  dimension: total_owned_assets {
    type: number
    sql: ${TABLE}."TOTAL_OWNED_ASSETS" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    value_format_name: usd
  }

  dimension: current_rentals {
    type: number
    sql: ${TABLE}."CURRENT_RENTALS" ;;
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

  measure: total_new_current_week {
    type: sum_distinct
    sql_distinct_key: ${name} ;;
    sql: ${current_week} ;;
    filters: [current_week: ">= 1"]
    drill_fields: [detail*]
  }

  measure: total_new_previous_week {
    type: sum_distinct
    sql_distinct_key: ${name} ;;
    sql: ${previous_week} ;;
    filters: [previous_week: ">= 1"]
    drill_fields: [detail*]
  }

  measure: total_exisiting {
    type: number
    sql: ${total_visits} - ${total_new} ;;
  }

  measure: total_new {
    type: count_distinct
    sql: ${name} ;;
    filters: [new_visit_flag: "1"]
  }

  measure: total_visits {
    type: count_distinct
    sql: ${name} ;;
  }

  dimension: first_visit_date_formatted {
    group_label: "HTML Formatted"
    label: "First Visit Date"
    type: date
    sql: ${first_visit} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: visit_date_formatted {
    group_label: "HTML Formatted"
    label: "Visit Date"
    type: date
    sql: ${visit_date_week} ;;
    html: {{ rendered_value | date: "Week %U (%b %d)" }};;
  }

  set: detail {
    fields: [
      name,
      company_id,
      first_visit_date_formatted,
      total_owned_assets,
      rental_revenue,
      current_rentals
    ]
  }
}
