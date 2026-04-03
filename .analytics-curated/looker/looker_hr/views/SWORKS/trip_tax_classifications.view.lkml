view: trip_tax_classifications {
  sql_table_name: "VEHICLE_USAGE_TRACKER"."TRIP_TAX_CLASSIFICATIONS"
    ;;
  drill_fields: [trip_tax_classification_id]

  dimension: trip_tax_classification_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRIP_TAX_CLASSIFICATION_ID" ;;
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

  dimension: business_destination {
    type: string
    sql: ${TABLE}."BUSINESS_DESTINATION" ;;
  }

  dimension: business_reason {
    type: string
    sql: ${TABLE}."BUSINESS_REASON" ;;
  }

  dimension_group: date_approved_by_driver {
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
    sql: CAST(${TABLE}."DATE_APPROVED_BY_DRIVER" AS TIMESTAMP_NTZ) ;;
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

  dimension: trip_classification_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRIP_CLASSIFICATION_TYPE_ID" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [trip_tax_classification_id, trip_classification_types.trip_classification_type_id, trip_classification_types.name]
  }
}
