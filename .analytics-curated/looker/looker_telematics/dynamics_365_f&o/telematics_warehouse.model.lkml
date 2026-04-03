connection: "es_snowflake_analytics"

# T3 SAAS VIEWS
include: "/views/custom_sql/t3_saas_warehouse_shipment_data.view.lkml"
include: "/views/custom_sql/t3_saas_hubspot_contract_data.view.lkml"
include: "/views/custom_sql/t3_saas_shipment_to_contract_mapping.view.lkml"
include: "/views/custom_sql/t3_saas_customer_master.view.lkml"
include: "/views/custom_sql/T3_SaaS_Revenue_Hardware_Cost_Totals.view.lkml"
include: "/views/custom_sql/T3aas_Admin_Revenue.view.lkml"
include: "/views/custom_sql/t3_saas_IBR_submissions.view.lkml"
include: "/views/custom_sql/t3_saas_booked_invoices.view.lkml"
include: "/views/custom_sql/t3_saas_in_service_inventory.view.lkml"
include: "/views/custom_sql/T3_SaaS_Admin_Invoices.view.lkml"
include: "/views/custom_sql/T3aaS_TAM_Referrals.view.lkml"
include: "/views/custom_sql/T3aaS_Deactivation_Billing_Adjustments.view.lkml"
include: "/views/custom_sql/T3aaS_Deactivation_Billing_Adjustments_Totals.view.lkml"
include: "/views/custom_sql/t3_saas_tam_referral_to_company_id.view.lkml"
include: "/views/custom_sql/t3_saas_tracker_report_v2.view.lkml"
include: "/views/custom_sql/t3_saas_billing_sheet_mrr.view.lkml"
# T3 SAAS DBT MODEL VIEWS
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/customer_master.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/hubspot_contract_data.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/shipment_to_contract.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/telematics_assignments.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/warehouse_shipment_data.view.lkml"


# TELEMATICS WAREHOUSE & OPERATIONS VIEWS
include: "/views/custom_sql/D365_ITEM_QTY_CHG_N90.view.lkml"
include: "/views/custom_sql/D365_ITEM_QTY_CHG_N180.view.lkml"
include: "/views/custom_sql/D365_Inventory_Valuation_by_Location.view.lkml"
include: "/views/custom_sql/D365_Open_Order_Totals_KCK.view.lkml"
include: "/views/custom_sql/telematics_warehouse_all_shipments.view.lkml"
include: "/views/custom_sql/telematics_warehouse_assignment_history.view.lkml"
include: "/views/custom_sql/kore_sims_iccids.view.lkml"
include: "/views/custom_sql/Telematics_Warehouse_Internal_Ordering_Inventory.view.lkml"
include: "/views/custom_sql/D365_SalesOrder_Totals_OEM.view.lkml"
include: "/views/custom_sql/D365_Kit_Totals_OEM.view.lkml"
include: "/views/custom_sql/purchase_order_headers_kck.view.lkml"
include: "/views/custom_sql/purchase_order_lines_kck.view.lkml"


# TELEMATICS ACCOUNTING VIEWS
include: "/views/custom_sql/telematics_accounting_trackers.view.lkml"
include: "/views/custom_sql/telematics_accounting_keypads_and_cameras.view.lkml"
include: "/views/custom_sql/telematics_accounting_non_serialized_parts.view.lkml"
include: "/views/custom_sql/tracker_manager_accounting_es1.view.lkml"
include: "/views/custom_sql/tracker_manager_accounting_es2.view.lkml"
include: "/views/custom_sql/tracker_manager_accounting_es3.view.lkml"
include: "/views/custom_sql/tracker_manager_accounting_es2_and_es3_installs.view.lkml"
include: "/views/custom_sql/Tracker_Manager_Telematics_In_Service_Inventory.view.lkml"
include: "/views/custom_sql/Telematics_Devices_TBR.view.lkml"
include: "/views/custom_sql/Telematics_Devices_AS4K_Details.view.lkml"
include: "/views/custom_sql/Telematics_Mothership_Asset_Accounting.view.lkml"
# TELEMATICS ACCOUNTING DBT MODEL VIEWS
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/es1_tracker_installs.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/es2_es3_keypad_camera_installs.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/es2_keypad_installs.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/es3_camera_installs.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/tele_01_trackers.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/tele_02_keypads_and_cameras.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/UR_TELEMATICS_GOLD/tele_03_non_serialized.view.lkml"


# T3 SAAS MODELS

