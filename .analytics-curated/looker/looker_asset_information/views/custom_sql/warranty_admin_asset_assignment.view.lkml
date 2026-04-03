view: warranty_admin_asset_assignments { #For lookup tool filter.
  derived_table: {
      sql:
      select aa.asset_id
    , coalesce(waa.warranty_admin, 'Jennifer Bradstreet') as warranty_admin
    , coalesce(waa.user_id, '210771') as user_id
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
left join (
        select make
            , warranty_admin
            , user_id
        from ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS
        where current_flag = 1) waa
    on waa.make = aa.make ;;
    }

    dimension: warranty_admin {
      type: string
      sql: ${TABLE}.warranty_admin ;;
    }

    dimension: user_id { #Has to be a string because of Dealer only OEMs
      type: string
      sql: ${TABLE}.user_id ;;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.asset_id ;;
    }
}
