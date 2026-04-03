view: dim_rental_statuses {
  sql_table_name: "PLATFORM"."GOLD"."V_RENTAL_STATUSES" ;;

  # PRIMARY KEY
  dimension: rental_status_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."RENTAL_STATUS_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: rental_status_source {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_SOURCE" ;;
    description: "Source system for rental status data"
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
    description: "Natural rental status ID"
    value_format_name: id
  }

  # RENTAL STATUS DETAILS
  dimension: rental_status_name {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_NAME" ;;
    description: "Rental status name"
  }

  dimension: rental_status_description {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_DESCRIPTION" ;;
    description: "Rental status description"
  }

  dimension: rental_status_active {
    type: yesno
    sql: ${TABLE}."RENTAL_STATUS_ACTIVE" ;;
    description: "Rental status is active"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of rental statuses"
    drill_fields: [rental_status_id, rental_status_name]
  }

  # TIMESTAMP
  dimension_group: rental_status_recordtimestamp {
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
    sql: CAST(${TABLE}."RENTAL_STATUS_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this rental status record was created"
  }
}
