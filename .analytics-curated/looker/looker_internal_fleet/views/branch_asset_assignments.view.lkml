view: branch_asset_assignments {
  sql_table_name: "PUBLIC"."BRANCH_ASSET_ASSIGNMENTS" ;;
  drill_fields: [branch_asset_assignment_id]

  dimension: branch_asset_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BRANCH_ASSET_ASSIGNMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: branch_asset_assignment_type_id {
    type: number
    sql: ${TABLE}."BRANCH_ASSET_ASSIGNMENT_TYPE_ID" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: formatted_start_date {
    group_label: "HTML Formatted Date"
    label: "Start Date"
    type: date
    sql: ${start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_end_date {
    group_label: "HTML Formatted Date"
    label: "Start Date"
    type: date
    sql: ${end_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_start_time {
    group_label: "HTML Formatted Time"
    label: "Start Date & Time"
    type: date_time
    sql: ${start_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }};;
  }

  dimension: formatted_end_time {
    group_label: "HTML Formatted Time"
    label: "End Date & Time"
    type: date_time
    sql: ${end_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }};;
  }

  measure: count {
    type: count
    drill_fields: [branch_asset_assignment_id]
  }
}
