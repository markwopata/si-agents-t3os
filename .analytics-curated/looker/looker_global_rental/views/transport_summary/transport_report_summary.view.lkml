view: transport_report_summary {
  derived_table: {
    sql: select
          d.delivery_id as transport_id,
          d.order_id,
          d.rental_id,
          d.asset_id,
          po.name as purchase_order,
          c2.name as customer,
          dft.name as transport_facilitator,
          concat(u.first_name, ' ', u.last_name, ' - ', c.name) as assigned_driver_company,
          c.name as transport_provider,
          dst.name as transport_status,
          d.charge as price,
          concat_ws(', ', coalesce(l.street_1,' '), coalesce(l.city,' '), coalesce(st.abbreviation, ' ')) || ' ' || coalesce(l.zip_code, 0) as deliver_to_address,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) as scheduled_date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',d.completed_date) as completed_date,
          rst.name as rental_status,
          j.name as job_code,
          pc.name as phase_code,
          a.custom_name as asset,
          dt.name as transport_type,
          d.run_name as run,
          a.asset_class,
          m.name as branch,
          concat_ws(', ', coalesce(ol.street_1,' '), coalesce(ol.city,' '), coalesce(st2.abbreviation,' ')) || ' ' || coalesce(ol.zip_code, 0) as origin
      from
          ES_WAREHOUSE.public.deliveries d
          left join ES_WAREHOUSE.public.delivery_facilitator_types dft on d.facilitator_type_id = dft.delivery_facilitator_type_id
          left join ES_WAREHOUSE.public.delivery_statuses dst on d.delivery_status_id = dst.delivery_status_id
          left join ES_WAREHOUSE.public.locations l on d.location_id = l.location_id
          left join ES_WAREHOUSE.public.states st on l.state_id = st.state_id
          left join ES_WAREHOUSE.public.users u on d.driver_user_id = u.user_id
          left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
          left join ES_WAREHOUSE.public.orders o on d.order_id = o.order_id
          left join ES_WAREHOUSE.public.purchase_orders po on o.purchase_order_id = po.purchase_order_id
          left join ES_WAREHOUSE.public.jobs j on j.job_id = o.job_id
          left join ES_WAREHOUSE.public.jobs pc on j.job_id = pc.parent_job_id
          left join ES_WAREHOUSE.public.users u2 on o.user_id = u2.user_id
          left join ES_WAREHOUSE.public.companies c2 on u2.company_id = c2.company_id
          left join ES_WAREHOUSE.public.markets m on o.market_id = m.market_id
          left join es_warehouse.public.rentals r on d.rental_id = r.rental_id
          left join ES_WAREHOUSE.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
          left join ES_WAREHOUSE.public.assets a on a.asset_id = d.asset_id
          left join ES_WAREHOUSE.public.delivery_types dt on dt.delivery_type_id = d.delivery_type_id
          left join ES_WAREHOUSE.public.locations ol on d.origin_location_id = ol.location_id
          left join ES_WAREHOUSE.public.states st2 on l.state_id = st2.state_id
      where
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND {% condition order_id_filter %} d.order_id {% endcondition %}
          AND {% condition rental_id_filter %} d.rental_id {% endcondition %}
          AND {% condition transport_id_filter %} d.delivery_id {% endcondition %}
          AND {% condition rental_status_filter %} rst.name {% endcondition %}
          AND {% condition customer_filter %} c2.name {% endcondition %}
          AND {% condition facilitator_filter %} dft.name {% endcondition %}
          AND {% condition job_code_filter %} j.name {% endcondition %}
          AND {% condition phase_code_filter %} pc.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND
          {% if view._parameter_value == "'Outstanding Deliveries'" %}
          d.completed_date is null
          {% elsif view._parameter_value == "'Completed Deliveries'" %}
          d.completed_date is not null
          {% else %}
          --d.completed_date is null or d.completed_date is not null AND
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND (CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',d.scheduled_date)::timestamp_ntz BETWEEN coalesce({% date_start date_filter %},'2000-01-01') AND coalesce({% date_end date_filter %},'2999-12-31')
          OR CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',d.completed_date)::timestamp_ntz BETWEEN coalesce({% date_start date_filter %},'2000-01-01') AND coalesce({% date_end date_filter %},'2999-12-31'))
          {% endif %}
          AND
          {% if filter_on_date._parameter_value == "'Scheduled Date'" %}
          CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',d.scheduled_date)::timestamp_ntz BETWEEN coalesce({% date_start date_filter %},'2000-01-01') AND coalesce({% date_end date_filter %},'2999-12-31')
          {% else %}
          CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',d.completed_date)::timestamp_ntz BETWEEN coalesce({% date_start date_filter %},'2000-01-01') AND coalesce({% date_end date_filter %},'2999-12-31')
          {% endif %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: transport_id {
    type: string
    sql: ${TABLE}."TRANSPORT_ID" ;;
    value_format_name: id
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
    html: <font color="#0063f3"><u><a href="https://manage.estrack.io/rentops/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
    value_format_name: id
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
    html: <font color="#0063f3"><u><a href="https://manage.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
    value_format_name: id
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: transport_facilitator {
    label: "Facilitator"
    type: string
    sql: ${TABLE}."TRANSPORT_FACILITATOR" ;;
  }

  dimension: assigned_driver_company {
    label: "Driver/Company"
    type: string
    sql: ${TABLE}."ASSIGNED_DRIVER_COMPANY" ;;
  }

  dimension: transport_provider {
    type: string
    sql: ${TABLE}."TRANSPORT_PROVIDER" ;;
  }

  dimension: transport_status {
    type: string
    sql: ${TABLE}."TRANSPORT_STATUS" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
    value_format_name: usd
  }

  dimension: deliver_to_address {
    label: "Delivery Location"
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS" ;;
  }

  dimension_group: scheduled_date {
    type: time
    sql: ${TABLE}."SCHEDULED_DATE" ;;
  }

  dimension_group: completed_date {
    type: time
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: job_code {
    type: string
    sql: ${TABLE}."JOB_CODE" ;;
  }

  dimension: phase_code {
    type: string
    sql: ${TABLE}."PHASE_CODE" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: transport_type {
    type: string
    sql: ${TABLE}."TRANSPORT_TYPE" ;;
  }

  dimension: run {
    type: string
    sql: ${TABLE}."RUN" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: origin {
    type: string
    sql: ${TABLE}."ORIGIN" ;;
  }

  dimension: scheduled_date_formatted {
    group_label: "HTML Passed Date Format"
    label: "Scheduled Date"
    type: date_time
    sql: ${scheduled_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: completed_date_formatted {
    group_label: "HTML Passed Date Format"
    label: "Completed Date"
    type: date_time
    sql: ${completed_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  parameter: view {
    type: string
    allowed_value: { value: "All Deliveries" }
    allowed_value: { value: "Outstanding Deliveries"}
    allowed_value: { value: "Completed Deliveries"}
  }

  parameter: filter_on_date {
    type: string
    allowed_value: { value: "Scheduled Date" }
    allowed_value: { value: "Completed Date"}
  }

  parameter: schedule_delivery_time_frame {
    type: string
    allowed_value: { value: "Current Month" }
    allowed_value: { value: "Next Month" }
    allowed_value: { value: "Next 3 Months"}
    allowed_value: { value: "Last Month" }
    allowed_value: { value: "Last 3 Months"}
    allowed_value: { value: "Last 6 Months"}
    allowed_value: { value: "Last 9 Months"}
    allowed_value: { value: "Last 12 Months"}
    allowed_value: { value: "All Time" }
  }

  filter: date_filter {
    type: date_time
  }

  filter: order_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: rental_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: transport_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: rental_status_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: customer_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: facilitator_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: job_code_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: phase_code_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: branch_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  # {% if schedule_delivery_time_frame._parameter_value == "'Current Month'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',current_date()) AND last_day(current_timestamp())
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Next Month'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',1,current_date())) AND last_day(dateadd('month',1,current_date()))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Next 3 Months'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',1,current_date())) AND last_day(dateadd('month',3,current_date()))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Last Month'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',-1,current_date())) AND last_day(dateadd('month',-1,current_date()))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Last 3 Months'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',-1,current_date())) AND DATE_TRUNC('month',(dateadd('month',-3,current_date())))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Last 6 Months'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',-1,current_date())) AND DATE_TRUNC('month',(dateadd('month',-6,current_date())))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Last 9 Months'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',-1,current_date())) AND DATE_TRUNC('month',(dateadd('month',-9,current_date())))
  #         {% elsif schedule_delivery_time_frame._parameter_value == "'Last 12 Months'" %}
  #         convert_timezone('{{ _user_attributes['user_timezone'] }}',d.scheduled_date) BETWEEN DATE_TRUNC('month',dateadd('month',-1,current_date())) AND DATE_TRUNC('month',(dateadd('month',-12,current_date())))
  #         {% else %}
  #         d.completed_date >= current_timestamp OR d.completed_date <= current_timestamp
  #         {% endif %}

  set: detail {
    fields: [
      transport_id,
      order_id,
      rental_id,
      asset_id,
      purchase_order,
      customer,
      transport_facilitator,
      assigned_driver_company,
      transport_provider,
      transport_status,
      price,
      deliver_to_address,
      scheduled_date_time,
      completed_date_time,
      rental_status
    ]
  }
}
