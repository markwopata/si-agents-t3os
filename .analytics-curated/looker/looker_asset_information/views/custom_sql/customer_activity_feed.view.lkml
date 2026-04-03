view: customer_activity_feed {
  derived_table: {
    sql: select
      d.delivery_id as unique_id_to_status,
      d.asset_id,
      c.company_id,
      c.name as company_name,
      convert_timezone('America/Chicago',d.completed_date) as completed_date,
      'Completed Delivery' as Status
      from
      ES_WAREHOUSE.PUBLIC.deliveries d
      join ES_WAREHOUSE.PUBLIC.rentals r on d.delivery_id = r.drop_off_delivery_id
      left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
      d.completed_date::DATE >= current_timestamp()::DATE - interval '30 day'
      UNION
      select
        d.delivery_id as unique_id_to_status,
        d.asset_id,
        c.company_id,
        c.name as company_name,
        convert_timezone('America/Chicago',d.scheduled_date) as completed_date,
        concat('Pending Delivery', ' - ', (case when driver_user_id is null then 'No Driver Assigned' else concat(u2.first_name, ' ', u2.last_name) end))  as status

      from
        ES_WAREHOUSE.PUBLIC.deliveries d
        join ES_WAREHOUSE.PUBLIC.rentals r on d.delivery_id = r.drop_off_delivery_id
        left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
        left join ES_WAREHOUSE.PUBLIC.users u2 on d.driver_user_id = u2.user_id
      where
        delivery_status_id = 1
        and completed_date is null
        and d.scheduled_date::DATE >= current_timestamp()::DATE - interval '30 day'
      UNION
      select
      wo.work_order_id,
      wo.asset_id,
      c.company_id,
      c.name,
      convert_timezone('America/Chicago',wo.date_completed) as completed_date,
      'Work Order Completed' as Status
      from
      ES_WAREHOUSE.WORK_ORDERS.work_orders as wo
      left join ES_WAREHOUSE.PUBLIC.rentals r on wo.asset_id = r.asset_id
      left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      inner join ES_WAREHOUSE.PUBLIC.equipment_assignments ea
        on ea.asset_id = wo.asset_id
        and
          (wo.date_completed between ea.start_date and ea.end_date or wo.date_created between ea.start_date and ea.end_date )
        and ea.rental_id = r.rental_id
      where
      wo.date_completed::DATE >= current_timestamp()::DATE - interval '30 day'
      UNION
      select
      r.rental_id,
      a.asset_id,
      c.company_id,
      c.name,
      convert_timezone('America/Chicago',r.end_date) as completed_date,
      'Off Rent' as Status
      from
      ES_WAREHOUSE.PUBLIC.assets a
      left join ES_WAREHOUSE.PUBLIC.rentals r on a.asset_id = r.asset_id
      left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
      r.end_date::DATE >= current_timestamp()::DATE - interval '30 day'
      and a.asset_type_id = 1
      UNION
      select
      r.rental_id,
      a.asset_id,
      c.company_id,
      c.name,
      convert_timezone('America/Chicago',r.start_date) as completed_date,
      'On Rent' as Status
      from
      ES_WAREHOUSE.PUBLIC.assets a
      left join ES_WAREHOUSE.PUBLIC.rentals r on a.asset_id = r.asset_id
      left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
      r.start_date::DATE >= current_timestamp()::DATE - interval '30 day'
      and a.asset_type_id = 1
      UNION
      select
      wo.work_order_id,
      wo.asset_id,
      c.company_id,
      c.name,
      convert_timezone('America/Chicago',wo.date_created) as completed_date,
      'Work Order Created' as Status
      from
      ES_WAREHOUSE.WORK_ORDERS.work_orders as wo
      left join ES_WAREHOUSE.PUBLIC.rentals r on wo.asset_id = r.asset_id
      left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      inner join ES_WAREHOUSE.PUBLIC.equipment_assignments ea
        on ea.asset_id = wo.asset_id
        and
          (wo.date_completed between ea.start_date and ea.end_date or wo.date_created between ea.start_date and ea.end_date )
        and ea.rental_id = r.rental_id
      where
      wo.date_created::DATE >= current_timestamp()::DATE - interval '30 day'
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: unique_id_to_status {
    type: number
    sql: ${TABLE}."UNIQUE_ID_TO_STATUS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [assets.asset_id,assets.make_and_model,assets.name]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      time_of_day,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }

  dimension: timestamp_for_activity_date {
    type: date_time
    sql: ${date_completed_raw} ;;
    html: {{ rendered_value | date: "%m/%d/%Y %I:%M %p"}} ;;
  }


  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  set: detail {
    fields: [asset_id, company_id, company_name, date_completed_date, status]
  }

  dimension: work_order_id {
    type: string
    sql: CASE WHEN ${status} = 'Work Order Completed' THEN ${unique_id_to_status}::TEXT
      WHEN ${status} = 'Work Order Created' THEN ${unique_id_to_status}::TEXT ELSE ' ' END ;;
  }

  dimension: status_with_link{
    type: string
    # sql: CASE WHEN ${testing_bit} = 1 THEN ${link_for_work_orders}::TEXT ELSE ${status}::TEXT END;;
    sql: ${status} ;;
    html:
    {% if status._value == 'Work Order Completed' %}
    <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ customer_activity_feed.unique_id_to_status._value }}" target="_blank">Work Order Completed</a></font></u>
    {% elsif status._value == 'Work Order Created' %}
    <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ customer_activity_feed.unique_id_to_status._value }}" target="_blank">Work Order Created</a></font></u>
    {% else %}
    <p style="color: black">{{ status._value }}</p>
    {% endif %};;
  }
#     <p style="color: green">{{ status._value }}</p>



}
