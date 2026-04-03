
view: monthly_customer_insights {
  derived_table: {
    sql: select * from analytics.bi_ops.monthly_customer_insights ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }


  dimension_group: month {
    type: time
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_string {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_formatted {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: date
    sql: ${month_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: month_company_id {
    type: string
    sql: concat(${company_id},${month_string}) ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: hva_session_count {
    type: number
    sql: ${TABLE}."HVA_SESSION_COUNT" ;;
  }
  measure: hva_session_count_sum {
    type: sum
    sql: ${hva_session_count} ;;
  }

  dimension: active_users {
    type: number
    sql: ${TABLE}."ACTIVE_USERS" ;;
  }

  dimension: active_user_ratio {
    type: number
    sql: ${TABLE}."ACTIVE_USER_RATIO" ;;
  }

  dimension: active_time_ratio {
    type: number
    sql: ${TABLE}."ACTIVE_TIME_RATIO" ;;
  }

  dimension: action_rate {
    type: number
    sql: ${TABLE}."ACTION_RATE" ;;
  }

  dimension: active_time {
    type: number
    sql: ${TABLE}."ACTIVE_TIME" ;;
  }

  dimension: active_sessions {
    type: number
    sql: ${TABLE}."ACTIVE_SESSIONS" ;;
  }

  dimension: sample_weighted_engagement_score {
    type: number
    sql: ${TABLE}."SAMPLE_WEIGHTED_ENGAGEMENT_SCORE" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: rental_revenue_sum {
    type: sum
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: total_trackers_installed {
    type: number
    sql: ${TABLE}."TOTAL_TRACKERS_INSTALLED" ;;
  }

  measure: total_trackers_installed_sum {
    label: "Total Trackers Installed"
    group_label: "Tracker Status Measures"
    type: sum
    sql: ${total_trackers_installed} ;;
  }

  dimension: healthy {
    type: number
    sql: ${TABLE}."HEALTHY" ;;
  }

  measure: healthy_sum {
    label: "Healthy"
    group_label: "Tracker Status Measures"
    type: sum
    sql: ${healthy} ;;
  }

  dimension: needs_service_attention {
    type: number
    sql: ${TABLE}."NEEDS_SERVICE_ATTENTION" ;;
  }

  measure: needs_service_attention_sum {
    label: "Needs Service Attention"
    group_label: "Tracker Status Measures"
    type: sum
    sql: ${needs_service_attention} ;;
  }

  dimension: needs_telematics_attention {
    type: number
    sql: ${TABLE}."NEEDS_TELEMATICS_ATTENTION" ;;
  }

  measure: needs_telematics_attention_sum {
    label: "Needs Telematics Attention"
    group_label: "Tracker Status Measures"
    type: sum
    sql: ${needs_telematics_attention} ;;
  }

  dimension: unstable {
    type: number
    sql: ${TABLE}."UNSTABLE" ;;
  }

  measure: unstable_sum {
    label: "Unstable"
    group_label: "Tracker Status Measures"
    type: sum
    sql: ${unstable} ;;
  }

  dimension: t3_unhealthy_percentage {
    type: number
    sql: ${TABLE}."BAD_PERC" ;;
    value_format_name: percent_1
  }

  dimension: grouping {
    type: string
    sql: ${TABLE}."GROUPING" ;;
  }

  set: detail {
    fields: [
        month_string,
  company_id,
  company_name,
  hva_session_count,
  active_users,
  active_user_ratio,
  active_time_ratio,
  action_rate,
  active_time,
  active_sessions,
  sample_weighted_engagement_score,
  rental_revenue,
  total_trackers_installed,
  healthy,
  needs_service_attention,
  needs_telematics_attention,
  unstable,
  t3_unhealthy_percentage,
  grouping
    ]
  }
}
