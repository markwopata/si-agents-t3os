connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: concor_pl_bs {
  view_name: concor_pl_bs
  label: "Concor P&L and BS"

  sql_always_where: 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${concor_pl_bs.gl_date}::date = ${plexi_periods.date}::date ;;
  }
}

explore: auto_claims_count_and_charges {
  from: auto_claims_count_and_charges
  case_sensitive: no

  join: plexi_periods_to_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${auto_claims_count_and_charges.date_month} = ${plexi_periods_to_date.date} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${auto_claims_count_and_charges.market_id} = ${market_region_xwalk.market_id};;
  }
}
