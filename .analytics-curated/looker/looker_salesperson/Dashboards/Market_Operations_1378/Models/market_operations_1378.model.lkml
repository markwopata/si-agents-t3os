connection: "es_snowflake_c_analytics"

# Everything Related to the Dashboard
include: "/Dashboards/Market_Operations_1378/Historical/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/Historical/kpi_daily_joined_historical.view.lkml"
include: "/Dashboards/Market_Operations_1378/Current/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/TAM_Quotes/*.view.lkml"

# Rank Information
include: "/Dashboards/Market_Operations_1378/Historical/Rankings/*.view.lkml"
# Individual Views for Muliple Projects Locations
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ANALYTICS/es_companies.view.lkml"
include: "/views/ANALYTICS/rateachievement_points.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/custom_sql/salesperson_info.view.lkml"
##include: "/views/custom_sql/secondary_sales_rep_revenue.view.lkml"
include: "/Dashboards/salesperson/rental/under_125k_dashboard.view.lkml"

include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/ANALYTICS/pay_periods.view.lkml"


# For Commissions Tile
include: "/Dashboards/Market_Operations_1378/sales_manager_permissions/*.view.lkml"
include: "/views/ANALYTICS/pay_periods.view.lkml"

# Salesperson Permissions View
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/salesperson_permissions.view.lkml"

# Parent Market
include: "/views/ANALYTICS/branch_earnings_market.view.lkml"


# Salesperson Goals
include: "/Dashboards/salesperson/rental/rental_salesperson_goals.view.lkml"



# Business Intelligence DBT Tables
include: "/views/BUSINESS_INTELLIGENCE/*.view.lkml"
##include: "/views/BUSINESS_INTELLIGENCE/int_credit_app_first_intake_resolved.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/v_dim_dates_bi.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/dim_companies_bi.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/fact_company_customer_start.view.lkml"
# branch 'master' of https://github.com/EquipmentShare/looker_salesperson.git

#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: rep_company_oec_aor_arc_90 {
  group_label: "Sales Manager Dashboard"
  label: "Rep/Company OEC/AOR/ARC for Past 90 Days"
  description: "Rep/company daily report of assets on rent and oec on rent.  Can be used to find actively renting customers."
  case_sensitive: no
}

explore: historical_combo_revenue  {
  case_sensitive: no
}

