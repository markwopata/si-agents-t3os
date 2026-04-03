view: certification {
  sql_table_name: "PEOPLE_ANALYTICS"."DOCEBO"."CERTIFICATION" ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: awarded_from_id {
    type: number
    sql: ${TABLE}."AWARDED_FROM_ID" ;;
  }
  dimension: awarded_from_type {
    type: string
    sql: ${TABLE}."AWARDED_FROM_TYPE" ;;
  }
  dimension: certification_code {
    type: string
    sql: ${TABLE}."CERTIFICATION_CODE" ;;
  }
  dimension: certification_id {
    type: number
    sql: ${TABLE}."CERTIFICATION_ID" ;;
  }
  dimension: certification_name {
    type: string
    sql: ${TABLE}."CERTIFICATION_NAME" ;;
  }
  dimension: created_at {
    type: date_raw
    sql: ${TABLE}."CREATED_AT" ;;
    hidden:  yes
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension: expiring_at {
    type: date_raw
    sql: ${TABLE}."EXPIRING_AT" ;;
    hidden:  yes
  }
  dimension: issued_at {
    type: date_raw
    sql: ${TABLE}."ISSUED_AT" ;;
    hidden:  yes
  }
  dimension: renewable_from {
    type: string
    sql: ${TABLE}."RENEWABLE_FROM" ;;
  }
  dimension: renewal_resource {
    type: string
    sql: ${TABLE}."RENEWAL_RESOURCE" ;;
  }
  dimension: renewal_started {
    type: yesno
    sql: ${TABLE}."RENEWAL_STARTED" ;;
  }
  dimension: updated_at {
    type: date_raw
    sql: ${TABLE}."UPDATED_AT" ;;
    hidden:  yes
  }
  dimension: updated_by_id {
    type: number
    sql: ${TABLE}."UPDATED_BY_ID" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [id, certification_name]
  }
}
