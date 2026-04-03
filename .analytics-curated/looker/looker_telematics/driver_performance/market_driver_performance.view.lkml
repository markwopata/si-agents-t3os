view: market_driver_performance {
  sql_table_name: "ANALYTICS"."BI_OPS"."MARKET_DRIVER_PERFORMANCE" ;;

  dimension: market_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_safety_score_4_w {
    label: "Market Safety Score (4W)"
    type: number
    sql: ${TABLE}."MARKET_SAFETY_SCORE_4W" ;;
    value_format_name: decimal_1
  }

  dimension: market_health_score {
    label: "Market Health Score"
    type: number
    sql: ${TABLE}."MARKET_HEALTH_SCORE" ;;
    value_format_name: decimal_1
  }

  dimension: fleet_avg_health {
    label: "Fleet Avg Health Score"
    type: number
    sql: ${TABLE}."FLEET_AVG_HEALTH" ;;
    value_format_name: decimal_1
  }

  dimension: fleet_safety_score_4_w {
    label: "Fleet Safety Score (4W)"
    type: number
    sql: ${TABLE}."FLEET_SAFETY_SCORE_4W" ;;
    value_format_name: decimal_1
  }

  dimension: vs_fleet_delta {
    label: "vs Fleet Delta"
    type: number
    sql: ${TABLE}."VS_FLEET_DELTA" ;;
    value_format_name: decimal_1
  }

  dimension: market_risk_band {
    label: "Risk Classification"
    type: string
    sql: ${TABLE}."MARKET_RISK_BAND" ;;
    html:
    {% if value == 'Low Risk' %}
    <span style="color: #00CB86;">◉ </span>{{rendered_value}}
    {% elsif value == 'Medium Risk' %}
    <span style="color: #ffad6a;">◉ </span>{{rendered_value}}
    {% elsif value == 'High Risk' %}
    <span style="color: #b02a3e;">◉ </span>{{rendered_value}}
    {% elsif value == 'Unclassified' %}
    <span style="color: #999999;">◉ </span>{{rendered_value}}
    {% endif %}
    ;;
  }

  dimension: market_rank {
    type: number
    sql: ${TABLE}."MARKET_RANK" ;;
  }

  dimension: drivers_included {
    type: number
    sql: ${TABLE}."DRIVERS_INCLUDED" ;;
  }

  dimension: total_drive_hours_4_w {
    type: number
    sql: ${TABLE}."TOTAL_DRIVE_HOURS_4W" ;;
  }

  # Band distribution -- counts

  dimension: critical_drivers {
    group_label: "Band Distribution"
    type: number
    sql: ${TABLE}."CRITICAL_DRIVERS" ;;
  }

  dimension: at_risk_drivers {
    group_label: "Band Distribution"
    type: number
    sql: ${TABLE}."AT_RISK_DRIVERS" ;;
  }

  dimension: fair_drivers {
    group_label: "Band Distribution"
    type: number
    sql: ${TABLE}."FAIR_DRIVERS" ;;
  }

  dimension: good_drivers {
    group_label: "Band Distribution"
    type: number
    sql: ${TABLE}."GOOD_DRIVERS" ;;
  }

  dimension: excellent_drivers {
    group_label: "Band Distribution"
    type: number
    sql: ${TABLE}."EXCELLENT_DRIVERS" ;;
  }

  # Band distribution -- percentages

  dimension: pct_critical {
    group_label: "Band Distribution %"
    label: "% Critical"
    type: number
    sql: ${TABLE}."PCT_CRITICAL" ;;
    value_format_name: decimal_1
  }

  dimension: pct_at_risk {
    group_label: "Band Distribution %"
    label: "% At Risk"
    type: number
    sql: ${TABLE}."PCT_AT_RISK" ;;
    value_format_name: decimal_1
  }

  dimension: pct_needs_attention {
    group_label: "Band Distribution %"
    label: "% Needs Attention"
    type: number
    sql: ${TABLE}."PCT_NEEDS_ATTENTION" ;;
    value_format_name: decimal_1
  }

  # Trend

  dimension: pct_worsening {
    group_label: "Trend"
    label: "% Worsening"
    type: number
    sql: ${TABLE}."PCT_WORSENING" ;;
    value_format_name: decimal_1
  }

  dimension: pct_improving {
    group_label: "Trend"
    label: "% Improving"
    type: number
    sql: ${TABLE}."PCT_IMPROVING" ;;
    value_format_name: decimal_1
  }

  # Event totals

  dimension: total_aggressive_events {
    group_label: "Event Totals"
    type: number
    sql: ${TABLE}."TOTAL_AGGRESSIVE_EVENTS" ;;
  }

  dimension: total_collision_events {
    group_label: "Event Totals"
    type: number
    sql: ${TABLE}."TOTAL_COLLISION_EVENTS" ;;
  }

  dimension: total_distraction_events {
    group_label: "Event Totals"
    type: number
    sql: ${TABLE}."TOTAL_DISTRACTION_EVENTS" ;;
  }

  dimension: total_compliance_events {
    group_label: "Event Totals"
    type: number
    sql: ${TABLE}."TOTAL_COMPLIANCE_EVENTS" ;;
  }

  dimension: events_per_drive_hour {
    group_label: "Event Totals"
    type: number
    sql: ${TABLE}."EVENTS_PER_DRIVE_HOUR" ;;
    value_format_name: decimal_4
  }

  # Measures

  measure: total_hours_driven_last_four_weeks {
    type: sum
    sql: ${total_drive_hours_4_w} ;;
    value_format_name: decimal_1
  }

  measure: market_ranking {
    type: max
    sql: ${market_rank} ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
