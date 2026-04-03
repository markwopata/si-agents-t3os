connection: "non_prod_financial_systems"

include: "/views/FINANCIAL_SYSTEMS__STAGE/costentory_sandbox_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__items {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__markets {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__po_audit_log {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__po_headers {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__po_lines {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__po_receipt_headers {}

# Commented out due to low usage on 2026-03-30
# explore: costentory_sandbox__po_receipt_lines {}

include: "/views/FINANCIAL_SYSTEMS__STAGE/fleet_sandbox_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: fleet_sandbox__po_audit_log{}

# Commented out due to low usage on 2026-03-30
# explore: fleet_sandbox__po_headers {}

# Commented out due to low usage on 2026-03-30
# explore: fleet_sandbox__po_lines {}
explore: fleet_sandbox__vic_write_back {}

include: "/views/FINANCIAL_SYSTEMS__STAGE/intacct_sandbox_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__ap_headers {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__ap_lines {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__ap_resolve {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__assets {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__contacts {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__departments {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__employees {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__expense_lines {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__gl_accounts {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__gl_batches {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__gl_entries {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__gl_journals {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__gl_resolve {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__item_gl_groups {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__items {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__locations {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__po_headers {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__po_lines {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__users {}

# Commented out due to low usage on 2026-03-30
# explore: intacct_sandbox__vendors {}

include: "/views/FINANCIAL_SYSTEMS__STAGE/integrations_sandbox_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__dimensions {}

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__dimension_sync_plan {}

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__po_header_check {
#   join: costentory_sandbox__po_headers {
#     relationship: one_to_one
#     sql_on: ${costentory_sandbox__po_headers.pk_po_header_id} = ${integrations_vic_costcapture_sandbox__po_header_check.pk_po_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__po_line_check {
#   join: costentory_sandbox__po_lines {
#     relationship: one_to_one
#     sql_on: ${costentory_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_costcapture_sandbox__po_line_check.pk_po_line_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__po_header_sync_plan {
#   join: costentory_sandbox__po_headers {
#     relationship: one_to_one
#     sql_on: ${costentory_sandbox__po_headers.pk_po_header_id} = ${integrations_vic_costcapture_sandbox__po_header_sync_plan.pk_po_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_costcapture_sandbox__po_line_sync_plan {
#   join: costentory_sandbox__po_lines {
#     relationship: one_to_one
#     sql_on: ${costentory_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_costcapture_sandbox__po_line_sync_plan.pk_po_line_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_sandbox__dimensions {}

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_sandbox__dimension_sync_plan {}

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_sandbox__po_header_check {
#   join: fleet_sandbox__po_lines {
#     relationship: one_to_one
#     sql_on: ${fleet_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_fleet_sandbox__po_header_check.pk_po_line_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_e1_sandbox__po_header_sync_plan {
#   join: fleet_sandbox__po_lines {
#     relationship: one_to_one
#     # yes this really is to pk_po_header_id!
#     sql_on: ${fleet_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_fleet_e1_sandbox__po_header_sync_plan.pk_po_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_e1_sandbox__po_line_sync_plan {
#   join: fleet_sandbox__po_lines {
#     relationship: one_to_one
#     sql_on: ${fleet_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_fleet_e1_sandbox__po_line_sync_plan.pk_po_line_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_e7_sandbox__po_header_sync_plan {
#   join: fleet_sandbox__po_lines {
#     relationship: one_to_one
#     # yes this really is to pk_po_header_id!
#     sql_on: ${fleet_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_fleet_e7_sandbox__po_header_sync_plan.pk_po_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_fleet_e7_sandbox__po_line_sync_plan {
#   join: fleet_sandbox__po_lines {
#     relationship: one_to_one
#     sql_on: ${fleet_sandbox__po_lines.pk_po_line_id} = ${integrations_vic_fleet_e7_sandbox__po_line_sync_plan.pk_po_line_id} ;;
#   }
# }


include: "/views/FINANCIAL_SYSTEMS__STAGE/vic_sandbox_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__dimensions {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__invoice_headers {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__invoice_lines {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__invoice_line_items {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__po_headers {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__po_lines {}

# Commented out due to low usage on 2026-03-30
# explore: vic_sandbox__po_line_invoice_items_matched {}




# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
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
