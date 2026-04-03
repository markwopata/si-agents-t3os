view: locations {
  sql_table_name: "PUBLIC"."LOCATIONS"
    ;;
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: zip_code_extended {
    type: number
    sql: ${TABLE}."ZIP_CODE_EXTENDED" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      location_id,
      nickname,
      users.company_name,
      users.first_name,
      users.username,
      users.last_name,
      users.user_id,
      users.middle_name,
      markets.count,
      orders.count,
      users.count
    ]
  }
}
