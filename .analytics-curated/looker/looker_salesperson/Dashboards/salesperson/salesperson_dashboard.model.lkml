connection: "es_snowflake_analytics"

include: "/Dashboards/salesperson/rental/rental_salesperson_goals.view.lkml"
include: "/Dashboards/salesperson/rental/rental_salesperson_line_items.view.lkml"
include: "/Dashboards/salesperson/rental_goals/salesperson_goals_current.view.lkml"
include: "/Dashboards/salesperson/rental_goals/salesperson_goals_historic.view.lkml"
include: "/Dashboards/salesperson/navigation/navigation_for_salesperson.view.lkml"
include: "/Dashboards/salesperson/navigation/salesperson_general_information.view.lkml"
include: "/Dashboards/salesperson/navigation/employee_disc_codes.view.lkml"
include: "/Dashboards/salesperson/salesperson_rentals_and_reservations.view.lkml"
include: "/Dashboards/salesperson/credits/salesperson_credits_by_month.view.lkml"
include: "/Dashboards/Market_Operations_1378/Historical/Rankings/current_rep_home_market.view.lkml"
include: "/Dashboards/salesperson/tam_company_permissions.view.lkml"
include: "/Dashboards/salesperson/manager_location_permissions.view.lkml"
include: "/Dashboards/salesperson/salesperson_dashboard.model.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/Dashboards/National_Accounts_Dashboard/views/national_account_assignments.view.lkml"


explore: rental_salesperson_goals {
  group_label: "Rental Salesperson"
  join: rental_salesperson_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rental_salesperson_goals.pk} = ${rental_salesperson_line_items.fk_rsg} ;;
  }
  case_sensitive: no
  description: "Goals is on month-salesperson data grain, including total, in-, and out-of-market goals and actual rental revenue.
                Line items is on the line item data grain, and is meant for drill down purposes.
                This explore also includes measures with advanced html for cards on Salesperson dashboard."
}

explore: salesperson_goals_current {
  group_label: "Salesperson Dashboard"
  label: "Salesperson Current and Historical Rental Revenue and Goals"
  case_sensitive: no
  description: "This explore includes current month rental revenue and goals as the base. Joined into this explore is the same information
  but includes historical as well."

  join: salesperson_goals_historic {
    type: left_outer
    relationship: one_to_many
    sql_on: ${salesperson_goals_current.user_id} = ${salesperson_goals_historic.user_id} ;;
  }

}

explore: navigation_for_salesperson {
  group_label: "Salesperson Dashboard"
  label: "Navigation for Salesperson Dashboard"
  case_sensitive: no
  description: "This explore pulls user information in and is mainly used for the navigation tile on the salesperson dashboard."
}


explore: salesperson_general_information {
  group_label: "Salesperson Dashboard"
  label: "Navigation for Sales Manager/Performance Dashboard"
  case_sensitive: no
  description: "This explore pulls hire date, home market and direct report for active employees."
}

explore: salesperson_rentals_and_reservations {
  group_label: "Salesperson Dashboard"
  case_sensitive: no
  sql_always_where: (${manager_location_permissions.region_access} = 'Yes'
                     or ${manager_location_permissions.district_access} = 'Yes'
                     or ${manager_location_permissions.market_access} = 'Yes'
                    )
OR
  ('nam' = {{ _user_attributes['job_role'] }} AND ${nam_email_address} ILIKE '{{ _user_attributes['email'] }}')
OR
  (('tam' = {{ _user_attributes['job_role'] }} AND ${tam_email_address} ILIKE '{{ _user_attributes['email'] }}') OR ${tam_company_permissions.can_view_company_flag} = 'Yes');;

  join: tam_company_permissions {
    type: left_outer
    relationship: many_to_many
    sql_on: ${tam_company_permissions.company_id} = ${salesperson_rentals_and_reservations.company_id} ;;
  }

  join: manager_location_permissions {
    type: left_outer
    relationship: many_to_many
    sql_on: ${manager_location_permissions.market_id} = ${salesperson_rentals_and_reservations.market_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_rentals_and_reservations.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${national_account_companies.company_id} ;;
  }

}

explore: salesperson_credits_by_month {
  group_label: "Salesperson Dashboard"
  label: "Credits by Salesperson"
  case_sensitive: no
  description: "This explore pulls credits by salesperson by month."

  join: current_rep_home_market {
    type: inner
    relationship: many_to_one
    sql_on: ${current_rep_home_market.user_id} = ${salesperson_credits_by_month.user_id} ;;
  }
}
