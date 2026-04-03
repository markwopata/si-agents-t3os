connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: lease_accelerator_ledger_export {
  label: "lease_accelerator_ledger_export"
}

explore: lease_accelerator_roll_forward {
  label: "lease_accelerator_roll_forward"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'roman.garcia@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'taylor.burnett@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'shannon.clark@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'ethan.glick@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'payton.staggs@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'tory.hicks@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'emily.nolting@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mollie.goodwin@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${lease_accelerator_roll_forward.market_id} = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: lease_accelerator_bu_asset {
  label: "lease_accelerator_bu_asset"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'roman.garcia@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'taylor.burnett@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'shannon.clark@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'ethan.glick@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'payton.staggs@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'tory.hicks@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'emily.nolting@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mollie.goodwin@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${lease_accelerator_bu_asset.market_id} = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: lease_accelerator_cost_center_mapping {
  label: "lease_accelerator_cost_center_mapping"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'roman.garcia@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'taylor.burnett@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'shannon.clark@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'ethan.glick@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'payton.staggs@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'tory.hicks@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'emily.nolting@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mollie.goodwin@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'trilce.maddle@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${lease_accelerator_cost_center_mapping.market_id} = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: lease_accelerator_leasing_summary {
  label: "lease_accelerator_leasing_summary"
  sql_always_where:
    'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'roman.garcia@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'taylor.burnett@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'shannon.clark@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'ethan.glick@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'payton.staggs@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'tory.hicks@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'emily.nolting@equipmentshare.com'
    or trim('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mollie.goodwin@equipmentshare.com';;
}
