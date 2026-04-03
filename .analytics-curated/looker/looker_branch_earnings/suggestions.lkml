# More simple models to use for suggestions. This should make filtering for some fields faster. This is a generic lkml file that needs to be included in every model file that's going to use it.

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/account_suggestions_be_snap.view.lkml"

explore: market_region_xwalk_suggestion {
  view_name: market_region_xwalk
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;
}

explore: account_suggestions_be_snap {}
