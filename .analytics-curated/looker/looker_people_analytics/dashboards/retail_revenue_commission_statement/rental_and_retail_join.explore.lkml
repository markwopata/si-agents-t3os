include: "/_standard/analytics/commission/rental_and_retail_join.layer.lkml"
include: "/dashboards/retail_revenue_commission_statement/salesperson_permissions.view.lkml"
include: "/dashboards/commission_statement/commission_statement_access.view.lkml"

explore: rental_and_retail_join {

  sql_always_where:
    (
    ( ({{ _user_attributes['job_role'] }} = 'tam' OR {{ _user_attributes['job_role'] }} = 'ram' OR {{ _user_attributes['job_role'] }} = 'rc') AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
    OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
    OR {{ _user_attributes['job_role'] }} = 'developer'
    OR {{ _user_attributes['job_role'] }} = 'hrbp'
    OR {{ _user_attributes['job_role'] }} = 'leadership'
    OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
    OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('mark.wopata@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR
    (case
    when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'brandon.wilson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'brandon.wilson@equipmentshare.com')
    when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
    when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
    when 'chad.pilawski@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'chad.pilawski@equipmentshare.com')
    when lower('{{ _user_attributes['email'] }}') in (
    select lower(employee_email) from analytics.payroll.pa_employee_access ca
      join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
      where manager_access_emails ilike 'william.woodruff@equipmentshare.com%' -- Direct Manager = Dub Woodruff
      and employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
)
    then contains(lower(ca.manager_access_emails), 'william.woodruff@equipmentshare.com')


    when lower('{{ _user_attributes['email'] }}') in (
    select lower(employee_email) from analytics.payroll.pa_employee_access ca
      join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
      where manager_access_emails ilike 'daniel.weinshenker@equipmentshare.com%' -- Direct Manager = Daniel Weinshenker
      and employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
)
    then contains(lower(ca.manager_access_emails), 'daniel.weinshenker@equipmentshare.com')
    END))
    ;;

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: TO_CHAR(${rental_and_retail_join.employee_id})= TO_CHAR(${salesperson_permissions.employee_id});;
  }

}