# T3 SaaS Warehouse Shipment Data
explore: t3_saas_warehouse_shipment_data {
  label: "T3 SaaS Warehouse Shipment Data"
  case_sensitive: no

  join: t3_saas_shipment_to_contract_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_warehouse_shipment_data.SHIPPED_SERIAL_FORMATTED} = ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED}
      AND ${t3_saas_warehouse_shipment_data.SALES_REF_ID} = ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID};;
  }

  join:  t3_saas_hubspot_contract_data {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID}
      AND ${t3_saas_hubspot_contract_data.CONTRACT_NAME} = ${t3_saas_shipment_to_contract_mapping.CONTRACT_NAME}
      AND ${t3_saas_shipment_to_contract_mapping.LINKED_DEVICE_TYPE} = ${t3_saas_hubspot_contract_data.LINKED_DEVICE_TYPE}
      AND ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_warehouse_shipment_data.SALES_REF_ID}
      AND ${t3_saas_hubspot_contract_data.PRODUCT_ID} = ${t3_saas_shipment_to_contract_mapping.PRODUCT_ID};;
  }

  join: T3aaS_TAM_Referrals {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_hubspot_contract_data.COMPANY_ID} = ${T3aaS_TAM_Referrals.ES_ADMIN_ID} ;;
  }

  join: t3aas_admin_revenue {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${t3_saas_hubspot_contract_data.COMPANY_ID} = ${t3aas_admin_revenue.COMPANY_ID} ;;
  }

  join: t3_saas_in_service_inventory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_warehouse_shipment_data.ADJ_CURRENT_SERIAL_FORMATTED} = ${t3_saas_in_service_inventory.DEVICE_SERIAL};;
  }

  join: t3_saas_customer_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_customer_master.COMPANY_ID} = ${t3_saas_hubspot_contract_data.COMPANY_ID} ;;
  }

  join: t3_saas_revenue_hardware_cost_totals {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_revenue_hardware_cost_totals.SALES_ORDER_CUSTOMER_REF} = ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID} ;;
  }

  join: t3_saas_IBR_submissions {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID} = ${t3_saas_IBR_submissions.SALES_REF_ID} ;;
  }

  join: T3aaS_Deactivation_Billing_Adjustments {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED} =  ${T3aaS_Deactivation_Billing_Adjustments.SERIAL_FORMATTED};;
  }

  join: T3aaS_Deactivation_Billing_Adjustments_Totals {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.CONTRACT_NAME} =  ${T3aaS_Deactivation_Billing_Adjustments_Totals.BUNDLE_TYPE} and ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID} =  ${T3aaS_Deactivation_Billing_Adjustments_Totals.SALES_REF_ID} ;;
  }

}


# HubSpot Contract Data
explore: t3_saas_hubspot_contract_data {
  label: "Hubspot Contract Data"
  view_name: t3_saas_hubspot_contract_data

  join: T3aaS_TAM_Referrals {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_hubspot_contract_data.COMPANY_ID} = ${T3aaS_TAM_Referrals.ES_ADMIN_ID} ;;
  }

  join: t3aas_admin_revenue {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${t3_saas_hubspot_contract_data.COMPANY_ID} = ${t3aas_admin_revenue.COMPANY_ID} ;;
  }

  join: t3_saas_shipment_to_contract_mapping {
    type: full_outer
    relationship: many_to_one
    sql_on: ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID}
      AND ${t3_saas_hubspot_contract_data.CONTRACT_NAME} = ${t3_saas_shipment_to_contract_mapping.CONTRACT_NAME}
      AND ${t3_saas_shipment_to_contract_mapping.LINKED_DEVICE_TYPE} = ${t3_saas_hubspot_contract_data.LINKED_DEVICE_TYPE}
      AND ${t3_saas_shipment_to_contract_mapping.PRODUCT_ID} = ${t3_saas_hubspot_contract_data.PRODUCT_ID};;
  }

  join: t3_saas_warehouse_shipment_data {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${t3_saas_warehouse_shipment_data.SHIPPED_SERIAL_FORMATTED} = ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED}
      AND ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_warehouse_shipment_data.SALES_REF_ID};;
  }

  join: t3_saas_in_service_inventory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_warehouse_shipment_data.ADJ_CURRENT_SERIAL_FORMATTED} = ${t3_saas_in_service_inventory.DEVICE_SERIAL};;
  }

  join: T3aaS_Deactivation_Billing_Adjustments {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED} =  ${T3aaS_Deactivation_Billing_Adjustments.SERIAL_FORMATTED};;
  }

  join: T3aaS_Deactivation_Billing_Adjustments_Totals {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.CONTRACT_NAME} =  ${T3aaS_Deactivation_Billing_Adjustments_Totals.BUNDLE_TYPE} and ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID} =  ${T3aaS_Deactivation_Billing_Adjustments_Totals.SALES_REF_ID} ;;
  }

  join: t3_saas_customer_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_customer_master.COMPANY_ID} = ${t3_saas_hubspot_contract_data.COMPANY_ID} ;;
  }

  join: t3_saas_tracker_report_v2  {
    type: full_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_in_service_inventory.DEVICE_SERIAL} = ${t3_saas_tracker_report_v2.DEVICE_SERIAL} ;;
  }

  join: t3_saas_billing_sheet_mrr {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_in_service_inventory.COMPANY_ID} = ${t3_saas_billing_sheet_mrr.COMPANY_ID} and  ${t3_saas_in_service_inventory.CONTRACT_NAME} = ${t3_saas_billing_sheet_mrr.CONTRACT_NAME} and  ${t3_saas_in_service_inventory.CONTRACT_UNIT_COST} = ${t3_saas_billing_sheet_mrr.CONTRACT_UNIT_COST} and  ${t3_saas_in_service_inventory.BINARY_CUSTOMER_BILLING_DESIGNATION} = ${t3_saas_billing_sheet_mrr.SUBSCRIPTION_AGREEMENT} ;;
  }
}


