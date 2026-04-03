# The name of this view in Looker is "Equipment Assignments"
view: equipment_assignments {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_ASSIGNMENTS"
    ;;
  drill_fields: [equipment_assignment_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: equipment_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Asset ID" in Explore.

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
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

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_assignment_id]
  }
}
