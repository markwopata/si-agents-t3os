view: branch_survey_comment {
  sql_table_name: "PUBLIC"."BRANCH_SURVEY_COMMENT" ;;

  dimension: additional_comments {
    type: string
    sql: ${TABLE}."ADDITIONAL_COMMENTS" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }
  dimension: current_survey_results {
    type: yesno
    sql: ${TABLE}."CURRENT_SURVEY_RESULTS" ;;
  }
  dimension_group: insert_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INSERT_TIMESTAMP" ;;
  }
  dimension: respondent_email {
    type: string
    sql: ${TABLE}."RESPONDENT_EMAIL" ;;
  }
  measure: count {
    type: count
    drill_fields: [branch_name]
  }
}
