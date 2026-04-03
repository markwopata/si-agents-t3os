view: usage_patterns {
  derived_table: {
    sql:
with logins as (SELECT hu.company_id,
       DATE_TRUNC('month', time) AS login_date,
                       count(*) as num_sessions
  FROM heap_main_production.heap.users hu
       INNER JOIN heap_main_production.heap.sessions s
                  ON hu.user_id = s.user_id
 WHERE hu.company_id IS NOT NULL
--and login_date > dateadd('year', -2, current_date())
and (login_date >= {% date_start date_filter %} and login_date <= COALESCE({% date_end date_filter %}, '2099-01-01'::date))
group by hu.company_id, DATE_TRUNC('month', time))

select *
from logins

match_recognize(
    partition by company_id
    order by login_date
    measures
        match_number() as match_number,
        first(login_date) as start_date,
        last(login_date) as end_date,
--        count(*) as rows_in_sequence,
        count(row_with_decrease.*) as num_decreases
--         ,count(row_with_increase.*) as num_increases
    one row per match
    after match skip to last row_with_decrease
    pattern(row_before_decrease row_with_decrease{3,} )
    define
        row_with_decrease as num_sessions < lag(num_sessions)
--         ,row_with_increase as num_sessions > lag(num_sessions)
        );;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: start_date {
    type: date_month
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date_month
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: match_number {
    type: number
    sql: ${TABLE}."MATCH_NUMBER" ;;
  }

  dimension: decreases {
    type: number
    sql: ${TABLE}."NUM_DECREASES" ;;
  }

  measure: total_decreases {
    type: sum
    sql: ${decreases} ;;
    drill_fields: [sessions.time_month, sessions.count]
  }

  measure: max_decreases {
    type: max
    sql: ${decreases} ;;
    drill_fields: [sessions.time_month, sessions.count]
  }

  measure: total_patterns {
    type: max
    sql: ${match_number} ;;
    drill_fields: [sessions.time_month, sessions.count]
  }

  filter: date_filter {
    type: date
  }


 }
