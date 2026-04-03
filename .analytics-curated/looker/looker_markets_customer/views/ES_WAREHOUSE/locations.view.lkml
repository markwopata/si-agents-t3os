view: locations {
  derived_table: {
    sql:

SELECT l.*
     , s.name         AS state_name
     , s.abbreviation AS state
  FROM es_warehouse.public.locations l
       JOIN es_warehouse.public.states s
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state_name {
    type: string
    sql: ${TABLE}."STATE_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
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
    # hidden: yes
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

   dimension: company_address {
    type: string
    sql: concat(${street_1},' ',${street_2}, ', ',${city}, ', ',${state} , ' ',${zip_code})  ;;
  }

  dimension: company_address_alt {
    type: string
    sql: coalesce((locations."STREET_1"), '') || coalesce((locations."STREET_2"), '') || ', ' || coalesce((locations."CITY"), '') || ', ' || coalesce((${state}), '') || ' ' || LPAD(coalesce((locations."ZIP_CODE"), 0), 5, 0);;
  }

  dimension: company_address_pretty {
    type: string
    sql: CASE WHEN locations."STREET_1" IS NULL THEN 'No address on file' ELSE coalesce((locations."STREET_1"), '') || coalesce((locations."STREET_2"), '') || ', ' || coalesce((locations."CITY"), '') || ', ' || coalesce((${state}), '') || ' ' || LPAD(coalesce((locations."ZIP_CODE"), 0), 5, 0) END;;
  }

  dimension: company_city_state {
    type: string
    sql: concat(${city}, ', ',${state}) ;;
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
      users.first_name,
      users.username,
      users.company_name,
      users.middle_name,
      users.user_id,
      users.last_name,
      states.state_id,
      states.name,
      orders.count,
      users.count
    ]
  }
}
