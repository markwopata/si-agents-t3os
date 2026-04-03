view: mechanic_response_time {
  derived_table: {
    sql: with first_clock_in_events as (
      select
        work_order_id,
        concat(u.first_name,' ',u.last_name) as mechanic,
        min(start_date) as start_date
      from
        work_orders.work_order_user_times wout
        join users u on u.user_id = wout.user_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        --u.company_id = 50::numeric
      group by
        work_order_id,
        concat(u.first_name,' ',u.last_name)
      union
      select
        work_order_id,
        concat(u.first_name,' ',u.last_name) as mechanic,
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
        work_order_id,
        concat(u.first_name,' ',u.last_name)
      )
      , first_clock_in_events_agg as (
      select
        work_order_id,
        mechanic,
        min(start_date) as first_clock_in
      from
        first_clock_in_events
      group by
        work_order_id,
        mechanic
      )
      , response_time_per_wo as (
      select
          m.market_id as branch_id,
          fli.mechanic,
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
          as response_time,
          ul.name as urgency_level,
          ROW_NUMBER() OVER(partition by m.market_id, wo.work_order_id ORDER BY fli.first_clock_in asc) first_clock_ranking
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
          join first_clock_in_events_agg fli on fli.work_order_id = wo.work_order_id
          join work_orders.urgency_levels ul on ul.urgency_level_id = wo.urgency_level_id
      where
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          --wo.date_created BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          AND wo.archived_date is null
          --AND m.company_id = 50::numeric
          AND m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND wo.work_order_type_id = 1
          AND wo.date_created <= fli.first_clock_in
          AND wo.date_completed >= fli.first_clock_in
      )
      ,branches_per_company as (
      select
          m.market_id as branch_id,
          wo.work_order_id,
          wo.work_order_type_id
      from
          work_orders.work_orders wo
          join markets m on wo.branch_id = m.market_id
      where
          --m.company_id = 50::numeric
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND (
          --wo.date_completed BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          OR
          --wo.date_created BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          )
          AND wo.work_order_type_id = 1
      )
      select
          bpc.branch_id,
          bpc.work_order_id,
          bpc.work_order_type_id,
          mechanic,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',first_clock_in_time) as first_clock_in_time,
          response_time,
          urgency_level
      from
          branches_per_company bpc
          join response_time_per_wo rt on rt.work_order_id = bpc.work_order_id AND rt.branch_id = bpc.branch_id
      where
        first_clock_ranking = 1
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

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: mechanic {
    type: string
    sql: ${TABLE}."MECHANIC" ;;
    description: "This is the first person who recorded a clock in event for this work order."
  }

  dimension_group: first_clock_in_time {
    type: time
    sql: ${TABLE}."FIRST_CLOCK_IN_TIME" ;;
  }

  dimension: response_time {
    type: number
    sql: ${TABLE}."RESPONSE_TIME" ;;
  }

  dimension: first_clock_in_time {
    type: date_time
    group_label: "HTML Format" label: "First Clock In"
    sql: ${TABLE}."FIRST_CLOCK_IN_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: urgency_level {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL" ;;
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
    drill_fields: [mechanic_wo_response_time*]
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    html:
    {% if work_order_type_id._value == 1 %}
    <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">WO-{{rendered_value}}</a></font></u>
    {% else %}
    <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">INSP-{{rendered_value}}</a></font></u>
    {% endif %}
    ;;
  }

  measure: total_work_orders_responded_to {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [wo_response_time*]
  }

  measure: count_critical_urgency_level {
    type: count
    filters: [urgency_level: "Critical"]
    html: Count of Work Orders: {{rendered_value}} ;;
  }

  measure: count_high_urgency_level {
    type: count
    filters: [urgency_level: "High"]
    html: Count of Work Orders: {{rendered_value}} ;;
  }

  measure: count_medium_urgency_level {
    type: count
    filters: [urgency_level: "Medium"]
    html: Count of Work Orders: {{rendered_value}} ;;
  }

  measure: count_low_urgency_level {
    type: count
    filters: [urgency_level: "Low"]
    html: Count of Work Orders: {{rendered_value}} ;;
  }

  measure: critical_urgency_level_avg_response_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "Critical Average Response Time"
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
    drill_fields: [mechanic_wo_response_time*]
    filters: [urgency_level: "Critical"]
  }

  measure: high_urgency_level_avg_response_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "High Average Response Time"
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
    drill_fields: [mechanic_wo_response_time*]
    filters: [urgency_level: "High"]
  }

  measure: medium_urgency_level_avg_response_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "Medium Average Response Time"
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
    drill_fields: [mechanic_wo_response_time*]
    filters: [urgency_level: "Medium"]
  }

  measure: low_urgency_level_avg_response_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "Low Average Response Time"
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
    drill_fields: [mechanic_wo_response_time*]
    filters: [urgency_level: "Low"]
  }

  dimension: urgency_level_text {
    group_label: "Urgency Level Text"
    label: " "
    type: string
    sql: 'Urgency Level' ;;
  }

  set: detail {
    fields: [
      work_orders.link_to_work_order_t3,
      mechanic,
      work_order_user_times.start_date_formatted,
      work_order_user_times.end_date_formatted,
      work_order_user_times.total_hours
    ]
  }

  set: mechanic_wo_response_time {
    fields: [
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      first_clock_in_time,
      avg_response_time
    ]
  }

  set: wo_response_time {
    fields: [
      mechanic,
      markets_branch.name,
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      first_clock_in_time,
      avg_response_time
    ]
  }

}
