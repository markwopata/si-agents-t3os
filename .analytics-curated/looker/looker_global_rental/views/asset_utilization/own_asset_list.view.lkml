view: own_asset_list {
  derived_table: {
    sql: select
              alo.asset_id,
              a.asset_class,
              a.custom_name,
              cat.name as category,
              m.name as branch,
              concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
          from
            --table(assetlist(101457::numeric)) alo
            table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
            join assets a on a.asset_id = alo.asset_id
            left join asset_types ast on ast.asset_type_id = a.asset_type_id
            left join categories cat on cat.category_id = a.category_id
            left join markets m on m.market_id = a.inventory_branch_id
          UNION
          select
              a.asset_id,
              a.asset_class,
              a.custom_name,
              cat.name as category,
              m.name as branch,
              concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
          from
             assets a
             join assets_aggregate aa on a.asset_id = aa.asset_id
             left join asset_types ast on ast.asset_type_id = a.asset_type_id
             left join categories cat on cat.category_id = a.category_id
             join markets m on m.market_id = a.rental_branch_id AND m.company_id = {{ _user_attributes['company_id'] }}
          where
            a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND a.deleted = FALSE
            AND m.company_id = {{ _user_attributes['company_id'] }}
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  set: detail {
    fields: [
      asset_id,
      asset_class,
      custom_name,
      category,
      branch,
      asset_type
    ]
  }
}
