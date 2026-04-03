view: organization_asset_xref {
  sql_table_name: "PUBLIC"."ORGANIZATION_ASSET_XREF"
    ;;
  drill_fields: [organization_asset_xref_id]

  dimension: organization_asset_xref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORGANIZATION_ASSET_XREF_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [organization_asset_xref_id, assets.custom_name, assets.asset_id, assets.name, assets.driver_name]
    hidden: yes
  }
}
