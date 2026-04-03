view: wo_branch_avg_response_completion_time {
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
      where
        u.company_id = {{ _user_attributes['company_id'] }}::numeric
        --u.company_id = 50::numeric
        and er.work_order_id is not null
        AND er.event_type_id = 1 --only pulling 'on duty' event types
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
          {% else %}
          1
          {% endif %}
          as response_time
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
          join first_clock_in_events_agg fli on fli.work_order_id = wo.work_order_id
      where
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start wo_response_completion_time.date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end wo_response_completion_time.date_filter %})
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
          {% else %}
          1
          {% endif %}
          as completion_time
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
      where
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start wo_response_completion_time.date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end wo_response_completion_time.date_filter %})
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
          wo.date_completed BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start wo_response_completion_time.date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end wo_response_completion_time.date_filter %})
          OR
          wo.date_created BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start wo_response_completion_time.date_filter %}) AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end wo_response_completion_time.date_filter %})
          --wo.date_created BETWEEN convert_timezone('UTC', '2021-10-20'::timestamp_ntz) AND convert_timezone('UTC', '2021-10-29'::timestamp_ntz)
          )
          AND wo.work_order_type_id = 1
      )
      select
          bpc.branch_id,
          avg(response_time) as average_response_time,
          avg(completion_time) as average_completion_time
      from
          branches_per_company bpc
          left join completion_time_per_wo ct on ct.work_order_id = bpc.work_order_id AND ct.branch_id = bpc.branch_id
          left join response_time_per_wo rt on rt.work_order_id = bpc.work_order_id AND rt.branch_id = bpc.branch_id
      group by
          bpc.branch_id
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

  dimension: average_response_time {
    type: number
    sql: ${TABLE}."AVERAGE_RESPONSE_TIME" ;;
    value_format_name: decimal_2
  }

  dimension: average_completion_time {
    type: number
    sql: ${TABLE}."AVERAGE_COMPLETION_TIME" ;;
    value_format_name: decimal_2
  }

  filter: date_filter {
    type: date_time
  }

  filter: employee_name_filter {
    type: string
    #suggest_explore: wo_detailed_time_entrys
    #suggest_dimension: employee_names.time_entry_user_name
  }

  parameter: view_data_in {
    type: string
    allowed_value: { value: "Hours"}
    allowed_value: { value: "Minutes"}
    allowed_value: { value: "Seconds"}
  }

  set: detail {
    fields: [branch_id, average_response_time, average_completion_time]
  }
}
