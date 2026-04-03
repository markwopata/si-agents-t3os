view: company_customer_success_agents {
  derived_table: {
    sql: with total_assets as (
      select
          company_id,
          count(a.tracker_id) as total_trackers,
          count(a.asset_id) as total_assets
      from
          assets a
      where
          deleted = FALSE
      group by
          company_id
      )
      , total_telematics_assets as (
      select
          ts.company_id,
          count(ts.asset_id) as tracked_assets
      from
          telematics_service_providers_assets ts
          join assets a on a.asset_id = ts.asset_id
      where
          a.deleted = FALSE
      group by
          ts.company_id
      )
      , total_users as (
      select
          company_id,
          count(user_id) as total_users
      from
          users
      where
          deleted = FALSE
      group by
          company_id
      )
      ,sessions_last_30_days as (
      SELECT
          u.company_id,
          count(distinct(ss.session_id)) as total_sessions
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
          JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
      WHERE
          ss.time BETWEEN DATEADD(day,-31,current_date()) AND DATEADD(day,-1,current_date())
          AND u.mimic_user <> 'Yes'
      GROUP BY
          u.company_id
      )
      ,sessions_previous_30_days as (
      SELECT
          u.company_id,
          count(distinct(ss.session_id)) as total_sessions
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.SESSIONS ss
          JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.USERS U on ss.user_id = u.user_id
      WHERE
          ss.time BETWEEN DATEADD(day,-62,current_date()) AND DATEADD(day,-32,current_date())
          AND u.mimic_user <> 'Yes'
      GROUP BY
          u.company_id
      )
      select
          regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+') as company_id,
          oc.property_name as company_name,
          oc.property_t3_customer_success_agent as customer_success_agent,
          coalesce(oc.property_t3aas_customer_,' ') as t3aas_customer,
          coalesce(sum(coalesce(ta.total_assets,0) + coalesce(tta.tracked_assets,0)),0) as total_assets,
          coalesce(sum(coalesce(ta.total_trackers,0) + coalesce(tta.tracked_assets,0)),0) as total_tracked_assets,
          coalesce(tu.total_users,0) as total_users,
          coalesce(sl.total_sessions,0) as sessions_last_30_days,
          coalesce(sp.total_sessions,0) as sessions_previous_30_days,
          DATEADD(day,-31,current_date()) as last_date_range_start,
          DATEADD(day,-1,current_date()) as last_date_range_end,
          DATEADD(day,-62,current_date()) as previous_date_range_start,
          DATEADD(day,-32,current_date()) as previous_date_range_end
      from
          hubspot.v2_daily.objects_companies oc
          left join total_assets ta on ta.company_id = regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+')
          left join total_telematics_assets tta on tta.company_id = regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+')
          left join total_users tu on tu.company_id = regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+')
          left join sessions_last_30_days sl on sl.company_id = regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+')
          left join sessions_previous_30_days sp on sp.company_id = regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+')
      where
        oc.property_t3_customer_success_agent is not null
      group by
          regexp_replace(oc.property_es_admin_id,'[^a-zA-Z0-9]+'),
          oc.property_name,
          oc.property_t3_customer_success_agent,
          oc.property_t3aas_customer_,
          tu.total_users,
          sl.total_sessions,
          sp.total_sessions
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    primary_key: yes
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: customer_success_agent {
    type: string
    sql: ${TABLE}."CUSTOMER_SUCCESS_AGENT" ;;
  }

  dimension: t3aas_customer {
    type: string
    label: "T3aaS Customer"
    sql: ${TABLE}."T3AAS_CUSTOMER" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: total_tracked_assets {
    type: number
    sql: ${TABLE}."TOTAL_TRACKED_ASSETS" ;;
  }

  dimension: total_users {
    type: number
    sql: ${TABLE}."TOTAL_USERS" ;;
  }

  dimension: sessions_last_30_days {
    type: number
    sql: ${TABLE}."SESSIONS_LAST_30_DAYS" ;;
    description: "Sessions from today are not included!"
  }

  dimension: sessions_previous_30_days {
    type: number
    sql: ${TABLE}."SESSIONS_PREVIOUS_30_DAYS" ;;
    description: "Sessions from today are not included!"
  }

  dimension: last_date_range_start {
    type: date
    sql: ${TABLE}."LAST_DATE_RANGE_START" ;;
  }

  dimension: last_date_range_end {
    type: date
    sql: ${TABLE}."LAST_DATE_RANGE_END" ;;
  }

  dimension: previous_date_range_start {
    type: date
    sql: ${TABLE}."PREVIOUS_DATE_RANGE_START" ;;
  }

  dimension: previous_date_range_end {
    type: date
    sql: ${TABLE}."PREVIOUS_DATE_RANGE_END" ;;
  }

  dimension: sessions_last_date_range {
    label: "Sessions Last 30 Days Date Range"
    type: string
    sql: concat(${last_date_range_start}, ' - ', ${last_date_range_end}) ;;
  }

  dimension: previous_last_date_range {
    label: "Sessions Previous 30 Days Date Range"
    type: string
    sql: concat(${previous_date_range_start}, ' - ', ${previous_date_range_end}) ;;
  }

  measure: session_difference {
    type: number
    sql: ${sessions_last_30_days} - ${sessions_previous_30_days} ;;
    html:
    {% if value > 0 %}
    <a href="#drillmenu" target="_self">
    <font color="#00CB86">▴ {{ rendered_value }}</font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% elsif value < 0 %}
    <a href="#drillmenu" target="_self">
    <font color="#DA344D">▾ {{ rendered_value }}</font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% else %}
    <a href="#drillmenu" target="_self">
    <font color="black">{{ rendered_value }}</font>
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% endif %} ;;
    drill_fields: [user_detail*]
    link: {
      label: "View User Activity Product Data"
    }
  }

  measure: percent_of_session_change {
    label: "Session Change %"
    type: number
    sql: (${sessions_last_30_days} - ${sessions_previous_30_days})/ case when ${sessions_previous_30_days} = 0 then null else ${sessions_previous_30_days} end ;;
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

  measure: percent_of_tracked_assets {
    label: "% of Tracked Assets"
    type: number
    sql: ${total_tracked_assets} / case when ${total_assets} = 0 then null else ${total_assets} end ;;
    value_format_name: percent_1
  }

  set: user_detail {
    fields: [
      heap_user_sessions.user_name,
      heap_user_sessions.total_sessions_last_30_days,
      heap_user_sessions.total_sessions_previous_30_days,
      heap_user_sessions.session_difference,
      heap_user_sessions.percent_of_session_change
    ]
  }

  set: detail {
    fields: [
      company_name,
      customer_success_agent,
      total_assets,
      total_tracked_assets,
      total_users,
      sessions_last_30_days,
      sessions_previous_30_days
    ]
  }
}
