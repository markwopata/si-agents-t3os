view: engineering_shortcut_stories {
  sql_table_name: "GS"."ENGINEERING_SHORTCUT_STORIES" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  measure: total__row {
    type: sum
    sql: ${_row} ;;
  }

  measure: average__row {
    type: average
    sql: ${_row} ;;
  }
  dimension_group: completed_at {
    type: time
    sql: ${TABLE}."COMPLETED_AT" ;;
  }
  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: estimate {
    type: number
    sql: ${TABLE}."ESTIMATE" ;;
  }

  dimension: is_completed {
    type: yesno
    sql: ${TABLE}."IS_COMPLETED" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: owners {
    type: string
    sql: ${TABLE}."OWNERS" ;;
  }
  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }
  dimension: project {
    type: string
    sql: ${TABLE}."PROJECT" ;;
  }
  dimension: project_id {
    type: number
    sql: ${TABLE}."PROJECT_ID" ;;
  }
  dimension: requester {
    type: string
    sql: ${TABLE}."REQUESTER" ;;
  }
  dimension: severity {
    type: string
    sql: ${TABLE}."SEVERITY" ;;
  }
  dimension: started_at {
    type: string
    sql: ${TABLE}."STARTED_AT" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: tasks {
    type: string
    sql: ${TABLE}."TASKS" ;;
  }
  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }
  dimension: team_id {
    type: string
    sql: ${TABLE}."TEAM_ID" ;;
  }
  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }
  dimension: updated_at {
    type: string
    sql: ${TABLE}."UPDATED_AT" ;;
  }
  dimension: utc_offset {
    type: string
    sql: ${TABLE}."UTC_OFFSET" ;;
  }
  dimension: workflow {
    type: string
    sql: ${TABLE}."WORKFLOW" ;;
  }
  dimension: workflow_id {
    type: number
    sql: ${TABLE}."WORKFLOW_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
