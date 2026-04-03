view: activity_feed {
  derived_table: {
    sql: select
          wo.date_created as action_time,
          concat(' Created / Originated from ',ot.name) as action,
          wo.work_order_id as work_order_id,
          wo.work_order_type_id as work_order_type_id,
          'wo_created' as action_note,
          '' as user_action,
          '' as color
      from
          work_orders.work_orders wo
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date >= current_timestamp)
          left join es_warehouse.public.users u on u.user_id = woua.user_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          datediff(hours,wo.date_created, current_timestamp) <= 24
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND wo.archived_date is null
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      UNION
      select
          wo.date_completed as action_time,
          concat(' Marked as Completed') as action,
          wo.work_order_id,
          wo.work_order_type_id as work_order_type_id,
          'wo_completed' as action_note,
          '' as user_action,
          '' as color
      from
          work_orders.work_orders wo
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date >= current_timestamp)
          left join es_warehouse.public.users u on u.user_id = woua.user_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          datediff(hours,wo.date_completed, current_timestamp) <= 24
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND wo.archived_date is null
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      UNION
      select
          won.date_created as action_time,
          concat(' Added Note to ') as action,
          wo.work_order_id,
          wo.work_order_type_id as work_order_type_id,
          'wo_note_added' as action_note,
          concat(u.first_name,' ',u.last_name) as user_action,
          '' as color
      from
          work_orders.work_order_notes won
          join work_orders.work_orders wo on won.work_order_id = wo.work_order_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join es_warehouse.public.users u on u.user_id = won.creator_user_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date >= current_timestamp)
          left join es_warehouse.public.users u2 on u2.user_id = woua.user_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          datediff(hours,wo.date_completed, current_timestamp) <= 24
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND wo.archived_date is null
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u2.first_name,' ',u2.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      UNION
      select
          wot.user_assignment_start_date as action_time,
          ct.name as action,
          wo.work_order_id,
          wo.work_order_type_id as work_order_type_id,
          'wo_user_tag_added' as action_note,
          concat(wot.first_name, ' ',wot.last_name) as user_action,
          ct.color
      from
          work_orders.work_orders_by_tag wot
          join work_orders.work_orders wo on wot.work_order_id = wo.work_order_id
          join work_orders.company_tags ct on ct.company_tag_id = wot.company_tag_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date >= current_timestamp)
          left join es_warehouse.public.users u2 on u2.user_id = woua.user_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          datediff(hours,wot.user_assignment_start_date, current_timestamp) <= 24
          AND wo.archived_date is null
          AND wo.date_completed is null
          AND ct.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u2.first_name,' ',u2.last_name) {% endcondition %}
          AND {% condition user_assignment_filter %} concat(wot.first_name,' ',wot.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: action_time {
    type: time
    sql: ${TABLE}."ACTION_TIME" ;;
  }

  dimension: action {
    type: string
    sql: ${TABLE}."ACTION" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: action_note {
    type: string
    sql: ${TABLE}."ACTION_NOTE" ;;
  }

  dimension: user_action {
    type: string
    sql: ${TABLE}."USER_ACTION" ;;
  }

  dimension: color {
    type: string
    sql: ${TABLE}."COLOR" ;;
  }

  dimension: action_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Time"
    type: date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${action_time_raw}) ;;
    html:
    <b>{{ rendered_value | date: "%r"  }} {{ _user_attributes['user_timezone_label'] }}</b><br />
    <font color="#ADAA8D">{{ rendered_value | date: "%b %d, %Y"  }}</font>;;
    # html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: work_order_with_type {
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">View {{rendered_value}}</a></font></u> ;;
  }

  dimension: action_summary {
    type: string
    sql: case when ${action_note} = 'wo_created' then concat(${link_to_work_order_t3},${action})
    when ${action_note} = 'wo_completed' then concat(${link_to_work_order_t3},${action})
    else concat(${action},${link_to_work_order_t3})
    end
    ;;
    html: {% if action_note._value == 'wo_created' %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{work_order_with_type._rendered_value}}</a></u> </font>

    <b>{{action._rendered_value}}</b>
    {% elsif action_note._value == 'wo_completed' %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{work_order_with_type._rendered_value}}</a></u> </font>

    <b>{{action._rendered_value}}</b>
    {% elsif action_note._value == 'wo_note_added' %}
    <b>{{user_action._rendered_value}}</b> {{action._rendered_value}} <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{work_order_with_type._rendered_value}}</a></u> </font>
    {% else %}
    <b>{{user_action._rendered_value}}</b> Added <font color={{ color._rendered_value }}>{{action._rendered_value}}</font> tag to <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{work_order_with_type._rendered_value}}</a></u> </font>



    {% endif %} ;;
  }

  filter: branch_filter {
  }

  filter: originator_filter {
  }

  filter: user_assignment_filter {
  }

  filter: inventory_status_filter {
  }

  set: detail {
    fields: [action_time_time, action, work_order_id]
  }
}
