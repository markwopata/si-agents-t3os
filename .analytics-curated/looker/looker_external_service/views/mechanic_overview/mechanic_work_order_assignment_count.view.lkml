view: mechanic_work_order_assignment_count {
  derived_table: {
    sql: with time_entries as (
      select
        te.user_id,
        work_order_id,
        sum(regular_hours) as regular_hours,
        sum(overtime_hours) as overtime_hours
      from
        time_tracking.time_entries te
      join
        users u on u.user_id = te.user_id
      where
        work_order_id is not null
        and u.company_id = {{ _user_attributes['company_id'] }}
      group by
        1,2
      )
      select
          'open' as status,
          concat(u.first_name,' ',u.last_name) as user_assignment,
          wo.work_order_id,
          u.user_id,
          wo.asset_id,
          ot.name as originator,
          m.name as branch,
          wo.work_order_type_id,
          sum((coalesce(regular_hours, 0))) as regular_hours,
          sum((coalesce(overtime_hours, 0))) as overtime_hours
      from
          work_orders.work_order_user_assignments woua
          join es_warehouse.public.users u on u.user_id = woua.user_id
          join work_orders.work_orders wo on wo.work_order_id = woua.work_order_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join time_entries te on te.user_id = woua.user_id and te.work_order_id = woua.work_order_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          (woua.end_date is null OR woua.end_date >= current_timestamp)
          AND wo.archived_date is null
          AND wo.date_completed is null
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      group by
          concat(u.first_name,' ',u.last_name),
          wo.work_order_id,
          u.user_id,
          wo.asset_id,
          ot.name,
          m.name,
          wo.work_order_type_id
    UNION
      select
          'completed' as status,
          concat(u.first_name,' ',u.last_name) as user_assignment,
          wo.work_order_id,
          u.user_id,
          wo.asset_id,
          ot.name as originator,
          m.name as branch,
          wo.work_order_type_id,
          sum((coalesce(regular_hours, 0))) as regular_hours,
          sum((coalesce(overtime_hours, 0))) as overtime_hours
      from
          work_orders.work_order_user_assignments woua
          join es_warehouse.public.users u on u.user_id = woua.user_id
          join work_orders.work_orders wo on wo.work_order_id = woua.work_order_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join time_entries te on te.user_id = woua.user_id and te.work_order_id = woua.work_order_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          --(woua.end_date is null OR woua.end_date >= current_timestamp) AND
          wo.archived_date is null
          AND datediff(days,wo.date_completed,current_date) <= 30
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      group by
          concat(u.first_name,' ',u.last_name),
          wo.work_order_id,
          u.user_id,
          wo.asset_id,
          ot.name,
          m.name,
          wo.work_order_type_id
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_assignment {
    type: string
    sql: ${TABLE}."USER_ASSIGNMENT" ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: regular_hours {
    type: number
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }

  dimension: overtime_hours {
    type: number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: total_open_work_orders_assigned {
    label: "Open Work Orders Assigned"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [status: "open", work_order_type_id: "1"]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [work_order_details*]
  }

  measure: total_open_inspections_assigned {
    label: "Open Inspections Assigned"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [status: "open", work_order_type_id: "2"]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [work_order_details*]
  }

  measure: total_closed_work_orders {
    label: "Last 30 Days Closed Work Orders"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [status: "completed", work_order_type_id: "1"]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [work_order_details*]
  }

  measure: total_closed_inspections {
    label: "Last 30 Days Closed Inspections"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [status: "completed", work_order_type_id: "2"]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [work_order_details*]
  }

  measure: total_regular_hours_open_work_orders {
    label: "Open Work Order Regular Hours Worked"
    type: sum
    sql: ${regular_hours} ;;
    filters: [status: "open"]
  }

  measure: total_overtime_hours_open_work_orders {
    label: "Open Work Order Overtime Hours Worked"
    type: sum
    sql: ${overtime_hours} ;;
    filters: [status: "open"]
  }


  measure: total_regular_hours_closed_work_orders {
    label: "Last 30 Days Closed Work Order Regular Hours"
    type: sum
    sql: ${regular_hours} ;;
    filters: [status: "completed"]
  }

  measure: total_overtime_hours_closed_work_orders {
    label: "Last 30 Days Closed Work Order Overtime Hours"
    type: sum
    sql: ${overtime_hours} ;;
    filters: [status: "completed"]
  }

  filter: branch_filter {
  }

  filter: originator_filter {
  }

  filter: user_assignment_filter {
  }

  set: detail {
    fields: [user_assignment]
  }

  filter: inventory_status_filter {
  }

  set: work_order_details {
    fields: [
      mechanic_open_work_orders_info.link_to_work_order_t3,
      mechanic_open_work_orders_info.date_created_date,
      mechanic_open_work_orders_info.originator,
      mechanic_open_work_orders_info.description,
      mechanic_open_work_orders_info.work_order_tags,
      mechanic_open_work_orders_info.branch,
      mechanic_open_work_orders_info.link_to_asset_service_view,
      mechanic_open_work_orders_info.total_regular_hours,
      mechanic_open_work_orders_info.total_overtime_hours
    ]
  }
}

# mechanic_open_work_orders_info.assignments, pulling out of drill down since it drills to user
# mechanic_open_work_orders_info.address, pulling out of drill down since adress is in asset column
