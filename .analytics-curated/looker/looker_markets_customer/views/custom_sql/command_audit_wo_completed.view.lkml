view: command_audit_wo_completed {
  derived_table: {
    sql:
    SELECT
    *
    FROM ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT AS CA
    WHERE CA.COMMAND = 'CloseWorkOrder'
    AND CA.DATE_CREATED > CURRENT_TIMESTAMP()::DATE - interval '3 months'
 ;;
  }

  dimension: command_audit_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: audit_event_source_id {
    type: number
    sql: ${TABLE}."AUDIT_EVENT_SOURCE_ID" ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }

  dimension_group: date_created {
    type: time
    label: "WO close"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${parameters}:work_order_id  ;;
  }

  dimension:  command_is_last_month {
    type: yesno
    sql: date_part(month,${date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
      and date_part(year,${date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  command_is_current_month {
    type: yesno
    sql: date_part(day,${date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${date_created_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: close_work_order_command {
    type: yesno
    sql: ${command} = 'CloseWorkOrder' ;;
  }

  dimension: work_order_is_null {
    type: yesno
    sql: ${work_order_id} IS NULL ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  measure: total_work_orders_last_month {
    type: count
    filters: [close_work_order_command: "Yes" ,
      work_order_is_null: "No",
      command_is_last_month: "Yes"]
    drill_fields: [employee_branch_ukg.full_employee_name, date_created_date, work_order_id_with_link_to_work_order]
  }

  measure: total_work_orders_mtd {
    type: count
    filters: [close_work_order_command: "Yes" ,
      work_order_is_null: "No",
      command_is_current_month: "Yes"]
    drill_fields: [employee_branch_ukg.full_employee_name, date_created_date, work_order_id_with_link_to_work_order]
  }

  measure: count {
    type: count
    drill_fields: [command_audit_id]
  }
}
