view: company_owned_assets_and_groups {
  derived_table: {
    sql: select
          a.asset_id,
          o.name as groups
      from
          assets a
          left join organization_asset_xref oax on oax.asset_id = a.asset_id
          left join organizations o on o.organization_id = oax.organization_id
      where
          --a.company_id = 50
          --and o.company_id = '50'::integer
          a.company_id = {{ _user_attributes['company_id'] }}::numeric
          and o.company_id = {{ _user_attributes['company_id'] }}::numeric::integer
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

  dimension: groups {
    type: string
    sql: ${TABLE}."GROUPS" ;;
  }

  set: detail {
    fields: [asset_id, groups]
  }
}
