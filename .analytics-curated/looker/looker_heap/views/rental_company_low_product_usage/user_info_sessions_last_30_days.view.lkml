
view: user_info_sessions_last_30_days {
  derived_table: {
    sql: SELECT
            u.company_id,
            u.user_name,
            users.email_address,
            count(distinct(ss.session_id)) as total_sessions
        FROM
            HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
            JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
            JOIN es_warehouse.public.users users on users.user_id = u._user_id
        WHERE
            ss.time BETWEEN DATEADD(day,-31,current_date()) AND DATEADD(day,-1,current_date())
            AND u.mimic_user <> 'Yes'
        GROUP BY
            u.company_id,
            u.user_name,
            users.email_address ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${company_id},${user_name}) ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: total_sessions {
    type: number
    sql: ${TABLE}."TOTAL_SESSIONS" ;;
  }

  measure: total_t3_sessions {
    type: sum
    sql: ${total_sessions} ;;
  }

  set: detail {
    fields: [
        company_id,
  user_name,
  email_address,
  total_sessions
    ]
  }
}
