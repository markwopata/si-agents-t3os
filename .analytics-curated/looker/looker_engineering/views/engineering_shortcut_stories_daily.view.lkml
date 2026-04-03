view: engineering_shortcut_stories_daily {
  sql_table_name: "ES_WAREHOUSE"."HISTORY"."ENGINEERING_SHORTCUT_STORIES_HISTORY_DAILY"
    ;;

  dimension: card_id {
    type: number
    sql: ${TABLE}."CARD_ID" ;;
  }

  dimension: card_name {
    type: string
    sql: ${TABLE}."CARD_NAME" ;;
  }

  dimension_group: completed {
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
    sql: ${TABLE}."COMPLETED" ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}."CREATED" ;;
  }

  dimension: cycle_time {
    type: number
    sql: ${TABLE}."CYCLE_TIME" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: labels {
    type: string
    sql: ${TABLE}."LABELS" ;;
  }

  dimension: roadmap_completed {
    type: number
    sql: ${TABLE}."NUM_ROADMAP_COMPLETED" ;;
  }

  dimension: techdebt_completed {
    type:  number
    sql: ${TABLE}."NUM_TECHDEBT_COMPLETED" ;;
  }

  dimension: unplanned_completed {
    type:  number
    sql: ${TABLE}."NUM_UNPLANNED_COMPLETED" ;;
  }

  dimension: xteam_unplanned_completed {
    type:  number
    sql: ${TABLE}."NUM_XTEAM_PLANNED_COMPLETED" ;;
  }

  dimension: xteam_planned_completed {
    type:  number
    sql: ${TABLE}."NUM_XTEAM_PLANNED_COMPLETED" ;;
  }

  dimension: dependency_defect_completed {
    type:  number
    sql: ${TABLE}."NUM_DEPENDENCY_DEFECT_COMPLETED" ;;
  }

  dimension: unplanned_complete {
    type:  number
    sql: ${TABLE}."NUM_UNPLANNED_COMPLETED" ;;
  }

  dimension: unlabeled_complete {
    type:  number
    sql: ${TABLE}."NUM_UNLABELED_COMPLETED" ;;
  }

  measure: lead_time {
    type: sum
    sql: ${TABLE}."LEAD_TIME" ;;
  }

  measure: num_roadmap_completed {
    type: sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_ROADMAP_COMPLETED" ;;
  }

  measure: num_techdebt_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_TECHDEBT_COMPLETED" ;;
  }

  measure: num_unplanned_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_UNPLANNED_COMPLETED" ;;
  }

  measure: num_bug_xteam_unplanned_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_BUG_XTEAM_UNPLANNED_COMPLETED" ;;
  }

  measure: num_feature_xteam_unplanned_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_FEATURE_XTEAM_UNPLANNED_COMPLETED" ;;
  }

  measure: num_xteam_planned_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_XTEAM_PLANNED_COMPLETED" ;;
  }

  measure: num_dependency_defect_completed {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_DEPENDENCY_DEFECT_COMPLETED" ;;
  }

  measure: num_unplanned_complete {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_UNPLANNED_COMPLETED" ;;
  }

  measure: num_unlabeled_complete {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."NUM_UNLABELED_COMPLETED" ;;
  }

  measure: num_in_progress {
    type:  sum_distinct
    sql_distinct_key: ${team} || ${date_date};;
    sql: ${TABLE}."TOTAL_IN_PROGRESS" ;;
  }

  # measure: num_bug_completed {
  #   type: number
  #   sql: ${TABLE}."NUM_BUG_COMPLETED" ;;
  # }

  # measure: num_bug_in_progress {
  #   type: sum
  #   sql: ${TABLE}."NUM_BUG_IN_PROGRESS" ;;
  # }

  # measure: num_chore_backlog {
  #   type: sum
  #   sql: ${TABLE}."NUM_CHORE_BACKLOG" ;;
  # }

  # measure: num_chore_completed {
  #   type: sum
  #   sql: ${TABLE}."NUM_CHORE_COMPLETED" ;;
  # }

  # measure: num_chore_in_progress {
  #   type: sum
  #   sql: ${TABLE}."NUM_CHORE_IN_PROGRESS" ;;
  # }

  # measure: num_completed {
  #   type: sum
  #   sql: ${TABLE}."NUM_COMPLETED" ;;
  # }

  # measure: num_feature_backlog {
  #   type: sum
  #   sql: ${TABLE}."NUM_FEATURE_BACKLOG" ;;
  # }

  # measure: num_feature_completed {
  #   type: sum
  #   sql: ${TABLE}."NUM_FEATURE_COMPLETED" ;;
  # }

  # measure: num_feature_in_progress {
  #   type: sum
  #   sql: ${TABLE}."NUM_FEATURE_IN_PROGRESS" ;;
  # }

  dimension_group: started {
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
    sql: ${TABLE}."STARTED" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [card_name]
  }
}
