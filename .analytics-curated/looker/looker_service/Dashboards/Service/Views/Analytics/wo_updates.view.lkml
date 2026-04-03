view: wo_updates {
  sql_table_name: "ANALYTICS"."SERVICE"."WO_UPDATES"
    ;;

  dimension_group: wo_date_created {
    label: "WO Created"
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
    sql: CAST(${TABLE}."WO_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: update_date {
    label: "WO Updated"
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
    sql: CAST(${TABLE}."UPDATE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: max_update {
    type: date
    sql: max(${update_date_date}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: wo_update_num {
    type: number
    sql: ${TABLE}."WO_UPDATE_NUM" ;;
  }

  dimension: asset_sequence_num {
    type: number
    sql: ${TABLE}."ASSET_SEQUENCE_NUM" ;;
  }

  dimension: update_type {
    label: "WO Update Type"
    type: string
    sql: ${TABLE}."UPDATE_TYPE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: wo_update {
    label: "WO Update Info"
    type: string
    sql: ${TABLE}."WO_UPDATE" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: wo_update_no_pics {
    type: string
    sql: iff(${TABLE}."WO_UPDATE" ilike '%jpeg%' or "WO_UPDATE" ilike '%png%', null, ${TABLE}."WO_UPDATE")  ;;
  }

  measure: updates {
    type: list
    list_field: wo_update_no_pics
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