explore: new_accounts_by_type_historical {
  group_label: "Sales Manager Dashboard"
  label: "New Account By Type Historical"
  description: "Log of each new account brought into ES, along with its type, date, source, and sales rep associated with the new account."
  case_sensitive: no
  sql_always_where:
  ${salesperson_permissions.employee_status} not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
          (( {{ _user_attributes['job_role'] }} = 'tam' AND
              '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email} )
          OR
          (contains(${salesperson_permissions.manager_access_emails},'{{ _user_attributes['email'] }}'))

          OR
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'hrbp')
          OR
          ({{ _user_attributes['job_role'] }} = 'leadership')
          OR
          ({{ _user_attributes['job_role'] }} = 'legal')
          OR
          ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('5-8', '5-4') OR (${salesperson_permissions.region_name_dated} IN ('Southeast') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) --si specific just to tie in employees in the salesmanager info table
          OR
          ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('2-3') OR (${salesperson_permissions.region_name_dated} IN ('Mountain West') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
          OR
          ('kevin.stobb@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND ((${salesperson_permissions.district_dated} IN ('4-9') OR (${salesperson_permissions.employee_id} IN ('15499', '18442', '14046', '17959', '15703'))) AND business_segment IN ('Core Solutions')))
          OR
          ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
            OR
          ('jason.jones@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.region_name_dated} IN ('Florida')))
          OR
          ('jeremy.dooley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.region_name_dated} IN ('Southeast')))
          OR
          ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker

          OR
          (case when 'ryan.frazier@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3490','7509','15499','15703','17959','19952','19447','14023','20390','14046','18442','9172','20537','18914','5461','14435','18447','12374','15984')) then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') end)
          OR
          (case when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880', '18980')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'brian.kniffen@equipmentshare.com') end)

          OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when ${salesperson_permissions.business_segment} = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN ( select work_email from analytics.payroll.company_directory cd where cd.employee_title ILIKE '%Regional Manager - Industrial%' OR cd.employee_title ILIKE '%Director of Tooling%') THEN contains(${salesperson_permissions.manager_access_emails},'grant.reviere@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            END
          )
          )
  ;;

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${users.user_id} = ${new_accounts_by_type_historical.sp_user_id} ;;
  }
  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${new_accounts_by_type_historical.sp_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }
}

explore: current_month_rev_by_company {
  group_label: "Sales Manager Dashboard"
  label: "Current Month Revenue By Company By Rep"
  persist_for: "3 hours"
  case_sensitive: no
  sql_always_where:
    ${salesperson_permissions.employee_status} not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
          (( {{ _user_attributes['job_role'] }} = 'tam' AND
              '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email} )
          OR
          (contains(${salesperson_permissions.manager_access_emails},'{{ _user_attributes['email'] }}'))

          OR
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'hrbp')
          OR
          ({{ _user_attributes['job_role'] }} = 'leadership')
          OR
          ({{ _user_attributes['job_role'] }} = 'legal')
          OR
          ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
          OR
          ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('5-8', '5-4') OR (${salesperson_permissions.region_name_dated} IN ('Southeast') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) --si specific just to tie in employees in the salesmanager info table
          OR
          ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('2-3') OR (${salesperson_permissions.region_name_dated} IN ('Mountain West') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
          OR
          ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('jason.jones@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.region_name_dated} IN ('Florida')))
          OR
          ('jeremy.dooley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.region_name_dated} IN ('Southeast')))

          OR
          (case when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880', '18980')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'brian.kniffen@equipmentshare.com') end)
          OR
          (case when 'ryan.frazier@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3490','7509','15499','15703','17959','19952','19447','14023','20390','14046','18442','9172','20537','18914','5461','14435','18447','12374','15984')) then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') end)

          OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when ${salesperson_permissions.business_segment} = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN ( select work_email from analytics.payroll.company_directory cd where cd.employee_title ILIKE '%Regional Manager - Industrial%' OR cd.employee_title ILIKE '%Director of Tooling%') THEN contains(${salesperson_permissions.manager_access_emails},'grant.reviere@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            END
          )
          );;

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${current_month_rev_by_company.sp_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${current_month_rev_by_company.rental_company_id} = ${dim_companies_bi.company_id} ;;
  }
}



explore: kpi_daily_joined_historical {
  group_label: "Sales Manager Dashboard"
  label: "Rep Metrics"
  description: "Main metrics for reps that are on the sales manager dashboard"
  case_sensitive: no
  sql_always_where: ${kpi_daily_joined_historical.employee_status_present} = 'Active' AND ${kpi_daily_joined_historical.employee_title_dated}IN ('Territory Account Manager' , 'Strategic Account Manager', 'Rental Territory Manager', 'Market Consultant Manager') ;;

  join: current_month_rev_by_company {
    type: left_outer
    relationship: one_to_many
    sql_on: ${kpi_daily_joined_historical.salesperson_user_id} =  ${current_month_rev_by_company.sp_user_id}
    AND ${kpi_daily_joined_historical.date_date} = ${current_month_rev_by_company.date_month}
    AND ${kpi_daily_joined_historical.one_row_per_month_per_rep_flag} = ${current_month_rev_by_company.one_flag}
    ;;
  }

  join: current_month_oec_by_rep_company {
    type: left_outer
    relationship:  one_to_many
    sql_on:  ${kpi_daily_joined_historical.salesperson_user_id} =  ${current_month_oec_by_rep_company.salesperson_user_id}
    AND ${kpi_daily_joined_historical.date_date} = ${current_month_oec_by_rep_company.date_date}
    AND ${kpi_daily_joined_historical.one_row_per_date_per_rep_flag} = ${current_month_oec_by_rep_company.one_flag}
    ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${kpi_daily_joined_historical.home_market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: salesperson_permissions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${current_month_rev_by_company.sp_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: secondary_rev_for_reps{
    type:  left_outer
    relationship: many_to_one
    sql_on: concat(${kpi_daily_joined_historical.salesperson_user_id}) = concat(${secondary_rev_for_reps.secondary_salesperson_id})
      AND ${kpi_daily_joined_historical.date_date} =${secondary_rev_for_reps.date_date} ;;
  }

 join: es_companies {
  type: left_outer
  relationship: many_to_one
  sql_on: ${secondary_rev_for_reps.company_id} = ${es_companies.company_id} ;;
}

  join: branch_earnings_market {
    type: inner
    relationship: many_to_one
    sql_on:  ${kpi_daily_joined_historical.market_id} = ${branch_earnings_market.child_market_id};;
  }

}

explore: rental_salesperson_goals {
  case_sensitive: no

  join: current_rep_home_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_salesperson_goals.user_id} =  ${current_rep_home_market.user_id};;
  }
}

explore: revenue_monthly_insights {
  case_sensitive: no
}

explore: last_365_oec_by_rep_company {
  case_sensitive: no
  group_label: "Sales Manager Dashboard"
  label: "Last 365 OEC By Rep/Company"
}

explore: new_accounts_revenue_oec_rankings {
  case_sensitive: no

  join: current_month_oec_by_rep_company {
    type: left_outer
    relationship: one_to_many
    sql_on: ${new_accounts_revenue_oec_rankings.sp_user_id} =  ${current_month_oec_by_rep_company.salesperson_user_id}
          AND ${new_accounts_revenue_oec_rankings.date_month_date} = ${current_month_oec_by_rep_company.month_date}
          ;;
  }

  join: current_rep_home_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_accounts_revenue_oec_rankings.sp_user_id} =  ${current_rep_home_market.user_id};;
  }

  join: last_guarantee_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_accounts_revenue_oec_rankings.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month} AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE';;
  }

  join: first_commission_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_accounts_revenue_oec_rankings.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month} AND ${first_commission_paycheck.comm_check_date} = 'TRUE';;
  }
}

explore: salesperson_historical_rankings {
  group_label: "Individual Insight Analysis"
  label: "Rep Rankings of Main Metrics"
  description: "Rankings of Reps for Revenue, New Accounts and OEC"
  case_sensitive: no
}

explore: fuel_revenue {
  from: v_line_items

  join: invoices {
    type: inner
    relationship: many_to_one
    sql_on: ${fuel_revenue.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${fuel_revenue.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: es_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${es_companies.company_id} ;;
  }
}

explore: rateachievement_points {
  group_label: "Rate Achievement"
  label: "Rate Achievement Pts"
  case_sensitive: no


  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${rateachievement_points.salesperson_user_id}=${users.user_id} ;;
  }

  join: salesperson_info {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${rateachievement_points.salesperson_user_id}=${salesperson_info.user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${rateachievement_points.invoice_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.new_class_id} = ${equipment_classes.equipment_class_id};;
  }


  join: es_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id} = ${es_companies.company_id} ;;
  }
}



explore: orders {
 # group_label: "Info for Sales Rep Performance"
  label: "Salesperson Performance Info"
  description: ""
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ${users.user_id} = COALESCE(${order_salespersons.user_id}, ${orders.salesperson_user_id})
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
 ;;


  join: order_salespersons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type:  inner
    relationship:  many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }


  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: users {
    view_label: "Salesperson"
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.salesperson_user_id} = ${users.user_id} ;;
  }

  join: rateachievement_points {
    view_label: "Rate Achievement"
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.salesperson_user_id} = ${rateachievement_points.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id}  ;;
  }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${customer.user_id} ;;
  }

  join: es_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${es_companies.company_id} = ${customer.company_id} ;;
  }

  join: salesperson_info {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${invoices.salesperson_user_id} = ${salesperson_info.user_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }


  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_to_market.salesperson_user_id} = ${users.user_id} ;;
  }

  }


