view: organizations {
  derived_table: {
    sql: select
    a.asset_id,
    o._es_update_timestamp,
    o.organization_id,
    a.company_id,
    coalesce(o.name,'No Group') as name
    from assets a
    left join organization_asset_xref oax on a.asset_id = oax.asset_id
    left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
    where o.company_id = {{ _user_attributes['company_id'] }}::numeric
    ;;
    }


  drill_fields: [organization_id]

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: groups {
    type: string
    sql: coalesce(${name}, 'Ungrouped Assets')  ;;
  }

  measure: asset_groups {
    type: list
    list_field: groups
  }

  measure: count {
    type: count
    drill_fields: [organization_id, name]
  }
}
