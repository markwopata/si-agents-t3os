connection: "es_snowflake"

#include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
#include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
include: "/Dashboards/Fleet_QBR/views/*.view.lkml"

# for use with the Fleet Quarterly Business Review Dashboard
explore: fleet_qbr_asset_purchasing {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "Asset Purchasing for Fleet QBR"
  description: "Use this explore to tell the high-level story of fleet purchasing"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]

  join: fleet_qbr_purchasing_goals {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_qbr_asset_purchasing.equipment_class_id} = ${fleet_qbr_purchasing_goals.equipment_class_id} ;;
  }

  join: ideal_core_mix {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_qbr_asset_purchasing.equipment_class_id} = ${ideal_core_mix.equipment_class_id} ;;
  }
  }

explore: fleet_qbr_purchasing_by_vendor {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "By-Vendor Asset Purchasing for Fleet QBR"
  description: "Aggregated vendor-only view of fleet purchasing"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]
}

explore: fleet_qbr_purchasing_by_category {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "By-Category Asset Purchasing for Fleet QBR"
  description: "Aggregated category-only view of fleet purchasing"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]
}

  explore: fleet_qbr_markets_monday {
    case_sensitive: no
    group_label: "Fleet QBR"
    label: "Monday.com Markets Data for Fleet QBR"
    description: "View of Monday.com data regarding potential market real estate/acquisitions in progress"
    persist_for: "24 hours"
    fields: [ALL_FIELDS*
    ]

    join: fleet_qbr_market_locations {
      type:  left_outer
      relationship: one_to_one
      sql_on: ${fleet_qbr_markets_monday.monday_market_id} = ${fleet_qbr_market_locations.monday_market_id} ;;
    }


  }

explore: fleet_qbr_historical_utilization {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "Historical Utilization for Fleet QBR"
  description: "Asset-level view of utilization inputs in discrete time blocks"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]
}

explore: fleet_qbr_ideal_make_for_class {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "Fleet QBR Ideal Make Analysis"
  description: "Use this explore to analyze purchasing in correspondence with ideal make"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]
}

explore: fleet_qbr_oec_market_density {
  case_sensitive: no
  group_label: "Fleet QBR"
  label: "OEC Density Analysis for Fleet QBR"
  description: "Use this explore to analyze OEC density of current markets"
  persist_for: "24 hours"
  fields: [ALL_FIELDS*
  ]
}
