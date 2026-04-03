view: locations {
  derived_table: {
    sql:

SELECT l.*,
       s.abbreviation as state
  FROM es_warehouse.public.locations l
       INNER JOIN es_warehouse.public.states s
                  ON l.state_id = s.state_id
;;
  }
  drill_fields: [location_id]

  dimension: location_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: jobsite {
    type: yesno
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: location_geo {
    type: string
    sql: ${TABLE}."LOCATION_GEO" ;;
  }

  dimension: location_type_id {
    type: number
    sql: ${TABLE}."LOCATION_TYPE_ID" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: needs_review {
    type: yesno
    sql: ${TABLE}."NEEDS_REVIEW" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: street_1 {
    type: string
    sql: ${TABLE}."STREET_1" ;;
  }

  dimension: street_2 {
    type: string
    sql: ${TABLE}."STREET_2" ;;
  }

  dimension: address {
    type: string
    sql: CONCAT(${street_1}, ', ', ${city}, ', ', ${state}, ' ', ${zip_code}) ;;
  }

  dimension: universal_entity_id {
    type: number
    sql: ${TABLE}."UNIVERSAL_ENTITY_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: LPAD(${TABLE}."ZIP_CODE", 5, '0') ;;
  }

  dimension: zip_code_extended {
    type: number
    sql: ${TABLE}."ZIP_CODE_EXTENDED" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [location_id, nickname, markets.count]
  }
}
