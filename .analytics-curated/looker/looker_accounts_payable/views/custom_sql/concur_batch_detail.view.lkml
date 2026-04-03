view: concur_batch_detail {
  derived_table: {
    sql: SELECT
          BATCH_ID             AS RUN_NUMBER,
          COUNT(DETAIL)        AS RECORD_COUNT,
          BATCH_DATE           AS RUN_DATE,
          _ES_UPDATE_TIMESTAMP AS SNOWFLAKE_SYNC
      FROM
          ANALYTICS.CONCUR.APPROVED_BILL_DETAIL
      GROUP BY
          BATCH_ID,
          BATCH_DATE,
          _ES_UPDATE_TIMESTAMP
      ORDER BY
          BATCH_ID DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: run_number {
    type: number
    sql: ${TABLE}."RUN_NUMBER" ;;
  }

  dimension: record_count {
    type: number
    sql: ${TABLE}."RECORD_COUNT" ;;
  }

  dimension: run_date {
    type: date
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension_group: snowflake_sync {
    type: time
    sql: ${TABLE}."SNOWFLAKE_SYNC" ;;
  }

  set: detail {
    fields: [run_number, record_count, run_date, snowflake_sync_time]
  }
}
