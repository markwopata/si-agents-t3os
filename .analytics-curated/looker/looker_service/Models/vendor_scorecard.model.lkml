connection: "es_snowflake_analytics"

include: "/views/custom_sql/vendor_scorecard/*"
include: "/views/custom_sql/lead_time_2023.view.lkml"
include: "/views/custom_sql/back_order_parts.view.lkml"
include: "/views/ANALYTICS/top_vendor_mapping.view.lkml"
include: "/views/custom_sql/get_past_dates.view.lkml"
#for OEC import
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/ANALYTICS/INTACCT/company_to_sage_vendor_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
include: "/views/custom_sql/warranty_invoices.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/warranty_oec.view.lkml"
include: "/views/custom_sql/oem_assets_vendor_scorecard.view.lkml"
include: "/views/ANALYTICS/SERVICE/asset_month_maintenance_cost.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/ap_detail.view.lkml"
include: "/views/ANALYTICS/INTACCT/glaccount.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/category_growth.view.lkml"
include: "/views/custom_sql/vendor_scorecard/purchase_orders_without_invoices.view.lkml"
include: "/views/custom_sql/vendor_scorecard/warranty_vendor_level.view.lkml"
include: "/views/ANALYTICS/ASSETS/int_asset_historical.view.lkml"
include: "/views/FLEET_OPTIMIZATION/fact_total_cost_to_own.view.lkml"
include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
include: "/views/ANALYTICS/WARRANTIES/warranty_terms.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/vendor_rebate_terms.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/vendor_freight_terms.view.lkml"
include: "/views/custom_sql/vendor_scorecard/vendor_market_share.view.lkml"
include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
include: "/views/custom_sql/vendor_accountability.view.lkml"
include: "/views/PLATFORM/dim_parts.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/parts_attributes.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"

explore: top_vendors_by_part_category_spend {
  from: top_vendor_mapping
  case_sensitive: no

  join: vendor_category_spend_12mo {
    type: inner
    relationship: one_to_many
    sql_on: ${top_vendors_by_part_category_spend.vendorid} = ${vendor_category_spend_12mo.vendorid} ;;
  }
}

explore: vendor_accountability_tvm {
  from: top_vendor_mapping
  case_sensitive: no

  join: vendor_accountability {
    type: inner
    relationship: one_to_many
    sql_on: ${vendor_accountability_tvm.vendorid} = ${vendor_accountability.vendor} ;;
  }

  join: dim_parts {
    type: inner
    relationship: many_to_one
    sql_on: ${vendor_accountability.part_id} = ${dim_parts.part_id} ;;
  }
}

explore: top_vendor_mapping_for_po_without_invoice {
  from: top_vendor_mapping
  label: "PO's not in Sage - Top Vendor Mapping"
  case_sensitive: no

  join: purchase_orders {
    from: purchase_orders_without_invoices
    type: inner
    relationship: one_to_many
    sql_on: ${top_vendor_mapping_for_po_without_invoice.vendorid} = ${purchase_orders.vendorid} ;;
  }
}

explore: sage_spending {
  from: top_vendor_mapping
  group_label: "Vendor Scorecard"
  label: "Vendor Scorecard Spend Sage Level"
  case_sensitive: no
  sql_always_where: ${ap_detail.ap_header_type} ilike 'apbill' ;;

  join: ap_detail {
    type: inner
    relationship: many_to_one
    sql_on: ${ap_detail.vendor_id} = ${sage_spending.vendorid} ;;
  }

  join: glaccount {
    type: inner
    relationship: one_to_many
    sql_on: ${glaccount.accountno} = coalesce(${ap_detail.expense_account_number}, ${ap_detail.account_number}) ;;
  }

  join: oec_comparison {
    type: left_outer
    from: oec_for_comparison
    relationship: one_to_many
    view_label: "OEC for comparison"
    sql_on: ${sage_spending.vendorid} = ${oec_comparison.vendorid}
      and ${oec_comparison.generateddate} = ${ap_detail.gl_month}
      ;;
  }

  join: reporting_markets {
    from: dim_markets_fleet_opt
    type: left_outer
    relationship: many_to_one
    sql_on: ${ap_detail.department_id} = ${reporting_markets.market_id}
      and ${reporting_markets.reporting_market};;
  }
}