explore:  guarantees_commissions {
  group_label: "Guarantee/Commission Information"
  label: "Guarantee/Commission Info"
  description: "Guarantee Information for Sales Manager Dashboard"
  case_sensitive: no
  sql_always_where: ${salesperson_user_id} = ${sales_manager_permissions.employee_user_id} ;;
join: sales_manager_permissions {
  type:  inner
  relationship: one_to_one
  sql_on: ${guarantees_commissions.salesperson_user_id} = ${sales_manager_permissions.employee_user_id} ;;
}


  join: last_guarantee_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on: ${guarantees_commissions.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month} AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE';;
  }

  join: first_commission_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on: ${guarantees_commissions.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month} AND ${first_commission_paycheck.comm_check_date} = 'TRUE';;
  }

}

explore: rep_company_rev_historical {
  label: "Historical Revenue By Rep/Company"
  description: "Monthly revenue sum by rep/company/rental market for the past 12 months"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rep_company_rev_historical.sp_market_id_dated} = ${market_region_xwalk.market_id} ;;
  }

}

explore: historical_combo_revenue_info {
  label: "Historical Rev By Type Dashboard Info"
  description: "A drilldown linked to an html object explains metrics within the dashboard"
  case_sensitive: no
  persist_for: "24 hours"
}

explore: salesperson_quotes {
  label: "Salesperson Refresh - Quotes"
  case_sensitive: no
  persist_for: "24 hours"
  sql_always_where:
           (( {{ _user_attributes['job_role'] }} = 'tam' AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
        OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
        OR {{ _user_attributes['job_role'] }} = 'developer'
        OR {{ _user_attributes['job_role'] }} = 'hrbp'
        OR {{ _user_attributes['job_role'] }} = 'leadership'
        OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
        OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            END))
        ;;

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${salesperson_quotes.salesperson_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_quotes.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${national_account_companies.company_id} ;;
  }



}

