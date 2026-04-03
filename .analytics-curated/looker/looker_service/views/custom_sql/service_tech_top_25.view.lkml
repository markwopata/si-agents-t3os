view: service_tech_top_25 {
  sql_table_name:"ANALYTICS"."SERVICE"."SERVICE_TECH_WO_MIX";;

  drill_fields: [detail*]

  dimension: unused_parts_percentage {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.unused_parts_percent ;;
  }


  dimension: parts_orders {
    type: number
    sql: ${TABLE}.order_count ;;
  }

  dimension: tech_id {
    type:  string
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}.employee_name ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.branch_id  ;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: expected_tech_hours {
    type:  number
    value_format: "0.##"
    sql: ${TABLE}.expected_emp_hours ;;
  }

  dimension: regular_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.reg_hours ;;
  }

  dimension: overtime_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.ot_hours ;;
  }

  dimension: total_billed_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.billed_hours ;;
  }

  dimension: billed_hours_share {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.billed_hours_share ;;
  }

  dimension: tech_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.emp_hours ;;
  }

  dimension: total_hours_on_work_order {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.wo_hours ;;
  }

  dimension: expected_wo_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.exp_wo_hours ;;
  }

  dimension: employees_on_wo {
    type: number
    sql: ${TABLE}.employees_on_wo ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension_group: completed {
    type: time
    timeframes: [date,week, month,year]
    sql: convert_timezone('America/Chicago',${TABLE}.date_completed) ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: severity_level {
    type: string
    sql: ${TABLE}.severity_level_name ;;
  }

  dimension: wo_type {
    type: string
    sql:  ${TABLE}.wo_type ;;
  }

  dimension: seven_day_breakdown {
    type: string
    sql: ${TABLE}.seven_day_breakdown ;;
  }

  measure: work_order_count {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  measure: total_tech_wo_hours {
    type: sum
    value_format: "0.##"
    sql: ${tech_hours} ;;

  }

  measure: total_tech_expected_wo_hours{
    type: sum
    value_format: "0.##"
    sql: ${expected_tech_hours} ;;
    drill_fields: [detail*]
  }

  dimension: tech_type {
    type: string
    sql: ${TABLE}.tech_type ;;
  }
  measure: work_order_closures {
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [tech_type: "Closer"]
  }

  # dimension: work_order_id_with_link {
  #   type: string
  #   sql: ${work_order_id} ;;
  #   html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  # }

  set: detail {
    fields: [employee_name
        ,completed_date
        ,market_id
        ,work_orders.work_order_id_with_link_to_work_order
        , severity_level
        ,description
        ,asset_id
        , tech_hours
        , regular_hours
        , overtime_hours
        , expected_tech_hours
        , billed_hours_share
        , total_billed_hours
        ,unused_parts_percentage
        ,parts_orders
        , tech_type
        ,seven_day_breakdown]
  }
}
