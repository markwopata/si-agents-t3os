view: latest_asset_assignments {
  derived_table: {
    sql: WITH latest_driver_assignments as (
              SELECT *
              FROM analytics.fleetcam.driver_assignments
              QUALIFY ROW_NUMBER() OVER(PARTITION BY asset_id ORDER BY assignment_time desc) = 1
            ),

            latest_trips as (
              SELECT asset_id, CONVERT_TIMEZONE('America/Chicago', start_timestamp) as start_timestamp
              FROM es_warehouse.public.trips
              WHERE start_timestamp > '2024-11-01'::timestamp_ntz
                AND datediff(second, start_timestamp, end_timestamp) >= 1*60 --only trips longer than 1 minutes
              QUALIFY ROW_NUMBER() OVER(PARTITION BY asset_id ORDER BY start_timestamp desc) = 1
            ),

            general_managers as (
              SELECT
                market_id,
                CASE WHEN position(' ', coalesce(nickname, first_name)) = 0
                        THEN concat(coalesce(nickname, first_name), ' ', last_name)
                     ELSE concat(coalesce(nickname, concat(first_name, ' ', last_name)))
                END AS name,
                work_email
              FROM analytics.payroll.company_directory
              WHERE employee_title = 'General Manager'
                AND employee_status IN ('Active', 'Leave without Pay', 'Leave with Pay', 'Military Training Program', 'Work Comp Leave', 'External Payroll')
              QUALIFY ROW_NUMBER() OVER(PARTITION BY market_id ORDER BY date_hired::date) = 1
            )

            SELECT
                afx.es_asset_id,
                CONCAT(a.make, ' ', a.model) as asset_make_model,
                mrx.market_name as inventory_branch,
                mrx.district as inventory_district,
                CONCAT(mrx.region, ' - ', mrx.region_name) as inventory_region,
                gm.name as inventory_branch_gm,
                gm.work_email as gm_email,
                lda.user_id as driver_user_id,
                CONVERT_TIMEZONE('America/Chicago', lda.assignment_time) as assignment_time,
                CONVERT_TIMEZONE('America/Chicago', lda.unassignment_time) as unassignment_time,
                lda.current_assignment,
                lda.operator_id IS NULL as asset_never_assigned,
                t.start_timestamp as latest_trip_start
            FROM analytics.fleetcam.asset_fleetcam_xwalk afx
            JOIN es_warehouse.public.assets a
                ON afx.es_asset_id = a.asset_id
            LEFT JOIN analytics.public.market_region_xwalk mrx
                ON a.inventory_branch_id = mrx.market_id
            LEFT JOIN general_managers gm
                ON a.inventory_branch_id = gm.market_id
            LEFT JOIN latest_driver_assignments lda
                ON afx.es_asset_id = lda.asset_id
            LEFT JOIN latest_trips t
                ON a.asset_id = t.asset_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: es_asset_id {
    label: "Asset ID"
    type: number
    value_format: "0"
    sql: ${TABLE}."ES_ASSET_ID" ;;
    html: <font color="#000000">
      {{rendered_value}}
      <br />
      <font style="color: #8C8C8C; text-align: right;">{{asset_make_model._rendered_value}}</font>
      </font> ;;
  }

  dimension: asset_make_model {
    type: string
    sql: ${TABLE}."ASSET_MAKE_MODEL" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH";;
    html: <font color="#000000">
      {{rendered_value}}
      <br />
      <font style="color: #8C8C8C; text-align: right;">GM: {{inventory_branch_gm._rendered_value}}</font>
      </font> ;;
    link: {
      label: "Email GM"
      url: "mailto:{{gm_email._value}}"
    }
  }

  dimension: inventory_district {
    type: string
    sql: ${TABLE}."INVENTORY_DISTRICT";;
  }

  dimension: inventory_region {
    type: string
    sql: ${TABLE}."INVENTORY_REGION";;
  }

  dimension: inventory_branch_gm {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_GM" ;;
  }

  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_EMAIL" ;;
  }

  dimension: driver_user_id {
    type: number
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }

  dimension: driver {
    type: string
    sql: ${drivers_incl_out_of_program.operator_name} ;;
    html: <font color="#000000">
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{drivers_incl_out_of_program.market_name._rendered_value}}</font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{drivers_incl_out_of_program.employee_title._rendered_value}}</font>
    </font> ;;
  }

  dimension_group: assignment_time {
    type: time
    sql: ${TABLE}."ASSIGNMENT_TIME" ;;
  }

  dimension_group: unassignment_time {
    type: time
    sql: ${TABLE}."UNASSIGNMENT_TIME" ;;
    html: {% if unassignment_time_date._value < latest_trip_start_date._value %}
          <p style="background-color: #FF8E2B; color: #000000; text-align: left;">{{rendered_value}}</p>
          {% else %}
          {{rendered_value}}
          {% endif %}  ;;
  }

  dimension: current_assignment {
    type: yesno
    sql: ${TABLE}."CURRENT_ASSIGNMENT" ;;
  }

  dimension: asset_never_assigned {
    type: yesno
    sql: ${TABLE}."ASSET_NEVER_ASSIGNED" ;;
  }

  dimension_group: latest_trip_start {
    type: time
    sql: ${TABLE}."LATEST_TRIP_START";;
    html: {% if unassignment_time_date._value < latest_trip_start_date._value %}
          <p style="background-color: #FF8E2B; color: #000000; text-align: left;">{{rendered_value}}</p>
          {% else %}
          {{rendered_value}}
          {% endif %}  ;;
  }

  dimension: cdl_asset {
    type: yesno
    sql: ${drivers_incl_out_of_program.employee_title} ilike '%cdl%';;
  }

  dimension: included_asset {
    type: yesno
    sql: ${asset_never_assigned} OR ${drivers_incl_out_of_program.market_in_program} ;;
  }

  dimension: latest_trip_past_unassignment {
    type: yesno
    sql: ${latest_trip_start_date} > ${unassignment_time_date} ;;
  }

  dimension: stale_unassignment {
    type: yesno
    sql: CASE WHEN ${cdl_asset}
                THEN ${unassignment_time_raw} < CONVERT_TIMEZONE('America/Chicago', current_timestamp) - INTERVAL '120 Hours'
              ELSE ${unassignment_time_raw} < CONVERT_TIMEZONE('America/Chicago', current_timestamp) - INTERVAL '168 Hours'
         END;;
  }

  dimension: assignment_needed {
    type: yesno
    sql: ${latest_trip_past_unassignment} OR ${stale_unassignment} ;;
  }

  dimension: recent_unassignment {
    type: yesno
    sql: NOT(${latest_trip_past_unassignment}) AND
        CASE WHEN ${cdl_asset}
                THEN ${unassignment_time_raw} >= CONVERT_TIMEZONE('America/Chicago', current_timestamp) - INTERVAL '120 Hours'
              ELSE ${unassignment_time_raw} >= CONVERT_TIMEZONE('America/Chicago', current_timestamp) - INTERVAL '168 Hours'
         END;;
  }

  dimension: never_assigned_has_trips {
    type: yesno
    sql: ${asset_never_assigned} AND ${latest_trip_start_raw} IS NOT NULL;;
  }

  dimension: never_assigned_no_trips {
    type: yesno
    sql: ${asset_never_assigned} AND ${latest_trip_start_raw} IS NULL;;
  }

  dimension: asset_assignment_group {
    type: string
    sql: CASE WHEN ${current_assignment} THEN 'Currently Assigned'
              WHEN ${assignment_needed} THEN 'Assignment Needed?'
              WHEN ${recent_unassignment} THEN 'Recently Unassigned'
              WHEN ${never_assigned_has_trips} THEN 'Never Assigned\; Has Trips'
              WHEN ${never_assigned_no_trips} THEN 'Never Assigned\; No Trips'
         END;;
    html:
      {% if current_assignment._rendered_value == 'Yes' %}
      <p style="background-color: #3c91e6; color: #ffffff; text-align: center;">{{rendered_value}}</p>
      {% elsif assignment_needed._rendered_value == 'Yes' %}
      <p style="background-color: #FF8E2B; color: #000000; text-align: center;">{{rendered_value}}</p>
      {% elsif recent_unassignment._rendered_value == 'Yes' %}
      <p style="background-color: #56d4b8; color: #000000; text-align: center;">{{rendered_value}}</p>
      {% elsif never_assigned_has_trips._rendered_value == 'Yes' %}
      <p style="background-color: #ffbd87; color: #000000; text-align: center;">{{rendered_value}}</p>
      {% elsif never_assigned_no_trips._rendered_value == 'Yes' %}
      <p style="background-color: #95e3cf; color: #000000; text-align: center;">{{rendered_value}}</p>
      {% endif %};;
    # {% elsif stale_unassignment._rendered_value == 'Yes' %}
    # <p style="background-color: #00b9df; color: #ffffff; text-align: center;">{{rendered_value}}</p>
  }

  measure: currently_assigned_count {
    group_label: "Group Counts"
    label: "Currently Assigned"
    type: count
    filters: [current_assignment: "Yes"]
    drill_fields: [detail*]
  }

  measure: assignment_needed_count {
    group_label: "Group Counts"
    label: "Assignment Needed?"
    type: count
    filters: [assignment_needed: "Yes"]
    drill_fields: [detail*]
  }

  measure: recently_unassigned_count {
    group_label: "Group Counts"
    label: "Recently Unassigned"
    type: count
    filters: [recent_unassignment: "Yes"]
    drill_fields: [detail*]
  }

  measure: never_assigned_has_trips_count {
    group_label: "Group Counts"
    label: "Never Assigned; Has Trips"
    type: count
    filters: [never_assigned_has_trips: "Yes"]
    drill_fields: [detail*]
  }

  measure: never_assigned_no_trips_count {
    group_label: "Group Counts"
    label: "Never Assigned; No Trips"
    type: count
    filters: [never_assigned_no_trips: "Yes"]
    drill_fields: [detail*]
  }

  dimension: days_since_unassignment {
    type: number
    sql: DATEDIFF(day, ${unassignment_time_raw}, CONVERT_TIMEZONE('America/Chicago', current_timestamp)) ;;
    html: {% if stale_unassignment._rendered_value == 'Yes' %}
          <p style="background-color: #FF8E2B; color: #000000; text-align: left;">{{rendered_value}}</p>
          {% else %}
          {{rendered_value}}
          {% endif %}  ;;
  }

  set: detail {
    fields: [
      es_asset_id,
      inventory_branch,
      driver,
      current_assignment,
      assignment_time_time,
      unassignment_time_time,
      latest_trip_start_time
    ]
  }
}
