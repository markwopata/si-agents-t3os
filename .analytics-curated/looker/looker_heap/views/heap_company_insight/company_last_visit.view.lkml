view: company_last_visit {
  derived_table: {
    sql: with last_company_visit as (
        select
            --u.company_name,
            {% if view_by._parameter_value == "'Company'" %}
            u.company_name as name,
            {% else %}
            u.user_name as name,
            {%  endif %}
            u.company_id,
            max(s.time) as last_visit
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
          AND u.company_id not in ('1854','6302','420')
        group by
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name,
          {% else %}
          u.user_name,
          {%  endif %}
          u.company_id
        )
        , total_previous_visits as (
        select
            --u.company_name,
            {% if view_by._parameter_value == "'Company'" %}
            u.company_name as name,
            {% else %}
            u.user_name as name,
            {%  endif %}
            u.company_id,
            count(s.time) as total_visits_last_sixty_to_one_hundred_twenty_days
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
          AND u.company_id not in ('1854','6302','420')
          AND s.time BETWEEN dateadd(days,-120,current_date)::timestamp AND dateadd(days,-60,current_date)::timestamp
        group by
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name,
          {% else %}
          u.user_name,
          {%  endif %}
          u.company_id
        )
        , visits_last_forty_five_to_sixty_days as (
        select
            --u.company_name,
            {% if view_by._parameter_value == "'Company'" %}
            u.company_name as name,
            {% else %}
            u.user_name as name,
            {%  endif %}
            u.company_id,
            count(s.time) as total_visits_last_forty_five_to_sixty_days
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
          AND u.company_id not in ('1854','6302','420')
          AND s.time BETWEEN dateadd(days,-60,current_date)::timestamp AND dateadd(days,-45,current_date)::timestamp
        group by
          {% if view_by._parameter_value == "'Company'" %}
          u.company_name,
          {% else %}
          u.user_name,
          {%  endif %}
          u.company_id
        )
        , total_own_assets as (
      select
        cv.company_id,
        count(*) as total_owned_assets
      from
        last_company_visit cv
        left join es_warehouse.public.assets a on a.company_id = cv.company_id
      group by
        cv.company_id
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
          join last_company_visit cv on cv.company_id = c.company_id
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
          join last_company_visit cv on cv.company_id = c.company_id
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
          cv.name,
          cv.last_visit,
          coalesce(total_owned_assets,0) as total_owned_assets,
          coalesce(rr.rental_revenue,0) as rental_revenue,
          coalesce(cr.current_rentals,0) as current_rentals,
          coalesce(total_visits_last_sixty_to_one_hundred_twenty_days,0) as total_visits_last_sixty_to_one_hundred_twenty_days,
          coalesce(total_visits_last_forty_five_to_sixty_days,0) as total_visits_last_forty_five_to_sixty_days
      from
          last_company_visit cv
          left join total_own_assets toa on toa.company_id = cv.company_id
          left join rental_rev rr on rr.company_id = cv.company_id
          left join current_rentals cr on cr.company_id = cv.company_id
          left join total_previous_visits tpv on tpv.name = cv.name
          left join visits_last_forty_five_to_sixty_days  vfs on vfs.name = cv.name
      where
          last_visit BETWEEN dateadd(days,-60,current_date) AND dateadd(days,-45,current_date)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: last_visit {
    type: time
    sql: ${TABLE}."LAST_VISIT" ;;
    convert_tz: no
  }

  dimension: total_owned_assets {
    type: number
    sql: ${TABLE}."TOTAL_OWNED_ASSETS" ;;
    html: {{rendered_value}} assets ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    value_format_name: usd
  }

  dimension: current_rentals {
    type: number
    sql: ${TABLE}."CURRENT_RENTALS" ;;
    html: {{rendered_value}} rentals ;;
  }

  dimension: total_visits_last_sixty_to_one_hundred_twenty_days {
    type: number
    sql: ${TABLE}."TOTAL_VISITS_LAST_SIXTY_TO_ONE_HUNDRED_TWENTY_DAYS" ;;
  }

  dimension: total_visits_last_forty_five_to_sixty_days {
    type: number
    sql: ${TABLE}."TOTAL_VISITS_LAST_FORTY_FIVE_TO_SIXTY_DAYS" ;;
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

  dimension: last_visit_formatted {
    group_label: "HTML Formatted Time"
    label: "Last Visit Date"
    type: date
    sql: ${last_visit_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: last_visit_week_formatted {
    group_label: "HTML Formatted Time"
    label: "Last Visit Week"
    type: date
    sql: ${last_visit_week} ;;
    html: {{ rendered_value | date: "Week %U (%b %d)" }};;
  }

  dimension: has_current_rentals {
    type: string
    sql: case when ${current_rentals} > 0 then 'Has Active Rentals' else 'No Active Rentals' end;;
  }

  dimension: has_owned_assets {
    type: string
    sql: case when ${total_owned_assets} > 0 then 'Has Owned Assets' else 'No Owned Assets' end ;;
  }

  measure: total_visits_last_60_120_days {
    label: "Total Visits Last 60-120 Days"
    type: sum
    sql: ${total_visits_last_sixty_to_one_hundred_twenty_days} ;;
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  measure: total_visits_last_45_60_days {
    label: "Total Visits Last 45-60 Days"
    type: sum
    sql: ${total_visits_last_forty_five_to_sixty_days} ;;
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }


  set: detail {
    fields: [name, total_owned_assets, current_rentals, rental_revenue ,last_visit_formatted]
  }
}
