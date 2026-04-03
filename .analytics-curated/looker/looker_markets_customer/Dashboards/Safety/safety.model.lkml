connection: "es_snowflake"

include: "/Dashboards/Safety/Safety_Observation/safety_observation_responses.view.lkml"
include: "/location_permissions/location_permissions.view.lkml"
include: "/Dashboards/Safety/Safety_Meeting/safety_meeting_union.view.lkml"
include: "/Dashboards/Safety/Safety_Observation/safety_observation_photos.view.lkml"
include: "/views/Business_Intelligence/dim_employees_bi.view.lkml"
include: "/views/Business_Intelligence/dim_users_bi.view.lkml"
include: "/views/Business_Intelligence/fact_safety_observation_details.view.lkml"
include: "/views/Business_Intelligence/fact_safety_observation_photos.view.lkml"
include: "/views/Platform/dim_dates.view.lkml"
include: "/views/Platform/dim_times.view.lkml"
include: "/views/Platform/dim_markets.view.lkml"
include: "/views/ANALYTICS/looker_user_permissions.view.lkml"
include: "/Dashboards/Safety/Safety_Monthly_Reporting/safety_monthly_reporting_amalgamation.view.lkml"

access_grant: safety_champion_exclusion {
  user_attribute: safety_champion
  allowed_values: [ "'no'" ]
}

explore: safety_observation_responses {
  group_label: "Safety Observation"
  case_sensitive: no
  description: "Responses to the safety team's Safety Observation jotform."

  join: safety_observation_photos {
    type: left_outer
    sql_on: ${safety_observation_responses.sor_id} = ${safety_observation_photos.sor_id} ;;
    relationship: one_to_many
  }
}

explore: safety_meeting_union {
  group_label: "Safety Meeting"
  case_sensitive:  no
  description: "Tracks safety meeting attendance, participation metrics, and topic completion rates"
  persist_for: "1 minute"
}


explore: safety_observation {
  group_label: "Safety Observation Rework"
  view_label: "Safety Observation Details"
  from: fact_safety_observation_details
  case_sensitive: no
  description: "Responses to the safety team's Safety Observation jotform."
  sql_always_where:
      CASE
      -- full access
      WHEN {{ _user_attributes['job_role'] }} IN ('safety', 'developer' , 'leadership')
      OR LOWER(${looker_user_permissions.looker_user_employee_title}) = 'regional safety manager'
      OR ${looker_user_permissions.looker_user_dccfp_region} = 'National'
      OR ${looker_user_permissions.looker_user_dccfp_region} = 'Corp'
      THEN TRUE

      -- region access
      WHEN {{ _user_attributes['job_role'] }} IN ('regional_ops', 'regional_service_mgr')
      THEN CAST(${dim_markets.market_region} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_dccfp_region} AS VARCHAR)


      -- district access
      WHEN {{ _user_attributes['job_role'] }} IN ('district_ops', 'district_sales_manager')
      THEN CAST(${dim_markets.market_district} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_dccfp_district} AS VARCHAR)

      -- need to give a GM access to more than one market
      WHEN ${looker_user_permissions.looker_user_employee_id} = 13588 THEN CAST(${dim_markets.market_id} AS VARCHAR) IN
      ('116676', '169657')

      WHEN ${looker_user_permissions.looker_user_employee_id} = 16856 THEN CAST(${dim_markets.market_id} AS VARCHAR) IN
      ('153625','61872','169038')

      -- market access
      WHEN {{ _user_attributes['job_role'] }} IN ('general_mgr', 'service_mgr')
      THEN CAST(${dim_markets.market_id} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_market_id} AS VARCHAR)

      -- hard coded access
      WHEN ${looker_user_permissions.looker_user_employee_id} = 7113 THEN CAST(${dim_markets.market_id} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_market_id} AS VARCHAR)

      WHEN ${looker_user_permissions.looker_user_employee_id} = 17460 THEN CAST(${dim_markets.market_id} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_market_id} AS VARCHAR)

      WHEN ${looker_user_permissions.looker_user_employee_id} = 15653 THEN CAST(${dim_markets.market_id} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_market_id} AS VARCHAR)

      WHEN ${looker_user_permissions.looker_user_employee_id} = 4408 THEN CAST(${dim_markets.market_region} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_dccfp_region} AS VARCHAR)

      WHEN ${looker_user_permissions.looker_user_employee_id} = 460 THEN CAST(${dim_markets.market_region} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_dccfp_region} AS VARCHAR)

      WHEN ${looker_user_permissions.looker_user_employee_id} = 9541 THEN CAST(${dim_markets.market_region} AS VARCHAR) in
      ('Midwest', 'Northeast')

      -- safety champions
      WHEN {{ _user_attributes['safety_champion'] }} = 'yes' THEN CAST(${dim_markets.market_id} AS VARCHAR) =
      CAST(${looker_user_permissions.looker_user_market_id} AS VARCHAR)

      ELSE FALSE
      END;;

    join: fact_safety_observation_photos {
      view_label: "Safety Observation Photos"
      type: left_outer
      sql_on: ${safety_observation.safety_observation_key} = ${fact_safety_observation_photos.safety_observation_key};;
      relationship: one_to_many
    }

    join: dim_times {
      view_label: "Observation Time"
      type: inner
      sql_on: ${safety_observation.safety_observation_observation_time_final_key} = ${dim_times.time_key};;
      relationship: many_to_one
    }

    join: submission_dates {
      from:  dim_dates
      view_label: "Submission Date"
      type: inner
      sql_on: ${safety_observation.safety_observation_submission_date_key} = ${submission_dates.date_key};;
      relationship: many_to_one
    }

    join: observation_date {
      from:  dim_dates
      view_label: "Observation Date"
      type: inner
      sql_on: ${safety_observation.safety_observation_observation_date_final_key} = ${observation_date.date_key};;
      relationship: many_to_one
    }

    join: dim_employees_bi {
      view_label: "Employees"
      type: inner
      sql_on: ${safety_observation.safety_observation_employee_key} = ${dim_employees_bi.employee_key};;
      relationship: one_to_many
    }

    join: dim_markets {
      view_label: "Markets"
      type: inner
      sql_on: ${safety_observation.safety_observation_market_key} = ${dim_markets.market_key};;
      relationship: one_to_many
    }

    join: looker_user_permissions {
      view_label: "Permissions"
      type: left_outer
      relationship: one_to_one
      sql_on: ${looker_user_permissions.looker_user_email_address} = '{{ _user_attributes["email"]}}';;
    }
  }

explore: safety_monthly_reporting_amalgamation {
  case_sensitive:  no
  description: "Gives market-based totals for monthly safety reporting: YTD workplace injuries, total and reportable; YTD at-fault auto accidents; all-time outstanding ESU safety training courses; YTD outstanding safety meeting attendance."
}
