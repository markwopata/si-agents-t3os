view: comp_geocode_miles {
  derived_table: {
    sql:  SELECT COMPETITOR AS COMPETITOR, STREET AS STREET, CITY AS CITY, STATE AS STATE, ZIP AS ZIP, LATITUDE AS LATITUDE, LONGITUDE AS LONGITUDE
    , HAVERSINE({% parameter latitude_filter %}, {% parameter longitude_filter %}, LATITUDE, LONGITUDE)/1.60934 AS MILES
FROM ANALYTICS.PUBLIC.COMP_GEOCODE
                               ;;
  }

  filter: latitude_filter { type: string }
  filter: longitude_filter { type: string }


  dimension: competitor {
    type: string
    sql: ${TABLE}."COMPETITOR" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }


  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: miles {
    type: number
    sql: ${TABLE}."MILES" ;;
  }

  measure: comp_count {
    type: count_distinct
    sql: ${miles} ;;
  }

  dimension: show_route_in_google_maps {
    label: "View Path"
    type: string
    sql: ${latitude} ;;
    html: <font color="blue"><u><a href="https://www.google.com/maps/dir/{{ latitude_filter._value }},{{ longitude_filter._value }}/{{ latitude._value }},+{{ longitude._value }}/@39.2284628,-92.7933467,11z/data=!3m1!4b1!4m7!4m6!1m0!1m3!2m2!1d{{ longitude._value }}!2d{{ latitude._value }}!3e0" target="_blank">View Trip in Google Maps</a></font?</u> ;;
  }

  }
