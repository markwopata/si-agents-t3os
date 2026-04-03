connection: "es_snowflake_analytics"

include: "/Dashboards/Asset_Hours_Overage/Views/*.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/categories.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"



explore: asset_hours_overage {
  from: asset_hours_overage_current
  label: "Current Assets with Overage Hours"
  fields: [asset_hours_overage*,
    companies*,
    salesperson*,
    market_region_xwalk*,
    order_salespersons*,
    assets_aggregate.category,
    assets_aggregate.make,
    assets_aggregate.model,
    assets_aggregate.make_model]
  sql_always_where: 'collectors' = {{ _user_attributes['department'] }} OR
                    'developer' = {{ _user_attributes['department'] }} OR
                    'god view' = {{ _user_attributes['department'] }} OR
                    'fleet' = {{ _user_attributes['department'] }} OR
                    'leadership' = {{ _user_attributes['job_role'] }} OR
                    ('salesperson' = {{ _user_attributes['department'] }} AND ${salesperson.deleted} = 'No' AND ${salesperson.email_address} =  '{{ _user_attributes['email'] }}' ) OR
                    ${market_region_xwalk.District_Region_Market_Access} ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hours_overage.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate  {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hours_overage.rental_asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hours_overage.order_id} = ${orders.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${users.user_id} ;;
  }

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: salesperson {
    from:  users
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_salespersons.user_id} = ${salesperson.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.company_id} = ${companies.company_id} ;;
  }
}
