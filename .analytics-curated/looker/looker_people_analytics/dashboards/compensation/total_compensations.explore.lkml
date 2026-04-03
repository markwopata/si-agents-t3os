include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"
# include: "/_standard/explores/company_directory_12_month_master.explore.lkml"
include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml"
include: "/_standard/custom_sql/job_changes.view.lkml"
include: "/_standard/people_analytics/looker/gl_report.layer.lkml"
include: "/_base/people_analytics/looker/base_compensation_history.view.lkml"
  # view: +gl_report {
  #   measure: percent_of_total_payroll {
  #     type: percent_of_total
  #     sql: ${debit_total}  ;;
  #   }
  # }
include: "/_standard/people_analytics/looker/payroll_details.layer.lkml"
  view: +payroll_details {
    dimension: combined_description {
      type: string
      description: "Combination of Double Time and Overtime Line Items "
      sql: CASE WHEN ${description} IN ('Double Time','Overtime')
          THEN 'Double and Overtime'
          ELSE ${description} END;;
    }

    dimension: Cost_Center_Division_Name {
      type: string
      sql: CASE WHEN ${_cost_centers_name_division} IN ('Rental','Materials','T3', 'National', 'Manufacturing', 'E-Commerce', 'Tele')
                THEN ${_cost_centers_name_division} ELSE NULL END ;;
    }

    ## Revisit measures below in V2.0 of dashboard

    # measure: count_of_bonus_employees {
    #   type: count
    #   filters: [combined_description: "Bonus"]
    #   drill_fields: [first_name, last_name, jobs_hr1, total_debit]
    # }

    measure: cumulative_total_payroll {
      type: running_total
      sql: ${total_debit} ;;
      value_format_name: usd_0
    }

     measure: count_double_and_overtime_payroll {
       type: count_distinct
       sql: ${employee_id} ;;
       filters: [combined_description: "Double and Overtime"]
       drill_fields: [first_name, last_name, employee_id, description, gl_account_no_description, gl_account_no, total_debit, total_hours, hourly_rate]
    }

    measure: count_regular_payroll {
      type: count_distinct
      sql: ${employee_id} ;;
      filters: [combined_description: "Regular"]
      drill_fields: [first_name, last_name, employee_id, description, gl_account_no_description, gl_account_no, total_debit, total_hours, hourly_rate]
    }

    # measure: max_debit {
    #   type: max
    #   sql: ${total_debit} ;;
    #   value_format_name: usd_0
    # }

    # measure: min_debit {
    #   type: min
    #   sql: ${total_debit} ;;
    #   value_format_name: usd_0
    # }

    # measure: percent_of_total_payroll {
    #   type: percent_of_total
    #   sql: ${total_debit} ;;
    #   value_format_name: percent_2
    # }

    # measure: percent_of_employees {
    #   type: percent_of_total
    #   sql: ${employee_distinct_count} ;;
    # }

  }

include: "/_standard/analytics/payroll/company_directory.layer.lkml"

  view:  +company_directory {
    dimension: tenure_years {
      type: number
      sql:  DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) ;;
    }

    dimension: tenure_tiers {
      type: string
      sql: CASE WHEN DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) <= 1
                  AND DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) < 2 THEN 'Under 2 years'
                WHEN DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) >= 2
                  AND DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) < 4 THEN '2-4 years'
                WHEN DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) >= 4
                  AND DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) <= 6 THEN '4-6 years'
                WHEN DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) >= 6
                  AND DATEDIFF(YEAR, ${date_most_recent_hire_date}, COALESCE(${date_terminated}, GETDATE())) <= 8 THEN '6-8 years'
                ELSE '9 & Above Years' END;;
  }

  measure: count {
    type: count
  }
 }

# include: "/_standard/people_analytics/looker/base_compensation_history.layer.lkml"

explore: payroll_details {
  label: "Total_Compensation"
  always_join: [pa_market_access]
  sql_always_where:  'yes' = {{ _user_attributes['people_analytics_access'] }}
  OR CONTAINS(${pa_market_access.market_access_email},  LOWER('{{ _user_attributes['email'] }}')) ;;

  join: company_directory {
    type: left_outer
    relationship: many_to_many
    sql_on: ${payroll_details.employee_id} = ${company_directory.employee_id} ;;
  }

  # join: gl_report {
  #   type: inner
  #   relationship: many_to_many
  #   sql_on: ${payroll_details.employee_id} = ${gl_report.employee_id};;
  # }

  # join: payroll_details {
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${payroll_details.employee_id} = ${base_compensation_history.employee_id} ;;
  # }

  # join: base_compensation_history {
  #   type: inner
  #   relationship: many_to_many
  #   sql_on: ${payroll_details.employee_id} = ${base_compensation_history.employee_id} ;;
  # }

  join: pa_market_access {
    type: left_outer
    relationship: one_to_many
    sql_on: ${pa_market_access.market_id}::varchar = ${payroll_details.intaact};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payroll_details.intaact} = ${market_region_xwalk.market_id}::varchar ;;
  }

  join: ee_company_directory_12_month {
    type: full_outer
    relationship: one_to_many
    sql_on: ${ee_company_directory_12_month.employee_id} = ${payroll_details.employee_id};;
  }

  join: job_changes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }
}
