view: maintenance_groups {
  derived_table: {
    sql: select * from ES_WAREHOUSE.PUBLIC.MAINTENANCE_GROUPS
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: archived_date {
    type: time
    sql: ${TABLE}."ARCHIVED_DATE" ;;
  }

  set: detail {
    fields: [
      maintenance_group_id,
      name,
      date_created_time,
      date_updated_time,
      description,
      company_id,
      _es_update_timestamp_time,
      archived_date_time
    ]
  }
}
