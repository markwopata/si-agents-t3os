view: heap_user_sessions {
  derived_table: {
    sql: with sessions_last_30_days as (
      SELECT
          u.company_id,
          u._user_id as user_id,
          count(distinct(ss.session_id)) as total_sessions
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
          JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
      WHERE
          ss.time BETWEEN DATEADD(day,-30,current_date()) AND current_date()
          AND u.mimic_user <> 'Yes'
      GROUP BY
          u.company_id,
          u._user_id
      )
      ,sessions_last_60_days as (
      SELECT
          u.company_id,
          u._user_id as user_id,
          count(distinct(ss.session_id)) as total_sessions
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
          JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
      WHERE
          ss.time BETWEEN DATEADD(day,-61,current_date()) AND DATEADD(day,-31,current_date())
          AND u.mimic_user <> 'Yes'
      GROUP BY
          u.company_id,
          u._user_id
      )
      SELECT
          concat(u.first_name,' ',u.last_name) as user_name,
          u.company_id,
          ifnull(sl.total_sessions,0) as total_sessions_last_30_days,
          ifnull(sp.total_sessions,0) as total_sessions_previous_30_days
      FROM
          es_warehouse.public.users u
          LEFT JOIN sessions_last_30_days sl on sl.user_id = u.user_id
          LEFT JOIN sessions_last_60_days sp on sp.user_id = u.user_id
      WHERE
          u.deleted = false
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: total_sessions_last_30_days {
    type: number
    sql: ${TABLE}."TOTAL_SESSIONS_LAST_30_DAYS" ;;
  }

  dimension: total_sessions_previous_30_days {
    type: number
    sql: ${TABLE}."TOTAL_SESSIONS_PREVIOUS_30_DAYS" ;;
  }

  measure: session_difference {
    type: number
    sql: ${total_sessions_last_30_days} - ${total_sessions_previous_30_days} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">▴ {{ rendered_value }}</font>
    {% elsif value < 0 %}
    <font color="#DA344D">▾ {{ rendered_value }}</font>
    {% else %}
    <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: percent_of_session_change {
    label: "Session Change %"
    type: number
    sql: (${total_sessions_last_30_days} - ${total_sessions_previous_30_days})/ case when ${total_sessions_previous_30_days} = 0 then null else ${total_sessions_previous_30_days} end ;;
    value_format_name: percent_1
    html:
    {% if value > 0 %}
    <font color="#00CB86">▴ {{ rendered_value }}</font>
    {% elsif value < 0 %}
    <font color="#DA344D">▾ {{ rendered_value }}</font>
    {% else %}
    <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }


  set: detail {
    fields: [user_name, company_id, total_sessions_last_30_days, total_sessions_previous_30_days]
  }
}
