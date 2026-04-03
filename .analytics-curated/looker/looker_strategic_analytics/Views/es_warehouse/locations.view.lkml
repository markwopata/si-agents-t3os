view: locations {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" ;;

  dimension: location_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: state_id {
    type: string
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: location_type_id {
    type: string
    sql: ${TABLE}."LOCATION_TYPE_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: universal_entity_id {
    type: string
    sql: ${TABLE}."UNIVERSAL_ENTITY_ID" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: street_1 {
    type: string
    sql: ${TABLE}."STREET_1" ;;
  }

  dimension: street_2 {
    type: string
    sql: ${TABLE}."STREET_2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: zip_code_extended {
    type: string
    sql: ${TABLE}."ZIP_CODE_EXTENDED" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: location_geo {
    type: string
    sql: ${TABLE}."LOCATION_GEO" ;;
    hidden: yes
  }

  dimension: needs_review {
    type: yesno
    sql: ${TABLE}."NEEDS_REVIEW" ;;
  }

  dimension: jobsite {
    type: yesno
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail_drill {
    fields: [location_id, nickname, city, street_1, state_id, zip_code, latitude, longitude]
  }

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }
}
