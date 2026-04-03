include: "/_base/analytics/service/overdue_inspections_snapshot.view.lkml"

view: most_recent_per_record {
  derived_table: {
    sql:
    select
      *
    from ${overdue_inspections_snapshot.SQL_TABLE_NAME} as ois
    qualify row_number() over (partition by ois.SERVICE_RECORD_ID order by DATE_OF desc) = 1 ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension_group: current_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }
  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }
  dimension_group: date_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF" ;;
  }
  dimension_group: last_service_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_SERVICE_TIME_VALUE" ;;
  }
  dimension: last_service_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_USAGE_VALUE" ;;
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
    value_format_name: id
  }
  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension_group: next_service_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }
  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }
  dimension: on_rent_flag {
    type: yesno
    sql: ${TABLE}."ON_RENT_FLAG" ;;
  }
  dimension: overdue_flag {
    type: number
    sql: ${TABLE}."OVERDUE_FLAG" ;;
  }
  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }
  dimension: service_interval_type_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: service_interval_type_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_TYPE_NAME" ;;
  }
  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
    value_format_name: id
  }
  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
    value_format_name: id
  }
  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }
  dimension: until_next_service_usage {
    type: number
    sql: zeroifnull(${TABLE}."UNTIL_NEXT_SERVICE_USAGE") ;;
  }
  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
    value_format_name: id
  }
  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }
  measure: pm_acceptance {
    type: yesno
    sql: ${time_entries.total_total_hours} > 0 and ${work_order_parts.total_part_cost} > 0 and ${work_order_files.images_attached} > 2 ;;
  }
  measure: status {
    type: string
    sql: case
          when ${work_orders.date_completed_date} is not null and ${pm_acceptance} then 'Complete'
          when ${work_orders.date_completed_date} is not null and ${pm_acceptance} = 'No' then 'Missing Info'
          when ${work_orders.date_completed_date} is null and ${until_next_service_usage} < 0 then 'Overdue'
          else 'Due Soon' end;;
    html:
    {% if value == 'Complete' %}
    <p style="color: black; background-color: lightgreen;">{{ value }}</p>
    {% elsif value == 'Missing Info' %}
    <p style="color: black; background-color: yellow;">{{ value }}</p>
    {% elsif value == 'Overdue' %}
    <p style="color: white; background-color: red;">{{ value }}</p>
    {% else %}
    <p style="color: black; background-color: white;">{{ value }}</p>
    {% endif %}
    ;;
  }
}
