view: asset_down_time_work_orders {
  derived_table: {
    sql: select
        wo.asset_id,
        wo.work_order_id,
        date_trunc('month', wo.date_created) as month,
        wo.date_created,
        wo.date_completed,
        wo.description,
        wo.solution,
        ul.name as priority
      from
        work_orders.work_orders wo
        join work_orders.work_order_originators woo using(work_order_id)
        join markets m on branch_id = market_id
        left join work_orders.urgency_levels ul on ul.urgency_level_id = wo.urgency_level_id
      where
        m.company_id = {{ _user_attributes['company_id'] }}
        and originator_type_id in (1,4,5,6,8)
        and archived_date is null
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${work_order_id},${month_raw},${asset_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension_group: month {
    type: time
    sql: ${TABLE}."MONTH" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: link_to_work_order_for_asset_downtime {
    group_label: "Link to Work Order"
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="0063f3 "><u><a href="https://app.estrack.com/#/service/work-orders/{{ asset_down_time_work_orders.work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: date_created_formatted {
    group_label: "HTML Formatted Time"
    label: "WO Date Created"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: date_completed_formatted {
    group_label: "HTML Formatted Time"
    label: "WO Date Completed"
    type: date
    sql: ${date_completed_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [
      asset_id,
      work_order_id,
      month_time,
      date_created_time,
      date_completed_time,
      solution,
      priority
    ]
  }
}
