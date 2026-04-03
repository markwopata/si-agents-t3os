view: wo_response_time {
  derived_table: {
    sql: with first_clock_in_events as (
      select
        work_order_id,
        min(start_date) as start_date
      from
        es_warehouse.work_orders.work_order_user_times wout
        join es_warehouse.public.users u on u.user_id = wout.user_id
      --where

        --u.company_id = 50::numeric
      group by
        work_order_id
      union
      select
        work_order_id,
        min(start_date) as start_date
      from
        es_warehouse.time_tracking.time_entries te
        join es_warehouse.public.users u on u.user_id = te.user_id
      where
        te.work_order_id is not null
        AND te.event_type_id = 1 --only pulling 'on duty' event types
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
          wo.date_created,
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
          es_warehouse.work_orders.work_orders wo
          join es_warehouse.public.markets m on m.market_id = wo.branch_id
          join first_clock_in_events_agg fli on fli.work_order_id = wo.work_order_id
      where
          wo.date_created BETWEEN convert_timezone('UTC', {% date_start date_filter %}::timestamp_ntz) AND convert_timezone('UTC', {% date_end date_filter %}::timestamp_ntz)
          AND wo.archived_date is null
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
    sql: ${TABLE}."FIRST_CLOCK_IN_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}};;
    skip_drill_filter: yes
  }

  dimension: wo_date_created {
    group_label: "HTML Format" label: "WO Date Created"
    sql: ${TABLE}."DATE_CREATED" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}};;
    skip_drill_filter: yes
  }

  dimension_group: wo_create_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  parameter: view_data_in {
    type: string
    allowed_value: { value: "Hours"}
    allowed_value: { value: "Minutes"}
    allowed_value: { value: "Seconds"}
  }

  filter: date_filter {
    type: date
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
    <img src="https://i.ibb.co/3czBQcM/Gear-447.png" height="15" width="15">
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
      market_region_xwalk.market_name,
      work_orders.work_order_id_with_link_to_work_order,
      wo_date_created,
      first_clock_in_time,
      avg_response_time
    ]
  }
}
