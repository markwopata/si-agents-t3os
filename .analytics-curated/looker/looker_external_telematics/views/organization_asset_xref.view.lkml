view: organization_asset_xref {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORGANIZATION_ASSET_XREF" ;;
  drill_fields: [organization_asset_xref_id]

  dimension: organization_asset_xref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORGANIZATION_ASSET_XREF_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: organization_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [organization_asset_xref_id, organizations.name, organizations.organization_id]
  }
}
