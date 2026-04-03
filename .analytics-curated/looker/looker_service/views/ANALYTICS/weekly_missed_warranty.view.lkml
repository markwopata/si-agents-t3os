view: weekly_missed_warranty {
  sql_table_name: ANALYTICS.WARRANTIES.WEEKLY_MISSED_WARRANTY ;;

  dimension: work_order_id {
    type: string
    sql: ${TABLE}.work_order_id ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type;;
  }

  dimension: completed {
    type: date
    sql: ${TABLE}.date_completed ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.branch_name ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model;;
  }

  dimension: asset_year {
    type: number
    value_format_name: id
    sql: ${TABLE}.year;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.class;;
  }

  dimension: serial_number{
    type: string
    sql: ${TABLE}.serial_number;;
  }

  dimension: oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}.oec ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}.hours_at_service ;;
  }

  dimension: std_warranty {
    type: string
    sql: ${TABLE}.std_warranty_at_completion ;;
  }

  dimension: any_warranty {
    type: string
    sql: ${TABLE}.any_warranty_at_completion ;;
  }

  dimension: warrantable_parts_used {
    type: number
    sql: ${TABLE}.warrantable_parts_used ;;
  }

  dimension: part_numbers {
    type: string
    sql: ${TABLE}.part_numbers ;;
  }

  dimension: part_descriptions {
    type: string
    sql: ${TABLE}.part_descriptions  ;;
  }

  dimension: total_part_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_part_cost ;;
  }

  dimension: total_hours {
    type: number
    sql: ${TABLE}.total_hours;;
  }

  dimension: labor_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_payroll_expense ;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_cost ;;
  }

  dimension: warranties {
    type: string
    sql: ${TABLE}.warranties;;
  }
  }
