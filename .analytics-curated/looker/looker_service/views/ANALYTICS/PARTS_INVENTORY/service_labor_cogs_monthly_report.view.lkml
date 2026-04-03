view: service_labor_cogs_monthly_report {
  sql_table_name: ANALYTICS.PARTS_INVENTORY.SERVICE_LABOR_COGS_MONTHLY_REPORT ;;

  dimension_group: run {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.run_time AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: report {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.report_month AS TIMESTAMP_NTZ) ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.invoice_id ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ invoice_no._value }}</a> ;;
  }
  dimension: billing_approved_date {
    type: date
    convert_tz: no
    sql: ${TABLE}.billing_approved_date  ;;
  }
  dimension: billed_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.company_id ;;
  }
  dimension: billed_hours {
    type: number
    sql: ${TABLE}.hours ;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }
  dimension: line_item_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.line_item_type_id  ;;
  }
  dimension: invoice_display_name {
    type: string
    sql: ${TABLE}.invoice_display_name ;;
  }
  dimension: tech_average {
    type: number
    value_format_name: usd
    sql: ${TABLE}.tech_average ;;
  }
  measure: avg_tech_wage {
    type: average_distinct
    value_format_name: usd
    sql: ${tech_average}  ;;
  }
  measure: overtime_tech_wage {
    type: number
    value_format_name: usd
    sql: ${avg_tech_wage} * 1.5  ;;
  }
  dimension: blended_rate {
    type: number
    value_format_name: usd
    sql: ${TABLE}.blended_hourly_rate ;;
  }
  measure: blended_rate_with_overtime {
    type: average_distinct
    value_format_name: usd
    sql: ${blended_rate} ;;
  }
  dimension: is_warranty {
    type: yesno
    sql: iff(${line_item_type_id} in (22,134), true, false) ;;
  }
  measure: non_warranty_hours {
    type: sum
    filters: [is_warranty: "no"]
    sql: ${billed_hours} ;;
  }
  measure: warranty_hours {
    type: sum
    filters: [is_warranty: "yes"]
    sql: ${billed_hours} ;;
  }
  measure: service_labor_cogs_total {
    type: number
    value_format_name: usd
    sql: (${non_warranty_hours} * ${blended_rate_with_overtime}) + (${warranty_hours} * 0.85 * ${blended_rate_with_overtime}) ;;
  }
}