# T3 SaaS Admin Revenue
explore: T3aas_Admin_Revenue {
  label: "t3aas_admin_revenue"
  view_name:  t3aas_admin_revenue
  case_sensitive: no

  join:  t3_saas_booked_invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${t3aas_admin_revenue.COMPANY_ID} =  ${t3_saas_booked_invoices.COMPANY_ID}
    and ${t3aas_admin_revenue.INVOICE_MONTH} =  ${t3_saas_booked_invoices.INVOICE_MONTH}
    and ${t3aas_admin_revenue.INVOICE_YEAR} =  ${t3_saas_booked_invoices.INVOICE_YEAR};;
  }

  join:  T3_SaaS_Admin_Invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${t3aas_admin_revenue.COMPANY_ID} =  ${T3_SaaS_Admin_Invoices.COMPANY_ID}
    and ${t3aas_admin_revenue.INVOICE_MONTH} =  ${T3_SaaS_Admin_Invoices.BILLING_APPROVED_MONTH}
    and ${t3aas_admin_revenue.INVOICE_YEAR} =  ${T3_SaaS_Admin_Invoices.BILLING_APPROVED_YEAR};;
  }

  join: t3_saas_customer_master {
    type: left_outer
    relationship: many_to_one
    sql_on: ${t3_saas_customer_master.COMPANY_ID} = ${t3aas_admin_revenue.COMPANY_ID} ;;
  }

  join: t3_saas_tam_referral_to_company_id {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${t3_saas_customer_master.COMPANY_ID} = ${t3_saas_tam_referral_to_company_id.COMPANY_ID} ;;
  }

  join: t3_saas_revenue_hardware_cost_totals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${t3aas_admin_revenue.COMPANY_ID} = ${t3_saas_revenue_hardware_cost_totals.COMPANY_ID} ;;
  }
}


# T3 SaaS In Service Inventory
explore: t3_saas_in_service_inventory {
  label: "t3_saas_in_service_inventory"
  view_name:  t3_saas_in_service_inventory
  case_sensitive: no

  join: t3_saas_shipment_to_contract_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED} = ${t3_saas_in_service_inventory.DEVICE_SERIAL} ;;
  }

  join: t3_saas_warehouse_shipment_data {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${t3_saas_warehouse_shipment_data.SHIPPED_SERIAL_FORMATTED} = ${t3_saas_shipment_to_contract_mapping.SHIPPED_SERIAL_FORMATTED} ;;
  }

  join:  t3_saas_hubspot_contract_data {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_shipment_to_contract_mapping.SALES_REF_ID}
      AND ${t3_saas_hubspot_contract_data.CONTRACT_NAME} = ${t3_saas_shipment_to_contract_mapping.CONTRACT_NAME}
      AND ${t3_saas_shipment_to_contract_mapping.LINKED_DEVICE_TYPE} = ${t3_saas_hubspot_contract_data.LINKED_DEVICE_TYPE}
      AND ${t3_saas_hubspot_contract_data.SALES_REF_ID} = ${t3_saas_warehouse_shipment_data.SALES_REF_ID};;
  }
}


