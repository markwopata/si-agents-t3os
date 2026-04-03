view: company_information {
  derived_table: {
    sql: with first_company_visit as (
      select
          u.company_id,
          u.company_name,
          min(s.time) as first_visit
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
          u.mimic_user = 'No'
          AND u.company_id not in ('1854','6302','420')
          AND {% if application._parameter_value == "'Analytics'" %}
          _app_name = 'Analytics'
          {% else %}
          (app_name is null or app_name is not null)
          {%  endif %}
      group by
          u.company_id,
          u.company_name
      )
      , total_own_assets as (
      select
        cv.company_id,
        count(*) as total_owned_assets
      from
        first_company_visit cv
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
          join first_company_visit cv on cv.company_id = c.company_id
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
          join first_company_visit cv on cv.company_id = c.company_id
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
          cv.company_name,
          cv.first_visit as first_visit,
          coalesce(total_owned_assets,0) as total_owned_assets,
          coalesce(rr.rental_revenue,0) as rental_revenue,
          coalesce(cr.current_rentals,0) as current_rentals
      from
          first_company_visit cv
          left join total_own_assets toa on toa.company_id = cv.company_id
          left join rental_rev rr on rr.company_id = cv.company_id
          left join current_rentals cr on cr.company_id = cv.company_id
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

  dimension_group: first_visit {
    type: time
    sql: ${TABLE}."FIRST_VISIT" ;;
    convert_tz: no
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

  dimension: first_visit_date_formatted {
    group_label: "HTML Formatted Time"
    label: "First Date"
    type: date
    sql: ${first_visit_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
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

  dimension: has_current_rentals {
    group_label: "Active Rentals Tag"
    label: " "
    type: string
    sql: case when ${current_rentals} > 0 then 'Active Rentals' else 'No Active Rentals' end;;
    html:
    {% if value == 'Active Rentals' %}
      <p style="color: white; background-color: #3EBCD2; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% else %}
    {% endif %}
    ;;
  }

  dimension: has_owned_assets {
    group_label: "Owned Assets Tag"
    label: " "
    type: string
    sql: case when ${total_owned_assets} > 0 then 'Owned Assets' else 'No Owned Assets' end ;;
    html:
    {% if value == 'Owned Assets' %}
    <p style="color: white; background-color: #D3DAE6; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% else %}
    {% endif %}
    ;;
  }

  set: detail {
    fields: [company_name, first_visit_date]
  }
}
