view: int_equipment_assignments {
  sql_table_name: "ANALYTICS"."ASSETS"."INT_EQUIPMENT_ASSIGNMENTS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_end_with_nulls {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: iff(${TABLE}."DATE_END"::DATE = '9999-12-31', null, CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ))  ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }
  dimension: equipment_assignment_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }
  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }
  dimension: is_last_assignment_on_day {
    type: yesno
    sql: ${TABLE}."IS_LAST_ASSIGNMENT_ON_DAY" ;;
  }
  dimension_group: next_date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEXT_DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: rental_duration {
    type: number
    sql: ${TABLE}."RENTAL_DURATION" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }
  measure: count {
    type: count
  }
}
