view: transport_details {
  derived_table: {
    sql:
    select d.delivery_id as transport_id,
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
    --    from_address,
        concat_ws(', ', l.street_1, l.city, st.abbreviation) || ' ' || l.zip_code as deliver_to_address,
        d.scheduled_date,
        d.completed_date,
        d.note
    from ES_WAREHOUSE.public.deliveries d
        left join ES_WAREHOUSE.public.delivery_facilitator_types dft on d.facilitator_type_id = dft.delivery_facilitator_type_id
        left join ES_WAREHOUSE.public.delivery_statuses dst on d.delivery_status_id = dst.delivery_status_id
        left join ES_WAREHOUSE.public.locations l on d.location_id = l.location_id
        left join ES_WAREHOUSE.public.states st on l.state_id = st.state_id
        left join ES_WAREHOUSE.public.users u on d.driver_user_id = u.user_id
        left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
        left join ES_WAREHOUSE.public.orders o on d.order_id = o.order_id
        left join ES_WAREHOUSE.public.purchase_orders po on o.purchase_order_id = po.purchase_order_id
        left join ES_WAREHOUSE.public.users u2 on o.user_id = u2.user_id
        left join ES_WAREHOUSE.public.companies c2 on u2.company_id = c2.company_id
        left join ES_WAREHOUSE.public.markets m on o.market_id = m.market_id
    where m.company_id = {{ _user_attributes['company_id'] }}
    ;;
  }
  dimension: transport_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRANSPORT_ID";;
    value_format_name: id
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID";;
    value_format_name: id
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID";;
    value_format_name: id
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID";;
    value_format_name: id
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER";;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER";;
  }

  dimension: transport_facilitator {
    type: string
    sql: ${TABLE}."TRANSPORT_FACILITATOR";;
  }

  dimension: transport_provider {
    type: string
    sql: ${TABLE}."TRANSPORT_PROVIDER";;
  }

  dimension: assigned_driver_company {
    label: "Driver/Company"
    type: string
    sql: ${TABLE}."ASSIGNED_DRIVER_COMPANY" ;;
  }

  dimension: transport_status {
    type: string
    sql: ${TABLE}."TRANSPORT_STATUS";;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: deliver_to_address {
    label: "Delivery Location"
    type: string
    sql: ${TABLE}."DELIVER_TO_ADDRESS";;
  }

  dimension_group: scheduled {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."SCHEDULED_DATE" AS TIMESTAMP_NTZ);;
  }

  dimension_group: completed {
    type: time
    timeframes: [
      raw,
      date,
      month,
      year
    ]
    sql: CAST(${TABLE}."COMPLETED_DATE" AS TIMESTAMP_NTZ);;
  }

  dimension: completed_transport {
    type: yesno
    sql: ${transport_status} = 'Completed';;
  }

  measure: transport_count {
    type: count
    value_format_name: decimal_0
    drill_fields: [transport_report_details*]
  }

  measure: completed_transport_count {
    type: count
    value_format_name: decimal_0
    filters: [completed_transport: "yes"]
    drill_fields: [transport_report_details*]
  }

  # measure: outstanding_transport_billed {
  #   label: "Outstanding Billed"
  #   type: number
  #   sql: ${price} - coalesce(${line_items.sub_total}, 0) ;;
  #   value_format_name: usd_0
  # }

  set: transport_line_items_detail {
    fields: [transport_id, rental_id, customer, transport_facilitator, assigned_driver_company, deliver_to_address, completed_date, line_items.id, line_items.transport_price, line_items.transport_revenue_without_tax]
  }

  set: transport_report_details {
    fields: [transport_id,
             order_id,
            rental_id,
            rental_details.rental_status,
            purchase_order,
            transport_facilitator,
            assigned_driver_company,
            transport_status,
            deliver_to_address,
            scheduled_date,
            completed_date,
            price
            ]
  }


  }
