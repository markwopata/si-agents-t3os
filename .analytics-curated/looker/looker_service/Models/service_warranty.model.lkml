connection: "es_snowflake_analytics"

include: "/views/custom_sql/warranty_invoices.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ANALYTICS/warranty_invoices.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ANALYTICS/tech_user_weekly.view.lkml"
include: "/views/ANALYTICS/paycor_employees_managers.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/WORK_ORDERS/work_order_company_tags.view.lkml"
include: "/views/WORK_ORDERS/company_tags.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/custom_sql/error_invoices_credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/es_asset_warranty.view.lkml"
include: "/views/custom_sql/warranty_oec.view.lkml"
include: "/views/SCD/scd_asset_hours.view.lkml"
include: "/views/INVENTORY/asset_delivery_date.view.lkml"
include: "/views/INVENTORY/assets_under_warranty.view.lkml"
include: "/views/custom_sql/current_own_program_assets.view.lkml"
include: "/views/custom_sql/warranty_claim_performance.view.lkml"
include: "/views/custom_sql/missed_warranty_opportunity_beta.view.lkml"
include: "/views/custom_sql/warrantable_assets_aggregate.view.lkml"
include: "/views/ANALYTICS/weekly_missed_warranty.view.lkml"
include: "/views/ANALYTICS/warranty_admin_assignments.view.lkml"
include: "/views/custom_sql/warranty_admin_weekly_report.view.lkml"
include: "/views/custom_sql/warranty_admin_lookup_wo_remainder.view.lkml"
include: "/views/custom_sql/warranty_admin_lookup_wo_remainder.view.lkml"
include: "/views/INVENTORY/parts.view.lkml"
include: "/views/INVENTORY/part_types.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/custom_sql/warranty_oec_year_summary.view.lkml"
include: "/views/custom_sql/new_warranty_missed_opportunity.view.lkml"
include: "/views/custom_sql/q1_q2_missed_opp_tmp.view.lkml"
include: "/views/custom_sql/current_warranty_oec.view.lkml"
include: "/views/custom_sql/new_warranty_missed_opportunity.view.lkml"
include: "/views/custom_sql/warranty_goal_2_percent_per_year.view.lkml"
include: "/views/custom_sql/annualized_warranty.view.lkml"
include: "/views/custom_sql/min_date_branch_warranty_oec.view.lkml"
include: "/views/ANALYTICS/plexi_periods.view.lkml"
include: "/views/be_market_start_month.view.lkml"
include: "/views/custom_sql/warranty_missed_opp_weekly_report.view.lkml"
include: "/views/custom_sql/es_ownership_3_flags.view.lkml"
include: "/views/custom_sql/warranty_credits_and_denials_log.view.lkml"
include: "/views/custom_sql/est_work_order_cost.view.lkml"
include: "/views/custom_sql/external_labor_on_warranty_work_orders.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/custom_sql/warranty_pre_file_denial_codes.view.lkml"
include: "/views/custom_sql/warranty_branch_grades.view.lkml"
include: "/views/be_market_start_month.view.lkml"
include: "/views/custom_sql/asset_engines.view.lkml"
include: "/views/custom_sql/asset_warranties.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"

explore: warranty_branch_grades {
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${warranty_branch_grades.market_id} ;;
  }

  join: be_market_start_month {
    type: left_outer
    relationship: one_to_one
    sql_on: ${be_market_start_month.market_id} = ${market_region_xwalk.market_id}  ;;
  }
}

explore: warranty_pre_file_denials {
  from: warranty_pre_file_denial_codes
  case_sensitive: no
  description: "Work Orders that an Admin has put a pre-file denial code on"

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${warranty_pre_file_denials.work_order_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_pre_file_denials.user_id} =  ${users.user_id} ;;
  }
}

explore: external_labor_on_warranty_work_orders {
  description: "A Lookup tool for POs and Invoices for External Labor on Warranty Work Orders"
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${external_labor_on_warranty_work_orders.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${external_labor_on_warranty_work_orders.work_order_id} = ${work_orders.work_order_id}::STRING ;;
  }

  join: wo_tags_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_tags_aggregate.work_order_id} = ${work_orders.work_order_id} ;;
  }
}

explore: warranty_credits_and_denials_log {
  case_sensitive: no

  join: warranty_invoice_asset_info {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_credits_and_denials_log.invoice_id} = ${warranty_invoice_asset_info.invoice_id} ;;
    }

  join: assets_aggregate {
      type: left_outer
      relationship: many_to_one
      sql_on: ${warranty_invoice_asset_info.asset_id} = ${assets_aggregate.asset_id} ;;
    }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_invoice_asset_info.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_credits_and_denials_log.user_id} =  ${users.user_id} ;;
  }

  join: invoices {
    type: inner
    relationship: many_to_many
    sql_on: ${warranty_invoice_asset_info.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${companies.company_id} ;;
  }


}

