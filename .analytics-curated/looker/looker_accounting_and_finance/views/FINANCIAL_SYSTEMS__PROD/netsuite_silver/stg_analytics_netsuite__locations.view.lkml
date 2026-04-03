view: stg_analytics_netsuite__locations {
  # Note: Update the sql_table_name with your actual schema and table name
  sql_table_name: "NETSUITE_SILVER"."STG_ANALYTICS_NETSUITE__LOCATIONS" ;;


  dimension: fk_t3_store_id {
    type: string
    description: "Foreign key to T3 store id in Netsuite"
    sql: ${TABLE}."FK_T3_STORE_ID" ;;
  }

  dimension: is_inactive_location {
    type: string
    description: "Indicates whether the location is inactive in Netsuite"
    sql: ${TABLE}."IS_INACTIVE_LOCATION" ;;
  }

  dimension: location_main_address {
    type: number
    description: "Main address of the location in Netsuite"
    sql: ${TABLE}."LOCATION_MAIN_ADDRESS" ;;
  }

  dimension: location_return_address {
    type: number
    description: "Return address of the location in Netsuite"
    sql: ${TABLE}."LOCATION_RETURN_ADDRESS" ;;
  }

  dimension: name_full_location {
    type: string
    description: "Full name of the location in Netsuite"
    sql: ${TABLE}."NAME_FULL_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    description: "Name of the location in Netsuite"
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: pk_location_id {
    type: number
    primary_key: yes
    description: "Netsuite location id (primary key), unique identifier for each location record"
    sql: ${TABLE}."PK_LOCATION_ID" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    description: "UTC timestamp the record was modified in system"
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension: type_location {
    type: number
    description: "Type of the location in Netsuite"
    sql: ${TABLE}."TYPE_LOCATION" ;;
  }

  measure: count {
    type: count
    drill_fields: [pk_location_id, name_location, name_full_location]
  }
}
