view: wo_completion_time {
  derived_table: {
    sql: select
          m.market_id as branch_id,
          wo.work_order_id,
          datediff(seconds,wo.date_created,wo.date_completed)/
          {% if view_data_in._parameter_value == "'Minutes'" %}
          60
          {% elsif view_data_in._parameter_value == "'Hours'" %}
          3600
          {% else %}
          1
          {% endif %}
          as completion_time
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
      where
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          AND wo.archived_date is null
          AND m.company_id = {{ _user_attributes['company_id'] }}::numeric
          --AND m.company_id = 50::numeric
          AND wo.work_order_type_id = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: completion_time {
    type: number
    sql: ${TABLE}."COMPLETION_TIME" ;;
  }

  parameter: view_data_in {
    type: string
    allowed_value: { value: "Hours"}
    allowed_value: { value: "Minutes"}
    allowed_value: { value: "Seconds"}
  }

  filter: date_filter {
    type: date_time
  }

  measure: avg_completion_time_kpi {
    group_label: "KPI"
    label: "Average Completion Time"
    type: average
    sql: ${completion_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{rendered_value }} mins.
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    </font>
    </a>
    ;;
    drill_fields: [wo_response_time*]
  }

  measure: avg_completion_time {
    type: average
    sql: ${completion_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{rendered_value }} mins.
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>
    ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      work_order_id,
      work_order_user_times.link_to_work_order,
      users.mechanic,
      work_order_user_times.start_date_formatted,
      work_order_user_times.end_date_formatted,
      work_order_user_times.total_hours
      ]
  }

  set: branch_wo_response_time {
    fields: [
      work_order_id,
      work_orders.link_to_work_order,
      work_orders.date_time_formatted,
      avg_completion_time
    ]
  }

  set: wo_response_time {
    fields: [
      markets_branch.name,
      work_order_id,
      work_orders.link_to_work_order,
      work_orders.date_time_formatted,
      avg_completion_time
    ]
  }
}
