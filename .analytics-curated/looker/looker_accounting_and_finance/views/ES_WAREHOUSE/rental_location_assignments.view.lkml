view: rental_location_assignments {
derived_table: {
  sql:
SELECT
                                   rental_id
                                 , location_id
                                 , rental_location_assignment_id
                                   FROM ES_WAREHOUSE.PUBLIC.rental_location_assignments
                                   WHERE rental_location_assignment_id IN
                                         (SELECT
                                              max(rental_location_assignment_id)
                                              FROM ES_WAREHOUSE.PUBLIC.rental_location_assignments
                                              GROUP BY rental_id);;
                                              }

  dimension: rental_location_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_LOCATION_ASSIGNMENT_ID" ;;
  }

  # dimension_group: _es_update_timestamp {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension: created_by_user_id {
  #   type: number
  #   sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  # }

  # dimension_group: date_created {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension_group: date_updated {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension_group: end {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  # }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  # dimension: move_delivery_id {
  #   type: number
  #   sql: ${TABLE}."MOVE_DELIVERY_ID" ;;
  # }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  # dimension_group: start {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  # }

  measure: count {
    type: count
    drill_fields: [rental_location_assignment_id]
  }
}
