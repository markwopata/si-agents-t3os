view: rental_history_by_date {
  derived_table: {
    sql:
    with asset_list_rental as (
    select asset_id, start_date, end_date, rental_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}'))
    --from table(rental_asset_list(33416::numeric, convert_timezone('America/Chicago', 'UTC', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz), convert_timezone('America/Chicago', 'UTC', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))::timestamp_ntz), 'America/Chicago'))
    )
    ,rental_info as (
    select
          r.rental_id,
          r.asset_id,
          convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.start_date::timestamp_ntz)::date as rental_start_date,
          convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.end_date::timestamp_ntz)::date as rental_end_date,
          --r.start_date::date as rental_start_date,
          --r.end_date::date as rental_end_date,
          po.name as po_name,
          l.nickname as jobsite,
          a.asset_class,
          r.price_per_day,
          r.price_per_week,
          r.price_per_month,
          o.order_id,
          concat(a.make,' ',a.model) as make_and_model,
          a.custom_name as custom_name,
          r.rental_status_id,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          s.name as jobsite_state,
          cm.name as vendor
      from
          asset_list_rental alr
          inner join rentals r on r.rental_id = alr.rental_id and r.asset_id = alr.asset_id
          left join orders o on r.order_id = o.order_id
          left join users u on u.user_id = o.user_id
          left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
          --left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= {% date_end date_filter %}::date AND rla.start_date >= {% date_start date_filter %}::date))
          left join (select r.rental_id, listagg(l.nickname, ', ') as nickname
                     from rentals r
                     left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= {% date_end date_filter %}::date AND rla.start_date >= {% date_start date_filter %}::date))
                     left join locations l on l.location_id = rla.location_id group by r.rental_id) l on l.rental_id = r.rental_id
          --left join locations l on l.location_id = rla.location_id
          left join assets a on a.asset_id = r.asset_id
          left join rental_location_assignments rla on rla.rental_id = r.rental_id
          left join locations dl on dl.location_id = rla.location_id and dl.company_id = {{ _user_attributes['company_id'] }}::integer
          left join states s on s.state_id = dl.state_id
          left join markets m on m.market_id = o.market_id
          left join companies cm on cm.company_id = m.company_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}
        and po.company_id = {{ _user_attributes['company_id'] }}
        --and l.company_id = {{ _user_attributes['company_id'] }}
        and r.deleted = false
      AND
      {% condition jobsite_state_filter %} jobsite_state {% endcondition %}
      AND
      {% condition jobsite_filter %} jobsite {% endcondition %}
      AND
      {% condition po_name_filter %} po_name {% endcondition %}
      AND
      {% condition vendor_filter %} cm.name {% endcondition %}
      union
      select
      r.rental_id,
      r.asset_id,
      convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.start_date::timestamp_ntz)::date as rental_start_date,
      convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', r.end_date::timestamp_ntz)::date as rental_end_date,
      --r.start_date::date as rental_start_date,
      --r.end_date::date as rental_end_date,
      po.name as po_name,
      l.nickname as jobsite,
      pt.description as asset_class,
      r.price_per_day,
      r.price_per_week,
      r.price_per_month,
      o.order_id,
      concat('Bulk Item - ',p.part_id) as make_and_model,
      'Bulk Item' as custom_name,
      r.rental_status_id,
      concat(u.first_name,' ',u.last_name) as ordered_by,
      s.name as jobsite_state,
      cm.name as vendor
      from
      rentals r
      join rental_part_assignments rpa on rpa.rental_id = r.rental_id
      join inventory.parts p on p.part_id = rpa.part_id
      left join inventory.part_types pt on pt.part_type_id = p.part_type_id
      left join orders o on r.order_id = o.order_id
      left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
      left join users u on u.user_id = o.user_id
      join companies c on c.company_id = u.company_id
      left join (select r.rental_id, listagg(l.nickname, ', ') as nickname
      from rentals r
      left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= {% date_end date_filter %}::date AND rla.start_date >= {% date_start date_filter %}::date))
      left join locations l on l.location_id = rla.location_id group by r.rental_id) l on l.rental_id = r.rental_id
      --left join rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date is null or (rla.end_date <= {% date_end date_filter %}::date AND rla.start_date >= {% date_start date_filter %}::date))
      --left join locations l on l.location_id = rla.location_id
      left join deliveries d on d.delivery_id = r.drop_off_delivery_id
      left join locations dl on dl.location_id = d.location_id and dl.company_id = {{ _user_attributes['company_id'] }}::integer
      left join states s on s.state_id = dl.state_id
      left join markets m on m.market_id = o.market_id
      left join companies cm on cm.company_id = m.company_id
      where
      u.company_id = {{ _user_attributes['company_id'] }}
      and po.company_id = {{ _user_attributes['company_id'] }}
      --and l.company_id = {{ _user_attributes['company_id'] }}
      and r.deleted = false
      AND
      {% condition jobsite_state_filter %} jobsite_state {% endcondition %}
      AND
      {% condition jobsite_filter %} jobsite {% endcondition %}
      AND
      {% condition po_name_filter %} po_name {% endcondition %}
      AND
      {% condition vendor_filter %} cm.name {% endcondition %}
      )
      ,utilization_info as (
      select
      alr.asset_id,
      sum(on_time) as on_time
      from
      asset_list_rental alr
      join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
      where
      report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
      AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
      alr.asset_id
      )
      , invoice_history as
      (
      select
      r.rental_id,
      sum(coalesce(li.total,0)+coalesce(li.tax,0)) as billed_amount
      from
      orders o
      join rentals r on o.order_id = r.order_id
      join global_line_items li on r.rental_id = li.rental_id
      join invoices i on li.invoice_id = i.invoice_id
      join users u on o.user_id = u.user_id and u.company_id = {{ _user_attributes['company_id'] }}
      left join deliveries d on d.delivery_id = r.drop_off_delivery_id
      left join locations dl on dl.location_id = d.location_id and dl.company_id = {{ _user_attributes['company_id'] }}::integer
      left join states s on s.state_id = dl.state_id
      where
      i.billing_approved_date between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      and r.deleted = false
      group by
      r.rental_id
      )
      select
      ri.rental_id,
      ri.asset_id,
      rental_start_date,
      rental_end_date,
      po_name,
      jobsite,
      asset_class,
      ui.on_time,
      price_per_day,
      price_per_week,
      price_per_month,
      order_id,
      make_and_model,
      custom_name,
      rental_status_id,
      ordered_by,
      coalesce(ih.billed_amount,0) as billed_amount,
      jobsite_state,
      vendor
      from
      rental_info ri
      left join utilization_info ui on ui.asset_id = ri.asset_id
      left join invoice_history ih on ih.rental_id = ri.rental_id
      --(UPPER( ast.name ) = UPPER('Equipment') OR UPPER( ast.name ) = UPPER('Vehicle'))
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    group_label: "Table Value"
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
    primary_key: yes
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: po_name {
    label: "PO"
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
  }


  dimension: jobsite_state {
    label: "Jobsite State"
    type: string
    sql: ${TABLE}."JOBSITE_STATE" ;;
  }


  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  parameter: date_selector {
    type: date
    description: "Use this field to select a date to filter results by."
  }

  filter: date_filter {
    type: date_time
  }

  measure: run_time {
    type: sum
    sql: ${on_time}/3600 ;;
    value_format_name: decimal_2
    drill_fields: [utilization_detail*]
  }

  parameter: view_run_time_by {
    type: string
    allowed_value: { value: "Jobsite"}
    allowed_value: { value: "Purchase Order"}
    allowed_value: { value: "Class"}
  }

  dimension: dynamic_view_by_selection {
    label_from_parameter: view_run_time_by
    sql:{% if view_run_time_by._parameter_value == "'Jobsite'" %}
      ${jobsite}
    {% elsif view_run_time_by._parameter_value == "'Purchase Order'" %}
      ${po_name}
    {% elsif view_run_time_by._parameter_value == "'Class'" %}
      ${asset_class}
    {% else %}
      NULL
    {% endif %} ;;
    # value_format_name: percent_1
    }

    dimension: rental_start_date_formatted {
      group_label: "HTML Passed Date Format" label: "Rental Start Date"
      sql: ${rental_start_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: rental_end_date_formatted {
      group_label: "HTML Passed Date Format" label: "Rental End Date"
      sql: ${rental_end_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

  dimension: rental_status {
    type: string
    sql: case when ${rental_status_id} = 5 then 'On Rent' when ${rental_start_date} > current_date() then 'Reservation' else 'Off Rent' end ;;
    html:
    {% if value == "On Rent" %}
         <p style="color: #00CB86">{{ rendered_value }}</p>
       {% else %}
         <p style="color: black">{{ rendered_value }}</p>
       {% endif %} ;;
  }

  dimension: view_rental_contract {
    label: "Rental ID"
    type: string
    sql: ${rental_id} ;;
    html: <font color="#0063f3"><u><a href="https://contracts.equipmentshare.com/c/{{contracts.contract_id._value}}" target="_blank">{{ rental_id._value }}</a></font></u> ;;
  }

  dimension: asset {
    type: string
    sql: concat(${custom_name}, ' (',${make_and_model},')') ;;
  }

  measure: total_billed_amount {
    description: "Billed amount for the rental during the date range selected"
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
  }


  set: detail {
    fields: [
      rental_id,
      custom_name,
      asset_class,
      po_name,
      jobsite,
      vendor,
      rental_start_date_formatted,
      rental_end_date_formatted
    ]
  }

  set: utilization_detail {
    fields: [
      rental_id,
      assets.custom_name,
      assets.asset_class,
      po_name,
      jobsite,
      vendor,
      price_per_day,
      price_per_week,
      price_per_month,
      rental_start_date_formatted,
      rental_end_date_formatted,
      run_time
    ]
  }

  filter: jobsite_state_filter {
    suggest_explore: rental_history_by_date
    suggest_dimension: rental_history_by_date.jobsite_state
  }

  filter: jobsite_filter {
    suggest_explore: rental_history_by_date
    suggest_dimension: rental_history_by_date.jobsite
  }

  filter: po_name_filter {
    suggest_explore: rental_history_by_date
    suggest_dimension: rental_history_by_date.po_name
  }

  filter: vendor_filter {
    suggest_explore: rental_history_by_date
  }

  }
