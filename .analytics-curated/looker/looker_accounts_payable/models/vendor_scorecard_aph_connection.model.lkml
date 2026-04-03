connection: "es_snowflake"

# include views here
include: "/views/custom_sql/t3_purchase_order_details.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"


# explores go here
#explore: accounts_payable_vendor_activity {}

# explore: vendor {}

# explore: vendor_activity_summary { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
# }


explore: t3_purchase_order_details {
  label: "Purchase Order Details with Asset Info"

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${t3_purchase_order_details.po_number} = ${asset_purchase_history.po_number} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets_aggregate.asset_id} ;;
  }

}
