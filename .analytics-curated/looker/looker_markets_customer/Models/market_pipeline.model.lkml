connection: "es_snowflake_analytics"

# include: "/views/ANALYTICS/market_directory.view.lkml"
# include: "/views/ANALYTICS/corporate_directory.view.lkml"
# include: "/views/ES_WAREHOUSE/markets.view.lkml"
# include: "/views/ES_WAREHOUSE/locations.view.lkml"
# include: "/views/ES_WAREHOUSE/states.view.lkml"
# include: "/views/ES_WAREHOUSE/users.view.lkml"
# include: "/views/ES_WAREHOUSE/invoices.view.lkml"
# include: "/views/ES_WAREHOUSE/line_items.view.lkml"
# include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
# include: "/views/ES_WAREHOUSE/command_audit.view.lkml"
# include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
# include: "/views/ES_WAREHOUSE/work_orders_by_tag.view.lkml"
# include: "/views/ANALYTICS/regions.view.lkml"
# include: "/views/ANALYTICS/districts.view.lkml"
# #include: "/views/ANALYTICS/employee_branch_allocation.view.lkml"
# #include: "/views/ANALYTICS/employee_branch_hierarchy.view.lkml"
# include: "/views/ANALYTICS/disc_master.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/GS/hr_links_to_resumes.view.lkml"
# #include: "/views/ANALYTICS/paycor_employees_managers.view.lkml"
# include: "/views/ANALYTICS/employee_branch_ukg.view.lkml"
# #include: "/views/ANALYTICS/intacct_code_by_ee.view.lkml"
# #include: "/views/ANALYTICS/intacct_code_by_ee.view.lkml"
# include: "/views/custom_sql/salesperson_qtd_revenue_ranking.view.lkml"
# include: "/views/custom_sql/command_audit_wo_completed.view.lkml"
# include: "/views/custom_sql/work_order_inspections_completed.view.lkml"
# include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
# include: "/views/ANALYTICS/company_directory.view.lkml"

# include: "/views/ES_WAREHOUSE/market_ap_links.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: market_directory {
#   view_name: market_directory
#   label: "Market Directory and Pipeline Information"
#   group_label: "Market Directory"
#   case_sensitive: no

#   join: markets {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${market_directory.market_id} = ${markets.market_id} ;;
#   }

#   join: states {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${locations.state_id} = ${states.state_id} ;;
#   }

#   join: locations {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.location_id} = ${locations.location_id} ;;
#     required_joins: [states]
#   }

#   join: districts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_directory.district_id} = ${districts.district_id} ;;
#   }

#   join: regions {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${districts.region_id} = ${regions.region_id} ;;
#   }

#   join: company_directory {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${market_directory.market_id} = ${company_directory.market_id} and
#             ${company_directory.employee_status} = 'Active' and
#             ${company_directory.employee_title} in ('General Manager', 'General Manager - Pump & Power',
#                                                     'General Manager - Industrial Tooling') and
#           ${company_directory.market_id} is not null;;

#   }


# }

# explore: corporate_directory {
#   label: "Market Directory and Pipeline Information"
#   group_label: "Corporate Directory"
#   case_sensitive: no
# }


# explore: employee_branch_ukg {
#   group_label: "Market Directory and Pipeline Information"
#   label: "Employee Branch UKG"
#   case_sensitive: no

#   #join: employee_branch_hierarchy {
#   #  type: left_outer
#   #  relationship: many_to_one
#   #  sql_on: lower(trim(${employee_branch_allocation.employee_email})) = lower(trim(${employee_branch_hierarchy.employee_email})) ;;
#   #}


#   #join: intacct_code_by_ee {
#   #  type:  left_outer
#   #  relationship: one_to_one
#   #  sql_on: ${intacct_code_by_ee.employee_id} = ${employee_branch_ukg.employee_id} ;;
#   #}

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: lower(trim(${employee_branch_ukg.employee_email})) = lower(trim(${users.email_address})) ;;
#   }

#   join: disc_master {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: lower(trim(${employee_branch_ukg.employee_email})) = lower(trim(${disc_master.email_address}))  ;;
#   }

#   join: hr_links_to_resumes {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: lower(trim(${employee_branch_ukg.employee_email}))=lower(trim(${hr_links_to_resumes.sales_rep_email})) ;;
#   }

#   #join: paycor_employees_managers {
#   #  type: full_outer
#   #  relationship: one_to_one
#   #  sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${paycor_employees_managers.employee_email})) ;;
#   #}

#   join: salesperson_qtd_revenue_ranking {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.user_id} = ${salesperson_qtd_revenue_ranking.salesperson_user_id} ;;
#   }

#   join: deliveries {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.user_id} = ${deliveries.driver_user_id} ;;
#   }

#   join: command_audit_wo_completed {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.user_id} = ${command_audit_wo_completed.user_id} ;;
#   }

#   join: work_order_inspections_completed {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${command_audit_wo_completed.work_order_id}=${work_order_inspections_completed.work_order_id}
#     ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: TRIM(LOWER(${employee_branch_ukg.market_id}))=TRIM(LOWER(${market_region_xwalk.region_name})) ;;
#   }

#   join: region_market_totals {
#     from: employee_branch_ukg
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${employee_branch_ukg.region_name}=${region_market_totals.region_name} ;;
#   }

#   join: district_market_totals {
#     from: employee_branch_ukg
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${employee_branch_ukg.district_id}=${district_market_totals.district_id} ;;
#   }

#   #join: market_region_xwalk {
#   #  type: left_outer
#   #  relationship: many_to_one
#   #  sql_on: TRIM(LOWER(${employee_branch_allocation.region_name}))=TRIM(LOWER(${market_region_xwalk.region_name})) ;;
#   #}

#   join: invoices {
#     type: left_outer
#     relationship: one_to_many
#     sql_on:${users.user_id}= ${invoices.salesperson_user_id}  ;;
#   }

#   join: line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: line_item_types {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${employee_branch_ukg.market_id} = ${markets.market_id} ;;
#   }

#   # join: states {
#   #   type: left_outer
#   #   relationship: many_to_one
#   #   sql_on: ${locations.state_id} = ${states.state_id} ;;
#   # }

#   # join: locations {
#   #   type: left_outer
#   #   relationship: one_to_one
#   #   sql_on: ${markets.location_id} = ${locations.location_id} ;;
#   #   required_joins: [states]
#   # }

#   # join: districts {
#   #   type: left_outer
#   #   relationship: many_to_one
#   #   sql_on: ${employee_branch_allocation.district_id} = ${districts.district_id} ;;
#   # }

#   # join: regions {
#   #   type: left_outer
#   #   relationship: many_to_one
#   #   sql_on: ${districts.region_id} = ${regions.region_id} ;;
#   # }
#   }

#   explore: market_directory_links {
#     label: "Market Directory w Email Links"
#     from: markets
#     extends: [corporate_directory]

#     join: market_ap_links {
#       relationship: one_to_one
#       sql_on: ${market_directory_links.market_id} = ${market_ap_links.market_id} ;;
#     }

#     join: districts {
#       relationship: one_to_one
#       sql_on: ${market_directory_links.market_id} = ${districts.district_id} ;;
#     }

#     join: regions {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${districts.region_id} = ${regions.region_id} ;;
#   }

#   }
