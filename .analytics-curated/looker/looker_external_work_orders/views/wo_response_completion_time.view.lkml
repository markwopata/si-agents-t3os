view: wo_response_completion_time {
  derived_table: {
    sql: with phases as (
          select
            j.name as phase_job_name
          , j.job_id as phase_job_id
          , jp.name as job_name
          , jp.job_id as job_id
          from
          es_warehouse.public.jobs j
          left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
          where j.parent_job_id is not null
          )
          , job_name_list as (
          select
            NULL as phase_job_name
          , NULL as phase_job_id
          , j.name as job_name
          , j.job_id as job_id
          from
          es_warehouse.public.jobs j
          where
          j.parent_job_id is null
          )
          , jobs_list as (
          Select * from phases
          UNION
          Select * from job_name_list
          )
          , first_clock_in_events as (
      select
        work_order_id,
        min(start_date) as start_date
      from
        work_orders.work_order_user_times wout
        join users u on u.user_id = wout.user_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        and {% condition employee_name_filter %} concat(u.first_name, ' ', u.last_name) {% endcondition %}
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
        left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRY_WORK_CODE_XREF te on te.time_entry_id = er.time_entry_id
        left join ES_WAREHOUSE.time_tracking.work_codes wc on wc.work_code_id = te.work_code_id
        left join jobs_list j on j.job_id = er.job_id
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        --u.company_id = 50::numeric
        and er.work_order_id is not null
        AND er.event_type_id = 1 --only pulling 'on duty' event types
        and {% condition job_filter %} j.job_name {% endcondition %}
        AND {% condition phase_filter %} j.phase_name {% endcondition %}
        AND {% condition work_code_filter %} wc.name {% endcondition %}
        and {% condition employee_name_filter %} concat(u.first_name, ' ', u.last_name) {% endcondition %}
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
      , response_time_per_wo as (
      select
          m.market_id as branch_id,
          wo.work_order_id,
          fli.first_clock_in as first_clock_in_time,
          datediff(seconds,wo.date_created,fli.first_clock_in)/
          {% if view_data_in._parameter_value == "'Minutes'" %}
          60
          {% elsif view_data_in._parameter_value == "'Hours'" %}
          3600
          {% elsif view_data_in._parameter_value == "'Days'" %}
          86400
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
          --wo.date_created BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          AND wo.archived_date is null
          --AND m.company_id = 50::numeric
          AND m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND wo.work_order_type_id = 1
          AND wo.date_created <= fli.first_clock_in

      )
      , completion_time_per_wo as (
      select
          m.market_id as branch_id,
          wo.work_order_id,
          datediff(seconds,wo.date_created,wo.date_completed)/
          {% if view_data_in._parameter_value == "'Minutes'" %}
          60
          {% elsif view_data_in._parameter_value == "'Hours'" %}
          3600
          {% elsif view_data_in._parameter_value == "'Days'" %}
          86400
          {% else %}
          1
          {% endif %}
          as completion_time
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
      where
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          --wo.date_completed BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          AND wo.archived_date is null
          AND m.company_id = {{ _user_attributes['company_id'] }}::numeric
          --AND m.company_id = 50::numeric
          AND wo.work_order_type_id = 1
      )
      ,branches_per_company as (
      select
          m.market_id as branch_id,
          wo.work_order_id
      from
          work_orders.work_orders wo
          join markets m on wo.branch_id = m.market_id
      where
          --m.company_id = 50::numeric
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND (
          --wo.date_completed BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          OR
          --wo.date_created BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          )
          AND wo.work_order_type_id = 1
      )
      select
          bpc.branch_id,
          bpc.work_order_id,
          first_clock_in_time,
          response_time,
          completion_time
      from
          branches_per_company bpc
          left join completion_time_per_wo ct on ct.work_order_id = bpc.work_order_id AND ct.branch_id = bpc.branch_id
          left join response_time_per_wo rt on rt.work_order_id = bpc.work_order_id AND rt.branch_id = bpc.branch_id
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
    primary_key: yes
  }

  dimension: first_clock_in_time {
    type: date_time
    group_label: "HTML Format" label: "First Clock In"
    sql: ${TABLE}."FIRST_CLOCK_IN_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: response_time {
    type: number
    sql: ${TABLE}."RESPONSE_TIME" ;;
  }

  dimension: completion_time {
    type: number
    sql: ${TABLE}."COMPLETION_TIME" ;;
  }

  parameter: view_data_in {
    type: string
    allowed_value: { value: "Days"}
    allowed_value: { value: "Hours"}
    allowed_value: { value: "Minutes"}
    allowed_value: { value: "Seconds"}
  }

  filter: date_filter {
    type: date_time
  }

  filter: work_code_filter {
    type: string
  }

  filter: job_filter {
    type: string
  }

  filter: phase_filter {
    type: string
  }

  filter: employee_name_filter {
    type: string
    #suggest_explore: wo_detailed_time_entrys
    #suggest_dimension: employee_names.time_entry_user_name
  }

  measure: total_completion_time {
    group_label: "Completion Time in Measure Format"
    label: "Completion Time"
    type: max
    sql: ${completion_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{ rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{ rendered_value }} days
    {% else %}
    {{ rendered_value }} secs.
    {% endif %}
    </font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>;;
    drill_fields: [detail*]
  }

  measure: total_response_time {
    group_label: "Response Time in Measure Format"
    label: "Response Time"
    type: max
    sql: ${response_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{ rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{ rendered_value }} days
    {% else %}
    {{ rendered_value }} secs.
    {% endif %}
    </font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>;;
    drill_fields: [detail*]
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
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{ rendered_value }} days
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
    {{ rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{ rendered_value }} days
    {% else %}
    {{ rendered_value }} secs.
    {% endif %}
    </font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>
    ;;
    drill_fields: [detail*]
    #<img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
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
    {{ avg_response_time._rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{ avg_response_time._rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{ avg_response_time._rendered_value }} Days
    {% else %}
    {{ avg_response_time._rendered_value }} secs.
    {% endif %}
    </a>
    ;;
    drill_fields: [branch_wo_response_time*]
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
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} days
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    </font>
    </a>
    ;;
    drill_fields: [wo_completion_time*]
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
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} days
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    </a>
    ;;
    drill_fields: [detail*]
    #<img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
  }

  measure: avg_completion_time_bar_chart {
    group_label: "Bar Chart KPI"
    label: "Average Completion Time"
    type: average
    sql: ${completion_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ avg_response_time._rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{ avg_response_time._rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} Days
    {% else %}
    {{ avg_response_time._rendered_value }} secs.
    {% endif %}
    </a>
    ;;
    drill_fields: [branch_wo_completion_time*]
  }

  measure: avg_response_time_scatter {
    type: average
    sql: ${response_time} ;;
    value_format_name: decimal_2
    html:
    <a href="#drillmenu" target="_self">
    {% if view_data_in._parameter_value == "'Hours'" %}
    <p>Average Response Time</p>
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{ rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} days
    {% else %}
    {{ rendered_value }} secs.
    {% endif %}
    </a>
    ;;
    drill_fields: [detail*]
    #<img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
  }

  set: detail {
    fields: [
      work_orders.link_to_work_order_t3,
      users.mechanic,
      work_order_user_times.start_date_formatted,
      work_order_user_times.end_date_formatted,
      work_order_user_times.total_hours
    ]
  }

  set: branch_wo_completion_time {
    fields: [
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      work_orders.date_time_completed_formatted,
      total_completion_time
    ]
  }

  set: wo_completion_time {
    fields: [
      markets_branch.name,
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      work_orders.date_time_completed_formatted,
      total_completion_time
    ]
  }

  set: branch_wo_response_time {
    fields: [
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      first_clock_in_time,
      total_response_time
    ]
  }

  set: wo_response_time {
    fields: [
      markets_branch.name,
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      first_clock_in_time,
      total_response_time
    ]
  }
}
