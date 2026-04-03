# The name of this view in Looker is "Engineering Shortcut Stories"
view: engineering_shortcut_stories {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "GS"."ENGINEERING_SHORTCUT_STORIES";;
  drill_fields: [id, name, card_type, labels, card_link, completed_at]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called " Row" in Explore.

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total__row {
    type: sum
    sql: ${_row} ;;
  }

  measure: average__row {
    type: average
    sql: ${_row} ;;
  }

  dimension: is_roadmap {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'roadmap') ;;
  }

  dimension: is_xteam_unplanned {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'xteam_unplanned') ;;
  }

  dimension: is_xteam_planned {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'xteam_planned') ;;
  }

  dimension: is_unplanned {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'unplanned') ;;
  }

  dimension: is_dependency_defect {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'dependency_defect') ;;
  }

  dimension: is_tech_debt {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'techdebt') ;;
  }

  dimension: is_feature_xteam_unplanned {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'xteam_unplanned') AND ${TABLE}."TYPE" = 'feature' ;;
  }

  dimension: is_bug_xteam_unplanned {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'xteam_unplanned') AND ${TABLE}."TYPE" = 'bug' ;;
  }

  dimension: completed_week_of_year {
    type:  date
    sql:   DATE_TRUNC(week, TO_TIMESTAMP(${TABLE}."COMPLETED_AT", 'YYYY/MM/DD HH:MI:SS'));;
  }

  dimension: created_week_of_year {
    type:  date
    sql:   DATE_TRUNC(week, TO_TIMESTAMP(${TABLE}."CREATED_AT", 'YYYY/MM/DD HH:MI:SS'));;
  }

  # dimension: card_type_old {
  #   type:  string
  #   sql:
  #     case(
  #       when(${is_xteam_planned}, 'FEATURE_XTEAM_PLANNED'),
  #       when(${is_feature_xteam_unplanned}, 'FEATURE_XTEAM_UNPLANNED'),
  #       when(${is_unplanned}, 'BUG_UNPLANNED'),
  #       when(${is_bug_xteam_unplanned}, 'BUG_XTEAM_UNPLANNED'),
  #       when(${is_dependency_defect}, 'BUG_DEPENDENCY_DEFECT'),
  #       when(${is_tech_debt}, 'CHORE_TECHDEBT'),
  #       when(${is_roadmap}, 'FEATURE_ROADMAP'),
  #       'UNKNOWN'
  #     );;
  # }

  dimension: card_type{
    case: {
      when: {
        sql: ${is_roadmap} ;;
        label: "FEATURE_ROADMAP"
      }
      when: {
        sql: ${is_xteam_planned};;
        label: "FEATURE_XTEAM_PLANNED"
      }
      when: {
        sql:  ${is_feature_xteam_unplanned} ;;
        label: "FEATURE_XTEAM_UNPLANNED"
      }
      when: {
        sql:${is_unplanned} ;;
        label: "BUG_UNPLANNED"
      }
      when: {
        sql: ${is_bug_xteam_unplanned} ;;
        label: "BUG_XTEAM_UNPLANNED"
      }
      when: {
        sql: ${is_dependency_defect} ;;
        label: "BUG_DEPENDENCY_DEFECT"
      }
      when: {
        sql: ${is_tech_debt} ;;
        label: "CHORE_TECHDEBT"
      }
      else: "UNLABELED"
    }
  }

  dimension: card_link {
    type:  string
    sql: CONCAT('https://app.shortcut.com/equipmentshare/story/', ${id});;
    html: <a href="{{rendered_value}}">{{rendered_value}}</a> ;;
  }

  dimension: completed_at {
    type: date
    sql: TO_TIMESTAMP(${TABLE}."COMPLETED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  # dimension: completed_at_2 {
  #   type: time
  #   sql: TO_TIMESTAMP(${TABLE}."COMPLETED_AT", 'YYYY/MM/DD HH:MI:SS');;
  # }

  dimension_group: completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."COMPLETED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."CREATED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: cycle_time {
    type: number
    sql:  DATEDIFF(day, ${started_at}, ${completed_at});;
  }

  dimension: total_time {
    type: number
    sql: TRUNC((TIMEDIFF(hour, ${created_at}, ${completed_at}) / 24), 0);;
  }

  dimension: created_at {
    type: date
    sql: TO_TIMESTAMP(${TABLE}."CREATED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: due_date{
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."DUE_DATE", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: epic {
    type: string
    sql: ${TABLE}."EPIC" ;;
  }

  dimension: epic_created_at {
    type: string
    sql: ${TABLE}."EPIC_CREATED_AT" ;;
  }

  dimension: epic_due_date {
    type: string
    sql: ${TABLE}."EPIC_DUE_DATE" ;;
  }

  dimension: epic_id {
    type: number
    sql: ${TABLE}."EPIC_ID" ;;
  }

  dimension: epic_is_archived {
    type: yesno
    sql: ${TABLE}."EPIC_IS_ARCHIVED" ;;
  }

  dimension: epic_labels {
    type: string
    sql: ${TABLE}."EPIC_LABELS" ;;
  }

  dimension: epic_planned_start_date {
    type: string
    sql: ${TABLE}."EPIC_PLANNED_START_DATE" ;;
  }

  dimension_group: epic_started_at {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."EPIC_STARTED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: epic_state {
    type: string
    sql: ${TABLE}."EPIC_STATE" ;;
  }

  dimension: estimate {
    type: number
    sql: ${TABLE}."ESTIMATE" ;;
  }

  dimension: external_ticket_count {
    type: number
    sql: ${TABLE}."EXTERNAL_TICKET_COUNT" ;;
  }

  dimension: external_tickets {
    type: string
    sql: ${TABLE}."EXTERNAL_TICKETS" ;;
  }

  dimension: is_a_blocker {
    type: yesno
    sql: ${TABLE}."IS_A_BLOCKER" ;;
  }

  dimension: is_archived {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED" ;;
  }

  dimension: is_blocked {
    type: yesno
    sql: ${TABLE}."IS_BLOCKED" ;;
  }

  dimension: is_completed {
    type: yesno
    sql: ${TABLE}."IS_COMPLETED" ;;
  }

  dimension: iteration {
    type: string
    sql: ${TABLE}."ITERATION" ;;
  }

  dimension: iteration_id {
    type: number
    sql: ${TABLE}."ITERATION_ID" ;;
  }

  dimension: labels {
    type: string
    sql: ${TABLE}."LABELS" ;;
  }

  dimension: milestone {
    type: string
    sql: ${TABLE}."MILESTONE" ;;
  }

  dimension: milestone_categories {
    type: string
    sql: ${TABLE}."MILESTONE_CATEGORIES" ;;
  }

  dimension: milestone_created_at {
    type: string
    sql: ${TABLE}."MILESTONE_CREATED_AT" ;;
  }

  dimension: milestone_due_date {
    type: string
    sql: ${TABLE}."MILESTONE_DUE_DATE" ;;
  }

  dimension: milestone_id {
    type: number
    sql: ${TABLE}."MILESTONE_ID" ;;
  }

  dimension: milestone_started_at {
    type: string
    sql: ${TABLE}."MILESTONE_STARTED_AT" ;;
  }

  dimension: milestone_state {
    type: string
    sql: ${TABLE}."MILESTONE_STATE" ;;
  }

  dimension: moved_at {
    type: string
    sql: ${TABLE}."MOVED_AT" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: owners {
    type: string
    sql: ${TABLE}."OWNERS" ;;
  }

  dimension: project {
    type: string
    sql: ${TABLE}."PROJECT" ;;
  }

  dimension: project_id {
    type: number
    sql: ${TABLE}."PROJECT_ID" ;;
  }

  dimension: requester {
    type: string
    sql: ${TABLE}."REQUESTER" ;;
  }

  dimension: started_at {
    type: string
    sql: TO_TIMESTAMP(${TABLE}."STARTED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension_group: started_at {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."STARTED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: tasks {
    type: string
    sql: ${TABLE}."TASKS" ;;
  }

  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }

  dimension: team_id {
    type: string
    sql: ${TABLE}."TEAM_ID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension_group: updated_at {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TO_TIMESTAMP(${TABLE}."UPDATED_AT", 'YYYY/MM/DD HH:MI:SS');;
  }

  dimension: utc_offset {
    type: string
    sql: ${TABLE}."UTC_OFFSET" ;;
  }

  dimension: workflow {
    type: string
    sql: ${TABLE}."WORKFLOW" ;;
  }

  dimension: workflow_id {
    type: number
    sql: ${TABLE}."WORKFLOW_ID" ;;
  }

  dimension: raw_severity {
    type:  string
    sql: ${TABLE}."SEVERITY" ;;
  }

  dimension: custom_fields {
    type:  string
    sql: ${TABLE}."CUSTOM_FIELDS" ;;
  }

  dimension: priority {
    type:  string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: severity{
    case: {
      when: {
        sql: ${raw_severity} = 'Critical';;
        label: "CRITICAL"
      }
      when: {
        sql: ${raw_severity} =  'High';;
        label: "HIGH"
      }
      when: {
        sql: ${raw_severity} =  'Medium';;
        label: "MEDIUM"
      }
      when: {
        sql: ${raw_severity} =  'Low';;
        label: "LOW"
      }
      when: {
        sql: ${raw_severity} =  'Cosmetic';;
        label: "COSMETIC"
      }
      when: {
        sql: ${raw_severity} =  'Closed - See Label';;
        label: "CLOSED - SEE LABEL"
      }
      # when: {
      #   sql: contains(${TABLE}."LABELS", 'Working as Intended');;
      #   label: "WORKING AS INTENDED"
      # }
      # when: {
      #   sql: contains(${TABLE}."LABELS", 'Feature Request');;
      #   label: "FEATURE REQUEST"
      # }
      else: "UNLABELED"
    }
  }

  # The below are Continuing Operations specific dimensions

  dimension: is_co {
    type:  yesno
    sql:  ${workflow_id} = 500039147;;
  }

  dimension: is_co_roadmap {
    type:  yesno
    sql:  ${workflow_id} = 500039155;;
  }

###
# Sources
###

  dimension: co_is_assets {
    type: yesno
    hidden: yes
    sql: (contains(${TABLE}."LABELS", 'Assets') and not contains(${TABLE}."LABELS", 'Fleet-')) ;;
  }

  dimension: co_is_fleet {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet') ;;
  }

  dimension: co_is_work_orders {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Work Orders') ;;
  }

  dimension: co_is_inventory {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Inventory') ;;
  }

  dimension: co_is_billing {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Billing') ;;
  }

  dimension: co_is_analytics {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Analytics') ;;
  }

  dimension: co_is_rentops {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'RentOps') OR contains(${TABLE}."LABELS", 'RentalOps') ;;
  }

  dimension: co_is_deliver_app {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Deliver App') ;;
  }
  dimension: co_is_elogs {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs');;
  }

  dimension: co_is_link {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link') ;;
  }

  dimension: co_is_quotes {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Quotes') ;;
  }

  dimension: co_is_cost_capture {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'CostCapture') ;;
  }

  dimension: co_is_admin {
    type: yesno
    hidden: yes
    sql: (contains(${TABLE}."LABELS", 'Admin') and not contains(${TABLE}."LABELS", '-Admin')) ;;
  }

  dimension: co_is_rent_mobile {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Rent Mobile') ;;
  }

  dimension: co_is_t3 {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'T3') ;;
  }

  dimension: co_is_time_tracking {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Time Tracking') ;;
  }

  dimension: co_is_telematics {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Telematics') OR contains(${TABLE}."LABELS", 'TELEMATICS');;
  }

  dimension: co_is_market_set_up {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Market Set Up') ;;
  }

  dimension: surface {
    type: string
    #This is extracting everything after 'Surface=' but before the next ';' then removing the word 'Surface='
    sql: replace(regexp_substr(${custom_fields}, 'Surface=[^;]*'), 'Surface=') ;;
  }



  dimension: co_source {
    case: {
      when: {
        sql: ${co_is_admin};;
        label: "Admin"
      }
      when: {
        sql: ${co_is_analytics};;
        label: "Analytics"
      }
      when: {
        sql: ${co_is_billing};;
        label: "Billing"
      }
      when: {
        sql: ${co_is_market_set_up};;
        label: "Chore - Market Setup"
      }
      when: {
        sql: ${co_is_cost_capture};;
        label: "CostCapture"
      }
      when: {
        sql: ${co_is_deliver_app};;
        label: "Deliver App"
      }
      when: {
        sql: ${co_is_elogs};;
        label: "Elogs"
      }
      when: {
        sql: ${co_is_fleet};;
        label: "Fleet"
      }
      when: {
        sql: ${co_is_inventory};;
        label: "Inventory"
      }
      when: {
        sql: ${co_is_link};;
        label: "Link"
      }
      when: {
        sql: ${co_is_quotes};;
        label: "Quotes"
      }
      when: {
        sql: ${co_is_rent_mobile};;
        label: "Rent Mobile"
      }
      when: {
        sql: ${co_is_rentops};;
        label: "RentOps"
      }
      when: {
        sql: ${co_is_t3};;
        label: "T3"
      }
      when: {
        sql: ${co_is_telematics};;
        label: "Telematics"
      }
      when: {
        sql: ${co_is_time_tracking};;
        label: "Time Tracking"
      }
      when: {
        sql: ${co_is_work_orders};;
        label: "Work Orders"
      }
      else: "UNKNOWN"
    }
  }

###
#sub-products
###
  dimension: co_is_admin_asset_management {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Admin-Asset Management') ;;
  }

  dimension: co_is_admin_rentals_branch_configuration {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Admin-Rentals-Branch Configuration') ;;

  }
  dimension: co_is_admin_rentals_operations {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Admin-Rentals-Operations') OR contains(${TABLE}."LABELS", 'Admin - Rentals Operations') ;;
  }

  dimension: co_is_admin_rentals_contracts {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Admin-Rentals-Contracts') ;;
  }

# dimension: co_is_admin_rentals_delivery_app {
#    type: yesno
#    hidden: yes
#    sql: contains(${TABLE}."LABELS", 'Admin-Rentals-Deliver App') ;;
#  }

  dimension: co_is_assets_trips_processor {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Assets-Trips Processor') ;;
  }

  dimension: co_is_elogs_account_management {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-Account Management') ;;
  }

  dimension: co_is_elogs_aep {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-AEP') ;;
  }

  dimension: co_is_elogs_batch {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-Batch') ;;
  }

  dimension: co_is_elogs_compliance {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-Compliance') ;;
  }

  dimension: co_is_elogs_mobile {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-Mobile') ;;
  }

  dimension: co_is_elogs_web {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Elogs-Web') ;;
  }

  dimension: co_is_fleet_alerts {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Alerts') ;;
  }

  dimension: co_is_fleet_account_management {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Account Management') ;;
  }

  dimension: co_is_fleet_assets {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Assets') ;;
  }

  dimension: co_is_fleet_branch_admin {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Branch-Admin') ;;
  }

  dimension: co_is_fleet_cam {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Cam') ;;
  }

  dimension: co_is_fleet_inventory {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Inventory') ;;
  }

  dimension: co_is_fleet_integrations_milwaukee {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Integrations-Milwaukee') ;;
  }

  dimension: co_is_fleet_internal_rentals {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Internal Rentals') ;;
  }

  dimension: co_is_fleet_keypads {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Keypads') ;;
  }

  dimension: co_is_fleet_rentals {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Fleet-Rentals') ;;
  }

  dimension: co_is_inventory_catalog {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Inventory-Catalog') ;;
  }

  dimension: co_is_link_assets {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link-Assets') ;;
  }

  dimension: co_is_link_elogs {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link-Elogs') ;;
  }

  dimension: co_is_link_global {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link-Global') ;;
  }
  dimension: co_is_link_timecards {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link-TimeCards') ;;
  }

  dimension: co_is_link_workorders {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Link-WorkOrders') ;;
  }

  dimension: co_is_rentops_billing {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'RentOps-Billing') ;;
  }

  dimension: co_is_rentmobile_rental_contracts {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Rent Mobile-Rentals-Contracts') ;;
  }
  dimension: co_is_rentmobile_global {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Rent Mobile-Global') ;;
  }

  dimension: co_is_t3_user_settings {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'T3-User Settings') ;;
  }

  dimension: co_is_telematics_keypads {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Telematics-Keypads') ;;
  }

  dimension: co_is_time_tracking_api {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Time Tracking-API') ;;
  }

  dimension: co_is_time_tracking_etl {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Time Tracking-ETL') ;;
  }

  dimension: co_is_time_tracking_infrastructure {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Time Tracking-Infrastructure') ;;
  }

  dimension: co_is_time_tracking_web {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Time Tracking-Web') ;;
  }

  dimension: co_product_sub_area {
    case: {
      when: {
        sql: ${co_is_admin_asset_management};;
        label: "Admin-Asset Management"
      }
      when: {
        sql: ${co_is_admin_rentals_branch_configuration};;
        label: "Admin-Rentals-Branch Configuration"
      }
      when: {
        sql: ${co_is_admin_rentals_operations};;
        label: "Admin-Rentals-Operations"
      }
      when: {
        sql: ${co_is_admin_rentals_contracts};;
        label: "Admin-Rentals-Contracts"
      }
      when: {
        sql: ${co_is_deliver_app};;
        label: "Deliver App"
      }
      when: {
        sql: ${co_is_elogs_account_management};;
        label: "Elogs-Account Management"
      }
      when: {
        sql: ${co_is_elogs_aep};;
        label: "Elogs-AEP"
      }
      when: {
        sql: ${co_is_elogs_batch};;
        label: "Elogs-Batch"
      }
      when: {
        sql: ${co_is_elogs_compliance};;
        label: "Elogs-Compliance"
      }
      when: {
        sql: ${co_is_elogs_mobile};;
        label: "Elogs-Mobile"
      }
      when: {
        sql: ${co_is_elogs_web};;
        label: "Elogs-Web"
      }
      when: {
        sql: ${co_is_fleet_account_management};;
        label: "Fleet-Account Management"
      }
      when: {
        sql: ${co_is_fleet_alerts};;
        label: "Fleet-Alerts"
      }
      when: {
        sql: ${co_is_fleet_assets};;
        label: "Fleet-Assets"
      }
      when: {
        sql: ${co_is_fleet_branch_admin};;
        label: "Fleet-Branch-Admin"
      }
      when: {
        sql: ${co_is_fleet_cam};;
        label: "Fleet-Cam"
      }
      when: {
        sql: ${co_is_fleet_integrations_milwaukee};;
        label: "Fleet-Integrations-Milwaukee"
      }
      when: {
        sql: ${co_is_fleet_internal_rentals};;
        label: "Fleet-Internal Rentals"
      }
      when: {
        sql: ${co_is_fleet_keypads};;
        label: "Fleet-Keypads"
      }
      when: {
        sql: ${co_is_fleet_rentals};;
        label: "Fleet-Rentals"
      }
      when: {
        sql: ${co_is_inventory_catalog};;
        label: "Inventory-Catalog"
      }
      when: {
        sql: ${co_is_link_assets};;
        label: "Link-Assets"
      }
      when: {
        sql: ${co_is_link_global};;
        label: "Link-Global"
      }
      when: {
        sql: ${co_is_link_elogs};;
        label: "Link-Elogs"
      }
      when: {
        sql: ${co_is_link_timecards};;
        label: "Link-TimeCards"
      }
      when: {
        sql: ${co_is_link_workorders};;
        label: "Link-WorkOrders"
      }
      when: {
        sql: ${co_is_rentops_billing};;
        label: "RentOps-Billing"
      }
      when: {
        sql: ${co_is_rentmobile_rental_contracts};;
        label: "Rent Mobile-Rentals-Contracts"
      }
      when: {
        sql: ${co_is_rentmobile_global};;
        label: "Rent Mobile-Global"
      }
      when: {
        sql: ${co_is_t3_user_settings};;
        label: "T3-User Settings"
      }
      when: {
        sql: ${co_is_telematics_keypads};;
        label: "Telematics-Keypads"
      }
      when: {
        sql: ${co_is_time_tracking_api};;
        label: "Time Tracking-API"
      }
      when: {
        sql: ${co_is_time_tracking_etl};;
        label: "Time Tracking-ETL"
      }
      when: {
        sql: ${co_is_time_tracking_infrastructure};;
        label: "Time Tracking-Infrastructure"
      }
      when: {
        sql: ${co_is_time_tracking_web};;
        label: "Time Tracking-Web"
      }
      else: "UNKNOWN"
    }
  }

###
# Work Categories
###

  dimension: co_is_feature_request {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Feature Requests') OR contains(${TABLE}."LABELS", 'Feature Request') ;;
  }

  dimension: co_is_legacy_team_chore {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Legacy Team Chore') ;;
  }

  dimension: co_is_maintenance {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Maintenance') ;;
  }

  dimension: co_is_special_project{
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Special Project') ;;
  }

  dimension: co_work_category {
    case: {
      when: {
        sql: ${co_is_feature_request};;
        label: "Feature Request"
      }
      when: {
        sql: ${co_is_legacy_team_chore};;
        label: "Legacy Team Chore"
      }
      when: {
        sql: ${co_is_maintenance};;
        label: "Maintenance"
      }
      when: {
        sql: ${co_is_special_project};;
        label: "Special Project"
      }
      else: "UNKNOWN"
    }
  }

###
# Closed Reasons
###

  dimension: co_is_capability_exists {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Capability Exists') ;;
  }

  dimension: co_is_duplicate {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Duplicate') ;;
  }

  dimension: co_is_wont_fix {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Not Planning To Address') ;;
  }

  dimension: co_is_cant_reproduce {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Unable to Reproduce') ;;
  }

  dimension: co_is_workaround_available {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Workaround Available') ;;
  }

  dimension: co_is_working_as_attended {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Working As Intended') ;;
  }

  dimension: co_closed_reason {
    case: {
      when: {
        sql: ${co_is_capability_exists};;
        label: "Capability Exists"
      }
      when: {
        sql: ${co_is_duplicate};;
        label: "Duplicate"
      }
      when: {
        sql: ${co_is_wont_fix};;
        label: "Won't Fix"
      }
      when: {
        sql: ${co_is_cant_reproduce};;
        label: "Can't Reproduce"
      }
      when: {
        sql: ${co_is_workaround_available};;
        label: "Workaround Available"
      }
      when: {
        sql: ${co_is_working_as_attended};;
        label: "Working as Intended"
      }
      else: "UNKNOWN"
    }
  }

###
# Drivers
###
  dimension: co_is_ac_miss {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'AC Miss') ;;
  }

  dimension: co_is_chore_automation {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Chore Automation') ;;
  }

  dimension: co_is_documentation {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Documentation') ;;
  }

  dimension: co_is_downstream_impact {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Downstream Impact') ;;
  }

  dimension: co_is_escalation_outside_co {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Escalation Outside CO') ;;
  }

  dimension: co_is_manual_data_fix {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'Manual Data Fix') ;;
  }

  dimension: co_is_missing_feature {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'Missing Feature') ;;
  }

  dimension: co_is_co_identified_feature {
    type: yesno
    sql: contains(${TABLE}."LABELS", 'CO Identified Feature') ;;
  }
  dimension: co_is_outage {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Outage') ;;
  }

  dimension: co_is_paired {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Paired') ;;
  }

  dimension: co_is_test_escape{
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Test Escape') ;;
  }

  dimension: co_is_technical_investigation {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Technical Investigation') ;;
  }

  dimension: co_is_technical_upgrade {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'Technical Upgrade') ;;
  }

  dimension: co_is_white_glove_treatment {
    type: yesno
    hidden: yes
    sql: contains(${TABLE}."LABELS", 'White Glove Treatment') ;;
  }


  dimension: co_Driver {
    case: {
      when: {
        sql: ${co_is_ac_miss};;
        label: "AC Miss"
      }
      when: {
        sql: ${co_is_chore_automation};;
        label: "Chore Automation"
      }
      when: {
        sql: ${co_is_documentation};;
        label: "Documentation"
      }
      when: {
        sql: ${co_is_downstream_impact};;
        label: "Downstream Impact"
      }
      when: {
        sql: ${co_is_escalation_outside_co};;
        label: "Escalation Outside CO"
      }
      when: {
        sql: ${co_is_legacy_team_chore};;
        label: "Legacy Team Chore"
      }
      when: {
        sql: ${co_is_manual_data_fix};;
        label: "Manual Data Fix"
      }
      when: {
        sql: ${co_is_missing_feature};;
        label: "Missing Feature"
      }
      when: {
        sql: ${co_is_co_identified_feature};;
        label: "CO Identified Feature"
      }
      when: {
        sql: ${co_is_outage};;
        label: "Outage"
      }
      when: {
        sql: ${co_is_test_escape};;
        label: "Test Escape"
      }
      when: {
        sql: ${co_is_technical_investigation};;
        label: "Technical Investigation"
      }
      when: {
        sql: ${co_is_technical_upgrade};;
        label: "Technical Upgrade"
      }
      when: {
        sql: ${co_is_white_glove_treatment};;
        label: "White Glove Treatment"
      }
      else: "UNKNOWN"
    }
  }

  measure: count {
    type: count
    drill_fields: [id, name, team, priority,  state, surface, card_type, labels, card_link]
  }

  measure: avg_total_time {
    type: average
    sql_distinct_key: ${TABLE}."ID" ;;
    sql: ${total_time} ;;
  }
}
