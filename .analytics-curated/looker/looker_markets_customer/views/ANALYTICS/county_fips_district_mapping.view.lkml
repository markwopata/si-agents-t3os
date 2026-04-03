view: county_fips_district_mapping {
  sql_table_name: "MARKET_DATA"."COUNTY_FIPS_DISTRICT_MAPPING"
    ;;

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}."COUNTY" ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}."FIPS" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: district_number {
    type: sum
    sql: ${district};;
  }

  measure: highlight {
    type: sum
    sql: 1;;
  }


  measure: count {
    type: count
    drill_fields: []
  }
}
