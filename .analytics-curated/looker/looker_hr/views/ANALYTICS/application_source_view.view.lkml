view: application_source_view {
  sql_table_name: "GREENHOUSE"."APPLICATION_SOURCE_VIEW"
    ;;

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: merged_source {
    type: string
    sql: ${TABLE}."merged_source" ;;
  }

  dimension: source_paid {
    type: string
    sql: ${TABLE}."source_paid" ;;
  }

  dimension: website {
    type: string
    sql: ${TABLE}."website" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: headcount {
    sql: CASE WHEN ${TABLE}."BEH_INTERVIEW_REC" ="yes" OR  ${TABLE}."BEH_INTERVIEW_REC" ="strong_yes" THEN 1
      ELSE 0 END;;
    type:  sum
  }

}
