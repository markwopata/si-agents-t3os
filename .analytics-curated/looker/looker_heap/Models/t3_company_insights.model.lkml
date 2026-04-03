connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/*.view.lkml"
include: "/views/t3_company_insights/*view.lkml"
include: "/views/ES_WAREHOUSE/*view.lkml"
include: "/views/VIP_Customer_Initiative/*view.lkml"
include: "/views/t3_company_insights/*view.lkml"
include: "/views/mission_yellow_metrics/*view.lkml"
include: "/heap_export/*view.lkml"


datagroup: heap_monthly {
  label: "Heap Monthly Freshness"
  sql_trigger: SELECT MAX(ENGAGEMENT_MONTH) FROM ANALYTICS.T3_ANALYTICS.FCT_MONTHLY_COMPANY_ENGAGEMENT ;;
  max_cache_age: "36 hours"
}


datagroup: engagement_tier_monthly {
  label: "Engagement Tier (Monthly)"
  sql_trigger: SELECT MAX(MONTH) FROM ANALYTICS.T3_ANALYTICS.ENGAGEMENT_TIER_MONTHLY_GROUP_T12M ;;
  max_cache_age: "36 hours"
}



explore: t3_subs {
  group_label: "T3 Company_insights"
  label: "T3 Subscription Companies"
  view_name: t3_subs

  join: hubspot_t3_customers {
    type: inner
    relationship: many_to_one
    sql_on: ${t3_subs.company_id} = ${hubspot_t3_customers.company_id} ;;
  }
}

explore: fct_monthly_company_engagement {
  label: "Engagement — Company (Monthly)"
  group_label: "Engagement & Cohorts"
  description: "One row per company-month with precomputed engagement KPIs."
  #persist_with: heap_monthly
  #always_filter: { filters: [fct_monthly_company_engagement.engagement_month_date: "24 months"] }
}


explore: vw_monthly_company_cohort_activity {
  label: "Cohort Activity — Company (Monthly)"
  group_label: "Engagement & Cohorts"
  description: "Cohort/health flags plus monthly engagement metrics."
  #persist_with: heap_monthly
  #always_filter: { filters: [vw_monthly_company_cohort_activity.report_month_date: "24 months"] }
}


explore: engagement_tier_monthly_group_t12m {
  label: "Engagement Tiers — Group (T12M)"
  group_label: "Engagement & Cohorts"
  description: "Sticky monthly engagement scores & tiers at group level."
  #persist_with: engagement_tier_monthly
  #always_filter: { filters: [engagement_tier_monthly_group_t12m.month_date: "12 months"] }
}





explore: monthly_rental_and_sub_revenue {
  group_label: "T3 Company Insights"
  label: "T3 Revenue"
  view_name: monthly_rental_and_sub_revenue

  join: monthly_company_engagement {
    type: left_outer
    relationship: one_to_one
    sql_on: ${monthly_rental_and_sub_revenue.uid} = ${monthly_company_engagement.uid} ;;
  }

  #join: company_reltationships_and_industry {
  #  type: inner
  #  relationship: many_to_one
  #  sql_on: ${monthly_rental_and_sub_revenue.company_id} = ${company_reltationships_and_industry.company_id} ;;
  #}

  join: vip_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${monthly_rental_and_sub_revenue.company_id} = ${vip_companies.company_id} ;;
  }

  join: t3_subs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${monthly_rental_and_sub_revenue.company_id} = ${t3_subs.company_id}and ${monthly_rental_and_sub_revenue.invoice_month_month} = ${t3_subs.invoiced_month_month};;
  }

  join: hubspot_t3_customers {
    type: inner
    relationship: many_to_one
    sql_on: ${monthly_company_engagement.company_id} = ${hubspot_t3_customers.company_id} ;;
  }

}

explore: t3_subs_monthly {
  group_label: "T3 Company Insights"
  label: "T3 Monthly Subscriptions"
  view_name:  t3_subs_monthly
}

explore: tracked_assets_by_day {
  group_label: "T3 Company Insights"
  label: "T3 Asset Tracking"
  view_name:  tracked_assets_by_day

  join: hubspot_t3_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracked_assets_by_day.company_id} = ${hubspot_t3_customers.company_id} ;;
  }

}

explore: company_cohort {
  group_label: "T3 Company Insights"
  label: "Company Cohort Tracker"
  description: "Explore the company cohort tracker metrics."
  view_name: company_cohort

   join: hubspot_t3_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_cohort.company_id} = ${hubspot_t3_customers.company_id} ;;
  }

  join: monthly_company_engagement {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_cohort.uid} = ${monthly_company_engagement.uid} ;;
  }

  join: monthly_rental_and_sub_revenue {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_cohort.uid} = ${monthly_rental_and_sub_revenue.uid} ;;
  }

  join: vip_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_cohort.company_id} = ${vip_companies.company_id};;
  }


}

explore: monthly_company_cohort_stats {
  group_label: "T3 Company Insights"
  label: "Company Cohort Tracker (Monthly)"
  description: "Explore the company cohort tracker metrics by month."
  view_name: monthly_company_cohort_stats
}


explore: user_engagement {
  group_label: "T3 Company Insights"
  label: "T3 User Engagement"
  description: "Explore the T3 user engagment monthly."
  view_name: user_engagement

  join: t3_subs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_engagement.company_id} = ${t3_subs.company_id} ;;
  }

  join: vip_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_engagement.company_id} = ${vip_companies.company_id} ;;
  }

  join: monthly_rental_and_sub_revenue {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_engagement.uid} = ${monthly_rental_and_sub_revenue.uid} ;;
  }
  join: hubspot_t3_customers {
    type: inner
    relationship: many_to_one
    sql_on: ${user_engagement.company_id} = ${hubspot_t3_customers.company_id} ;;
  }

}

explore: hubspot_t3_customers {
  group_label: "T3 Company Insights"
  label: "T3 Customers in Hubspot"
  description: "High level account hubspot data for companies that have a tag of current t3 customer in hubspot"
  view_name: hubspot_t3_customers

}

explore: intercom_conversations{
  group_label: "T3 Company Insights"
  label: "Intercom Cnversations"
  description: "Intercom stats by company/user to give insight into topic, user reporting the issue and issues within Intercom conversations."
  view_name: intercom_conversations

  join: t3_subs {
    type: left_outer
    relationship: many_to_many
    sql_on: ${intercom_conversations.company_id} = ${t3_subs.company_id};;
  }

  join: vip_companies {
    type: left_outer
    relationship: many_to_many
    sql_on: ${intercom_conversations.company_id} = ${vip_companies.company_id} ;;
  }

  join: hubspot_t3_customers {
    type: inner
    relationship: many_to_one
    sql_on: ${intercom_conversations.company_id} = ${hubspot_t3_customers.company_id} ;;
  }
}

explore: vip_feature_requests{
  group_label: "T3 Company Insights"
  label: "VIP Customer Feature Requests"
  description: "Feature requests and defect reported by VIP customers in addition to shortcut priority and progress."
  view_name: vip_feature_requests

  join: hubspot_t3_customers {
    type: inner
    relationship: many_to_one
    sql_on: ${vip_feature_requests.company_id} = ${hubspot_t3_customers.company_id} ;;
    }
}

explore: monthly_company_engagement {
  group_label:  "T3 Company Insights"
  label: "Monthly Company Engagement"
  view_name: monthly_company_engagement

  join: monthly_rental_and_sub_revenue {
    type: left_outer
    relationship: one_to_one
    sql_on: ${monthly_company_engagement.uid} = ${monthly_rental_and_sub_revenue.uid};;
  }
  join: t3_subs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${monthly_company_engagement.company_id} = ${t3_subs.company_id}and ${monthly_company_engagement.month_month} = ${t3_subs.invoiced_month_month} and ${monthly_rental_and_sub_revenue.invoice_month_month} = ${t3_subs.invoiced_month_month};;
  }

  join: company_cohort {
    type: left_outer
    relationship:one_to_one
    sql_on: ${monthly_company_engagement.uid} = ${company_cohort.uid} ;;
  }

  join: vip_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${monthly_company_engagement.company_id} = ${vip_companies.company_id} ;;
  }
  join: hubspot_t3_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${monthly_company_engagement.company_id} = ${hubspot_t3_customers.company_id} ;;
  }

}

explore: vip_companies {
  group_label: "T3 VIP Company Insights"
  label: "VIP Companies"
  description: "Explore the VIP company insights."
  view_name: vip_companies

  join: company_cohort {
    type: left_outer
    relationship:one_to_many
    sql_on: ${vip_companies.company_id} = ${company_cohort.company_id} ;;
  }


  join: monthly_company_engagement {
    type: left_outer
    relationship: one_to_many
    sql_on: ${vip_companies.company_id} = ${monthly_company_engagement.company_id}
      and ${monthly_company_engagement.uid} = ${company_cohort.uid} ;;
  }
}
explore: user_page_stats {
  group_label: "T3 Page Insights"
  label: "User Page Stats."
  view_name: user_page_stats

  join:  vip_companies {
    type: inner
    relationship: many_to_one
    sql_on: ${user_page_stats.company_id} = ${vip_companies.company_id} ;;
  }
}




explore: heap_data_export {
  group_label: "Heap Product"
  label: "Export Company Data into Heap"
  description: "Used in Heap to support dynamic company segments"
  case_sensitive: no
}

explore: heap_job_title_export {
  group_label: "Heap Product"
  label: "Export User Data into Heap"
  description: "Used in Heap to support dynamic users segments"
  case_sensitive: no
}
