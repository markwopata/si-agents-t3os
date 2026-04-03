view: drivers {
  derived_table: {
    sql:
      WITH driver_facing_event_drivers AS (
        SELECT
          da.operator_id
        from
        analytics.fleetcam.events e
        join analytics.fleetcam.asset_fleetcam_xwalk afx ON e.vehicle_id = afx.fleetcam_vehicle_id
        join analytics.fleetcam.driver_assignments da
            on e.event_date BETWEEN da.assignment_time AND coalesce(da.unassignment_time,'2999-12-31'::timestamp_ntz)
            and afx.es_asset_id = da.asset_id
        where e.event_type_id IN (3, 12, 13, 14, 31) --driver facing events
      )

      select *
      from analytics.fleetcam.drivers
      where market_id IN (SELECT market_id FROM analytics.fleetcam.v_markets_in_program)
         or employee_title IN ('Telematics Installer',
                               'Regional Telematics Installer',
                               'Mobile Telematics Installer',
                               'Telematics Specialist',
                               'Regional Lead Telematics Installer',
                               'CDL Delivery Driver Apprentice',
                               'CDL Apprentice',
                               'CDL Driver Apprentice')
        or (market_name = 'No Market' AND TRY_TO_NUMBER(region) IN (1,2,3,5,7))
        or (market_name = 'No Market' AND operator_id IN (SELECT * FROM driver_facing_event_drivers));;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
    primary_key: yes
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: operator_email {
    type: string
    sql: ${TABLE}."OPERATOR_EMAIL" ;;
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

  dimension: region_num {
    type: string
    sql: ${TABLE}."REGION";;
  }

  dimension: region {
    type: string
    sql: CASE WHEN ${region_num} = 1 THEN '1 - Pacific'
              WHEN ${region_num} = 2 THEN '2 - Mountain West'
              WHEN ${region_num} = 3 THEN '3 - Southwest'
              WHEN ${region_num} = 4 THEN '4 - Midwest'
              WHEN ${region_num} = 5 THEN '5 - Southeast'
              WHEN ${region_num} = 6 THEN '6 - Northeast'
              WHEN ${region_num} = 7 THEN '7 - Industrial';;
  }

  dimension: date_hired {
    type: string
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: driver {
    type: string
    sql: CONCAT(${operator_name}, ' - ', ${market_name});;
  }

  measure: driver_card {
    type: string
    sql: ${driver};;
    html:
    {% if driver._is_filtered %}
    <div style="font-size: 1.75rem; line-height: 1; text-align: left">
      <strong>{{operator_name._value}}</strong><br/><br/>
    </div>
    <div style="font-size: 1.25rem; line-height: 1; text-align: left">
      <strong>Title: </strong>{{employee_title._rendered_value}}<br/><br/>
      <strong>Date Hired: </strong>{{date_hired._rendered_value}}<br/><br/>
      <strong>Home Market: </strong>{{market_name._rendered_value}}<br/><br/>
      <strong>Manager: </strong>{{direct_manager_name._value}}<br/><br/>
      <strong>E-mail: </strong>{{operator_email._rendered_value}}
    </div>
    {% else %}
    No Driver Selected
    {% endif %}
    ;;
  }

  measure: driver_assignment_history_link {
    type: sum
    sql: 0 ;;
    drill_fields: [assignments*]
    html:
      <a href="#drillmenu" target="_self">
      <font size="5">View Asset Assignment History</font> <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 24px; height: 24px;">
      </a>
      ;;
  }

  measure: drivers_on_probation_card {
    type: number
    sql: ${coaching.drivers_on_probation_count} ;;
    html: <p>Drivers Currently<br>on Probation Period:<br>
            {{rendered_value}} of {{count._rendered_value}}</p>;;
  }

  measure: drivers_coached_card {
    type: number
    sql: ${coaching.complete_count} ;;
    html:<p>Drivers Coached<br>All Time:<br>
          {{rendered_value}} of {{count._rendered_value}}</p>;;
  }

  set: detail {
    fields: [
      operator_id,
      operator_name,
      user_id,
      market_id,
      market_name,
      date_hired,
      employee_title,
      direct_manager_name
    ]
  }

  set: assignments {
    fields: [
      driver_assignments.operator_name,
      driver_assignments.asset_id,
      driver_assignments.make_model,
      driver_assignments.assignment_time_time,
      driver_assignments.unassignment_time_time,
      driver_assignments.current_assignment
    ]
  }
}
