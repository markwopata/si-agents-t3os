view: work_codes {
 derived_table: {
  sql: select WORK_CODE_ID, CUSTOM_ID, ORGANIZATION_ID, NAME as WORK_CODE_TYPE, NAME, DESCRIPTION, CREATED_BY_USER_ID, CREATED_DATE, DELETED, _ES_UPDATE_TIMESTAMP from
    ES_WAREHOUSE.time_tracking.work_codes wc
    where deleted = false;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: work_code_id {
  type: number
  sql: ${TABLE}."WORK_CODE_ID" ;;
}

dimension: custom_id {
  type: string
  sql: ${TABLE}."CUSTOM_ID" ;;
}

dimension: organization_id {
  type: number
  sql: ${TABLE}."ORGANIZATION_ID" ;;
}

dimension: work_code_type {
  type: string
  sql: ${TABLE}."WORK_CODE_TYPE" ;;
}

dimension: name {
  type: string
  sql: ${TABLE}."NAME" ;;
}

dimension: description {
  type: string
  sql: ${TABLE}."DESCRIPTION" ;;
}

dimension: created_by_user_id {
  type: number
  sql: ${TABLE}."CREATED_BY_USER_ID" ;;
}

dimension_group: created_date {
  type: time
  sql: ${TABLE}."CREATED_DATE" ;;
}

dimension: deleted {
  type: yesno
  sql: ${TABLE}."DELETED" ;;
}

dimension_group: _es_update_timestamp {
  type: time
  sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
}

  filter: work_code_filter {
    type: string
  }

set: detail {
  fields: [
    work_code_id,
    custom_id,
    organization_id,
    work_code_type,
    name,
    description,
    created_by_user_id,
    created_date_time,
    deleted,
    _es_update_timestamp_time
  ]
}
}