explore: salesperson_co_filter {
  label: "Filtered SP Quote Info"
  case_sensitive: no
  persist_for: "24 hours"
  sql_always_where:
  (( {{ _user_attributes['job_role'] }} = 'tam' AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
  OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
  OR {{ _user_attributes['job_role'] }} = 'developer'
  OR {{ _user_attributes['job_role'] }} = 'hrbp'
  OR {{ _user_attributes['job_role'] }} = 'leadership'
  OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
  OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
  OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
  OR
  (case
  when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
  when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
  when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
  when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
  when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
  END))
  ;;

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_co_filter.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${national_account_companies.company_id} ;;
  }

  join: salesperson_quotes {
    type: inner
    relationship: many_to_many
    sql_on: ${salesperson_co_filter.company_id} = ${salesperson_quotes.company_id}
          OR ${salesperson_co_filter.company_name} = ${salesperson_quotes.complete_company_name};;
  }
  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${salesperson_co_filter.salesperson_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

}

  explore:  guarantees_commissions_retail_incl {
    from: guarantees_commissions
    label: "Guarantee/Commission Info + Retail"
    description: "Guarantee Information for Sales and Retail Managers"
    case_sensitive: no
    sql_always_where:
    ${sales_retail_permissions.employee_title} IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager','Market Consultant Manager', 'Retail Account Manager', 'National Account Manager') AND
     ${sales_retail_permissions.employee_status} not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND (
    contains(${sales_retail_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
    OR {{ _user_attributes['job_role'] }} = 'developer'
    OR {{ _user_attributes['job_role'] }} = 'hrbp'
    OR {{ _user_attributes['job_role'] }} = 'leadership'
    OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
    OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
    OR
    (case
    when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${sales_retail_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${sales_retail_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${sales_retail_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
    when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${sales_retail_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${sales_retail_permissions.manager_access_emails},'zach@equipmentshare.com')
    when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${sales_retail_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
    END))
    ;;

    join: sales_retail_permissions {
      type:  inner
      relationship: one_to_one
      sql_on: ${guarantees_commissions_retail_incl.salesperson_user_id} = ${sales_retail_permissions.employee_user_id} ;;
    }

    join: last_guarantee_paycheck {
      from: pay_periods
      type: left_outer
      relationship: many_to_one
      sql_on: ${guarantees_commissions_retail_incl.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month} AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE';;
    }

    join: first_commission_paycheck {
      from: pay_periods
      type: left_outer
      relationship: many_to_one
      sql_on: ${guarantees_commissions_retail_incl.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month} AND ${first_commission_paycheck.comm_check_date} = 'TRUE';;
    }

  }

explore: under_125k_dashboard {
  case_sensitive: no
  sql_always_having: ${new_accounts_revenue_oec_rankings.prev_total_rev_sum} < 125000 ;;

##  join: int_credit_app_first_intake_resolved {
##    type: left_outer
##    relationship: many_to_one
##    sql_on: ${under_125k_dashboard.salesperson_user_id} = ${int_credit_app_first_intake_resolved##.salesperson_user_id} ;;
 ## }

  join: fact_company_customer_start {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_company_customer_start.company_key} = ${dim_companies_bi.company_key} ;;
  }


  join: v_dim_dates_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.first_account_date_ct_key} = ${v_dim_dates_bi.date_key} ;;
  }

  join: new_account_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.first_account_date_ct_key} = ${new_account_date.date_key} ;;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${under_125k_dashboard.salesperson_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_company_customer_start.company_key} = ${dim_companies_bi.company_key} ;;
  }

  join: dim_salesperson_enhanced_historical {
    from: dim_salesperson_enhanced
    view_label: "Historical Salesperson Info"
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${under_125k_dashboard.salesperson_user_id} = ${dim_salesperson_enhanced_historical.user_id}
      AND ${v_dim_dates_bi.date} >= ${dim_salesperson_enhanced_historical._valid_from_date}
      AND ${v_dim_dates_bi.date} < ${dim_salesperson_enhanced_historical._valid_to_date} ;;
  }

  join: market_region_xwalk_historical {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_salesperson_enhanced_historical.market_id_hist} = ${market_region_xwalk_historical.market_id} ;;
  }

  join: current_month_oec_by_rep_company {
    type: left_outer
    relationship: one_to_many
    sql_on:
      ${under_125k_dashboard.salesperson_user_id} = ${current_month_oec_by_rep_company.salesperson_user_id}
      AND ${under_125k_dashboard.date_month_date} = ${current_month_oec_by_rep_company.month_date} ;;
  }

  join: new_accounts_revenue_oec_rankings {
    type: left_outer
    relationship: one_to_many
    sql_on: ${under_125k_dashboard.salesperson_user_id} = ${new_accounts_revenue_oec_rankings.sp_user_id};;
  }

  join: current_rep_home_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${under_125k_dashboard.salesperson_user_id} = ${current_rep_home_market.user_id} ;;
  }

  join: last_guarantee_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${new_accounts_revenue_oec_rankings.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month}
      AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE' ;;
  }

  join: first_commission_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${new_accounts_revenue_oec_rankings.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month}
      AND ${first_commission_paycheck.comm_check_date} = 'TRUE' ;;
  }
}


