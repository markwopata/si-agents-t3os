include: "/_standard/explores/company_directory_12_month_master.explore.lkml"
include: "/_base/analytics/payroll/pa_market_access.view.lkml"

  view: +ee_company_directory_12_month {
    dimension: Business_Segment {
      type: string
      sql: CASE WHEN ${department} = 'Accounting' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Credit & Collections' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Corporate Treasury' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Legal' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Tax' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Fleet' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'National Accounts' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Chief People Officer' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Learning & Development' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Performance & Training' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Talent Acquisition & Pipeline' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Talent Management & HR' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Workplace Safety' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Algorithms & Inferences' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Business Analytics' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Information Technology' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Insurance' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Public Affairs' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Real Estate & Construction' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Corporate Operations' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'Executive' THEN 'Corporate (Non-Builder)'
                WHEN ${department} = 'E-Commerce' THEN 'Builder'
                WHEN ${department} = 'Embedded Systems' THEN 'Builder'
                WHEN ${department} = 'Engineering' THEN 'Builder'
                WHEN ${department} = 'Robotics' THEN 'Builder'
                WHEN ${department} = 'Customer Support' THEN 'Builder'
                WHEN ${department} = 'Experience' THEN 'Builder'
                WHEN ${department} = 'Omnichannel Experience' THEN 'Builder'
                WHEN ${department} = 'Product & Design' THEN 'Builder'
                WHEN ${department} = 'T3' THEN 'Builder'
                WHEN ${division} = 'Rental' THEN 'Rental/Ops'
                WHEN ${division} = 'Materials' THEN 'Rental/Ops'
                WHEN ${division} = 'Manufacturing' THEN 'Rental/Ops'
                WHEN ${division} = 'National' THEN 'Rental/Ops'
                ELSE 'Other' END;;
    }

    dimension: employee_turnover_region_ind {
      description: "Indicator for primary Regions only to filter out other non-regional employees such as Corporate"
      type: yesno
      sql: CASE WHEN try_to_number(${region2}) is not null THEN true
                WHEN ${region2} = 'Corp' THEN true
                WHEN ${region2} = 'Tele' THEN true
      ELSE false END;;
    }
  }
include: "/_standard/people_analytics/looker/termination_details.layer.lkml"


explore: +ee_company_directory_12_month {
  label: "Employee Turnover"
  always_join: [termination_details, pa_market_access]
  case_sensitive: no
  sql_always_where:  ('yes' = {{ _user_attributes['people_analytics_access'] }})
      OR CONTAINS(LOWER(${pa_market_access.market_access_emails}),  LOWER('{{ _user_attributes['email'] }}'))
      OR ('hr' = {{ _user_attributes['department'] }})
      OR  ('hrbp' = {{ _user_attributes['job_role'] }})
      OR (LOWER('{{ _user_attributes['email'] }}') = 'aubrey.wise@equipmentshare.com')
      OR (LOWER('{{ _user_attributes['email'] }}') = 'abbigail.tyler@equipmentshare.com')
      ;;


  join: pa_market_access {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pa_market_access.market_id} = ${ee_company_directory_12_month.market_id};;
  }



  join: termination_details {
    type: left_outer
    relationship: one_to_one
    sql_on: ${termination_details.employee_id} = ${ee_company_directory_12_month.employee_id} and
            TO_DATE(${termination_details.termination}) = TO_DATE(${ee_company_directory_12_month.date_terminated2_raw});;
  }
}
