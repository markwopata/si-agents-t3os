# =====================================
# File: engagement_tier_monthly_group_t12m.view.lkml
# =====================================
view: engagement_tier_monthly_group_t12m {
  sql_table_name: ANALYTICS.T3_ANALYTICS.ENGAGEMENT_TIER_MONTHLY_GROUP_T12M ;;
  label: "Engagement Tier (Group, T12M)"
  view_label: "Engagement Tiers (Group)"


  dimension_group: month { label: "Month" type: time timeframes: [raw, date, month, quarter, year] sql: ${TABLE}.MONTH ;; }
  dimension_group: quarter { label: "Quarter" type: time timeframes: [raw, quarter, year] sql: ${TABLE}.QUARTER ;; }
  dimension: group_rollup_id { label: "Group (Rollup) ID" type: number sql: ${TABLE}.GROUP_ROLLUP_ID ;; }
  dimension: company_group_name { label: "Company Group Name" sql: ${TABLE}.COMPANY_GROUP_NAME ;; }
  dimension: engagement_tier_mo { label: "Engagement Tier (Monthly)" sql: ${TABLE}.ENGAGEMENT_TIER_MO ;; }
  dimension: engagement_tier_mo_sticky { label: "Engagement Tier (Sticky)" sql: ${TABLE}.ENGAGEMENT_TIER_MO_STICKY ;; }


  measure: engagement_score_mo { label: "Engagement Score (Monthly)" type: average sql: ${TABLE}.ENGAGEMENT_SCORE_MO ;; }
  measure: engagement_score_mo_sticky { label: "Engagement Score (Sticky)" type: average sql: ${TABLE}.ENGAGEMENT_SCORE_MO_STICKY ;; }
  measure: mau { label: "Active Users (MAU)" type: sum sql: ${TABLE}.MAU ;; }
  measure: total_users { label: "Total Users" type: sum sql: ${TABLE}.TOTAL_USERS ;; }
  measure: monthly_active_sessions { label: "Active Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_SESSIONS ;; }
  measure: monthly_active_t3_sessions { label: "Active T3 Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_T3_SESSIONS ;; }
  measure: rental_billed_revenue { label: "Billed Rental Revenue (Monthly)" type: sum sql: ${TABLE}.RENTAL_BILLED_REVENUE ;; }
  measure: quarterly_billed_revenue { label: "Billed Rental Revenue (Quarterly)" type: sum sql: ${TABLE}.QUARTERLY_RENTAL_BILLED_REVENUE ;; }


  dimension: group_activity_flag {
    label: "Group Activity Flag"
    group_label: "Cohort & Health"
    type: string
    sql: ${TABLE}.GROUP_ACTIVITY_FLAG ;;
  }

  dimension: group_cohort {
    label: "Group Cohort"
    group_label: "Cohort & Health"
    type: string
    sql: ${TABLE}.GROUP_COHORT ;;
  }

  dimension: quarterly_rental_billed_revenue {
    label: "Quarterly Rental Billed Revenue"
    group_label: "Revenue (Gate)"
    type: number
    sql: ${TABLE}.QUARTERLY_RENTAL_BILLED_REVENUE ;;
    value_format_name: usd_0
  }

  measure: groups {
    label: "Groups"
    group_label: "Support Dashboard"
    type: count_distinct
    sql: ${group_rollup_id} ;;
  }

  measure: pct_groups_high_engagement_sticky {
    label: "% Groups High Engagement (Sticky)"
    group_label: "Support Dashboard"
    type: number
    value_format_name: percent_2
    sql: COUNT(DISTINCT CASE WHEN ${TABLE}.ENGAGEMENT_TIER_MO_STICKY = '3 High Engagement'
                             THEN ${TABLE}.GROUP_ROLLUP_ID END)
       / NULLIF(COUNT(DISTINCT ${TABLE}.GROUP_ROLLUP_ID), 0) ;;
  }

  measure: avg_engagement_score_sticky {
    label: "Avg Engagement Score (Sticky)"
    group_label: "Support Dashboard"
    type: average
    sql: ${TABLE}.ENGAGEMENT_SCORE_MO_STICKY ;;
    value_format_name: decimal_2
  }
}
