view: date_range_test {

  # derived_table: {
  #   sql:
  #   select
  #   max({% date_end date_filter %}) as selected_range_end_date,
  #   max({% date_start date_filter %}) as selected_range_start_date,
  #   max(dateadd(day,-1,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))) as previous_range_end_date,
  #   max(dateadd(day,datediff(day,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))) as previous_range_start_date
  #   ;;
  # }

  derived_table: {
    sql:
    select
    max({% date_end date_filter %}) as selected_range_end_date,
    max({% date_start date_filter %}) as selected_range_start_date,
    max(dateadd(day,-1,{% date_start date_filter %})) as previous_range_end_date,
    max(dateadd(day,datediff(day,{% date_end date_filter %},{% date_start date_filter %}),{% date_start date_filter %})) as previous_range_start_date
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

}
