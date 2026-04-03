view: organizations {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORGANIZATIONS" ;;
  drill_fields: [organization_id]

  dimension: organization_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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

  measure: count {
    type: count
    drill_fields: [organization_id, name, organization_asset_xref.count]
  }
}
