view: user_session_activity {
  derived_table: {
    sql:
SELECT
       DATE_TRUNC('day', s.time) AS day,
       hu.user_id,
       hu.identity,
       hu.company_id,
       s.es_app_name,
       COUNT(DISTINCT s.session_id) as num_sessions
FROM analytics.heap_adjunct.heap_users hu
INNER JOIN analytics.heap_adjunct.sessions s
ON hu.user_id = s.user_id
GROUP BY day, hu.user_id, hu.identity, hu.company_id, s.es_app_name;;
  }

  dimension: pkey {
    hidden: yes
    type: string
    sql: ${date_date} || ${user_id} || ${es_app_name};;
  }

  dimension_group: date {
    type: time
    timeframes: [date, day_of_week_index, week, month, year]
    sql: ${TABLE}."DAY" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: identity {
    type: number
    sql: ${TABLE}."IDENTITY" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: es_app_name {
    type: string
    sql: ${TABLE}."ES_APP_NAME" ;;
  }

  dimension: num_sessions {
    type: number
    sql: ${TABLE}."NUM_SESSIONS" ;;
  }

  measure: total_sessions {
    type: sum
    sql: ${num_sessions} ;;
    drill_fields: [date_date, users.full_name, companies.name, total_sessions]
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [session_detail*]
  }

  measure: count_companies {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [companies.name, es_app_name, total_sessions]
  }

  measure: active_company_last_90 {
    type: sum
    sql: ${num_sessions} ;;
    filters: [date_date: "90 days ago"]
  }

  set: session_detail {
    fields: [
      date_date,
      users.full_name,
      companies.name,
      es_app_name,
      total_sessions]
  }
}
