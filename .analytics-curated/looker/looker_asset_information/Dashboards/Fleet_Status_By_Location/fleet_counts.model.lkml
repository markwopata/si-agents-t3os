connection: "es_snowflake"

# include: "/views/ANALYTICS/asset_physical.view.lkml"
# include: "/views/ANALYTICS/asset_rental.view.lkml"
# include: "/views/ES_WAREHOUSE/markets.view.lkml"
# include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
# include: "/Dashboards/Fleet_Status_By_Location/views/fleet_status_by_location.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"


#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: fleet_status {
#   view_label: "Asset - Physical info"
#   from: asset_physical
#   cancel_grouping_fields: [fleet_status.asset_id]

#   # Dictated by Andrew Lowe, May 2023. -Jack G
#   # sql_always_where:
#   # ${asset_type} <> 'vehicle'
#   # and not ${is_rerent}
#   # and not ${is_floor_plan}
#   # and (${is_public_rsp} OR ${company_id} = 1854)
#   # -- removing 420 and 155. This was not dictated to me. -Jack G 2023-06-16
#   # and ${company_id} not in (420, 155)
#   # --asset_information/Dashboards/Fleet_Status_By_Location/fleet_counts
#   # ;;

#   sql_always_where:
#   (${asset_type} <> 'vehicle' or ${asset_type} is null)
#   and (not ${is_rerent} or ${is_rerent} is null)
#   and (not ${is_floor_plan} or ${is_floor_plan} is null)
#   and (${is_public_rsp} OR ${company_id} = 1854)
#   and (${company_id} not in (420, 155) or ${company_id} is null)
#   ;;


#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${fleet_status.rental_branch_id} = ${market_region_xwalk.market_id};;
#   }
# }
