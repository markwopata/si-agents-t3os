
view: market_newsletter_insights {
  sql_table_name: analytics.bi_ops.market_metric_newsletter_sentences  ;;


  measure: count {
    type: count
  }

  dimension: as_of_date {
    type: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: sentence {
    type: string
    sql: ${TABLE}."SENTENCE" ;;
  }

  dimension_group: generated_at {
    type: time
    sql: ${TABLE}."GENERATED_AT" ;;
  }

  dimension: market_tag {
    type: string
    sql: ${TABLE}."MARKET_TAG" ;;
  }


}
