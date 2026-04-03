view: daily_active_companies {
  derived_table: {
    sql:
  WITH date_series AS (SELECT series AS date
                         FROM TABLE (es_warehouse.public.generate_series(
                                 DATE_TRUNC('day', (DATEADD('day', -365, CURRENT_DATE())))::timestamp_tz,
                                 CURRENT_DATE()::timestamp_tz, 'day'))),
       day_totals  AS (SELECT ds.date,
                              hu.company_id,
                              s.es_app_name,
                              COUNT(DISTINCT s.session_id) AS num_sessions
                         FROM date_series ds
                              LEFT OUTER JOIN analytics.heap_adjunct.sessions s
                                              ON ds.date = DATE_TRUNC('day', s.time)
                              LEFT OUTER JOIN analytics.heap_adjunct.heap_users hu
                                         ON s.user_id = hu.user_id

                        GROUP BY ds.date, hu.company_id, s.es_app_name)

SELECT d.date,
       d.company_id,
       d.es_app_name,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.company_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)  AS rolling_1,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.company_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)  AS rolling_7,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.company_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) AS rolling_30,
       SUM(d.num_sessions)
           OVER (PARTITION BY d.company_id, d.es_app_name ORDER BY d.date ROWS BETWEEN 90 PRECEDING AND CURRENT ROW) AS rolling_90,
       rolling_1 > 0                                                                                                 AS daily_active,
       rolling_7 > 0                                                                                                 AS weekly_active,
       rolling_30 > 0                                                                                                AS monthly_active,
       ROW_NUMBER() OVER (ORDER BY d.date)                                                                           AS pkey
  FROM day_totals d
 ORDER BY d.date, d.es_app_name, rolling_1, rolling_7, rolling_30;;
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

  measure: daily_active_companies {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [daily_active: "yes"]
  }

  measure: weekly_active_companies {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [weekly_active: "yes"]
  }

  measure: monthly_active_companies {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [monthly_active: "yes"]
  }

  # measure: total_sessions {
  #   type: sum
  #   sql:  ${rolling_90};;
  #   drill_fields: [company_id, es_app_name, count]
  # }

  measure: count_companies {
    type: count_distinct
    sql: ${company_id} ;;
  }

  measure: count {
    type: count
  }

}