# T3 SaaS TAM Referrals
explore: T3aaS_TAM_Referrals {
  label: "T3aaS_TAM_Referrals"
  view_name: T3aaS_TAM_Referrals
  case_sensitive: no
}


# TELEMATICS WAREHOUSE & OPERATIONS VIEWS

# Inventory Valuation By Location
explore: d365_inventory_valuation_by_location {
  label: "Inventory_Valuation_By_Location"
  case_sensitive: no

  join:  d365_item_qty_chg_n90 {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${d365_item_qty_chg_n90.PART_ID} = ${d365_inventory_valuation_by_location.D365_ITEM_ID} ;;
  }

  join:  d365_item_qty_chg_n180 {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${d365_item_qty_chg_n180.PART_ID} = ${d365_inventory_valuation_by_location.D365_ITEM_ID} ;;
  }

  join: d365_open_order_totals_kck {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${d365_open_order_totals_kck.D365_ITEM_ID} = ${d365_inventory_valuation_by_location.D365_ITEM_ID}  ;;
  }
}


# Telematics Warehouse All Shipments & Assignment History
explore: telematics_warehouse_all_shipments {
  label: "Telematics Warehouse All Shipments & Assignment History"
  case_sensitive: no

  join: telematics_warehouse_assignment_history {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${telematics_warehouse_all_shipments.SERIAL_FORMATTED} = ${telematics_warehouse_assignment_history.DEVICE_SERIAL}
      AND ${telematics_warehouse_all_shipments.DEVICE_TYPE} = ${telematics_warehouse_assignment_history.DEVICE_TYPE};;
  }
}


# Kore Sims ICCIDs
explore: kore_sims_iccids {
  label: "kore_sims_iccids"
  view_name:  kore_sims_iccids
  case_sensitive: no
}


# Internal Ordering Inventory
explore: Telematics_Warehouse_Internal_Ordering_Inventory {
  label: "telematics_warehouse_internal_ordering_inventory"
  view_name:  telematics_warehouse_internal_ordering_inventory
  case_sensitive: no
}


# OEM Kit Sales
explore: D365_SalesOrder_Totals_OEM {
  label: "D365_SalesOrder_Totals_OEM"
  view_name: D365_SalesOrder_Totals_OEM
  case_sensitive: no

  join: D365_Kit_Totals_OEM {
    type: left_outer
    relationship: one_to_one
    sql_on: ${D365_SalesOrder_Totals_OEM.D365_CUST_SALES_ORDER_NUMBER} = ${D365_Kit_Totals_OEM.D365_CUST_SALES_ORDER_NUMBER} ;;
  }
}

# Telematics Warehouse Purchasing Analytics
explore: purchase_order_lines_kck {
  label: "purchase_order_lines_kck"
  case_sensitive: no

  join: purchase_order_headers_kck {
    type: left_outer
    relationship: one_to_one
    sql_on: ${purchase_order_lines_kck.PO_NUMBER} = ${purchase_order_headers_kck.PO_NUMBER} ;;
  }
}


# TELEMATICS ACCOUNTING MODELS


# Asset Accounting In Service Inventory
explore: Tracker_Manager_Telematics_In_Service_Inventory {
  label: "Asset_Accounting_In_Service_Inventory"
  view_name:  Tracker_Manager_Telematics_In_Service_Inventory
  case_sensitive: no

  join: telematics_warehouse_all_shipments {
      type: left_outer
      relationship:  one_to_one
      sql_on: ${Tracker_Manager_Telematics_In_Service_Inventory.DEVICE_SERIAL} =  ${telematics_warehouse_all_shipments.SERIAL_FORMATTED};;
  }

  join: Telematics_Devices_TBR {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${Tracker_Manager_Telematics_In_Service_Inventory.DEVICE_SERIAL} =  ${Telematics_Devices_TBR.SERIAL_FORMATTED};;
  }

  join: Telematics_Devices_AS4K_Details {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${Tracker_Manager_Telematics_In_Service_Inventory.DEVICE_SERIAL} =  ${Telematics_Devices_AS4K_Details.SERIAL_NUMBER};;
  }

  join: Telematics_Mothership_Asset_Accounting {
    type: left_outer
    relationship: one_to_one
    sql_on: ${Telematics_Mothership_Asset_Accounting.SERIAL_FORMATTED} = ${Tracker_Manager_Telematics_In_Service_Inventory.DEVICE_SERIAL} ;;
  }
}


