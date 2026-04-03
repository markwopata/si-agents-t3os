view: driver_assignments {
  derived_table: {
    sql: SELECT
        da.user_id,
        da.operator_name,
        da.asset_id,
        CONCAT(a.make, ' ', a.model) as make_model,
        CONVERT_TIMEZONE('America/Chicago', da.assignment_time) as assignment_time,
        CONVERT_TIMEZONE('America/Chicago', da.unassignment_time) as unassignment_time,
        da.current_assignment
      FROM
        analytics.fleetcam.driver_assignments da
        join es_warehouse.public.assets a ON da.asset_id = a.asset_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format: "0"
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }

  dimension: make_model {
    type: string
    sql: ${TABLE}."MAKE_MODEL" ;;
  }

  dimension_group: assignment_time {
    type: time
    sql: ${TABLE}."ASSIGNMENT_TIME" ;;
  }

  dimension_group: unassignment_time {
    type: time
    sql: ${TABLE}."UNASSIGNMENT_TIME" ;;
  }

  dimension: current_assignment {
    type: yesno
    sql: ${TABLE}."CURRENT_ASSIGNMENT" ;;
  }

  set: detail {
    fields: [
      user_id,
      operator_name,
      asset_id,
      make_model,
      assignment_time_time,
      unassignment_time_time,
      current_assignment
    ]
  }
}
