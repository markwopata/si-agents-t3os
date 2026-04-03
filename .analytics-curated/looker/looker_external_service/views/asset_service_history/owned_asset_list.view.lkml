view: owned_asset_list {
  derived_table: {
    sql: select oa.asset_id, a.custom_name as asset
      from
      table(assetlist({{ _user_attributes['user_id'] }}::numeric)) oa
      join assets a on oa.asset_id = a.asset_id
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

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  set: detail {
    fields: [asset_id, asset]
  }
}
