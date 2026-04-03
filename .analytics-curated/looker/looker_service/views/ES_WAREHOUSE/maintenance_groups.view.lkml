view: maintenance_groups {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."MAINTENANCE_GROUPS" ;;
  drill_fields: [maintenance_group_id]

  dimension: maintenance_group_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [maintenance_group_id, name, maintenance_group_intervals.count]
  }
  measure: count_created {
    type: count_distinct
    sql: ${maintenance_group_id} ;;
    drill_fields: [companies.name,count_created_company]
  }
  measure: count_created_company {
    type: count_distinct
    sql: ${maintenance_group_id} ;;
    drill_fields: [name,description,date_created_date]
  }
}
