view: daily_summary {
  derived_table: {
    sql: WITH daily_points_by_type as (
      SELECT
      day,
      operator_id,
      event_type,
      total_points
      from
      analytics.fleetcam.daily_driver_points
      ),

      daily_points_by_category as (
      SELECT
      concat(day, ' - ', operator_id) as composite_key,
      event_category,
      sum(total_points) as total_points
      from
      analytics.fleetcam.daily_driver_points
      where
        {% if exclude_seatbelt._parameter_value == "'Yes'" %}
        event_category <> 'No Seat Belt'
        {% else %}
        1 = 1
        {% endif %}
      group by
      day,
      operator_id,
      event_category
      ),

      daily_events_by_type as (
      SELECT
      CONCAT(day, ' - ', operator_id) as composite_key,
      event_type,
      total_events
      from
      analytics.fleetcam.daily_driver_points
      ),

      daily_events_by_category as (
      SELECT
      CONCAT(day, ' - ', operator_id) as composite_key,
      event_category,
      sum(total_events) as total_events
      from
      analytics.fleetcam.daily_driver_points
      where
        {% if exclude_seatbelt._parameter_value == "'Yes'" %}
        event_category <> 'No Seat Belt'
        {% else %}
        1 = 1
        {% endif %}
      group by
      day,
      operator_id,
      event_category
      ),

      daily_total_events as (
      SELECT
      concat(day, ' - ', operator_id) as composite_key,
      sum(total_events) as total_events
      from
      analytics.fleetcam.daily_driver_points
      group by
      day,
      operator_id
      ),

      daily_drive_time_and_mileage as (
      SELECT
      concat(trip_start, ' - ', operator_id) as composite_key,
      trip_time_capped as total_drive_time,
      trip_miles as total_miles_driven,
      idle_duration as total_idle_time
      from
      analytics.fleetcam.daily_trip_times
      ),

      points_type_pivot as (
      select *
        from daily_points_by_type
            pivot(sum(total_points) for event_type in (ANY ORDER BY event_type)) --points columns ordered alphabetically by event_type
                --ADD NEW EVENT TYPES HERE
                --defined points columns must correspond to alphabetical order of event_type
                as p (day,
                      operator_id,
                      high_speeding_points,
                      extreme_speeding_points,
                      camera_points,
                      distracted_points,
                      smoking_points,
                      cell_phone_points,
                      distance_warning_points,
                      distance_harsh_points,
                      collision_warning_points,
                      harsh_breaking_points,
                      seat_belt_points
                     )
      ),

      points_category_pivot as (
      select *
        from daily_points_by_category
            pivot(sum(total_points) for event_category in (ANY ORDER BY event_category)) --points columns ordered alphabetically by event_category
                --ADD NEW EVENT CATEGORIES HERE
                --defined points columns must correspond to alphabetical order of event_category
                as p (composite_key,
                      policy_category_points,
                      safety_category_points,
                      speeding_category_points
                     )
      ),

      events_type_pivot as (
      select *
        from daily_events_by_type
            pivot(sum(total_events) for event_type in (ANY ORDER BY event_type)) --events columns ordered alphabetically by event_type
                --ADD NEW EVENT TYPES HERE
                as p (composite_key,
                      high_speeding_events,
                      extreme_speeding_events,
                      camera_events,
                      distracted_events,
                      smoking_events,
                      cell_phone_events,
                      distance_warning_events,
                      distance_harsh_events,
                      collision_warning_events,
                      harsh_breaking_events,
                      seat_belt_events
                     )
      ),

      events_category_pivot as (
      select *
        from daily_events_by_category
            pivot(sum(total_events) for event_category in (ANY ORDER BY event_category)) --events columns ordered alphabetically by event_category
                --ADD NEW EVENT CATEGORIES HERE
                as p (composite_key,
                      policy_category_events,
                      safety_category_events,
                      speeding_category_events
                     )
      )

      select
      {% if weekly_summary.time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day) as week_start,
      {% else %}
      date_trunc('week', day) as week_start,
      {% endif %}
      ptp.*,
      --ADD NEW EVENT CATEGORIES HERE
      pcp.policy_category_points,
      pcp.safety_category_points,
      pcp.speeding_category_points,
      (pcp.policy_category_points + pcp.safety_category_points + pcp.speeding_category_points) as total_points,
      etp.high_speeding_events,
      etp.extreme_speeding_events,
      etp.camera_events,
      etp.distracted_events,
      etp.smoking_events,
      etp.cell_phone_events,
      etp.distance_warning_events,
      etp.distance_harsh_events,
      etp.collision_warning_events,
      etp.harsh_breaking_events,
      etp.seat_belt_events,
      ecp.policy_category_events,
      ecp.safety_category_events,
      ecp.speeding_category_events,
      (ecp.policy_category_events + ecp.safety_category_events + ecp.speeding_category_events) as total_events,
      dd.total_drive_time,
      dd.total_idle_time,
      dd.total_miles_driven
      from points_type_pivot ptp
      join points_category_pivot pcp ON concat(ptp.day, ' - ', ptp.operator_id) = pcp.composite_key
      join events_type_pivot etp ON pcp.composite_key = etp.composite_key
      join events_category_pivot ecp ON pcp.composite_key = ecp.composite_key
      join daily_drive_time_and_mileage dd ON pcp.composite_key = dd.composite_key ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${drivers.operator_name} ;;
  }

  dimension: high_speeding_points {
    type: number
    sql: ${TABLE}."HIGH_SPEEDING_POINTS" ;;
  }

  dimension: extreme_speeding_points {
    type: number
    sql: ${TABLE}."EXTREME_SPEEDING_POINTS" ;;
  }

  dimension: camera_points {
    type: number
    sql: ${TABLE}."CAMERA_POINTS" ;;
  }

  dimension: distracted_points {
    type: number
    sql: ${TABLE}."DISTRACTED_POINTS" ;;
  }

  dimension: smoking_points {
    type: number
    sql: ${TABLE}."SMOKING_POINTS" ;;
  }

  dimension: cell_phone_points {
    type: number
    sql: ${TABLE}."CELL_PHONE_POINTS" ;;
  }

  dimension: distance_warning_points {
    type: number
    sql: ${TABLE}."DISTANCE_WARNING_POINTS" ;;
  }

  dimension: distance_harsh_points {
    type: number
    sql: ${TABLE}."DISTANCE_HARSH_POINTS" ;;
  }

  dimension: collision_warning_points {
    type: number
    sql: ${TABLE}."COLLISION_WARNING_POINTS" ;;
  }

  dimension: harsh_breaking_points {
    type: number
    sql: ${TABLE}."HARSH_BREAKING_POINTS" ;;
  }

  dimension: seat_belt_points {
    type: number
    sql: ${TABLE}."SEAT_BELT_POINTS" ;;
  }

  dimension: policy_category_points {
    type: number
    sql: ${TABLE}."POLICY_CATEGORY_POINTS" ;;
  }

  dimension: safety_category_points {
    type: number
    sql: ${TABLE}."SAFETY_CATEGORY_POINTS" ;;
  }

  dimension: speeding_category_points {
    type: number
    sql: ${TABLE}."SPEEDING_CATEGORY_POINTS" ;;
  }

  dimension: total_points {
    type: number
    sql: ${TABLE}."TOTAL_POINTS" ;;
  }

  dimension: high_speeding_events {
    type: number
    sql: ${TABLE}."HIGH_SPEEDING_EVENTS" ;;
  }

  dimension: extreme_speeding_events {
    type: number
    sql: ${TABLE}."EXTREME_SPEEDING_EVENTS" ;;
  }

  dimension: camera_events {
    type: number
    sql: ${TABLE}."CAMERA_EVENTS" ;;
  }

  dimension: distracted_events {
    type: number
    sql: ${TABLE}."DISTRACTED_EVENTS" ;;
  }

  dimension: smoking_events {
    type: number
    sql: ${TABLE}."SMOKING_EVENTS" ;;
  }

  dimension: cell_phone_events {
    type: number
    sql: ${TABLE}."CELL_PHONE_EVENTS" ;;
  }

  dimension: distance_warning_events {
    type: number
    sql: ${TABLE}."DISTANCE_WARNING_EVENTS" ;;
  }

  dimension: distance_harsh_events {
    type: number
    sql: ${TABLE}."DISTANCE_HARSH_EVENTS" ;;
  }

  dimension: collision_warning_events {
    type: number
    sql: ${TABLE}."COLLISION_WARNING_EVENTS" ;;
  }

  dimension: harsh_breaking_events {
    type: number
    sql: ${TABLE}."HARSH_BREAKING_EVENTS" ;;
  }

  dimension: seat_belt_events {
    type: number
    sql: ${TABLE}."SEAT_BELT_EVENTS" ;;
  }

  dimension: policy_category_events {
    type: number
    sql: ${TABLE}."POLICY_CATEGORY_EVENTS" ;;
  }

  dimension: safety_category_events {
    type: number
    sql: ${TABLE}."SAFETY_CATEGORY_EVENTS" ;;
  }

  dimension: speeding_category_events {
    type: number
    sql: ${TABLE}."SPEEDING_CATEGORY_EVENTS" ;;
  }

  dimension: total_events {
    type: number
    sql: ${TABLE}."TOTAL_EVENTS" ;;
  }

  dimension: total_drive_time {
    type: number
    sql: ${TABLE}."TOTAL_DRIVE_TIME" ;;
  }

  dimension: total_idle_time {
    type: number
    sql: ${TABLE}."TOTAL_IDLE_TIME" ;;
  }

  dimension: total_miles_driven {
    type: number
    sql: ${TABLE}."TOTAL_MILES_DRIVEN" ;;
  }

  dimension: week_start {
    type: date
    sql: ${TABLE}."WEEK_START" ;;
  }

  dimension: formatted_day {
    group_label: "HTML Formatted Date"
    label: "Day"
    type: date
    sql: ${day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_seat_belt_points {
    group_label: "Event Points"
    label: "No Seat Belt Points"
    type: sum
    sql: ${seat_belt_points} ;;
  }

  measure: total_cell_phone_points {
    group_label: "Event Points"
    label: "Driver Using Cell Phone Points"
    type: sum
    sql: ${cell_phone_points} ;;
  }

  measure: total_camera_points {
    group_label: "Event Points"
    label: "Camera Covered Points"
    type: sum
    sql: ${camera_points} ;;
  }

  measure: total_smoking_points {
    group_label: "Event Points"
    label: "Driver Smoking Points"
    type: sum
    sql: ${smoking_points} ;;
  }

  measure: total_distracted_points {
    group_label: "Event Points"
    label: "Driver Distracted Points"
    type: sum
    sql: ${distracted_points} ;;
  }

  measure: total_distance_warning_points {
    group_label: "Event Points"
    label: "Following Distance Warning Points"
    type: sum
    sql: ${distance_warning_points} ;;
  }

  measure: total_distance_harsh_points {
    group_label: "Event Points"
    label: "Following Distance Warning and Harsh Braking Points"
    type: sum
    sql: ${distance_harsh_points} ;;
  }

  measure: total_collision_warning_points {
    group_label: "Event Points"
    label: "Forward Collision Warning Points"
    type: sum
    sql: ${collision_warning_points} ;;
  }

  measure: total_harsh_braking_points {
    group_label: "Event Points"
    label: "Harsh Braking Points"
    type: sum
    sql: ${harsh_breaking_points} ;;
    drill_fields: [events.operator_name, events.event_date_and_time, events.event_type, events.view_video]
  }

  measure: total_extreme_speeding_points {
    group_label: "Event Points"
    label: "20+ MPH Over Speed Limit Points"
    type: sum
    sql: ${extreme_speeding_points} ;;
  }

  measure: total_high_speeding_points {
    group_label: "Event Points"
    label: "10-20 MPH Over Speed Limit Points"
    type: sum
    sql: ${high_speeding_points} ;;
  }

  measure: total_seat_belt_count{
    group_label: "Event Counts"
    label: "No Seat Belt Count"
    type: sum
    sql: ${seat_belt_events} ;;
    drill_fields: [operator_name, formatted_day, total_seat_belt_count_drill_down, total_seat_belt_points_drill_down]
  }

  measure: total_cell_phone_count {
    group_label: "Event Counts"
    label: "Driver Using Cell Phone Count"
    type: sum
    sql: ${cell_phone_events} ;;
    drill_fields: [operator_name, formatted_day, total_cell_phone_count_drill_down, total_cell_phone_points_drill_down]
  }

  measure: total_camera_count {
    group_label: "Event Counts"
    label: "Camera Covered Count"
    type: sum
    sql: ${camera_events} ;;
    drill_fields: [operator_name, formatted_day, total_camera_count_drill_down, total_camera_points_drill_down]
  }

  measure: total_smoking_count {
    group_label: "Event Counts"
    label: "Driver Smoking Count"
    type: sum
    sql: ${smoking_events} ;;
    drill_fields: [operator_name, formatted_day, total_smoking_count_drill_down, total_smoking_points_drill_down]
  }

  measure: total_distracted_count {
    group_label: "Event Counts"
    label: "Driver Distracted Count"
    type: sum
    sql: ${distracted_events} ;;
    drill_fields: [operator_name, formatted_day, total_distracted_count_drill_down, total_distracted_points_drill_down]
  }

  measure: total_distance_warning_count {
    group_label: "Event Counts"
    label: "Following Distance Warning Count"
    type: sum
    sql: ${distance_warning_events} ;;
    drill_fields: [operator_name, formatted_day, total_distance_warning_count_drill_down, total_distance_warning_points_drill_down]
  }

  measure: total_distance_harsh_count {
    group_label: "Event Counts"
    label: "Following Distance Warning and Harsh Braking Count"
    type: sum
    sql: ${distance_harsh_events} ;;
    drill_fields: [operator_name, formatted_day, total_distance_harsh_count_drill_down, total_distance_harsh_points_drill_down]
  }

  measure: total_collision_warning_count {
    group_label: "Event Counts"
    label: "Forward Collision Warning Count"
    type: sum
    sql: ${collision_warning_events} ;;
    drill_fields: [operator_name, formatted_day, total_collision_warning_count_drill_down, total_collision_warning_points_drill_down]
  }

  measure: total_harsh_braking_count {
    group_label: "Event Counts"
    label: "Harsh Braking Count"
    type: sum
    sql: ${harsh_breaking_events} ;;
    drill_fields: [operator_name, formatted_day, total_harsh_braking_count_drill_down, total_harsh_braking_points_drill_down]
  }

  measure: total_extreme_speeding_count {
    group_label: "Event Counts"
    label: "20+ MPH Over Speed Limit Count"
    type: sum
    sql: ${extreme_speeding_events} ;;
    drill_fields: [operator_name, formatted_day, total_extreme_speeding_count_drill_down, total_extreme_speeding_points_drill_down]
  }

  measure: total_high_speeding_count {
    group_label: "Event Counts"
    label: "10-20 MPH Over Speed Limit Count"
    type: sum
    sql: ${high_speeding_events} ;;
    drill_fields: [operator_name, formatted_day, total_high_speeding_count_drill_down, total_high_speeding_points_drill_down]
  }

  ######################################################################

  measure: total_seat_belt_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "No Seat Belt Points"
    type: sum
    sql: ${seat_belt_points} ;;
    drill_fields: [events_no_seat_belt.operator_name, events_no_seat_belt.event_date_and_time, events_no_seat_belt.event_type, events_no_seat_belt.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_cell_phone_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Driver Using Cell Phone Points"
    type: sum
    sql: ${cell_phone_points} ;;
    drill_fields: [events_cell_phone.operator_name, events_cell_phone.event_date_and_time, events_cell_phone.event_type, events_cell_phone.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_camera_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Camera Covered Points"
    type: sum
    sql: ${camera_points} ;;
    drill_fields: [events_camera_covered.operator_name, events_camera_covered.event_date_and_time, events_camera_covered.event_type, events_camera_covered.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_smoking_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Driver Smoking Points"
    type: sum
    sql: ${smoking_points} ;;
    drill_fields: [events_smoking.operator_name, events_smoking.event_date_and_time, events_smoking.event_type, events_smoking.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distracted_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Driver Distracted Points"
    type: sum
    sql: ${distracted_points} ;;
    drill_fields: [events_driver_distracted.operator_name, events_driver_distracted.event_date_and_time, events_driver_distracted.event_type, events_driver_distracted.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distance_warning_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Following Distance Warning Points"
    type: sum
    sql: ${distance_warning_points} ;;
    drill_fields: [events_distance_warning.operator_name, events_distance_warning.event_date_and_time, events_distance_warning.event_type, events_distance_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distance_harsh_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Following Distance Warning and Harsh Braking Points"
    type: sum
    sql: ${distance_harsh_points} ;;
    drill_fields: [events_distance_and_harsh_warning.operator_name, events_distance_and_harsh_warning.event_date_and_time, events_distance_and_harsh_warning.event_type, events_distance_and_harsh_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_collision_warning_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Forward Collision Warning Points"
    type: sum
    sql: ${collision_warning_points} ;;
    drill_fields: [events_collision_warning.operator_name, events_collision_warning.event_date_and_time, events_collision_warning.event_type, events_collision_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_harsh_braking_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "Harsh Braking Points"
    type: sum
    sql: ${harsh_breaking_points} ;;
    drill_fields: [events_harsh_braking.operator_name, events_harsh_braking.event_date_and_time, events_harsh_braking.event_type, events_harsh_braking.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_extreme_speeding_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "20+ MPH Over Speed Limit Points"
    type: sum
    sql: ${extreme_speeding_points} ;;
    drill_fields: [events_extreme_speeding.operator_name, events_extreme_speeding.event_date_and_time, events_extreme_speeding.event_type, events_extreme_speeding.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_high_speeding_points_drill_down {
    group_label: "Event Points Drill Down"
    label: "10-20 MPH Over Speed Limit Points"
    type: sum
    sql: ${high_speeding_points} ;;
    drill_fields: [events_high_speeding.operator_name, events_high_speeding.event_date_and_time, events_high_speeding.event_type, events_high_speeding.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_seat_belt_count_drill_down{
    group_label: "Event Counts Drill Down"
    label: "No Seat Belt Count"
    type: sum
    sql: ${seat_belt_events} ;;
    drill_fields: [events_no_seat_belt.operator_name, events_no_seat_belt.event_date_and_time, events_no_seat_belt.event_type, events_no_seat_belt.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_cell_phone_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Using Cell Phone Count"
    type: sum
    sql: ${cell_phone_events} ;;
    drill_fields: [events_cell_phone.operator_name, events_cell_phone.event_date_and_time, events_cell_phone.event_type, events_cell_phone.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_camera_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Camera Covered Count"
    type: sum
    sql: ${camera_events} ;;
    drill_fields: [events_camera_covered.operator_name, events_camera_covered.event_date_and_time, events_camera_covered.event_type, events_camera_covered.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_smoking_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Smoking Count"
    type: sum
    sql: ${smoking_events} ;;
    drill_fields: [events_smoking.operator_name, events_smoking.event_date_and_time, events_smoking.event_type, events_smoking.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distracted_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Distracted Count"
    type: sum
    sql: ${distracted_events} ;;
    drill_fields: [events_driver_distracted.operator_name, events_driver_distracted.event_date_and_time, events_driver_distracted.event_type, events_driver_distracted.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distance_warning_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Following Distance Warning Count"
    type: sum
    sql: ${distance_warning_events} ;;
    drill_fields: [events_distance_warning.operator_name, events_distance_warning.event_date_and_time, events_distance_warning.event_type, events_distance_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_distance_harsh_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Following Distance Warning and Harsh Braking Count"
    type: sum
    sql: ${distance_harsh_events} ;;
    drill_fields: [events_distance_and_harsh_warning.operator_name, events_distance_and_harsh_warning.event_date_and_time, events_distance_and_harsh_warning.event_type, events_distance_and_harsh_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_collision_warning_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Forward Collision Warning Count"
    type: sum
    sql: ${collision_warning_events} ;;
    drill_fields: [events_collision_warning.operator_name, events_collision_warning.event_date_and_time, events_collision_warning.event_type, events_collision_warning.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_harsh_braking_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Harsh Braking Count"
    type: sum
    sql: ${harsh_breaking_events} ;;
    drill_fields: [events_harsh_braking.operator_name, events_harsh_braking.event_date_and_time, events_harsh_braking.event_type, events_harsh_braking.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_extreme_speeding_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "20+ MPH Over Speed Limit Count"
    type: sum
    sql: ${extreme_speeding_events} ;;
    drill_fields: [events_extreme_speeding.operator_name, events_extreme_speeding.event_date_and_time, events_extreme_speeding.event_type, events_extreme_speeding.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_high_speeding_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "10-20 MPH Over Speed Limit Count"
    type: sum
    sql: ${high_speeding_events} ;;
    drill_fields: [events_high_speeding.operator_name, events_high_speeding.event_date_and_time, events_high_speeding.event_type, events_high_speeding.view_video]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  parameter: exclude_seatbelt {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  dimension: exclude_seatbelt_clean {
    type: string
    sql: REPLACE({{ exclude_seatbelt._parameter_value }}, '\'', '') ;;
  }

  ######################################################################

  set: detail {
    fields: [
      day,
      operator_name,
      high_speeding_points,
      extreme_speeding_points,
      camera_points,
      distracted_points,
      smoking_points,
      cell_phone_points,
      distance_warning_points,
      distance_harsh_points,
      collision_warning_points,
      harsh_breaking_points,
      seat_belt_points,
      policy_category_points,
      safety_category_points,
      speeding_category_points,
      total_points,
      total_events,
      total_drive_time
    ]
  }
}
