view: events_after_coaching {
  derived_table: {
    sql: WITH markets_in_program AS (
          SELECT market_id
          FROM analytics.fleetcam.v_markets_in_program
      ),

      drivers as (
          select
            operator_id,
            user_id,
            operator_name,
            market_id,
            market_name,
            district,
            region
          from analytics.fleetcam.drivers
          where market_id in (SELECT market_id FROM markets_in_program)
      ),

      events as (
      SELECT
              e.event_id,
              CONVERT_TIMEZONE('America/Chicago', e.event_date) as event_date,
              da.operator_id,
              et.name as event_type,
              et.es_category as event_category
          from
          analytics.fleetcam.events e
          join analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
          join analytics.fleetcam.event_types et ON e.event_type_id = et.event_type_id
          join analytics.fleetcam.driver_assignments da
              on e.event_date BETWEEN da.assignment_time AND coalesce(da.unassignment_time,'2999-12-31'::timestamp_ntz)
              and afx.es_asset_id = da.asset_id
          where et.effective_record = TRUE
      ),

      completed_coaching as (
      SELECT
          u.user_id,
          IFF(dcmb.coaching_status = 'Coaching Complete',
              COALESCE(dcmb.coaching_completed_date, dcmb.coaching_due_date),
              dcmb.coaching_completed_date
          ) as coaching_completed_date_helper,
          dcmb.primary_violation_type,
          dcmb.secondary_violation_type
      FROM analytics.monday.driver_coaching_management_board dcmb
      JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
      WHERE dcmb.coaching_status = 'Coaching Complete'
        AND {% condition coaching_severity %} dcmb.coaching_severity {% endcondition %}
        AND coaching_completed_date_helper IS NOT NULL
      ),

      primary_violations as (
          SELECT
              c.user_id,
              c.coaching_completed_date_helper as coaching_completed_date,
              c.primary_violation_type,
              count(e.event_id) as events_since_coaching
          FROM completed_coaching c
          JOIN drivers d ON c.user_id = d.user_id
          LEFT JOIN events e
              ON d.operator_id = e.operator_id
              AND (e.event_type = c.primary_violation_type
                   OR (c.primary_violation_type = 'Speeding'
                       AND e.event_type IN ('20+ MPH Over Speed Limit', '10-20 MPH Over Speed Limit')
                      )
                  )
              AND e.event_date > c.coaching_completed_date_helper
          WHERE {% if exclude_seatbelt._parameter_value == "'Yes'" %}
                c.primary_violation_type <> 'No Seat Belt'
                {% else %}
                1 = 1
                {% endif %}
          GROUP BY
              c.user_id,
              c.coaching_completed_date_helper,
              c.primary_violation_type
      ),

      secondary_violations as (
          SELECT
              c.user_id,
              c.coaching_completed_date_helper as coaching_completed_date,
              c.secondary_violation_type,
              count(e.event_id) as events_since_coaching
          FROM completed_coaching c
          JOIN drivers d ON c.user_id = d.user_id
          LEFT JOIN events e
              ON d.operator_id = e.operator_id
              AND (e.event_type = c.secondary_violation_type
                   OR (c.secondary_violation_type = 'Speeding'
                       AND e.event_type IN ('20+ MPH Over Speed Limit', '10-20 MPH Over Speed Limit')
                      )
                  )
              AND e.event_date > c.coaching_completed_date_helper
          WHERE c.secondary_violation_type IS NOT NULL
            AND {% if exclude_seatbelt._parameter_value == "'Yes'" %}
                c.secondary_violation_type <> 'No Seat Belt'
                {% else %}
                1 = 1
                {% endif %}
          GROUP BY
              c.user_id,
              c.coaching_completed_date_helper,
              c.secondary_violation_type
      )

      SELECT
          COALESCE(p.user_id, s.user_id) as user_id,
          CONCAT(d.operator_name, ' - ', d.market_name) as driver,
          d.market_id,
          d.market_name,
          d.district,
          d.region,
          COALESCE(p.coaching_completed_date, s.coaching_completed_date) as coaching_completed_date_helper,
          {% if time_interval._parameter_value == "'Monthly'" %}
          date_trunc('month', coaching_completed_date_helper) as coaching_completed_week,
          {% else %}
          date_trunc('week', coaching_completed_date_helper) as coaching_completed_week,
          {% endif %}
          COALESCE(p.primary_violation_type, s.secondary_violation_type) as coached_violation,
          COALESCE(p.events_since_coaching, 0) + COALESCE(s.events_since_coaching, 0) as events_since_coaching
      FROM primary_violations p
      FULL JOIN secondary_violations s
          ON p.user_id = s.user_id
          AND p.coaching_completed_date = s.coaching_completed_date
          AND p.primary_violation_type = s.secondary_violation_type
      JOIN drivers d ON COALESCE(p.user_id, s.user_id) = d.user_id ;;
  }

  measure: count {
    type: count
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: driver {
    type: string
    sql: ${TABLE}."DRIVER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: coaching_completed_date {
    type: date
    sql: ${TABLE}."COACHING_COMPLETED_DATE_HELPER" ;;
  }

  dimension: coaching_completed_week {
    type: date
    sql: ${TABLE}."COACHING_COMPLETED_WEEK" ;;
  }

  dimension: coached_violation {
    type: string
    sql: ${TABLE}."COACHED_VIOLATION" ;;
  }

  dimension: events_since_coaching {
    type: number
    sql: ${TABLE}."EVENTS_SINCE_COACHING" ;;
  }

  dimension: days_since_coaching {
    type: number
    sql: datediff(days, ${coaching_completed_date}, current_date) ;;
  }

  dimension: average_events_per_day_since_coaching {
    type: number
    sql: ${events_since_coaching} / NULLIFZERO(${days_since_coaching}) ;;
    value_format: "0.##"
  }

  measure: cell_phone_average_events  {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Driver Using Cell Phone"]
    value_format: "0.##"
  }

  measure: no_seat_belt_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "No Seat Belt"]
    value_format: "0.##"
  }

  measure: follow_warning_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Follow Distance Warning"]
    value_format: "0.##"
  }

  measure: collision_warning_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Forward Collision Warning"]
    value_format: "0.##"
  }

  measure: speeding_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Speeding"]
    value_format: "0.##"
  }

  measure: braking_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Harsh Braking"]
    value_format: "0.##"
  }

  measure: camera_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Camera Covered"]
    value_format: "0.##"
  }

  measure: smoking_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Driver Smoking"]
    value_format: "0.##"
  }

  measure: distracted_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Driver Distracted"]
    value_format: "0.##"
  }

  measure: follow_distance_and_braking_average_events {
    group_label: "Average Events"
    type: average
    sql: ${average_events_per_day_since_coaching} ;;
    filters: [coached_violation: "Follow Distance Warning and Harsh Braking"]
    value_format: "0.##"
  }

  filter: coaching_severity {}

  parameter: time_interval {
    type: string
    allowed_value: {value: "Weekly"}
    allowed_value: {value: "Monthly"}
  }

  parameter: exclude_seatbelt {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }
}
