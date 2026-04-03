connection: "es_snowflake_analytics"

include: "/Views/analytics/int_revenue.view.lkml"
include: "/Views/analytics/int_assets.view.lkml"
include: "/Views/es_warehouse/companies.view.lkml"
include: "/Views/business_intelligence/v_dim_dates_bi.view.lkml"


explore: int_revenue {
  label: "Rental Revenue Example"
  case_sensitive: no
  persist_for: "8 hours"
  description: "Test explore pulling all rental revenue related invoice/credit information from the last 90 days"
  sql_always_where: ${int_revenue.is_rental_revenue} and ${v_dim_dates_bi.is_last_90_days};;

  join: int_assets {
    view_label: "Asset Information"
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_revenue.asset_id} = ${int_assets.asset_id} ;;
  }

  join: v_dim_dates_bi {
    view_label: "GL Date Information"
    type: inner
    relationship: many_to_one
    sql_on: ${v_dim_dates_bi.date} = ${int_revenue.gl_date_date} ;;
  }



}