explore: vendor_scorecard {
  from: top_vendor_mapping
  group_label: "Vendor Scorecard"
  label: "Vendor Grading Explore"

  join: vendor_warranty_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_warranty_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  # join: vendor_fleet_unavailable_score { #This is using the old table. Replaced with the int_asset_historical table found in vendor_unavailable_score table below
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${vendor_fleet_unavailable_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  # }

  join: vendor_fulfillment_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_fulfillment_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_ap_detail_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_ap_detail_score.vendor_id} = ${vendor_scorecard.vendorid} ;;
  }

  # join: vendor_month_maintenance_score { #This is using the old table. Replaced with the fact_total_cost_to_own table found in vendor_cost_to_own_score table below
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${vendor_month_maintenance_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  # }

  join: vendor_unavailable_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_unavailable_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_cost_to_own_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_cost_to_own_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_lead_time_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_lead_time_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_back_order_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_back_order_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_payment_term_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_payment_term_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_warranty_terms_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_warranty_terms_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_rebate_terms_score  {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_rebate_terms_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }

  join: vendor_freight_terms_score {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor_freight_terms_score.vendorid} = ${vendor_scorecard.vendorid} ;;
  }
}

#vendor-level table
explore: top_vendor_mapping {
  group_label: "Vendor Scorecard"
  label: "Vendor Scorecard Full Explore"
  case_sensitive: no

  # persist_for: "1 minute"

  join: get_past_dates_filter {
    type: cross
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${get_past_dates_filter.generateddate_date} ;;
  }

  join: back_order_parts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${back_order_parts.vendorid}
    AND ${get_past_dates_filter.generateddate_date} = ${back_order_parts.date_created} ;;
  }

  join: back_order_parts_all_PO_status {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${back_order_parts_all_PO_status.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${back_order_parts_all_PO_status.date_created} ;;
  }

  join: parts_spend_vendor_level {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${parts_spend_vendor_level.vendorid}
    AND ${get_past_dates_filter.generateddate_date} = ${parts_spend_vendor_level.PO_Date_date} ;;
  }

  #for asset spend and total spend
  join: oec_asset {
    from: oec_vendor_level
    type: left_outer
    relationship: one_to_many
    view_label: "OEC for Asset Spend"
    sql_on: ${top_vendor_mapping.vendorid} = ${oec_asset.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${oec_asset.po_date_created} ;;
  }

  join: lead_time_2023 {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${lead_time_2023.vendorid}
    AND ${get_past_dates_filter.generateddate_date} = ${lead_time_2023.date_created} ;;
  }

  join: lost_revenue_vendor_level {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${lost_revenue_vendor_level.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${lost_revenue_vendor_level.filter_date_date} ;;
  }

  join: warranty_vendor_level {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${warranty_vendor_level.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${warranty_vendor_level.date_created} ;;
  }

  #date table joined between invoice billing approved date and paid date
  join: warranty_pending {
    from: warranty_vendor_level
    type: left_outer
    relationship: one_to_many
    view_label: "Pending Warranty"
    sql_on: ${top_vendor_mapping.vendorid} = ${warranty_pending.vendorid}
      AND ${get_past_dates_filter.generateddate_date} >= ${warranty_pending.billing_approved_date}
      AND (${get_past_dates_filter.generateddate_date} < ${warranty_pending.paid_date} OR ${warranty_pending.paid_date} IS NULL)
      ;;
  }

  #warranty vs 2% OEC over time
  join: warranty_oec_vendor {
    type: left_outer
    relationship: one_to_many
    view_label: "Warranty vs. OEC"
    sql_on: ${top_vendor_mapping.vendorid} = ${warranty_oec_vendor.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${warranty_oec_vendor.generateddate_date} ;;
  }

  #for unavailable OEC and comparison metrics (except warranty)
  #where we do not want OEC to be filtered, just the other metric
  join: oec_comparison {
    type: left_outer
    from: oec_for_comparison
    relationship: one_to_many
    view_label: "OEC for comparison"
    sql_on: ${top_vendor_mapping.vendorid} = ${oec_comparison.vendorid}
      and ${oec_comparison.generateddate} = ${get_past_dates_filter.generateddate_month}
      ;;
  }

  #for unavailable OEC and comparison to warranty
  join: oec_comparison_warranty {
    from: oec_vendor_level
    type: left_outer
    relationship: one_to_many
    view_label: "OEC for comparison warranty"
    sql_on: ${top_vendor_mapping.vendorid} = ${oec_comparison_warranty.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${oec_comparison_warranty.date_created_date}
      ;;
  }

  join: labor_cost_vendor_level {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${labor_cost_vendor_level.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${labor_cost_vendor_level.date_completed_date} ;;
  }

  join: labor_cost_parts_join {
    from: labor_cost_vendor_level
    type: left_outer
    relationship: one_to_many
    view_label: "Labor cost for parts spend vs OEC"
    sql_on: ${parts_spend_vendor_level.vendorid} = ${labor_cost_parts_join.vendorid}
      AND ${parts_spend_vendor_level.PO_Date_date} = ${labor_cost_parts_join.date_completed_date}
      ;;
      }

  join: fleet_unavailable {
    type: left_outer
    relationship: one_to_many
    view_label: "Fleet Unavailable %"
    sql_on: ${top_vendor_mapping.vendorid} = ${fleet_unavailable.vendorid}
      AND ${get_past_dates_filter.generateddate_date} = ${fleet_unavailable.generateddate_date}
      ;;
  }

  join: ap_detail_part_spend {
    type: left_outer
    relationship: many_to_many
    sql_on: ${ap_detail_part_spend.vendor_id} = ${top_vendor_mapping.vendorid}
      and ${ap_detail_part_spend.invoice_month} = ${get_past_dates_filter.generateddate_month} ;; # This is actually GL Date
  }

  join: ap_detail_total_daily_spend {
    type: left_outer
    relationship: many_to_many
    sql_on: ${ap_detail_total_daily_spend.vendor_id} = ${top_vendor_mapping.vendorid}
      and ${ap_detail_total_daily_spend.invoice_date} = ${get_past_dates_filter.generateddate_date} ;; # This is actually GL Date
  }

  join: ap_detail_total_daily_spend_gl_account {
    from: glaccount
    type: left_outer
    relationship: many_to_one
    sql_on: ${ap_detail_total_daily_spend.account_no} = ${ap_detail_total_daily_spend_gl_account.accountno} ;;
  }

  join: vendor_int_asset_historical {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${vendor_int_asset_historical.vendorid}
      and ${get_past_dates_filter.generateddate_date} = ${vendor_int_asset_historical.daily_timestamp_date} ;;
  }

  join: vendor_total_cost_to_own {
    type: left_outer
    relationship: one_to_many
    sql_on: ${top_vendor_mapping.vendorid} = ${vendor_total_cost_to_own.vendorid}
      and ${get_past_dates_filter.generateddate_date} = ${vendor_total_cost_to_own.reference_date};;
  }

  join: vendor_market_share {
    type: left_outer
    relationship: many_to_many
    sql_on: ${vendor_market_share.vendorid} = ${top_vendor_mapping.vendorid}
      and ${vendor_market_share.reference_date} = ${get_past_dates_filter.generateddate_date} ;;
  }
}

explore: cost_of_service_oem {
  from: oem_assets_vendor_scorecard
  case_sensitive: no

  join: asset_month_maintenance_cost {
    type: inner
    relationship: one_to_many
    sql_on: ${cost_of_service_oem.asset_id} = ${asset_month_maintenance_cost.asset_id} ;;
  }
}

explore: category_growth {

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${category_growth.asset_id} ;;
  }
}
