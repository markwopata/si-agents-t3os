view: work_order_task_list {
  derived_table: {
    sql: select
        work_order_id,
        display_name,
       concat(u.first_name, ' ', u.last_name) as completed_by,
       t.date_created,
       t.completed,
       t.current_state,
       t.note,
       t.item_updated_date as date_updated
from (
         select work_order_id,
                t.*,
                user_id,
                wosi.work_order_state_item_type_id is not null as completed,
                wosit.name as current_state,
                wosi.note as note,
                wosi.date_updated as item_updated_date
         from tasks t
                  left join work_orders.work_order_state_items wosi using (task_id)
                  left join work_orders.work_order_state_item_types wosit using (work_order_state_item_type_id)
         union
         select work_order_id,
                t.*,
                user_id,
                wossi.selection_id is not null as completed,
                wosso.display_name as current_state,
                wossi.note as note,
                wossi.date_updated as item_updated_date
         from tasks t
                  left join work_orders.work_order_single_select_items wossi using (task_id)
                  left join work_orders.work_order_single_select_options wosso using (work_order_single_select_item_id)
         union
         select work_order_id,
                t.*,
                user_id,
                woti.text is not null as completed,
                woti.text as current_state,
                woti.note as note,
                woti.date_updated as item_updated_date
         from tasks t
                  left join work_orders.work_order_text_items woti using (task_id)
         union
         select work_order_id,
                t.*,
                user_id,
                wocli.completed,
                wocli.completed::text as current_state,
                wocli.note as note,
                wocli.date_updated as item_updated_date
         from tasks t
                  left join work_orders.work_order_checklist_items wocli using (task_id)
     ) t
         join users u on u.user_id = t.user_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: display_name {
    type: string
    sql: ${TABLE}."DISPLAY_NAME" ;;
  }

  dimension: completed_by {
    type: string
    sql: ${TABLE}."COMPLETED_BY" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: completed {
    type: string
    sql: ${TABLE}."COMPLETED" ;;
  }

  dimension: current_state {
    type: string
    sql: case when ${TABLE}."CURRENT_STATE" = true then 'Completed' else ${TABLE}."CURRENT_STATE" end ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: task_completed {
    type: string
    sql: case when ${completed} = true then 'Yes' when ${completed} = false then 'No'
      else ${completed} end;;
  }

  dimension: date_created_date_formatted {
    group_label: "HTML Date Formatted"
    label: "Date Created"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_updated_date_formatted {
    group_label: "HTML Date Formatted"
    label: "Date Completed"
    type: date
    sql: ${date_updated_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  set: detail {
    fields: [
      work_order_id,
      display_name,
      completed_by,
      date_created_time,
      completed,
      current_state
    ]
  }
}
