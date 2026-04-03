view: coaching_eval_card {
  derived_table: {
    sql: WITH driver_facing_event_drivers AS (
        SELECT
          da.operator_id
        from
        analytics.fleetcam.events e
        join analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
        join analytics.fleetcam.driver_assignments da
            on e.event_date BETWEEN da.assignment_time AND coalesce(da.unassignment_time,'2999-12-31'::timestamp_ntz)
            and afx.es_asset_id = da.asset_id
        where e.event_type_id IN (3, 12, 13, 14, 31) --driver facing events
      ),

      drivers_in_program as (
        select user_id
        from analytics.fleetcam.drivers
        where (market_id IN (SELECT market_id FROM analytics.fleetcam.v_markets_in_program)
               or employee_title IN ('Telematics Installer',
                                     'Regional Telematics Installer',
                                     'Mobile Telematics Installer',
                                     'Telematics Specialist',
                                     'Regional Lead Telematics Installer',
                                     'CDL Delivery Driver Apprentice',
                                     'CDL Apprentice',
                                     'CDL Driver Apprentice')
              or (market_name = 'No Market' AND TRY_TO_NUMBER(region) IN (1,2,3,5,7))
              or (market_name = 'No Market' AND operator_id IN (SELECT * FROM driver_facing_event_drivers))
             )
              AND {% condition region %} region {% endcondition %}
              AND {% condition district %} district {% endcondition %}
              AND {% condition market_name %} market_name {% endcondition %}
      ),

      n_drivers_in_program as (
        SELECT count(*) as n_drivers_in_program
        FROM drivers_in_program
      ),

      drivers_coached_in_period AS (
        SELECT
          u.user_id,
          COALESCE(dcmb.coaching_completed_date, dcmb.coaching_due_date)::date as coaching_date
        FROM analytics.monday.driver_coaching_management_board dcmb
        JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
        WHERE dcmb.coaching_status = 'Coaching Complete'
          AND u.user_id IN (SELECT user_id FROM drivers_in_program)
      ),

      all_time_coachings AS (
        SELECT count(*) as all_time_coachings
        FROM analytics.monday.driver_coaching_management_board dcmb
        JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
        WHERE dcmb.coaching_status = 'Coaching Complete'
          AND u.user_id IN (SELECT user_id FROM drivers_in_program)
      ),

      coached_twice as (
        SELECT count(*) as coached_twice
        FROM (
              SELECT u.user_id
              FROM analytics.monday.driver_coaching_management_board dcmb
              JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
              WHERE coaching_status = 'Coaching Complete'
                AND u.user_id IN (SELECT user_id FROM drivers_in_program)
              GROUP BY u.user_id
              HAVING count(*) = 2
        )
      ),

      coached_thrice as (
        SELECT count(*) as coached_thrice
        FROM (
              SELECT u.user_id
              FROM analytics.monday.driver_coaching_management_board dcmb
              JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
              WHERE coaching_status = 'Coaching Complete'
                AND u.user_id IN (SELECT user_id FROM drivers_in_program)
              GROUP BY u.user_id
              HAVING count(*) = 3
        )
      )

      SELECT *
      FROM drivers_coached_in_period
      CROSS JOIN n_drivers_in_program
      CROSS JOIN all_time_coachings
      CROSS JOIN coached_twice
      CROSS JOIN coached_thrice ;;
  }

  measure: count {
    type: count
  }

  measure: drivers_coached_in_period {
    type: count_distinct
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: coaching_date {
    type: date
    sql: ${TABLE}."COACHING_DATE" ;;
  }

  dimension: n_drivers_in_program {
    type: number
    sql: ${TABLE}."N_DRIVERS_IN_PROGRAM" ;;
  }

  dimension: all_time_coachings {
    type: number
    sql: ${TABLE}."ALL_TIME_COACHINGS" ;;
  }

  dimension: coached_twice {
    type: number
    sql: ${TABLE}."COACHED_TWICE" ;;
  }

  dimension: coached_thrice {
    type: number
    sql: ${TABLE}."COACHED_THRICE" ;;
  }

  dimension: coaching_eval_card {
    type: number
    sql: ${n_drivers_in_program} ;;
    html:
    <div style="font-size: 1.25rem; line-height: 1; text-align: left">
      <strong>Number of Drivers in Program:</strong> {{rendered_value}}<br/><br/>
      <strong>Drivers Coached in Selected Timeframe:</strong> {{drivers_coached_in_period._rendered_value}}<br/><br/>
      <strong>All-Time Coachings:</strong> {{all_time_coachings._rendered_value}}<br/><br/>
      <strong>Drivers Coached Twice:</strong> {{coached_twice._rendered_value}}<br/><br/>
      <strong>Drivers Coached Three Times:</strong> {{coached_thrice._rendered_value}}<br/><br/>
    </div>;;
  }

  filter: region {}
  filter: district {}
  filter: market_name {}
}
