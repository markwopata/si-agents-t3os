view: ccc_entries {
  sql_table_name: "SAASY"."PUBLIC"."CCC_ENTRIES" ;;
  drill_fields: [ccc_entry_id]

  dimension: ccc_entry_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CCC_ENTRY_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: ccc_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CCC_ID" ;;
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [ccc_entry_id, cccs.ccc_id]
  }
}

view: latest_ccc_entries {
  derived_table: {
    sql:
      SELECT *
      FROM ${ccc_entries.SQL_TABLE_NAME} ccc_entry
      QUALIFY ROW_NUMBER() OVER (
        PARTITION BY ccc_id
        ORDER BY created_at DESC
      ) = 1 ;;
  }

  extends: [ccc_entries]
  }
