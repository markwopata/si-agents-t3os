view: fleet_qbr_market_locations {
  derived_table: {
    sql:
        Select
        monday_market_id,
        street_address,
        city,
        state,
        zip_code,
        latitude,
        longitude
        from data_science_stage.fleet_testing.market_locations
          ;;
  }

  dimension: monday_market_id {
    type: number
    primary_key: yes
    hidden: yes
    description: "Monday.com ID field, one id/name per row"
    sql:  ${TABLE}."MONDAY_MARKET_ID" ;;
  }

  dimension: street_address {
    type:  string
    description: "cleansed street address for location"
    sql:${TABLE}."STREET_ADDRESS";;
  }

  dimension: city {
    type:  string
    description: "cleansed city for location (either from monday.com address or name)"
    sql:${TABLE}."CITY";;
  }

  dimension: state {
    type:  string
    description: "cleansed state for location (either from monday.com address or name"
    sql:${TABLE}."STATE";;
  }

  dimension: zip_code {
    type:  zipcode
    description: "cleansed zip code for location"
    sql:${TABLE}."ZIP CODE";;
  }

  dimension: geolocation {
    type:  location
    sql_latitude: ${TABLE}."LATITUDE" ;;
    sql_longitude: ${TABLE}."LONGITUDE" ;;
  }
}