# Telematics Devices TBR
explore: Telematics_Devices_TBR {
  label: "Telematics_Devices_TBR"
  view_name:  Telematics_Devices_TBR
  case_sensitive: no

  join: Tracker_Manager_Telematics_In_Service_Inventory {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${Tracker_Manager_Telematics_In_Service_Inventory.DEVICE_SERIAL} = ${Telematics_Devices_TBR.SERIAL_FORMATTED} ;;
  }
}


# Telematics Accounting Trackers
explore: telematics_accounting_trackers {
  label: "telematics_accounting_trackers"
  view_name: telematics_accounting_trackers
  case_sensitive: no

  join: tracker_manager_accounting_es1 {
    type: left_outer
    relationship: one_to_one
    sql_on: ${telematics_accounting_trackers.SERIAL_FORMATTED} = ${tracker_manager_accounting_es1.SERIAL_FORMATTED} ;;
  }
}


# Telematics Accounting Keypads and Cameras
explore: telematics_accounting_keypads_and_cameras {
  label: "telematics_accounting_keypads_and_cameras"
  view_name: telematics_accounting_keypads_and_cameras
  case_sensitive: no

  join: tracker_manager_accounting_es2_and_es3_installs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${telematics_accounting_keypads_and_cameras.SERIAL_FORMATTED} = ${tracker_manager_accounting_es2_and_es3_installs.SERIAL_FORMATTED} ;;
  }
}


# Telematics Accounting Non Serialized Parts
explore: telematics_accounting_non_serialized_parts {
  label: "telematics_accounting_non_serialized_parts"
  view_name: telematics_accounting_non_serialized_parts
  case_sensitive: no
}


# Tracker Manager Accounting ES1
explore: tracker_manager_accounting_es1 {
  label: "tracker_manager_accounting_es1"
  view_name: tracker_manager_accounting_es1
  case_sensitive: no

  join: telematics_accounting_trackers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${telematics_accounting_trackers.SERIAL_FORMATTED} = ${tracker_manager_accounting_es1.SERIAL_FORMATTED} ;;
  }
}


# Tracker Manager Accounting ES2
explore: tracker_manager_accounting_es2 {
  label: "tracker_manager_accounting_es2"
  view_name: tracker_manager_accounting_es2
  case_sensitive: no

  join: telematics_accounting_keypads_and_cameras {
    type: left_outer
    relationship: one_to_one
    sql_on: ${telematics_accounting_keypads_and_cameras.SERIAL_FORMATTED} = ${tracker_manager_accounting_es2.SERIAL_FORMATTED} ;;
  }
}


# Tracker Manager Accounting ES3
explore: tracker_manager_accounting_es3 {
  label: "tracker_manager_accounting_es3"
  view_name: tracker_manager_accounting_es3
  case_sensitive: no

  join: telematics_accounting_keypads_and_cameras {
    type: left_outer
    relationship: one_to_one
    sql_on: ${telematics_accounting_keypads_and_cameras.SERIAL_FORMATTED} = ${tracker_manager_accounting_es3.SERIAL_FORMATTED} ;;
  }
}

# DBT Model Explores

## SaaS
explore: customer_master {
  label: "T3 SaaS Customer Master"
  view_name: "customer_master"
}

explore: hubspot_contract_data {
  label: "HubSpot Contract Data"
  view_name: "hubspot_contract_data"
}

explore: shipment_to_contract {
  label: "Shipment To Contract Mapping"
  view_name: "shipment_to_contract"
}

explore: telematics_assignments {
  label: "Telematics Assignments / In Service Inventory"
  view_name:  "telematics_assignments"
}

explore: warehouse_shipment_data {
  label: "T3 SaaS Warehouse Shipment Data"
  view_name: "warehouse_shipment_data"
}

## Accounting
explore: es1_tracker_installs {
  label: "es1_tracker_installs"
  view_name: "es1_tracker_installs"
}

explore: es2_es3_keypad_camera_installs {
  label: "es2_es3_keypad_camera_installs"
  view_name: "es2_es3_keypad_camera_installs"
}

explore: es2_keypad_installs {
  label: "es2_keypad_installs"
  view_name: "es2_keypad_installs"
}

explore: es3_camera_installs {
  label: "es3_camera_installs"
  view_name: "es3_camera_installs"
}

explore: tele_01_trackers {
  label: "tele_01_trackers"
  view_name: "tele_01_trackers"
}

explore: tele_02_keypads_and_cameras {
  label: "tele_02_keypads_and_cameras"
  view_name: "tele_02_keypads_and_cameras"
}

explore: tele_03_non_serialized {
  label: "tele_03_non_serialized"
  view_name: "tele_03_non_serialized"
}
