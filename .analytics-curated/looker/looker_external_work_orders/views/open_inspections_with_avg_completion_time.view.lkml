view: open_inspections_with_avg_completion_time {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      --from table(assetlist(27961::numeric))
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,completed_wo_inspections as (
      select
          concat(a.make,' ',a.model) as make_and_model,
          datediff(seconds,wut.start_date,wut.end_date) as completed_time
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
      union
      select
          concat(a.make,' ',a.model) as make_and_model,
          sum(overtime_hours + regular_hours) as completed_time
      from
          asset_list_own alo
          inner join work_orders.work_orders wo on wo.asset_id = alo.asset_id
          inner join time_tracking.time_entries er on wo.work_order_id = er.work_order_id
          inner join assets a on a.asset_id = alo.asset_id
      where
          wo.work_order_type_id = 2
          and wo.archived_date is null
          and wo.date_completed is not null
          AND er.event_type_id = 1 --only pulling 'on duty' event types
       group by
          concat(a.make,' ',a.model)
      )
      ,average_time_completed as (
      select
          make_and_model,
          round(avg(completed_time)/3600,2) as total_completed_hours
      from
          completed_wo_inspections
      group by
          make_and_model
      )
      ,open_wo_inspections as (
      select
          concat(a.make,' ',a.model) as make_and_model,
          round(sum(datediff(seconds,wut.start_date,wut.end_date))/3600,2) as time_on_wo,
          wo.work_order_id
      from
          asset_list_own alo
          inner join work_orders.work_orders wo on wo.asset_id = alo.asset_id
          left join work_orders.work_order_user_times wut on wo.work_order_id = wut.work_order_id
          inner join assets a on a.asset_id = alo.asset_id
      where
          wo.work_order_type_id = 2
          and wo.archived_date is null
          and wut.date_deleted is null
          and wo.date_completed is null
      group by
          concat(a.make,' ',a.model),
          wo.work_order_id
      union
      select
          concat(a.make,' ',a.model) as make_and_model,
          round(sum(overtime_hours + regular_hours),2) as time_on_wo,
          wo.work_order_id
      from
          asset_list_own alo
          inner join work_orders.work_orders wo on wo.asset_id = alo.asset_id
          left join time_tracking.time_entries er on wo.work_order_id = er.work_order_id
          inner join assets a on a.asset_id = alo.asset_id
      where
          wo.work_order_type_id = 2
          and wo.archived_date is null
          and wo.date_completed is null
          AND er.event_type_id = 1 --only pulling 'on duty' event types
      group by
          concat(a.make,' ',a.model),
          wo.work_order_id
      )
      select
        ow.work_order_id,
        ow.make_and_model,
        ow.time_on_wo as current_time_spent_on_wo,
        coalesce(ct.total_completed_hours,0) as average_completion_hours
      from
        open_wo_inspections ow
        left join average_time_completed ct on ct.make_and_model = ow.make_and_model
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [time_tracking_detail*]
  }

  dimension: current_time_spent_on_wo {
    type: number
    sql: ${TABLE}."CURRENT_TIME_SPENT_ON_WO" ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} hrs. </a>;;
    # drill_fields: [time_tracking_detail*]
    link: {
      label: "View Time Spent on Inspection"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {{dummy._link}}&f[work_orders_time.work_order_id]=&f[work_orders_time.archived_date]=NULL&vis={{vis | encode_uri}}"
    }
  }

  measure: dummy_two {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [wo_times*]
  }

  dimension: inspection_work_order_id {
    type: string
    sql: concat('INSP-',${work_order_id}) ;;
  }

  dimension: average_completion_hours {
    type: number
    sql: ${TABLE}."AVERAGE_COMPLETION_HOURS" ;;
    html: {{rendered_value}} hrs.;;
    # html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    # # drill_fields: [wo_times*]
    # link: {
    #   label: "View Hours on Completed Inspections by Make and Model"
    #   url: "{% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":\"12\",
    #   \"rows_font_size\":\"12\",
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"show_sql_query_menu_options\":false,
    #   \"column_order\":[\"$$$_row_numbers_$$$\",
    #   \"inspection_time_by_work_order.make_and_model\",
    #   \"inspection_time_by_work_order.view_inspection\",
    #   \"inspection_time_by_work_order.work_order_id\",
    #   \"inspection_time_by_work_order.total_hours\"],
    #   \"show_totals\":true,
    #   \"show_row_totals\":true,
    #   \"series_labels\":{\"inspection_time_by_work_order.view_inspection\":\"Work Order ID\"},
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_two._link}}&vis={{vis | encode_uri}}"
    # }
  }

  dimension: link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">View Work Order</a></font></u> ;;
  }

  dimension: link_to_inspection {
    label: "Inspection ID"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">INSP-{{rendered_value}}</a></font></u> ;;
  }

  dimension: test {
    type: string
    sql: 'Test' ;;
    html: background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='24' height='24'%3E%3Cpath fill='none' d='M0 0h24v24H0z'/%3E%3Cpath d='M10 6v2H5v11h11v-5h2v6a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h6zm11-3v8h-2V6.413l-7.793 7.794-1.414-1.414L17.585 5H13V3h8z' fill='rgba(0,99,243,1)'/%3E%3C/svg%3E") ;;
  }

  # <img alt="svgImg"
  # src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHg9IjBweCIgeT0iMHB4Igp3aWR0aD0iMjAiIGhlaWdodD0iMjAiCnZpZXdCb3g9IjAgMCAxNzIgMTcyIgpzdHlsZT0iIGZpbGw6IzAwMDAwMDsiPjxnIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0ibm9uemVybyIgc3Ryb2tlPSJub25lIiBzdHJva2Utd2lkdGg9IjEiIHN0cm9rZS1saW5lY2FwPSJidXR0IiBzdHJva2UtbGluZWpvaW49Im1pdGVyIiBzdHJva2UtbWl0ZXJsaW1pdD0iMTAiIHN0cm9rZS1kYXNoYXJyYXk9IiIgc3Ryb2tlLWRhc2hvZmZzZXQ9IjAiIGZvbnQtZmFtaWx5PSJub25lIiBmb250LXdlaWdodD0ibm9uZSIgZm9udC1zaXplPSJub25lIiB0ZXh0LWFuY2hvcj0ibm9uZSIgc3R5bGU9Im1peC1ibGVuZC1tb2RlOiBub3JtYWwiPjxwYXRoIGQ9Ik0wLDE3MnYtMTcyaDE3MnYxNzJ6IiBmaWxsPSJub25lIj48L3BhdGg+PGcgZmlsbD0iIzAwNjNmMyI+PHBhdGggZD0iTTE0OC45NTQ2OSwxNy4xNDQwMWMtMC4yMTM2NCwwLjAwNjc1IC0wLjQyNjczLDAuMDI1NDQgLTAuNjM4MjgsMC4wNTU5OWgtMzMuNjQ5NzRjLTIuMDY3NjUsLTAuMDI5MjQgLTMuOTkwODcsMS4wNTcwOSAtNS4wMzMyMiwyLjg0M2MtMS4wNDIzNiwxLjc4NTkyIC0xLjA0MjM2LDMuOTk0NzQgMCw1Ljc4MDY2YzEuMDQyMzYsMS43ODU5MiAyLjk2NTU4LDIuODcyMjUgNS4wMzMyMiwyLjg0M2gyMC41NTkzOGwtNTkuMDEzMDIsNTkuMDEzMDJjLTEuNDk3NzgsMS40MzgwMiAtMi4xMDExMywzLjU3MzQgLTEuNTc3MzUsNS41ODI2YzAuNTIzNzgsMi4wMDkyIDIuMDkyODQsMy41NzgyNiA0LjEwMjA0LDQuMTAyMDRjMi4wMDkyLDAuNTIzNzggNC4xNDQ1OCwtMC4wNzk1NyA1LjU4MjYsLTEuNTc3MzVsNTkuMDEzMDIsLTU5LjAxMzAydjIwLjU1OTM4Yy0wLjAyOTI0LDIuMDY3NjUgMS4wNTcwOSwzLjk5MDg3IDIuODQzLDUuMDMzMjJjMS43ODU5MiwxLjA0MjM2IDMuOTk0NzQsMS4wNDIzNiA1Ljc4MDY2LDBjMS43ODU5MiwtMS4wNDIzNiAyLjg3MjI1LC0yLjk2NTU4IDIuODQzLC01LjAzMzIydi0zMy42NzIxNGMwLjIzMTExLC0xLjY3MDc2IC0wLjI4NTExLC0zLjM1ODUzIC0xLjQxMTI5LC00LjYxNDE1Yy0xLjEyNjE3LC0xLjI1NTYyIC0yLjc0ODA2LC0xLjk1MTcyIC00LjQzNDAyLC0xLjkwMzA0ek0zNC40LDQwLjEzMzMzYy02LjI2Njg5LDAgLTExLjQ2NjY3LDUuMTk5NzcgLTExLjQ2NjY3LDExLjQ2NjY3djg2YzAsNi4yNjY4OSA1LjE5OTc3LDExLjQ2NjY3IDExLjQ2NjY3LDExLjQ2NjY3aDg2YzYuMjY2ODksMCAxMS40NjY2NywtNS4xOTk3NyAxMS40NjY2NywtMTEuNDY2Njd2LTU3LjMzMzMzdi0xNC43ODEyNWwtMTEuNDY2NjcsMTEuNDY2Njd2MTQuNzgxMjV2NDUuODY2NjdoLTg2di04Nmg0NS44NjY2N2gxMS40NjY2N2gzLjMxNDU4bDExLjQ2NjY3LC0xMS40NjY2N2gtMTQuNzgxMjVoLTExLjQ2NjY3eiI+PC9wYXRoPjwvZz48L2c+PC9zdmc+"/>

  set: time_tracking_detail {
    fields: [work_order_id, link_to_inspection, users.mechanic, work_order_user_times.start_date_formatted, work_order_user_times.end_date_formatted, work_order_user_times.total_hours, work_order_user_times.description]
  }

  set: wo_times {
    fields: [inspection_time_by_work_order.make_and_model, inspection_time_by_work_order.view_inspection, inspection_time_by_work_order.total_hours]
  }

  set: detail {
    fields: [work_order_id, link_to_inspection, make_and_model, current_time_spent_on_wo, average_completion_hours]
  }
}
