include: "/_base/people_analytics/test/gl_commission_test.view.lkml"

view: +gl_commission_test {
  label: "GL_Commission_Report"

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql:${_es_update_timestamp} ;;
  }
  dimension: _gl_commission_report_pk {
    primary_key:yes
    hidden: yes
  }
  # dimension: cost_centers_full_path {
  #   type: string
  #   sql: ${cost_centers_full_path} ;;
  # }
  dimension: credit {
    type: number
    # sql: COALESCE(${credit},0) ;;
    value_format_name: usd
  }
  dimension: debit {
    type: number
    # sql: COALESCE(${debit},0) ;;
    value_format_name: usd
  }
  # dimension: department {
  #   type: string
  #   sql: ${department} ;;
  # }
  # dimension: employee_id {
  #   type: number
  #   sql: ${employee_id} ;;
  #   value_format_name: id
  # }
  # dimension: gl_account_no {
  #   type: number
  #   sql: ${gl_account_no};;
  # }
  # dimension: gl_account_no_description {
  #   type: string
  #   sql: ${gl_account_no_description} ;;
  # }
  dimension: intaact_code {
    type: number
    # sql: ${intaact_code} ;;
    value_format_name: id
  }
  dimension_group: pay_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${pay_date} ;;
  }
  dimension: combined_gl_amount {
    type: number
    sql: COALESCE(${debit},0) - COALESCE(${credit},0) ;;
    hidden: yes
  }
  dimension: cost_center_fixed {
    type: string
    sql: case
           when len(${cost_centers_full_path})-len(replace(${cost_centers_full_path},'/','')) = 7
               then concat(
    split_part(${cost_centers_full_path},'/',1),'/',
    split_part(${cost_centers_full_path},'/',2),'/',
    split_part(${cost_centers_full_path},'/',3),'/',
    split_part(${cost_centers_full_path},'/',4),'/',
    split_part(${cost_centers_full_path},'/',8))
               else ${cost_centers_full_path} end ;;
    description: "Fixing errors in cost centers that were manually loaded by payroll from Jan 2023 - June 2023."
  }
  measure: total_gl_amount {
    type: sum_distinct
    sql: ${combined_gl_amount} ;;
    value_format_name: usd
    description: "Total amount including payroll debits and credits."
    drill_fields:
        [intaact_code,
        pay_date_date,
        cost_center_fixed,
        combined_gl_amount ]
  }

}
