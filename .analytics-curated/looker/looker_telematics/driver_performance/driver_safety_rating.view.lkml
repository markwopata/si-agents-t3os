
view: driver_safety_rating {
  sql_table_name: "ANALYTICS"."BI_OPS"."DRIVER_PERFORMANCE_TESTING" ;;

  measure: count {
    type: count
    drill_fields: [email_coaching_drill*]
  }

  dimension: overall_driver_band {
    type: string
    sql: ${TABLE}."OVERALL_DRIVER_BAND" ;;
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: week_start {
    type: date
    sql: ${TABLE}."WEEK_START" ;;
  }

  dimension: driver_safety_score_100 {
    type: number
    sql: ${TABLE}."DRIVER_SAFETY_SCORE_100" ;;
  }

  dimension: trend_against_4_wk_avg {
    type: string
    sql: ${TABLE}."TREND_AGAINST_4WK_AVG" ;;
  }

  dimension: recent_unsafe_index {
    type: number
    sql: ${TABLE}."RECENT_UNSAFE_INDEX" ;;
  }

  dimension: primary_risk_persona {
    type: string
    sql: ${TABLE}."PRIMARY_RISK_PERSONA" ;;
  }

  dimension: primary_contributing_event {
    type: string
    sql: ${TABLE}."PRIMARY_CONTRIBUTING_EVENT" ;;
  }

  dimension: secondary_contributing_event {
    type: string
    sql: ${TABLE}."SECONDARY_CONTRIBUTING_EVENT" ;;
  }

  # dimension: rush_hour_events {
  #   type: number
  #   sql: ${TABLE}."RUSH_HOUR_EVENTS" ;;
  # }

  # dimension: rush_hour_event_pct {
  #   type: number
  #   sql: ${TABLE}."RUSH_HOUR_EVENT_PCT" ;;
  # }

  dimension: total_drive_time {
    type: number
    sql: ${TABLE}."TOTAL_DRIVE_TIME" ;;
    value_format_name: decimal_1
  }

  dimension: total_miles_driven {
    type: number
    sql: ${TABLE}."TOTAL_MILES_DRIVEN" ;;
    value_format_name: decimal_1
  }

  dimension: aggressive_events {
    type: number
    sql: ${TABLE}."AGGRESSIVE_EVENTS" ;;
  }

  dimension: aggressive_ep100_mi {
    type: number
    sql: ${TABLE}."AGGRESSIVE_EP100MI" ;;
  }

  dimension: aggressive_risk {
    type: string
    sql: ${TABLE}."AGGRESSIVE_RISK" ;;
    html:
    {% if value == 'High Risk' %}
    <span style="background-color:#ffd6d5; color:#b02a3e; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Medium Risk' %}
    <span style="background-color:#f8df8c; color:#FFBF00; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Low Risk' %}
    <span style="background-color:#c1ecd4; color:#00ad73; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% else %}
    {{ value }}
    {% endif %};;
  }

  dimension: collision_events {
    type: number
    sql: ${TABLE}."COLLISION_EVENTS" ;;
  }

  dimension: collision_ep100_mi {
    type: number
    sql: ${TABLE}."COLLISION_EP100MI" ;;
  }

  dimension: collision_risk {
    type: string
    sql: ${TABLE}."COLLISION_RISK" ;;
    html:
    {% if value == 'High Risk' %}
    <span style="background-color:#ffd6d5; color:#b02a3e; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Medium Risk' %}
    <span style="background-color:#f8df8c; color:#FFBF00; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Low Risk' %}
    <span style="background-color:#c1ecd4; color:#00ad73; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% else %}
    {{ value }}
    {% endif %};;
  }

  dimension: distraction_events {
    type: number
    sql: ${TABLE}."DISTRACTION_EVENTS" ;;
  }

  dimension: distraction_eph {
    type: number
    sql: ${TABLE}."DISTRACTION_EPH" ;;
  }

  dimension: distraction_risk {
    type: string
    sql: ${TABLE}."DISTRACTION_RISK" ;;
    html:
    {% if value == 'High Risk' %}
    <span style="background-color:#ffd6d5; color:#b02a3e; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Medium Risk' %}
    <span style="background-color:#f8df8c; color:#FFBF00; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Low Risk' %}
    <span style="background-color:#c1ecd4; color:#00ad73; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% else %}
    {{ value }}
    {% endif %};;
  }

  dimension: compliance_events {
    type: number
    sql: ${TABLE}."COMPLIANCE_EVENTS" ;;
  }

  dimension: compliance_eph {
    type: number
    sql: ${TABLE}."COMPLIANCE_EPH" ;;
  }

  dimension: compliance_risk {
    type: string
    sql: ${TABLE}."COMPLIANCE_RISK" ;;
    html:
    {% if value == 'High Risk' %}
    <span style="background-color:#ffd6d5; color:#b02a3e; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Medium Risk' %}
    <span style="background-color:#f8df8c; color:#FFBF00; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Low Risk' %}
    <span style="background-color:#c1ecd4; color:#00ad73; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% else %}
    {{ value }}
    {% endif %};;
  }

  dimension: is_previous_week {
    type: yesno
    sql: ${TABLE}."IS_PREVIOUS_WEEK" ;;
  }

  measure: overall_driving_rating_formatted {
    type: string
    sql: ${overall_driver_band} ;;
    html:
    {% if value == 'Critical' %}
    <span style="background-color:#ffd6d5; color:#b02a3e; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'At Risk' %}
    <span style="background-color:#f8df8c; color:#DA344D; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Fair' %}
    <span style="background-color:#f8df8c; color:#FFBF00; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Good' %}
    <span style="background-color:#f8df8c; color:#00CB86; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% elsif value == 'Excellent' %}
    <span style="background-color:#c1ecd4; color:#00ad73; padding:4px 8px; border-radius:4px; font-weight:bold;">{{ value }}</span>
    {% else %}
    {{ value }}
    {% endif %};;
  }

  measure: overall_driving_score {
    type: max
    sql: ${driver_safety_score_100} ;;
  }

  measure: overall_trend_aganist_4_week_average {
    type: string
    sql: ${trend_against_4_wk_avg} ;;
  }

  measure: max_weekly_aggresive_events_per_100_miles {
    type: max
    sql: ${aggressive_ep100_mi} ;;
    value_format_name: decimal_1
  }

  measure: max_weekly_collision_events_per_100_miles {
    type: max
    sql: ${collision_ep100_mi} ;;
    value_format_name: decimal_1
  }

  measure: max_weekly_distraction_events_per_hour {
    type: max
    sql: ${distraction_eph} ;;
    value_format_name: decimal_1
  }

  measure: max_weekly_compliance_events_per_hour {
    type: max
    sql: ${compliance_eph} ;;
    value_format_name: decimal_1
  }

  measure: total_aggressive_events {
    type: max
    sql: ${aggressive_events} ;;
  }

  measure: total_collision_events {
    type: max
    sql: ${collision_events} ;;
  }

  measure: total_distraction_events {
    type: max
    sql: ${distraction_events} ;;
  }

  measure: total_compliance_events {
    type: max
    sql: ${compliance_events} ;;
  }

  # measure: total_rush_hour_events {
  #   type: max
  #   sql: ${rush_hour_events} ;;
  # }

  # measure: weekly_rush_hour_events_percentage {
  #   type: max
  #   sql: ${rush_hour_event_pct} ;;
  # }

  measure: weekly_miles_driven {
    type: max
    sql: ${total_miles_driven} ;;
    value_format_name: decimal_1
  }

  measure: weekly_drive_time {
    type: max
    sql: ${total_drive_time} ;;
    value_format_name: decimal_1
  }

  dimension: driver_band_category_ranking {
    type: string
    sql: case
    when ${overall_driver_band} = 'Excellent' then 1
    when ${overall_driver_band} = 'Good' then 2
    when ${overall_driver_band} = 'Fair' then 3
    when ${overall_driver_band} = 'At Risk' then 4
    when ${overall_driver_band} = 'Critical' then 5
    when ${overall_driver_band} = 'Unclassified' then 5
    else 6
    end
    ;;
  }

  dimension: four_week_trend_ranking {
    type: string
    sql: case
          when ${trend_against_4_wk_avg} = 'Improving' then 1
          when ${trend_against_4_wk_avg} = 'Flat' then 2
          when ${trend_against_4_wk_avg} = 'Worsening' then 3
          when ${trend_against_4_wk_avg} = 'Low Drive Week' then 4
          else 5
          end
          ;;
  }

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Driver"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2227?Driver={{ operator_name._filterable_value | url_encode}}"target="_blank">
    {{rendered_value}} ➔</a></font>;;
  }

  dimension: weeks_critical_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_CRITICAL_LAST_8" ;;
  }

  dimension: weeks_at_risk_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_AT_RISK_LAST_8" ;;
  }

  dimension: risk_level_score_100 {
    type: number
    sql: ${TABLE}."RISK_LEVEL_SCORE_100" ;;
  }

  dimension: risk_level_label {
    type: string
    sql: ${TABLE}."RISK_LEVEL_LABEL" ;;
  }

  dimension: deterioration_score_100 {
    type: number
    sql: ${TABLE}."DETERIORATION_SCORE_100" ;;
  }

  dimension: deterioration_label {
    type: string
    sql: ${TABLE}."DETERIORATION_LABEL" ;;
  }

  dimension: is_two_weeks_ago {
    type: yesno
    sql: ${TABLE}."IS_TWO_WEEKS_AGO" ;;
  }


  set: detail {
    fields: [
        overall_driver_band,
  operator_id,
  operator_name,
  market_name,
  week_start,
  total_drive_time,
  total_miles_driven,
  primary_risk_persona,
  trend_against_4_wk_avg,
  aggressive_events,
  aggressive_ep100_mi,
  collision_events,
  collision_ep100_mi,
  distraction_events,
  distraction_eph,
  compliance_events,
  compliance_eph,
  primary_contributing_event,
  secondary_contributing_event
    ]
  }

  set: email_coaching_drill {
    fields: [
      operator_name,
      drivers.operator_email,
      market_name,
      total_drive_time,
      total_miles_driven,
      overall_driver_band,
      primary_risk_persona,
      trend_against_4_wk_avg,
      primary_contributing_event
    ]
  }
}
