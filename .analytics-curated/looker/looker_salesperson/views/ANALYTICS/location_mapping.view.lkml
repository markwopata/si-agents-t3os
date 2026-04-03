view: location_mapping {
  sql_table_name: "PAYROLL"."LOCATION_MAPPING"
    ;;

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: loc_id {
    type: string
    sql: ${TABLE}."LOC_ID" ;;
  }

  dimension: loc_name {
    type: string
    sql: ${TABLE}."LOC_NAME" ;;
  }

  dimension: mkt_abbrev {
    type: string
    sql: ${TABLE}."MKT_ABBREV" ;;
  }

  dimension: mkt_name {
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, loc_name, mkt_name]
  }
}
