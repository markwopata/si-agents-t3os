view: fleet_status_by_location {
  sql_table_name: "ANALYTICS"."ASSET_DETAILS"."V_FLEET_STATUS_BY_LOCATION"
    ;;

  dimension: assigned {
    type: number
    sql: ${TABLE}."ASSIGNED" ;;
  }

  dimension: count_ute {
    type: number
    sql: ${TABLE}."COUNT_UTE" ;;
  }

  dimension: hard_down {
    type: number
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: make_ready {
    type: number
    sql: ${TABLE}."MAKE_READY" ;;
  }

  dimension: needs_inspection {
    type: number
    sql: ${TABLE}."NEEDS_INSPECTION" ;;
  }

  dimension: no_status {
    type: number
    sql: ${TABLE}."NO_STATUS" ;;
  }

  dimension: on_rent {
    type: number
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: on_rpo {
    type: number
    sql: ${TABLE}."ON_RPO" ;;
  }

  dimension: pending_return {
    type: number
    sql: ${TABLE}."PENDING_RETURN" ;;
  }

  dimension: pre_delivered {
    type: number
    sql: ${TABLE}."PRE_DELIVERED" ;;
  }

  dimension: ready_to_rent {
    type: number
    sql: ${TABLE}."READY_TO_RENT" ;;
  }

  dimension: received {
    type: number
    sql: ${TABLE}."RECEIVED" ;;
  }

  dimension: rental_branch {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH" ;;
  }

  dimension: shipped {
    type: number
    sql: ${TABLE}."SHIPPED" ;;
  }

  dimension: soft_down {
    type: number
    sql: ${TABLE}."SOFT_DOWN" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: oec_ute {
    type: number
    sql: ${TABLE}."OEC_UTE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
