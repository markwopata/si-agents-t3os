view: locations {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LOCATIONS";;
  drill_fields: [location_id]

  dimension: location_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
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

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
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
    label: "Jobsite"
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: state_abb {
    type: string
    sql: ${TABLE}."STATE_ABB" ;;
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
    label: "Jobsite Address"
    sql: concat(${street_1},', ',${city}, ', ', ${states.abbreviation} , ' ',${zip_code})  ;;
  }

  dimension: jobsite_link {
    type: string
    sql: ${company_address} ;;

    link: {
      label: "View Google Maps"
      url: "https://www.google.com/maps/place/{{ value | url_encode }}"
    }
  }

dimension: delivery_location {
  type: string
  sql: COALESCE (${nickname},'No Rental Location') ;;
}

  measure: count {
    type: count
    drill_fields: [location_id, nickname, states.name, states.state_id, deliveries.count]
  }
}
