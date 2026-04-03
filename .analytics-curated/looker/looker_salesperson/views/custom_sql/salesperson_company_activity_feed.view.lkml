view: salesperson_company_activity_feed {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: select
        concat(trim(u.first_name), ' ',trim(u.last_name)) as salesperson,
        u.user_id,
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
        left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = coalesce(o.salesperson_user_id,os.user_id)
        left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
      where
        d.completed_date >= dateadd(days,-7,current_timestamp())
        AND delivery_status_id = 3 --Completed
        AND delivery_type_id = 1 --Initial Drop Off
        AND
        {% if _user_attributes['department']  == "'salesperson'" %}
        u.email_address = '{{ _user_attributes['email'] }}'
        {% else %}
        1 = 1
        {% endif %}
      union
      select
        concat(trim(u.first_name), ' ',trim(u.last_name))  as salesperson,
        u.user_id,
        d.delivery_id as unique_id_to_status,
        d.asset_id,
        c.company_id,
        c.name as company_name,
        convert_timezone('America/Chicago',d.scheduled_date) as completed_date,
        concat('Pending Delivery', ' - ', (case when driver_user_id is null then 'No Driver Assigned' else concat(trim(u3.first_name),' ',trim(u3.last_name)) end)) as Status
      from
        ES_WAREHOUSE.PUBLIC.deliveries d
        join ES_WAREHOUSE.PUBLIC.rentals r on d.delivery_id = r.drop_off_delivery_id
        left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
        left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = coalesce(o.salesperson_user_id,os.user_id)
        left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
        left join ES_WAREHOUSE.PUBLIC.users u3 on d.driver_user_id = u3.user_id
      where
        delivery_status_id = 1 --Requested
        and delivery_type_id = 1 --Initial Drop Off
        and completed_date is null
        and d.scheduled_date >= dateadd(days,-7,current_timestamp())
        and d.completed_date is null
        AND
        {% if _user_attributes['department']  == "'salesperson'" %}
        u.email_address = '{{ _user_attributes['email'] }}'
        {% else %}
        1 = 1
        {% endif %}
      UNION
      select
        concat(trim(u2.first_name), ' ',trim(u2.last_name)) as salesperson,
        u2.user_id,
        wo.work_order_id,
          wo.asset_id,
          c.company_id,
          c.name,
          convert_timezone('America/Chicago',wo.date_completed) as completed_date,
          'Work Order Completed' as Status
      from
          ES_WAREHOUSE.work_orders.work_orders as wo
          left join ES_WAREHOUSE.PUBLIC.rentals r on wo.asset_id = r.asset_id
          left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
          left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
          left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
          left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = coalesce(o.salesperson_user_id,os.user_id)
          left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
          inner join ES_WAREHOUSE.PUBLIC.equipment_assignments ea
              on ea.asset_id = wo.asset_id
              and
                (wo.date_completed between ea.start_date and ea.end_date or wo.date_created between ea.start_date and ea.end_date )
              and ea.rental_id = r.rental_id
      where
          wo.date_completed >= dateadd(days,-7,current_timestamp())
          AND wo.archived_date is null
          AND
          {% if _user_attributes['department']  == "'salesperson'" %}
          u2.email_address = '{{ _user_attributes['email'] }}'
          {% else %}
          1 = 1
          {% endif %}
      UNION
      select
        concat(trim(u.first_name), ' ',trim(u.last_name)) as salesperson,
        u.user_id,
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
        left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = coalesce(o.salesperson_user_id,os.user_id)
        left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
      where
        r.end_date BETWEEN dateadd(days,-7,current_timestamp()) AND current_timestamp()
        and a.asset_type_id = 1
        AND r.rental_status_id in (6,7,9)
        AND
        {% if _user_attributes['department']  == "'salesperson'" %}
        u.email_address = '{{ _user_attributes['email'] }}'
        {% else %}
        1 = 1
        {% endif %}
      UNION
      select
        concat(trim(u.first_name), ' ',trim(u.last_name)) as salesperson,
        u.user_id,
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
        left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = coalesce(o.salesperson_user_id,os.user_id)
        left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
      where
        r.start_date BETWEEN dateadd(days,-7,current_timestamp()) AND current_timestamp()
        and a.asset_type_id = 1
        and r.rental_status_id = 5
        AND
        {% if _user_attributes['department']  == "'salesperson'" %}
        u.email_address = '{{ _user_attributes['email'] }}'
        {% else %}
        1 = 1
        {% endif %}
      UNION
      select
        concat(trim(u2.first_name), ' ',trim(u2.last_name)) as salesperson,
        u2.user_id,
        wo.work_order_id,
        wo.asset_id,
        c.company_id,
        c.name,
        convert_timezone('America/Chicago',wo.date_created) as completed_date,
        'Work Order Created' as Status
      from
        ES_WAREHOUSE.work_orders.work_orders as wo
        left join ES_WAREHOUSE.PUBLIC.rentals r on wo.asset_id = r.asset_id
        left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
        left join ES_WAREHOUSE.PUBLIC.order_salespersons os on o.order_id = os.order_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = coalesce(o.salesperson_user_id,os.user_id)
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
        inner join ES_WAREHOUSE.PUBLIC.equipment_assignments ea
            on ea.asset_id = wo.asset_id
            and
              (wo.date_completed between ea.start_date and ea.end_date or wo.date_created between ea.start_date and ea.end_date )
            and ea.rental_id = r.rental_id
      where
        wo.date_created BETWEEN dateadd(days,-7,current_timestamp()) AND current_timestamp()
        AND wo.archived_date is null
        AND
        {% if _user_attributes['department']  == "'salesperson'" %}
        u2.email_address = '{{ _user_attributes['email'] }}'
        {% else %}
        1 = 1
        {% endif %}
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: unique_id_to_status {
    type: number
    sql: ${TABLE}."UNIQUE_ID_TO_STATUS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: completed_date {
    type: time
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson}, ' - ',${user_id}) ;;
  }

  dimension: status_with_link{
    type: string
    sql: ${status} ;;
    html:
    {% if status._value == 'Work Order Completed' %}
    <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ salesperson_company_activity_feed.unique_id_to_status._value }}" target="_blank">Work Order Completed</a></font></u>
    {% elsif status._value == 'Work Order Created' %}
    <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ salesperson_company_activity_feed.unique_id_to_status._value }}" target="_blank">Work Order Created</a></font></u>
    {% else %}
    <p style="color: black">{{ status._value }}</p>
    {% endif %};;
  }

  dimension: timestamp_for_activity_date {
    type: date_time
    sql: ${completed_date_raw} ;;
    html: {{ rendered_value | date: "%m/%d/%Y %I:%M %p"}} ;;
  }

  filter: salesperson_filter {
  }

  set: detail {
    fields: [
      salesperson,
      user_id,
      unique_id_to_status,
      asset_id,
      company_id,
      company_name,
      completed_date_time,
      status
    ]
  }
}
