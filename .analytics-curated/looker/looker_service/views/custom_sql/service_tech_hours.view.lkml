view: service_tech_expected_hours {
  sql_table_name:"ANALYTICS"."SERVICE"."SERVICE_TECH_WO_DETAIL";;

drill_fields: [detail*]

  dimension: selected_hierarchy {
      type: string
      sql:{% if market_region_xwalk.market_name._in_query %}
            ${employee_name}
          {% elsif  market_region_xwalk.district._in_query %}
            ${market_region_xwalk.market_name}
          {% else %}
            ${market_region_xwalk.district}
          {% endif %};;
  }
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

  dimension: tech_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.emp_hours ;;
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
    sql: ${TABLE}.total_billed_hours ;;
  }

  dimension: billed_hours_share {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.billed_hours_share ;;
  }

  dimension: total_hours_on_work_order {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.wo_hours ;;
  }

  dimension: expected_wo_hours {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.expected_wo_hours ;;
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

  measure: total_tech_wo_hours {
    type: sum
    value_format: "0.##"
    sql: ${tech_hours} ;;
  }

  measure: total_tech_expected_wo_hours{
    type: sum
    value_format: "0.##"
    sql: ${expected_tech_hours} ;;
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

  set: detail {
    fields: [employee_name
        , market_region_xwalk.market_name
        , completed_date
        , severity_level
        , work_orders.work_order_id_with_link_to_work_order
        , description
        , tech_hours
        , regular_hours
        , overtime_hours
        , expected_tech_hours
        , billed_hours_share
        , total_hours_on_work_order
        , expected_wo_hours
        , total_billed_hours
        ]
  }
}
