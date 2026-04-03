include: "/_standard/people_analytics/looker/gl_report.layer.lkml"
include: "/_standard/analytics/payroll/ukg_employee_hierarchy.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
##replaced by company_directory_vault
#include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/payroll/company_directory_vault.layer.lkml"

view: +company_directory_vault {
  # label: "Company Directory Vault for GL Report"
  dimension: Full_Name {
    type:  string
    sql: CASE WHEN ${first_name} is null THEN 'Regional, District, National Employees' else concat(trim(${first_name}),' ',trim(${last_name})) END ;;
    html:

      {% if employee_status._value == "Terminated" %}

            <p style="color: red; font-size:100%">{{ rendered_value }}</p>


      {% else %}

      <p style="color: black; font-size:100%">{{ rendered_value }}</p>

      {% endif %} ;;
  }
}

# time_entry_link dimension updated by Paul Lim on 01/29/2026
view: +gl_report {
  dimension: time_entry_link {
    type: string

    # Ensure Liquid can access these values when rendering the link
    required_fields: [
      company_directory_vault.first_name,
      company_directory_vault.last_name,
      market_region_xwalk.market_name,
      gl_report.pay_date_month
    ]

    # Only non-null for hourly
    sql:
      CASE
        WHEN ${company_directory_vault.pay_calc} ILIKE '%hourly%'
          THEN 'Link'
        ELSE NULL
      END ;;

    # Only render HTML when the dimension is non-null
    html:
      {% if value != blank %}
        <font color='blue'><u>
          <a href='https://equipmentshare.looker.com/dashboards/1617?Market+Name="{{ market_region_xwalk.market_name._value | url_encode }}"&Start+Month={{ gl_report.pay_date_month._value | url_encode }}&Employee+Name={{ company_directory_vault.first_name._value | url_encode }}+{{ company_directory_vault.last_name._value | url_encode }}&Market+ID=' target='_blank'>
            Link to Dashboard
          </a>
        </u></font>
      {% endif %} ;;
  }
}

include: "/_standard/custom_sql/employee_manager_hierarchy.view.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"
include: "/_standard/custom_sql/be_transaction_listing.view.lkml"
include: "/_standard/custom_sql/be_main.view.lkml"
include: "/_standard/analytics/gs/plexi_periods.layer.lkml"
include: "/dashboards/branch_earnings_payroll_detail/revmodel_market_rollout_conservative.view.lkml"
include: "/_base/people_analytics/gl_account.view.lkml" ##still need to replace this view
include: "/_standard/custom_sql/plexi_bucket_mapping.view.lkml"


explore: gl_report {
  # required_access_grants: []
  view_label: "gl_report"
  label: "gl_report_confidential"
  always_join: [pa_market_access]
#  extends: [oec_detail]
# fields: []
# from: gl_report
  case_sensitive: no
  sql_always_where:  'yes' = {{ _user_attributes['people_analytics_access'] }}
    OR CONTAINS(LOWER(${pa_market_access.market_access_email}),  LOWER('{{ _user_attributes['email'] }}'))
    OR ('brody.cridlebaugh@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('phillip.duncan@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('peter.mooney@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('varun.mohan@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('zack.larimore@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('jack.martin@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('neil.maniar@equipmentshare.com' = '{{ _user_attributes['email'] }}');;

  join: ukg_employee_hierarchy {
    type: left_outer
    relationship: many_to_one
    sql_on: ${gl_report.employee_id} = ${ukg_employee_hierarchy.employee_id};;
  }

  ##replaced by company_directory_vault
  #join: company_directory {
  #  type: left_outer
  #  relationship: one_to_one
  #  sql_on: ${gl_report.employee_id} = ${company_directory.employee_id} ;;
  #}

  join: company_directory_vault {
    type: left_outer
    relationship: many_to_one
    sql_on:
    ${gl_report.employee_id} = ${company_directory_vault.employee_id}
      AND ${gl_report.pay_period_end} = ${company_directory_vault._es_update_timestamp_date} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${gl_report.intaact_code} = ${market_region_xwalk.market_id}::varchar ;;
  }

  join: employee_manager_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: ${ukg_employee_hierarchy.manager_employee_id} = ${gl_report.employee_id} ;;
  }

  join: pa_market_access {
    type: inner
    relationship: one_to_many
    sql_on: ${pa_market_access.market_id}::varchar = ${gl_report.intaact_code};;
  }

##Why is this part of the model? Not using it for dashboard and duplicates company_directory data
# join: ee_company_directory {
#   type: inner
#   relationship: one_to_many
#   sql_on: ${gl_report.employee_id} = ${ee_company_directory.employee_id} ;;
# }

  join: plexi_bucket_mapping {
    type: inner
    relationship: one_to_many
    sql_on: ${gl_report.gl_account_no}::text = ${plexi_bucket_mapping.gl_account_number};;
  }

  join: plexi_periods {
    type: left_outer
    relationship:  many_to_one
    sql_on: date_trunc(month, ${gl_report.pay_date_date}::date) = ${plexi_periods.date} ;;
  }


  # sql_always_where: (( 'developer' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }})
  # OR  ((('salesperson' = {{ _user_attributes['department'] }}
  # OR 'god view' = {{ _user_attributes['department'] }}) ;;
}
