view: wo_detailed_time_entrys {
  derived_table: {
    sql: with work_order_duration as (
      select
        wout.WORK_ORDER_ID
      , NULL as time_entry_id
      , NULL as job_id
      , wout.USER_ID
      , wout.start_date
      , wout.end_date
      , datediff('seconds', wout.start_date , wout.end_date)  as duration
       from
              work_orders.work_order_user_times wout
              join users u on u.user_id = wout.user_id
              where
              u.company_id = {{ _user_attributes['company_id'] }}::numeric
               and date_deleted is not null
              -- and {% condition employee_name_filter %} concat(u.first_name, ' ', u.last_name) {% endcondition %}

      union

      select
        er.work_order_id
      , er.time_entry_id
      , er.job_id
      , er.user_id
      , er.start_date
      , er.end_date
      , datediff('seconds',er.start_date , er.end_date) as duration
      --, er.regular_hours
      --, er.overtime_hours
      from
              time_tracking.time_entries er
              join users u on u.user_id = er.user_id
            where
              u.company_id = {{ _user_attributes['company_id'] }}::numeric
              --u.company_id = 50::numeric
              and er.work_order_id is not null
              AND er.event_type_id = 1
              -- and {% condition employee_name_filter %} concat(u.first_name, ' ', u.last_name) {% endcondition %}
              order by work_order_id
      )
       , phases as (
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
      select
        wo.work_order_id
      , m.market_id as branch_id
      , wo.work_order_status_name
      , wo.description
      , wo.date_created as work_order_date_created
      , wo.date_completed as work_order_date_completed
      , wo.urgency_level_name
      , wo.severity_level_name
      , wo.work_order_type_name
      , wo.creator_user_id
      --, wo.*
      , wd.time_entry_id
      , wd.user_id as time_entry_user_id
      , u2.user_id as time_entry_user_id_name
      , concat(u2.first_name, ' ', u2.last_name) as time_entry_user_name
      , LISTAGG(
          DISTINCT concat(u2.first_name, ' ', u2.last_name),
          ', '
        ) WITHIN GROUP (ORDER BY concat(u2.first_name, ' ', u2.last_name))
        OVER (PARTITION BY wo.work_order_id) as employee_names_list
      , wd.start_date as time_entry_start
      , wd.end_date as time_entry_end
      , wd.duration /
      {% if view_data_in._parameter_value == "'Minutes'" %}
          60
          {% elsif view_data_in._parameter_value == "'Hours'" %}
          3600
          {% elsif view_data_in._parameter_value == "'Days'" %}
          3600 / 24
          {% else %}
          1
          {% endif %}
          as duration
      , wc.work_code_id
      , coalesce(wc.custom_id, 'No Work Code Assigned') as work_code_custom_id
      , coalesce(wc.name, 'No Work Code Assigned') as work_code
      , j.job_id
      , coalesce(j.job_name, 'No Job Assigned') as job_name
      , coalesce(j.phase_job_name, 'No Job Phase Assigned') as phase_name

      from
      work_order_duration wd
                left join  work_orders.work_orders wo  on wo.work_order_id = wd.work_order_id
                left join users u on u.user_id = wo.creator_user_id
                left join users u2 on u2.user_id = wd.user_id
                left join markets m on m.market_id = wo.branch_id
                left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRY_WORK_CODE_XREF te on te.time_entry_id = wd.time_entry_id
                left join ES_WAREHOUSE.time_tracking.work_codes wc on wc.work_code_id = te.work_code_id
                left join jobs_list j on j.job_id = wd.job_id
               where wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start wo_response_completion_time.date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end wo_response_completion_time.date_filter %})
              and {% condition job_filter %} j.job_name {% endcondition %}
              AND {% condition phase_filter %} j.phase_name {% endcondition %}
              AND {% condition work_code_filter %} wc.name {% endcondition %}
              {% if employee_name_filter._is_filtered %}
              AND (
                EXISTS (
                  SELECT 1
                  FROM time_tracking.time_entries er2
                  JOIN users ux ON ux.user_id = er2.user_id
                  WHERE er2.work_order_id = wo.work_order_id
                    AND er2.event_type_id = 1
                    AND ux.company_id = {{ _user_attributes['company_id'] }}::numeric
                    AND {% condition employee_name_filter %} concat(ux.first_name, ' ', ux.last_name) {% endcondition %}
                )
                OR EXISTS (
                  SELECT 1
                  FROM work_orders.work_order_user_times wout2
                  JOIN users ux2 ON ux2.user_id = wout2.user_id
                  WHERE wout2.work_order_id = wo.work_order_id
                    AND ux2.company_id = {{ _user_attributes['company_id'] }}::numeric
                    AND wout2.date_deleted IS NOT NULL
                    AND {% condition employee_name_filter %} concat(ux2.first_name, ' ', ux2.last_name) {% endcondition %}
                )
              )
            {% endif %}

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
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{value}}/updates" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: work_order_date_created {
    type: time
    sql: ${TABLE}."WORK_ORDER_DATE_CREATED" ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  dimension_group: work_order_date_completed {
    type: time
    sql: ${TABLE}."WORK_ORDER_DATE_COMPLETED" ;;
    html: {{rendered_value | date: "%b %d, %Y"}} ;;
  }

  dimension: urgency_level_name {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL_NAME" ;;
  }

  dimension: severity_level_name {
    type: string
    sql: ${TABLE}."SEVERITY_LEVEL_NAME" ;;
  }

  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  dimension: time_entry_id {
    type: number
    sql: ${TABLE}."TIME_ENTRY_ID" ;;
  }

  dimension: time_entry_user_id {
    type: number
    sql: ${TABLE}."TIME_ENTRY_USER_ID" ;;
  }

  dimension: time_entry_user_id_name {
    type: number
    sql: ${TABLE}."TIME_ENTRY_USER_ID_NAME" ;;
  }

  dimension: time_entry_user_name {
    type: string
    sql: ${TABLE}."TIME_ENTRY_USER_NAME" ;;
  }

  dimension: employee_names_list {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAMES_LIST" ;;
  }


  dimension: work_code_id {
    type: number
    sql: ${TABLE}."WORK_CODE_ID" ;;
  }

  dimension: work_code_custom_id {
    type: string
    sql: ${TABLE}."WORK_CODE_CUSTOM_ID" ;;
  }

  dimension: work_code {
    type: string
    sql: ${TABLE}."WORK_CODE" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: phase_name {
    type: string
    sql: ${TABLE}."PHASE_NAME" ;;
  }

  dimension_group: time_entry_start {
    type: time
    sql: ${TABLE}."TIME_ENTRY_START" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: time_entry_end {
    type: time
    sql: ${TABLE}."TIME_ENTRY_END" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

  parameter: view_data_in {
    type: string
    allowed_value: { value: "Hours"}
    allowed_value: { value: "Minutes"}
    allowed_value: { value: "Seconds"}
    allowed_value: { value: "Days"}
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
  }

  measure: duration_variable_times_kpi {
    label: "Duration"
    type: sum
    sql: ${duration} ;;
    value_format_name: decimal_2
    drill_fields: [work_order_detail*]
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} days.
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    </font>
    </a>
    ;;
  }

  measure: distinct_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  measure: duration_average {
    label: "Average Duration"
    type: number
    sql: DIV0(${duration_variable_times_kpi} , ${distinct_work_orders}) ;;
    value_format_name: decimal_2
    drill_fields: [work_order_detail*]
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {% if view_data_in._parameter_value == "'Hours'" %}
    {{ rendered_value }} hrs.
    {% elsif view_data_in._parameter_value == "'Minutes'"%}
    {{rendered_value }} mins.
    {% elsif view_data_in._parameter_value == "'Days'"%}
    {{rendered_value }} days.
    {% else %}
    {{rendered_value }} secs.
    {% endif %}
    </font>
    </a>
    ;;
  }

  set: detail {
    fields: [
      work_order_id,
      work_order_status_name,
      description,
      work_order_date_created_time,
      work_order_date_completed_time,
      urgency_level_name,
      severity_level_name,
      work_order_type_name,
      creator_user_id,
      time_entry_user_id,
      time_entry_user_name,
      time_entry_start_time,
      time_entry_end_time,
      duration
    ]
  }

  set: work_order_detail {
    fields: [
      work_order_id,
      work_order_status_name,
      description,
      work_order_date_created_time,
      work_order_date_completed_time,
      urgency_level_name,
      severity_level_name,
      work_order_type_name,
      time_entry_user_name,
      time_entry_start_time,
      time_entry_end_time,
      duration
    ]
  }

}
