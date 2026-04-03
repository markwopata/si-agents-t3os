view: work_order_user_times {
  derived_table: {
    sql: with pre as (select
          work_order_id,
          NULL as time_entry_id,
          NULL as job_id,
          wout.date_created,
          u.user_id,
          start_date,
          end_date,
          round(datediff(seconds,start_date,end_date)/3600,2) as hours
       from
          work_orders.work_order_user_times wout
          join users u on u.user_id = wout.user_id
      where
          u.company_id = {{ _user_attributes['company_id'] }}::numeric
      union
      select
          work_order_id,
          er.time_entry_id,
          er.job_id,
          er.created_date,
          u.user_id,
          start_date,
          end_date,
          round(overtime_hours + regular_hours,2) as hours
      from
          time_tracking.time_entries er
          join users u on u.user_id = er.user_id
      where
          u.company_id = {{ _user_attributes['company_id'] }}::numeric
          and er.work_order_id is not null
          AND er.event_type_id = 1 --only pulling 'on duty' event types

        ) , phases as (
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
        pre.*
         , wc.work_code_id
      , coalesce(wc.custom_id, 'No Work Code Assigned') as work_code_custom_id
      , coalesce(wc.name, 'No Work Code Assigned') as work_code
      , coalesce(j.job_name, 'No Job Assigned') as job_name
      , coalesce(j.phase_job_name, 'No Job Phase Assigned') as phase_name
        from
        pre
         left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRY_WORK_CODE_XREF te on te.time_entry_id = pre.time_entry_id
                left join ES_WAREHOUSE.time_tracking.work_codes wc on wc.work_code_id = te.work_code_id
                left join jobs_list j on j.job_id = pre.job_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${work_order_id},${date_created_raw},${user_id},${hours}) ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: time_entry_id {
    type: number
    sql: ${TABLE}."TIME_ENTRY_ID" ;;
  }

  dimension: work_code_id {
    type: number
    sql: ${TABLE}."WORK_CODE_ID" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension_group: current_date {
    type: time
    sql: ${TABLE}."CURRENT_DATE" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension_group: start_date {
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: start_date_formatted {
    type: date_time
    group_label: "HTML Passed Date Format" label: "Start Date"
    sql: ${start_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: end_date_formatted {
    type: date_time
    group_label: "HTML Passed Date Format" label: "End Date"
    sql: ${end_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: total_hours {
    type: number
    sql: ${hours} ;;
    value_format_name: decimal_2
  }

  measure: kpi_total_open_work_hours_last_7_days {
    label: "Open Work Orders"
    filters: [ work_order_user_times.date_created_date: "Last 7 Days",work_orders.work_order_type_id: "1",work_orders.date_completed_date: "NULL",work_orders.archived_date: "NULL"  ]
    type: sum
    sql: ${total_hours} ;;
    value_format_name: decimal_2
    drill_fields: [kpi_time_tracking*]
    html:  {{rendered_value}} hrs. ;;
  }

  measure: kpi_total_closed_work_hours_last_7_days {
    label: "Closed Work Orders"
    filters: [ work_orders.date_completed_date: "Last 7 Days",work_orders.work_order_type_id: "1",work_orders.archived_date: "NULL"  ]
    type: sum
    sql:  ${total_hours}  ;;
    value_format_name: decimal_2
    drill_fields: [kpi_time_tracking*]
    html:  {{rendered_value}} hrs. ;;
    }

  measure: total_work_hours {
    type: sum
    sql: ${total_hours} ;;
    value_format_name: decimal_2
    drill_fields: [time_tracking*]
    html: <a href="#drillmenu" target="_self"><font color="#000000"> {{rendered_value}} hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"> </font></a>;;
  }

  measure: total_work_hours_calc {
    label: "Total Work Hours"
    type: sum
    sql: ${total_hours} ;;
    value_format_name: decimal_0
    drill_fields: [kpi_time_tracking*]
    html: {{rendered_value}} hrs.;;
  }

  dimension: view_time_tracking_entries {
    type: string
    sql: 'View Time Tracking Entries' ;;
    drill_fields: [time_tracking*]
  }

  set: kpi_time_tracking {
    fields: [work_orders.link_to_work_order, work_orders.days_open_uncompleted_wo, total_work_hours]
  }


  set: time_tracking {
    fields: [work_orders.link_to_work_order, users.mechanic, start_date_formatted, end_date_formatted, total_hours]
  }

  set: detail {
    fields: [work_order_id, user_id, start_date_time, end_date_time, hours]
  }
}
