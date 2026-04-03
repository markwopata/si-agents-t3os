view: work_orders_assigned_to {
  derived_table: {
    sql: select
          woa.work_order_id,
          listagg(concat(u.first_name,' ',u.last_name), ', ') within group (order by work_order_id desc) as assigned_to
        from
          work_orders.work_order_user_assignments woa
          inner join users u on u.user_id = woa.user_id
        where
          end_date is null
        group by
          work_order_id
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

  dimension: assigned_to {
    type: string
    sql: ${TABLE}."ASSIGNED_TO" ;;
  }

  set: detail {
    fields: [work_order_id, assigned_to]
  }
}
