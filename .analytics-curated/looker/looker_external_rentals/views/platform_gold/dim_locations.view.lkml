view: dim_locations {
  sql_table_name: "PLATFORM"."GOLD"."V_LOCATIONS" ;;
  drill_fields: [location_key]

  dimension: location_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."LOCATION_KEY" ;;
    description: "Primary key for dim_locations"
  }

  dimension: location_source {
    type: string
    sql: ${TABLE}."LOCATION_SOURCE" ;;
    description: "Source system for location data"
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
    description: "Natural key for location"
  }

  dimension: location_user_key {
    type: string
    sql: ${TABLE}."LOCATION_USER_KEY" ;;
    description: "Foreign key to dim_users"
  }

  dimension: location_nickname {
    type: string
    sql: ${TABLE}."LOCATION_NICKNAME" ;;
    description: "Location nickname"
  }

  dimension: location_street_1 {
    type: string
    sql: ${TABLE}."LOCATION_STREET_1" ;;
    description: "Location street address line 1"
  }

  dimension: location_street_2 {
    type: string
    sql: ${TABLE}."LOCATION_STREET_2" ;;
    description: "Location street address line 2"
  }

  dimension: location_city {
    type: string
    sql: ${TABLE}."LOCATION_CITY" ;;
    description: "Location city"
  }

  dimension: location_state_key {
    type: string
    sql: ${TABLE}."LOCATION_STATE_KEY" ;;
    description: "Foreign key to dim_states"
  }

  dimension: location_latitude {
    type: number
    sql: ${TABLE}."LOCATION_LATITUDE" ;;
    description: "Location latitude coordinate"
  }

  dimension: location_longitude {
    type: number
    sql: ${TABLE}."LOCATION_LONGITUDE" ;;
    description: "Location longitude coordinate"
  }

  dimension: location_needs_review {
    type: yesno
    sql: ${TABLE}."LOCATION_NEEDS_REVIEW" ;;
    description: "Flag indicating if location needs review"
  }

  dimension: location_jobsite {
    type: yesno
    sql: ${TABLE}."LOCATION_JOBSITE" ;;
    description: "Flag indicating if location is a jobsite"
  }

  dimension: location_description {
    type: string
    sql: ${TABLE}."LOCATION_DESCRIPTION" ;;
    description: "Location description"
  }

  dimension: location_company_key {
    type: string
    sql: ${TABLE}."LOCATION_COMPANY_KEY" ;;
    description: "Foreign key to dim_companies"
  }

  dimension: location_zip_code {
    type: string
    sql: ${TABLE}."LOCATION_ZIP_CODE" ;;
    description: "Location zip code"
  }

  dimension: location_zip_code_extended {
    type: string
    sql: ${TABLE}."LOCATION_ZIP_CODE_EXTENDED" ;;
    description: "Location extended zip code"
  }

  dimension_group: location_recordtimestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LOCATION_RECORDTIMESTAMP" ;;
    description: "Timestamp when location record was created"
  }

  # Computed dimensions for address formatting
  dimension: location_full_address {
    type: string
    sql: CONCAT(
      COALESCE(${location_street_1}, ''),
      CASE WHEN ${location_street_2} IS NOT NULL AND ${location_street_2} != ''
           THEN CONCAT(', ', ${location_street_2})
           ELSE '' END,
      CASE WHEN ${location_city} IS NOT NULL AND ${location_city} != ''
           THEN CONCAT(', ', ${location_city})
           ELSE '' END,
      CASE WHEN ${location_zip_code} IS NOT NULL AND ${location_zip_code} != ''
           THEN CONCAT(' ', ${location_zip_code})
           ELSE '' END
    ) ;;
    description: "Formatted full address"
  }

  dimension: location_short_address {
    type: string
    sql: CONCAT(
      COALESCE(${location_city}, ''),
      CASE WHEN ${location_zip_code} IS NOT NULL AND ${location_zip_code} != ''
           THEN CONCAT(' ', ${location_zip_code})
           ELSE '' END
    ) ;;
    description: "Short address (city, zip)"
  }
}
