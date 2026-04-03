view: date_range_html {

  derived_table: {
    sql:
select
max({% date_end date_filter %}) as selected_range_end_date,
max({% date_start date_filter %}) as selected_range_start_date,
max(dateadd(day,-1,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))) as previous_range_end_date,
max(dateadd(day,datediff(day,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))) as previous_range_start_date
;;
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  dimension_group: selected_range_start_date {
    type: time
    sql: ${TABLE}."SELECTED_RANGE_START_DATE" ;;
  }

  dimension_group: selected_range_end_date {
    type: time
    sql: ${TABLE}."SELECTED_RANGE_END_DATE" ;;
  }

  dimension_group: previous_range_start_date {
    type: time
    sql: ${TABLE}."PREVIOUS_RANGE_START_DATE" ;;
  }

  dimension_group: previous_range_end_date {
    type: time
    sql: ${TABLE}."PREVIOUS_RANGE_END_DATE" ;;
  }

  dimension: range_text {
    type: string
    sql: ${selected_range_start_date_date} ;;
    html:
    <div style="border-radius: 10px; background-color: #fff; color: #000000;">
        <p style="font-size: 1.5rem; height: 1.8rem"><strong>Selected Period</strong></p>
        <p style="font-size: 1.5rem; height: 2.4rem">{{selected_range_start_date_date._rendered_value}} - {{selected_range_end_date_date._rendered_value}}</p>
        <p style="font-size: 1.5rem; height: 0.4rem"></p>
        <p style="font-size: 1.5rem; height: 1.8rem"><strong>Previous Period</strong></p>
        <p style="font-size: 1.5rem; height: 2.4rem">{{previous_range_start_date_date._rendered_value}} - {{previous_range_end_date_date._rendered_value}}</p>
        <p style="font-size: 1.5rem; height: 1.2rem"></p>
    </div> ;;
  }

}
