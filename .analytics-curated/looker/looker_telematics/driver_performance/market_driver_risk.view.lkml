view: market_driver_risk {
  sql_table_name: "ANALYTICS"."BI_OPS"."MARKET_DRIVER_RISK" ;;

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
    primary_key: yes
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: operator_name {
    label: "Employee Name"
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  # ── 4-Week Composite ──

  dimension: driver_safety_score_4_w {
    type: number
    sql: ${TABLE}."DRIVER_SAFETY_SCORE_4W" ;;
  }

  dimension: eligible_weeks_4 {
    type: number
    sql: ${TABLE}."ELIGIBLE_WEEKS_4" ;;
  }

  dimension: drive_hours_4_w {
    type: number
    sql: ${TABLE}."DRIVE_HOURS_4W" ;;
  }

  # ── Latest Week Snapshot ──

  dimension: latest_week_score {
    type: number
    sql: ${TABLE}."LATEST_WEEK_SCORE" ;;
  }

  dimension: trend_against_4wk_avg {
    label: "Trend"
    type: string
    sql: ${TABLE}."TREND_AGAINST_4WK_AVG" ;;
  }

  dimension: primary_risk_persona {
    type: string
    sql: ${TABLE}."PRIMARY_RISK_PERSONA" ;;
  }

  # ── Contributing Events (with coaching links) ──

  dimension: primary_contributing_event {
    type: string
    sql: ${TABLE}."PRIMARY_CONTRIBUTING_EVENT" ;;
    link: {
      label: "How do they improve?"
      url: "{{ primary_improvement_recommendation._link }}"
    }
    html: {{ rendered_value }} <span style='opacity:.65;'>↗</span> ;;
  }

  dimension: secondary_contributing_event {
    type: string
    sql: ${TABLE}."SECONDARY_CONTRIBUTING_EVENT" ;;
    link: {
      label: "How do they improve?"
      url: "{{ secondary_improvement_recommendation._link }}"
    }
    html: {{ rendered_value }} <span style='opacity:.65;'>↗</span> ;;
  }

  dimension: primary_improvement_recommendation {
    type: string
    sql: '' ;;
    drill_fields: [
      primary_event_coaching.recommendation_1,
      primary_event_coaching.recommendation_2,
      primary_event_coaching.recommendation_3
    ]
  }

  dimension: secondary_improvement_recommendation {
    type: string
    sql: '' ;;
    drill_fields: [
      secondary_event_coaching.recommendation_1,
      secondary_event_coaching.recommendation_2,
      secondary_event_coaching.recommendation_3
    ]
  }

  # ── Chronic Risk ──

  dimension: weeks_critical_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_CRITICAL_LAST_8" ;;
  }

  dimension: weeks_at_risk_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_AT_RISK_LAST_8" ;;
  }

  # ── Category Risk Labels ──

  dimension: aggressive_risk {
    type: string
    sql: ${TABLE}."AGGRESSIVE_RISK" ;;
  }

  dimension: collision_risk {
    type: string
    sql: ${TABLE}."COLLISION_RISK" ;;
  }

  dimension: distraction_risk {
    type: string
    sql: ${TABLE}."DISTRACTION_RISK" ;;
  }

  dimension: compliance_risk {
    type: string
    sql: ${TABLE}."COMPLIANCE_RISK" ;;
  }

  # ── Population Comparison ──

  dimension: fleet_percentile {
    type: number
    sql: ${TABLE}."FLEET_PERCENTILE" ;;
  }

  dimension: market_percentile {
    type: number
    sql: ${TABLE}."MARKET_PERCENTILE" ;;
  }

  # ── Risk Level (replaces overall_driver_band / band_rank) ──

  dimension: risk_level {
    label: "Risk Classification"
    type: string
    sql: ${TABLE}."RISK_LEVEL" ;;
    order_by_field: risk_level_sort
    html:
      {% if value == '3 - High Risk' %}
        <span style="color: #b02a3e;">◉ </span>{{ rendered_value }}
      {% elsif value == '2 - Medium Risk' %}
        <span style="color: #ffad6a;">◉ </span>{{ rendered_value }}
      {% elsif value == '1 - Low Risk' %}
        <span style="color: #00CB86;">◉ </span>{{ rendered_value }}
      {% endif %} ;;
  }

  dimension: risk_level_sort {
    label: "Risk Level"
    type: number
    sql: ${TABLE}."RISK_LEVEL_SORT" ;;
    description: "Numeric risk tier for sorting/filtering: 3 = High Risk, 2 = Medium Risk, 1 = Low Risk"
    html:
      {% if value == 1 %}
        <span style="color: #00CB86;">◉ </span>{{ risk_level._rendered_value }}
      {% elsif value == 2 %}
        <span style="color: #ffad6a;">◉ </span>{{ risk_level._rendered_value }}
      {% elsif value == 3 %}
        <span style="color: #b02a3e;">◉ </span>{{ risk_level._rendered_value }}
      {% endif %} ;;
  }

  # ── Driver Rankings (worst = 1) ──

  dimension: driver_rank {
    type: number
    sql: ${TABLE}."DRIVER_RANK" ;;
    description: "Fleet-wide rank: 1 = worst driver across all markets"
  }

  dimension: market_driver_rank {
    type: number
    sql: ${TABLE}."MARKET_DRIVER_RANK" ;;
    description: "Within-market rank: 1 = worst driver in their market"
  }

  # ── Measures ──

  measure: total_hours_driven_last_four_weeks {
    type: sum
    sql: ${drive_hours_4_w} ;;
    value_format_name: decimal_1
  }

  measure: count {
    type: count
    drill_fields: [operator_name, market_name, driver_safety_score_4_w, risk_level]
  }

  measure: avg_safety_score_4w {
    type: average
    sql: ${driver_safety_score_4_w} ;;
    value_format_name: decimal_1
  }

  measure: count_high_risk {
    type: count
    filters: [risk_level: "3 - High Risk"]
    drill_fields: [operator_name, market_name, driver_safety_score_4_w, risk_level]
  }

  measure: count_medium_risk {
    type: count
    filters: [risk_level: "2 - Medium Risk"]
    drill_fields: [operator_name, market_name, driver_safety_score_4_w, risk_level]
  }

  measure: count_low_risk {
    type: count
    filters: [risk_level: "1 - Low Risk"]
    drill_fields: [operator_name, market_name, driver_safety_score_4_w, risk_level]
  }
}
