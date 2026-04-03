view: t3_role_spending_limits {
  derived_table: {
    sql: SELECT *

      FROM "ES_WAREHOUSE"."INVENTORY"."ROLES"

      WHERE SPENDING_LIMIT IS NOT NULL

      AND COMPANY_ID = 1854
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: role_id {
    type: number
    sql: ${TABLE}."ROLE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: spending_limit {
    type: number
    sql: ${TABLE}."SPENDING_LIMIT" ;;
  }

  set: detail {
    fields: [
      date_created_time,
      date_updated_time,
      role_id,
      name,
      company_id,
      date_archived_time,
      _es_update_timestamp_time,
      spending_limit
    ]
  }
}
