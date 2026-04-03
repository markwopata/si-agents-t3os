view: daily_active_users {
  derived_table: {
    sql:
  WITH date_series AS (SELECT series AS date
                         FROM TABLE (es_warehouse.public.generate_series(
                                 DATE_TRUNC('day', (DATEADD('day', -365, CURRENT_DATE())))::timestamp_tz,
                                 CURRENT_DATE()::timestamp_tz, 'day'))),
       day_totals  AS (SELECT ds.date,
                              s.user_id,
                              hu.company_id,
                              s.es_app_name,
                              COUNT(DISTINCT s.session_id) AS num_sessions
                         FROM date_series ds
                              LEFT OUTER JOIN analytics.heap_adjunct.sessions s
                                              ON ds.date = DATE_TRUNC('day', s.time)
                              LEFT OUTER JOIN analytics.heap_adjunct.heap_users hu
                                         ON s.user_id = hu.user_id

                        GROUP BY ds.date, s.user_id, hu.company_id, s.es_app_name)

SELECT d.date,
       d.user_id,
       d.company_id,
       d.es_app_name,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.user_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)  AS rolling_1,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.user_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)  AS rolling_7,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.user_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) AS rolling_30,
       rolling_1 > 0                                                                                             AS daily_active,
       rolling_7 > 0                                                                                             AS weekly_active,
       rolling_30 > 0                                                                                            AS monthly_active,
       ROW_NUMBER() OVER (ORDER BY d.date)                                                                        AS pkey
  FROM day_totals d
;;
  }

  dimension: pkey {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}."PKEY" ;;
  }

  dimension_group: date {
    type: time
    convert_tz: no
    timeframes: [
      date,
      day_of_week_index,
      day_of_week,
      week,
      month,
      year
    ]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: es_app_name {
    type: string
    sql: ${TABLE}."ES_APP_NAME" ;;
  }

  dimension: rolling_1 {
    type: number
    sql: ${TABLE}."ROLLING_1" ;;
  }

  dimension: rolling_7 {
    type: number
    sql: ${TABLE}."ROLLING_7" ;;
  }

  dimension: rolling_30 {
    type: number
    sql: ${TABLE}."ROLLING_30" ;;
  }

  dimension: daily_active {
    type: yesno
    sql: ${TABLE}."DAILY_ACTIVE" ;;
  }

  dimension: weekly_active {
    type: yesno
    sql: ${TABLE}."WEEKLY_ACTIVE" ;;
  }

  dimension: monthly_active {
    type: yesno
    sql: ${TABLE}."MONTHLY_ACTIVE" ;;
  }

  measure: total_rolling_1 {
    type: sum
    sql: ${TABLE}."ROLLING_1";;
  }

  measure: total_rolling_7 {
    type: sum
    sql: ${TABLE}."ROLLING_7" ;;
  }

  measure: total_rolling_30 {
    type: sum
    sql: ${TABLE}."ROLLING_30" ;;
  }

  measure: daily_active_users {
    type: count
    filters: [daily_active: "yes"]
  }

  measure: weekly_active_users {
    type: count
    filters: [weekly_active: "yes"]
  }

  measure: monthly_active_users {
    type: count
    filters: [monthly_active: "yes"]
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: count {
    type: count
  }
 }
