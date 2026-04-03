view: wo_response_time {
  derived_table: {
    sql: with first_clock_in_events as (
      select
        work_order_id,
        min(start_date) as start_date
      from
        work_orders.work_order_user_times wout
        join users u on u.user_id = wout.user_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        --u.company_id = 50::numeric
      group by
        work_order_id
      union
      select
        work_order_id,
        min(start_date) as start_date
      from
        time_tracking.time_entries er
        join users u on u.user_id = er.user_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        --u.company_id = 50::numeric
        and er.work_order_id is not null
        AND er.event_type_id = 1 --only pulling 'on duty' event types
      group by
        work_order_id
      )
      , first_clock_in_events_agg as (
      select
        work_order_id,
        min(start_date) as first_clock_in
      from
        first_clock_in_events
      group by
        work_order_id
      )
      select
          m.market_id as branch_id,
          wo.work_order_id,
          fli.first_clock_in as first_clock_in_time,
          datediff(seconds,wo.date_created,fli.first_clock_in)/
          {% if view_data_in._parameter_value == "'Minutes'" %}
          60
          {% elsif view_data_in._parameter_value == "'Hours'" %}
          3600
          {% else %}
          1
          {% endif %}
          as response_time
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
          join first_clock_in_events_agg fli on fli.work_order_id = wo.work_order_id
      where
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          AND wo.archived_date is null
          --AND m.company_id = 50::numeric
          AND m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND wo.work_order_type_id = 1
          AND wo.date_created <= fli.first_clock_in
          AND wo.date_completed >= fli.first_clock_in
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

  dimension: response_time {
    type: number
    sql: ${TABLE}."RESPONSE_TIME" ;;
  }

  dimension: first_clock_in_time {
    group_label: "HTML Format" label: "First Clock In"
    type: date_time
    sql: ${TABLE}."FIRST_CLOCK_IN_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
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

  measure: avg_response_time_kpi {
    group_label: "KPI"
    label: "Average Response Time"
    type: average
    sql: ${response_time} ;;
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

  measure: avg_response_time {
    type: average
    sql: ${response_time} ;;
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
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>
    ;;
    drill_fields: [detail*]
  }

  measure: avg_response_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "Average Response Time"
    type: average
    sql: ${response_time} ;;
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
    </a>
    ;;
    drill_fields: [branch_wo_response_time*]
  }

  set: detail {
    fields: [
      work_order_id,
      work_orders.link_to_work_order,
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
      first_clock_in_time,
      avg_response_time
    ]
  }

  set: wo_response_time {
    fields: [
      markets_branch.name,
      work_order_id,
      work_orders.link_to_work_order,
      work_orders.date_time_formatted,
      first_clock_in_time,
      avg_response_time
    ]
  }
}