explore: under_125k_dashboard2 {
  from: under_125k_dashboard
  case_sensitive: no
  sql_always_where: ${new_accounts_revenue_oec_rankings.date_month_date} = date_trunc(month, current_date)::DATE AND
  (${new_accounts_revenue_oec_rankings.prior_month_total_rev} < 125000  or ${new_accounts_revenue_oec_rankings.prior_month_total_rev} is null) AND ${salesperson_permissions.employee_status} = 'Active' AND ${salesperson_permissions.employee_title} = 'Territory Account Manager';;

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${under_125k_dashboard2.salesperson_user_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: new_accounts_revenue_oec_rankings {
    type: left_outer
    relationship: one_to_many
    sql_on: ${under_125k_dashboard2.salesperson_user_id} = ${new_accounts_revenue_oec_rankings.sp_user_id};;
  }

  join: dim_users_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_users_bi.user_id} = ${new_accounts_revenue_oec_rankings.sp_user_id} ;;
  }

  join: fact_company_customer_start {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fact_company_customer_start.salesperson_user_key} = ${dim_users_bi.user_key} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.company_key} = ${dim_companies_bi.company_key} ;;
  }

  join: new_account_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: one_to_many
    sql_on: ${fact_company_customer_start.first_account_date_ct_key} = ${new_account_date.date_key} ;;
  }

  join: last_guarantee_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${new_accounts_revenue_oec_rankings.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month}
      AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE' ;;
  }

  join: first_commission_paycheck {
    from: pay_periods
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${new_accounts_revenue_oec_rankings.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month}
      AND ${first_commission_paycheck.comm_check_date} = 'TRUE' ;;
  }
}
