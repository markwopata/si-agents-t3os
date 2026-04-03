connection: "es_snowflake_analytics"

include: "/views/custom_sql/combined_asset_thirty_day_counts.view.lkml"
include: "/views/custom_sql/thirty_day_counts_asset_filter.view.lkml"

include: "/views/custom_sql/thirty_day_reservations_detail.view.lkml"
include: "/views/custom_sql/thirty_day_reservations_asset_id.view.lkml"
include: "/views/custom_sql/thirty_day_reservations_no_asset_id.view.lkml"

#include: "/Dashboards/30_Day_Asset_Reservations_&_Utilization.dashboard.lookml"



explore: combined_asset_thirty_day_counts {
  label: "Combined Asset Counts & 30-Day Reservation Metrics"
  description: "One row per (subcategory, class, region, district, market) with on-rent counts, total counts, 30-day counts, and unit utilization"
  # persist_for: "1 minute"

  # join: thirty_day_counts_asset_filter {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on:
  #     ${combined_asset_thirty_day_counts.parent_category} = ${thirty_day_counts_asset_filter.parent_category}
  #     AND ${combined_asset_thirty_day_counts.subcategory}       = ${thirty_day_counts_asset_filter.subcategory}
  #     AND ${combined_asset_thirty_day_counts.class}       = ${thirty_day_counts_asset_filter.class}
  #     AND ${combined_asset_thirty_day_counts.class_clean} = ${thirty_day_counts_asset_filter.class_clean}
  #     AND ${combined_asset_thirty_day_counts.region_name} = ${thirty_day_counts_asset_filter.region_name}
  #     AND ${combined_asset_thirty_day_counts.district}    = ${thirty_day_counts_asset_filter.district}
  #     AND ${combined_asset_thirty_day_counts.market_name} = ${thirty_day_counts_asset_filter.market_name}
  #   ;;
  # }


  join: thirty_day_reservations_detail {
    type: inner
    relationship: one_to_many

    sql_on:
    ${combined_asset_thirty_day_counts.parent_category} = ${thirty_day_reservations_detail.parent_category}
      AND ${combined_asset_thirty_day_counts.subcategory} = ${thirty_day_reservations_detail.subcategory}
      AND ${combined_asset_thirty_day_counts.class}       = ${thirty_day_reservations_detail.class}
      AND ${combined_asset_thirty_day_counts.class_clean} = ${thirty_day_reservations_detail.class_clean}
      AND ${combined_asset_thirty_day_counts.region_name} = ${thirty_day_reservations_detail.region_name}
      AND ${combined_asset_thirty_day_counts.district}    = ${thirty_day_reservations_detail.district}
      AND ${combined_asset_thirty_day_counts.market_name} = ${thirty_day_reservations_detail.market_name}


    ;;
  }

  join: thirty_day_reservations_asset_id {
    type: inner
    relationship: one_to_many

    sql_on:
      ${combined_asset_thirty_day_counts.class}       = ${thirty_day_reservations_asset_id.class}
      AND ${combined_asset_thirty_day_counts.class_clean} = ${thirty_day_reservations_asset_id.class_clean}
      AND ${combined_asset_thirty_day_counts.region_name} = ${thirty_day_reservations_asset_id.region_name}
      AND ${combined_asset_thirty_day_counts.district}    = ${thirty_day_reservations_asset_id.district}
      AND ${combined_asset_thirty_day_counts.market_name} = ${thirty_day_reservations_asset_id.market_name}
    ;;
  }
  join: thirty_day_reservations_no_asset_id {
    type: inner
    relationship: one_to_many

    sql_on:
      ${combined_asset_thirty_day_counts.class}       = ${thirty_day_reservations_no_asset_id.class}
      AND ${combined_asset_thirty_day_counts.class_clean} = ${thirty_day_reservations_no_asset_id.class_clean}
      AND ${combined_asset_thirty_day_counts.region_name} = ${thirty_day_reservations_no_asset_id.region_name}
      AND ${combined_asset_thirty_day_counts.district}    = ${thirty_day_reservations_no_asset_id.district}
      AND ${combined_asset_thirty_day_counts.market_name} = ${thirty_day_reservations_no_asset_id.market_name}
    ;;
  }

}

# explore: combined_asset_thirty_day_counts {
#   label: "Combined Asset Counts & 30-Day Reservation Metrics"
#   description: "One row per (subcategory, class, region, district, market) with on-rent counts, total counts, 30-day counts, and unit utilization"
#   persist_for: "1 minute"


#   join: thirty_day_reservations_detail {
#     type: inner
#     relationship: one_to_many

#     sql_on:
#       ${combined_asset_thirty_day_counts.class}       = ${thirty_day_reservations_detail.class}
#       AND ${combined_asset_thirty_day_counts.region_name} = ${thirty_day_reservations_detail.region_name}
#       AND ${combined_asset_thirty_day_counts.district}    = ${thirty_day_reservations_detail.district}
#       AND ${combined_asset_thirty_day_counts.market_name} = ${thirty_day_reservations_detail.market_name}
#     ;;
#   }
# }