explore: warranty_missed_opp_weekly_report {
  case_sensitive: no

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${warranty_missed_opp_weekly_report.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: warranty_invoice_asset_info {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_missed_opp_weekly_report.invoice_id} = ${warranty_invoice_asset_info.invoice_id}  ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: monthly_claim_goal {
#   case_sensitive: no
#   persist_for: "8 hours"
# }

explore: min_date_branch_warranty_oec {
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${min_date_branch_warranty_oec.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

# Old BE Explore for Missed Warranty. Replaced in October 2025 for new process. See Warranty model for - TA
# explore: monthly_missed_opportunity_by_market {
#   case_sensitive: no
#   sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
#     -- and (${plexi_periods.period_published} = 'published'
#     or 'developer' = {{ _user_attributes['department'] }}
#     or 'admin' = {{ _user_attributes['department'] }}
#     OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
#     OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'lacy.harris@equipmentshare.com'  ;;

#   join: min_date_branch_warranty_oec {
#     type: full_outer
#     relationship: many_to_many
#     sql_on: ${monthly_missed_opportunity_by_market.month} = ${min_date_branch_warranty_oec.month}
#       and ${monthly_missed_opportunity_by_market.market_id} = ${min_date_branch_warranty_oec.branch_id}
#       and ${monthly_missed_opportunity_by_market.make} = ${min_date_branch_warranty_oec.make} ;;
#   }

#   join: plexi_periods {
#     type: inner
#     relationship: many_to_one
#     sql_on: coalesce(${monthly_missed_opportunity_by_market.month}, ${min_date_branch_warranty_oec.month}) = ${plexi_periods.date} ;;
#   }

#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: coalesce(${monthly_missed_opportunity_by_market.market_id}, ${min_date_branch_warranty_oec.branch_id})  = ${market_region_xwalk.market_id} ;;
#   }

#   join: be_market_start_month {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${be_market_start_month.market_id} ;;
#   }
# }

explore: weekly_claim_goal {
  case_sensitive: no

  join: warranty_oem_yr_claim_summary_by_make  {
  type: full_outer
  relationship: one_to_one
  sql_on: ${weekly_claim_goal.report_week} = ${warranty_oem_yr_claim_summary_by_make.generated_date}
     and ${warranty_oem_yr_claim_summary_by_make.make} = ${weekly_claim_goal.make} ;;
  }
}

explore: annualized_warranty {
  case_sensitive: no
}

explore: warranty_goal_2_percent_per_year {
  label: "Warranty Goal by OEM"
  case_sensitive: no
  persist_for: "8 hours"

  join: warranty_oem_summary {
    type: full_outer
    relationship: one_to_one
    sql_on: ${warranty_goal_2_percent_per_year.make} = ${warranty_oem_summary.make}
      and ${warranty_goal_2_percent_per_year.year} = ${warranty_oem_summary.year};;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: missed_opportunity_weekly_stats  {
#   case_sensitive: no
#   persist_for: "8 hours"
# }

# Commented out due to low usage on 2026-03-27
# explore: warranty_missed_opportunity {
#   case_sensitive: no
#
#   join: es_ownership_3_flags {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${warranty_missed_opportunity.asset_id} = ${es_ownership_3_flags.asset_id} ;;
#   }
#
#   join: work_orders {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${work_orders.work_order_id} = ${warranty_missed_opportunity.work_order_id} ;;
#   }
#
#   join: dim_markets_fleet_opt {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${dim_markets_fleet_opt.market_id} = ${work_orders.branch_id} ;;
#   }
# }

explore: current_warranty_oec {
  case_sensitive: no
}

explore: warranty_oec_summary_by_quarter {
  case_sensitive: no

  join: new_missed_warranty_by_quarter {
    type: left_outer
    relationship: one_to_one
    sql_on: ${new_missed_warranty_by_quarter.quarter} = ${warranty_oec_summary_by_quarter.quarter}
      and ${new_missed_warranty_by_quarter.make} = ${warranty_oec_summary_by_quarter.make} ;;
  }

  join: q1_q2_missed_opp_tmp {
    type: left_outer
    relationship: one_to_one
    sql_on: ${q1_q2_missed_opp_tmp.make} = ${warranty_oec_summary_by_quarter.make}
      and ${warranty_oec_summary_by_quarter.quarter} = ${q1_q2_missed_opp_tmp.quarter};;
  }
}

explore: warranty_oec_summary_by_month {
  case_sensitive: no
}

explore: warranty_oec_year_summary {
  case_sensitive: no
}

# Commented out due to low usage on 2026-03-27
# explore: warranty_oec_company_wide_summary {
#   case_sensitive: no
# }

explore: warranty_admin_weekly_report {
  case_sensitive: no
  persist_for: "8 hours"
}

explore: warranty_admin_assignments {
  case_sensitive: no
  persist_for: "8 hours"
}

# Commented out due to low usage on 2026-03-27
# explore: weekly_missed_warranty {
#   case_sensitive: no
#   description: "Weekly Report of potential warranty Work Orders not warranty billed"
# }

# Commented out due to low usage on 2026-03-27
# explore: warranty_claim_performance {
#   label: "New Warranty Team Goal - May 2024"
#   case_sensitive: no
# }

# Commented out due to low usage on 2026-03-27
# explore: missed_warranty_opportunity_beta {
#   label: "Test Missed Warranty Oppourtunity Report"
#   case_sensitive: no
#
#   join: work_orders {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${missed_warranty_opportunity_beta.work_order_id} = ${work_orders.work_order_id} ;;
#   }
# }

explore: warrantable_assets_aggregate {
  label: "Asset Lookup Tool (Warranty Team) - Assets Aggregate"
  case_sensitive: no

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${warrantable_assets_aggregate.company_id} = ${companies.company_id} ;;
  }

  join: assets {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: scd_asset_hours {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${scd_asset_hours.asset_id};;
    sql_where: ${scd_asset_hours.current_flag} = 1 ;;
  }

  join: asset_delivery_date {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_delivery_date.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: assets_under_warranty {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_under_warranty.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: current_own_program_assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${current_own_program_assets.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: asset_engines {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_engines.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: asset_warranties {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_warranties.asset_id} = ${warrantable_assets_aggregate.asset_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = coalesce(${warrantable_assets_aggregate.rental_branch_id}, ${warrantable_assets_aggregate.inventory_branch_id}) ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warrantable_assets_aggregate.asset_id} = ${transportation_assets.asset_id} ;;
  }
}

explore: warranty_oec_v_oec {
  label: "Current month OEC vs Warranty OEC"
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_oec_v_oec.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

# Looking at warranty information for service
explore: invoices {
  group_label: "Invoice Information"
  label: "Pulling Warranty Info Service Project"
  case_sensitive: no
  # sql_always_where: ${assets.asset_id} in ${warranty_invoice_asset_info.asset_id} ;;
  ## MB commented the line below out 1_3_22
  #sql_always_where: ${warranty_invoice_asset_info.formatted_invoice_no} in ${warranty_invoices.invoice_number} ;;


  join: warranty_invoice_asset_info {
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.invoice_id} = ${warranty_invoice_asset_info.invoice_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${warranty_invoice_asset_info.branch_id}  ;;
  }

  join: assets {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${warranty_invoice_asset_info.asset_id} = ${assets.asset_id} ;;
    }

  join:  assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${warranty_invoice_asset_info.asset_id}  ;;
  }

  join: warranty_invoices {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_invoice_asset_info.work_order_id}::STRING = ${warranty_invoices.work_order_number} ;;
  }

# Old connector, may be deleted -Bri
#  join: warranty {
#    type: left_outer
#    relationship: one_to_one
#    sql_on: ${warranty_invoice_asset_info.formatted_invoice_no} = ${warranty.invoice_number} ;;
#  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${invoices.created_by_user_id} = ${users.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_many
    sql_on: ${invoices.company_id} = ${companies.company_id};;
  }

  join: es_asset_warranty {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.make} = ${es_asset_warranty.make} ;;
  }

  join: line_items {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.part_id} = ${parts.part_id} ;;
  }

  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }

  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id}::STRING = ${warranty_invoice_asset_info.work_order_id}::STRING ;;
  }

  join: est_work_order_cost {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${est_work_order_cost.work_order_id} ;;
  }

}

explore: line_items  {
  group_label: "Invoice Information"
  label: "Rental Revenue for Service Project"
  case_sensitive: no

  join: warranty_invoice_asset_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.invoice_id} = ${warranty_invoice_asset_info.invoice_id} ;;
  }

  join: invoices {
    type: inner
    relationship: many_to_many
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${line_items.branch_id}  ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_many
    sql_on: ${invoices.company_id} = ${companies.company_id};;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: warranty_oec {
#   group_label: "Asset Information"
#   label: "Warranty OEC Over Time"
#   case_sensitive: no
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${market_region_xwalk.market_id} = ${warranty_oec.branch_id}  ;;
#   }
# }

# New Weekly Tech Users
# explore: tech_user_weekly { --MB comment out 10-10-23 due to inactivity
#   label: "Tech User Report"
#   case_sensitive: no

#   join: users {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${tech_user_weekly.admin_id}=${users.user_id} ;;
#   }
# }

# # New Weekly All Users
# explore: paycor_employees_managers { --MB comment out 10-10-23 due to inactivity
#   label: "All LMS Users Report"
#   case_sensitive: no

#   join: users {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: trim(lower(${paycor_employees_managers.employee_email}))=trim(lower(${users.email_address})) ;;
#   }
# }

# explore: warranty_invoices { --MB comment out 10-10-23 due to inactivity
#   label: "Warranty Billing"
#   case_sensitive: no

#   join: work_orders {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${warranty_invoices.formatted_work_order_number} = ${work_orders.work_order_id} ;;
#   }

#   join: warranty_invoice_asset_info {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${warranty_invoice_asset_info.formatted_invoice_no} = ${warranty_invoices.invoice_number} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${market_region_xwalk.market_id} = ${warranty_invoice_asset_info.branch_id}  ;;
#   }
# }

# explore: work_orders {
# label: "Warranty Work Orders"
# case_sensitive: no

#   join: work_order_company_tags {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${work_orders.work_order_id} = ${work_order_company_tags.work_order_id} ;;
#   }

#   join: company_tags {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
#   }
# }
