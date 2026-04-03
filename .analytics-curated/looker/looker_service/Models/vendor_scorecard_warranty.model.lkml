connection: "es_snowflake_analytics"


# include: "/views/ES_WAREHOUSE/invoices.view.lkml"
# include: "/views/custom_sql/warranty_invoice_asset_info.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/ES_WAREHOUSE/assets.view.lkml"
# include: "/views/ANALYTICS/warranty_invoices.view.lkml"
# include: "/views/ES_WAREHOUSE/credit_notes.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
# include: "/views/ES_WAREHOUSE/company_purchase_orders.view.lkml"
# include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
# include: "/views/ES_WAREHOUSE/PURCHASES/entities.view.lkml"
# include: "/views/ES_WAREHOUSE/PURCHASES/entity_vendor_settings.view.lkml"
# include: "/views/custom_sql/lost_revenue.view.lkml"
# include: "/views/ANALYTICS/INTACCT/company_to_sage_vendor_xwalk.view.lkml"
# include: "/views/ANALYTICS/INTACCT_MODELS/src_intacct__vendor.view.lkml"
# include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
# include: "/views/custom_sql/lead_time_2023.view.lkml"


# #MB commented out 5/22/24
# # explore: invoices {
# #   #group_label: "Vendor Scorecard"
# #   label: "Old Warranty Info Vendor Scorecard"
# #   case_sensitive: no

# #   join: warranty_invoice_asset_info {
# #     type: inner
# #     relationship: many_to_one
# #     sql_on: ${invoices.invoice_id} = ${warranty_invoice_asset_info.invoice_id} ;;
# #   }

# #   join: market_region_xwalk {
# #     type: left_outer
# #     relationship: one_to_one
# #     sql_on: ${market_region_xwalk.market_id} = ${warranty_invoice_asset_info.branch_id}  ;;
# #   }

# #   join: assets {
# #     type:  left_outer
# #     relationship: many_to_one
# #     sql_on:  ${warranty_invoice_asset_info.asset_id} = ${assets.asset_id} ;;
# #   }

# #   join: warranty_invoices {
# #     type: left_outer
# #     relationship: many_to_one
# #     sql_on: ${warranty_invoice_asset_info.formatted_invoice_no} = ${warranty_invoices.invoice_number} ;;
# #   }

# #   join: credit_notes {
# #     type: left_outer
# #     relationship: one_to_one
# #     sql_on: ${invoices.invoice_id} = ${credit_notes.originating_invoice_id} ;;
# #   }

# #   join: asset_purchase_history {
# #     type:  left_outer
# #     relationship: one_to_one
# #     sql_on:  ${assets.asset_id} = ${asset_purchase_history.asset_id} ;;
# #   }

# #   join: company_purchase_order_line_items {
# #     type:  left_outer
# #     relationship: one_to_one
# #     sql_on:  ${asset_purchase_history.asset_id} = ${company_purchase_order_line_items.asset_id} ;;
# #   }

# #   join: company_purchase_orders {
# #     type:  inner
# #     relationship: one_to_one
# #     sql_on:  ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
# #   }

# #   join: company_to_sage_vendor_xwalk {
# #     type:  inner
# #     relationship: one_to_one
# #     sql_on:  ${company_purchase_orders.vendor_id} = ${company_to_sage_vendor_xwalk.company_id} ;;
# #   }

# #   join: src_intacct__vendor {
# #     type:  inner
# #     relationship: one_to_one
# #     sql_on:  ${src_intacct__vendor.vendor_id} = ${company_to_sage_vendor_xwalk.vendorid} ;;
# #   }
# #   }



# explore: entities {
#   #group_label: "Vendor Scorecard"
#   label: "Old Entity/Vendor Base Table"
#   case_sensitive: no

#   join: entity_vendor_settings {
#     type:  inner
#     relationship: one_to_one
#     sql_on:  ${entities.entity_id} = ${entity_vendor_settings.entity_id} ;;
#   }
#   }

# explore: vendor {
#   #group_label: "Vendor Scorecard"
#   label: "Old Vendor Base Table"
#   case_sensitive: no
# }

# explore: lost_revenue {
#   #group_label: "Vendor Scorecard"
#   label: "Old Lost Revenue"
#   case_sensitive: no
# }

# # explore: lead_time_2023 {
# #   #group_label: "Vendor Scorecard"
# #   label: "Old Lead Time"
# #   case_sensitive: no

# #   join: entity_vendor_settings {
# #     type:  left_outer
# #     relationship: one_to_one
# #     sql_on:  ${lead_time_2023.vendor_id} = ${entity_vendor_settings.entity_id} ;;
# #   }
# # }
