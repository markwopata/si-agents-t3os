view: inspection_time_by_work_order {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,wo_inspections as (
      select
          wo.work_order_id,
          wo.asset_id,
          wut.start_date,
          wut.end_date,
          datediff(seconds,wut.start_date,wut.end_date) as time,
          concat(a.make,' ',a.model) as make_and_model
      from
          asset_list_own alo
          inner join work_orders.work_orders wo on wo.asset_id = alo.asset_id
          inner join work_orders.work_order_user_times wut on wo.work_order_id = wut.work_order_id
          inner join assets a on a.asset_id = alo.asset_id
      where
          wo.work_order_type_id = 2
          and wo.archived_date is null
          and wut.date_deleted is null
          and wo.date_completed is not null
      )
      select
          work_order_id,
          asset_id,
          make_and_model,
          round(sum(time)/3600,2) as total_hours
      from
          wo_inspections
      group by
          work_order_id,
          asset_id,
          make_and_model
       ;;
  }

  measure: count {
    type: count
    # drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${work_order_id},${asset_id},${make_and_model}) ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: total_hours {
    type: number
    sql: ${TABLE}."TOTAL_HOURS" ;;
    drill_fields: [time_tracking_entries*]
  }

  dimension: view_inspection {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  measure: average_hours {
    type: average
    sql: ${total_hours} ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs. ;;
    drill_fields: [inspection_detail*]
  }


  set: time_tracking_entries {
    fields: [users.mechanic, work_order_id, work_order_user_times.start_date_formatted, work_order_user_times.end_date_formatted, work_order_user_times.total_hours]
  }

  set: inspection_detail {
    fields: [make_and_model, view_inspection, assets.custom_name, total_hours]
  }

}
