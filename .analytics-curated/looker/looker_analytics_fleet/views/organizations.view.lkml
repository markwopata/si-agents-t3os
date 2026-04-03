view: organizations {
  sql_table_name: "PUBLIC"."ORGANIZATIONS"
    ;;
  drill_fields: [organization_id]

  dimension: organization_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    hidden: yes
  }

  dimension: groups {
    type: string
    sql: coalesce(${name}, 'Ungrouped Assets')  ;;
    hidden: yes
  }

  measure: asset_groups {
    type: list
    list_field: groups
    view_label: "Groups"
  }

  measure: count {
    type: count
    drill_fields: [organization_id, name]
    view_label: "Groups"
  }
}
