connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: new_dealership_sales {
  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_dealership_sales.market_id}::text = ${parent_market.market_id}::text
      and date_trunc(month, ${new_dealership_sales.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${new_dealership_sales.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${new_dealership_sales.market_id}) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${new_dealership_sales.display_month} = ${plexi_periods.display};;
  }
}

explore: retail_sales_asset_detail {
  label: "Retail Sales Asset Detail"

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = ${retail_sales_asset_detail.quote_date_filter};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.parent_market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: retail_sales_quote_detail {
  label: "Retail Sales Quote Detail"

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = ${retail_sales_quote_detail.quote_date_filter};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_quote_detail.parent_market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: sales_cogs_margin {
  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }};;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_cogs_margin.MARKET_ID}::text = ${parent_market.market_id}::text
              and date_trunc(month, ${sales_cogs_margin.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
                and date_trunc(month, ${sales_cogs_margin.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date),'2099-12-31')
              ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${sales_cogs_margin.MARKET_ID}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc(month,${sales_cogs_margin.gl_date}::date) = ${plexi_periods.date}::date;;
  }
}
