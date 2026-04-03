view: weekly_summary {
  derived_table: {
    sql: WITH weekly_points_by_type as (
      SELECT
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day) as week_start,
      {% else %}
      date_trunc('week', day) as week_start,
      {% endif %}
      operator_id,
      event_type,
      sum(total_points) as total_points
      from
      analytics.fleetcam.daily_driver_points
      group by
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day),
      {% else %}
      date_trunc('week', day),
      {% endif %}
      operator_id,
      event_type
      ),

      weekly_points_by_category as (
      SELECT
      {% if time_interval._parameter_value == "'Monthly'" %}
      concat(date_trunc('month', day), ' - ', operator_id) as composite_key,
      {% else %}
      concat(date_trunc('week', day), ' - ', operator_id) as composite_key,
      {% endif %}
      event_category,
      sum(total_points) as total_points
      from
      analytics.fleetcam.daily_driver_points
      where
        {% if daily_summary.exclude_seatbelt._parameter_value == "'Yes'" %}
        event_type <> 'No Seat Belt'
        {% else %}
        1 = 1
        {% endif %}
      group by
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day),
      {% else %}
      date_trunc('week', day),
      {% endif %}
      operator_id,
      event_category
      ),

      weekly_events_by_type as (
      SELECT
      {% if time_interval._parameter_value == "'Monthly'" %}
      concat(date_trunc('month', day), ' - ', operator_id) as composite_key,
      {% else %}
      concat(date_trunc('week', day), ' - ', operator_id) as composite_key,
      {% endif %}
      event_type,
      sum(total_events) as total_events
      from
      analytics.fleetcam.daily_driver_points
      group by
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day),
      {% else %}
      date_trunc('week', day),
      {% endif %}
      operator_id,
      event_type
      ),

      weekly_events_by_category as (
      SELECT
      {% if time_interval._parameter_value == "'Monthly'" %}
      concat(date_trunc('month', day), ' - ', operator_id) as composite_key,
      {% else %}
      concat(date_trunc('week', day), ' - ', operator_id) as composite_key,
      {% endif %}
      event_category,
      sum(total_events) as total_events
      from
      analytics.fleetcam.daily_driver_points
      where
        {% if daily_summary.exclude_seatbelt._parameter_value == "'Yes'" %}
        event_type <> 'No Seat Belt'
        {% else %}
        1 = 1
        {% endif %}
      group by
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', day),
      {% else %}
      date_trunc('week', day),
      {% endif %}
      operator_id,
      event_category
      ),

      weekly_drive_time_and_mileage as (
      SELECT
      {% if time_interval._parameter_value == "'Monthly'" %}
      concat(date_trunc('month', trip_start), ' - ', operator_id) as composite_key,
      {% else %}
      concat(date_trunc('week', trip_start), ' - ', operator_id) as composite_key,
      {% endif %}
      sum(trip_time_capped) as total_drive_time,
      sum(idle_duration) as total_idle_time,
      sum(trip_miles) as total_miles_driven
      from
      analytics.fleetcam.daily_trip_times
      group by
      {% if time_interval._parameter_value == "'Monthly'" %}
      date_trunc('month', trip_start),
      {% else %}
      date_trunc('week', trip_start),
      {% endif %}
      operator_id
      ),

      points_type_pivot as (
      select *
        from weekly_points_by_type
            pivot(sum(total_points) for event_type in (ANY ORDER BY event_type)) --points columns ordered alphabetically by event_type
                --ADD NEW EVENT TYPES HERE
                --defined points columns must correspond to alphabetical order of event_type
                as p (week_start,
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
        from weekly_points_by_category
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
        from weekly_events_by_type
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
        from weekly_events_by_category
            pivot(sum(total_events) for event_category in (ANY ORDER BY event_category)) --events columns ordered alphabetically by event_category
                --ADD NEW EVENT CATEGORIES HERE
                as p (composite_key,
                      policy_category_events,
                      safety_category_events,
                      speeding_category_events
                     )
      ),


      event_type_rank as (
      select
      concat(week_start, ' - ', operator_id) as composite_key,
      event_type,
      row_number() over(partition by week_start, operator_id order by total_points desc) as rnk
      from
      weekly_points_by_type
      where total_points <> 0
        and {% if daily_summary.exclude_seatbelt._parameter_value == "'Yes'" %}
            event_type <> 'No Seat Belt'
            {% else %}
            1 = 1
            {% endif %}
      ),

      top_event_types as (
      select
      composite_key,
      MAX(CASE WHEN rnk = 1 THEN event_type END) as primary_violation,
      MAX(CASE WHEN rnk = 2 THEN event_type END) as secondary_violation
      from
      event_type_rank
      where
      rnk <= 2
      group by
      composite_key
      )

      select
      ptp.*,
      pcp.composite_key,
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
      tet.primary_violation,
      tet.secondary_violation,
      wd.total_drive_time,
      wd.total_idle_time,
      wd.total_miles_driven,
      IFF(total_points > 200
          OR (pcp.policy_category_points - ptp.cell_phone_points) > 0
          OR ptp.cell_phone_points > 40
          OR ((total_drive_time/3600) >= 1 AND (total_events/(total_drive_time/3600)) > 5)
          OR ((total_drive_time/3600) >= 20 AND (total_events/(total_drive_time/3600)) > 5/2),
        TRUE, FALSE) as coaching_recommended
      from points_type_pivot ptp
      join points_category_pivot pcp ON concat(ptp.week_start, ' - ', ptp.operator_id) = pcp.composite_key
      join events_type_pivot etp ON pcp.composite_key = etp.composite_key
      join events_category_pivot ecp ON pcp.composite_key = ecp.composite_key
      join weekly_drive_time_and_mileage wd ON pcp.composite_key = wd.composite_key
      left join top_event_types tet ON pcp.composite_key = tet.composite_key ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: composite_key {
    primary_key: yes
    sql: ${TABLE}."COMPOSITE_KEY" ;;
  }

  dimension: week_start {
    type: date
    sql: ${TABLE}."WEEK_START" ;;
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${drivers.operator_name};;
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

  dimension: primary_violation {
    type: string
    sql: ${TABLE}."PRIMARY_VIOLATION" ;;
    skip_drill_filter: yes
  }

  dimension: secondary_violation {
    type: string
    sql: ${TABLE}."SECONDARY_VIOLATION" ;;
    skip_drill_filter: yes
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

  dimension: coaching_recommended {
    type: yesno
    sql: ${TABLE}."COACHING_RECOMMENDED" ;;
  }

  measure: total_policy_category_points {
    group_label: "Category Points"
    label: "Total Policy Points"
    type: sum
    sql: ${policy_category_points} ;;
    drill_fields: [policy_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_safety_category_points {
    group_label: "Category Points"
    label: "Total Safety Points"
    type: sum
    sql: ${safety_category_points} ;;
    drill_fields: [safety_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_speeding_category_points {
    group_label: "Category Points"
    label: "Total Speeding Points"
    type: sum
    sql: ${speeding_category_points} ;;
    drill_fields: [speeding_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_weekly_points {
    group_label: "Event Points"
    type: sum
    sql: ${total_points} ;;
  }

  measure: total_weekly_events {
    group_label: "Event Counts"
    type: sum
    sql: ${total_events} ;;
  }

  measure: total_policy_weekly_events {
    group_label: "Category Event Counts"
    type: sum
    sql: ${policy_category_events} ;;
    drill_fields: [policy_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_safety_weekly_events {
    group_label: "Category Event Counts"
    type: sum
    sql: ${safety_category_events} ;;
    drill_fields: [safety_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_speeding_weekly_events {
    group_label: "Category Event Counts"
    type: sum
    sql: ${speeding_category_events} ;;
    drill_fields: [speeding_drill*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_weekly_hours_driven {
    group_label: "Drive Time"
    type: sum
    sql: FLOOR(${total_drive_time} / 3600) ;;
  }

  measure: total_weekly_hours_driven_decimal {
    group_label: "Drive Time"
    type: sum
    sql: ${total_drive_time} / 3600 ;;
    value_format: "0.######"
  }

  measure: total_weekly_minutes_driven {
    group_label: "Drive Time"
    type: sum
    sql: FLOOR(MOD(${total_drive_time}, 3600) / 60) ;;
  }

  measure: total_weekly_drive_time_seconds {
    group_label: "Drive Time"
    type: sum
    sql: ${total_drive_time} ;;
  }

  measure: total_weekly_idle_time_seconds  {
    group_label: "Idle Time"
    type: sum
    sql: ${total_idle_time} ;;
  }

  measure: total_weekly_idle_percentage {
    group_label: "Drive Time"
    type: number
    sql: ${total_weekly_idle_time_seconds}/${total_weekly_drive_time_seconds};;
    value_format: "0%"
  }

  measure: total_weekly_drive_time  {
    group_label: "Drive Time"
    type: number
    sql: ${total_weekly_hours_driven_decimal} ;;
    html: {{total_weekly_hours_driven._rendered_value}} hrs. {{total_weekly_minutes_driven._rendered_value}} mins <br />
    <font style="color: #8C8C8C; text-align: right;">{{total_weekly_idle_percentage._rendered_value}} Idle</font>;;
  }

  measure: total_weekly_hours_idle {
    group_label: "Idle Time"
    type: sum
    sql: FLOOR(${total_idle_time} / 3600) ;;
  }

  measure: total_weekly_hours_idle_decimal {
    group_label: "Idle Time"
    type: sum
    sql: ${total_idle_time} / 3600 ;;
    value_format: "0.######"
  }

  measure: total_weekly_minutes_idle {
    group_label: "Idle Time"
    type: sum
    sql: FLOOR(MOD(${total_idle_time}, 3600) / 60) ;;
  }

  measure: total_weekly_idle_time  {
    group_label: "Idle Time"
    type: number
    sql: ${total_weekly_hours_idle_decimal} ;;
    html: {{total_weekly_hours_idle._rendered_value}} hrs. {{total_weekly_minutes_idle._rendered_value}} mins ;;
  }

  measure: total_weekly_drive_distance {
    type: sum
    sql: ${total_miles_driven} ;;
    value_format_name: "decimal_0"
    html: {{rendered_value}} miles;;
  }

  measure: total_seat_belt_points {
    group_label: "Event Points"
    label: "No Seat Belt Points"
    type: sum
    sql: ${seat_belt_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_seat_belt_count_drill_down, daily_summary.total_seat_belt_points_drill_down]
  }

  measure: total_cell_phone_points {
    group_label: "Event Points"
    label: "Driver Using Cell Phone Points"
    type: sum
    sql: ${cell_phone_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_cell_phone_count_drill_down, daily_summary.total_cell_phone_points_drill_down]
  }

  measure: total_camera_points {
    group_label: "Event Points"
    label: "Camera Covered Points"
    type: sum
    sql: ${camera_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_camera_count_drill_down, daily_summary.total_camera_points_drill_down]
  }

  measure: total_smoking_points {
    group_label: "Event Points"
    label: "Driver Smoking Points"
    type: sum
    sql: ${smoking_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_smoking_count_drill_down, daily_summary.total_smoking_points_drill_down]
  }

  measure: total_distracted_points {
    group_label: "Event Points"
    label: "Driver Distracted Points"
    type: sum
    sql: ${distracted_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distracted_count_drill_down, daily_summary.total_distracted_points_drill_down]
  }

  measure: total_distance_warning_points {
    group_label: "Event Points"
    label: "Following Distance Warning Points"
    type: sum
    sql: ${distance_warning_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distance_warning_count_drill_down, daily_summary.total_distance_warning_points_drill_down]
  }

  measure: total_distance_harsh_points {
    group_label: "Event Points"
    label: "Following Distance Warning and Harsh Braking Points"
    type: sum
    sql: ${distance_harsh_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distance_harsh_count_drill_down, daily_summary.total_distance_harsh_points_drill_down]
  }

  measure: total_collision_warning_points {
    group_label: "Event Points"
    label: "Forward Collision Warning Points"
    type: sum
    sql: ${collision_warning_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_collision_warning_count_drill_down, daily_summary.total_collision_warning_points_drill_down]
  }

  measure: total_harsh_braking_points {
    group_label: "Event Points"
    label: "Harsh Braking Points"
    type: sum
    sql: ${harsh_breaking_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_harsh_braking_count_drill_down, daily_summary.total_harsh_braking_points_drill_down]
  }

  measure: total_extreme_speeding_points {
    group_label: "Event Points"
    label: "20+ MPH Over Speed Limit Points"
    type: sum
    sql: ${extreme_speeding_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_extreme_speeding_count_drill_down, daily_summary.total_extreme_speeding_points_drill_down]
  }

  measure: total_high_speeding_points {
    group_label: "Event Points"
    label: "10-20 MPH Over Speed Limit Points"
    type: sum
    sql: ${high_speeding_points} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_high_speeding_count_drill_down, daily_summary.total_high_speeding_points_drill_down]
  }

  measure: total_seat_belt_count{
    group_label: "Event Counts"
    label: "No Seat Belt Count"
    type: sum
    sql: ${seat_belt_events} ;;
    drill_fields: [operator_name,total_seat_belt_count_drill_down, total_seat_belt_points]
  }

  measure: total_cell_phone_count {
    group_label: "Event Counts"
    label: "Driver Using Cell Phone Count"
    type: sum
    sql: ${cell_phone_events} ;;
    drill_fields: [operator_name,total_cell_phone_count_drill_down, total_cell_phone_points]
  }

  measure: total_camera_count {
    group_label: "Event Counts"
    label: "Camera Covered Count"
    type: sum
    sql: ${camera_events} ;;
    drill_fields: [operator_name,total_camera_count_drill_down, total_camera_points]
  }

  measure: total_smoking_count {
    group_label: "Event Counts"
    label: "Driver Smoking Count"
    type: sum
    sql: ${smoking_events} ;;
    drill_fields: [operator_name,total_smoking_count_drill_down, total_smoking_points]
  }

  measure: total_distracted_count {
    group_label: "Event Counts"
    label: "Driver Distracted Count"
    type: sum
    sql: ${distracted_events} ;;
    drill_fields: [operator_name,total_distracted_count_drill_down, total_distracted_points]
  }

  measure: total_distance_warning_count {
    group_label: "Event Counts"
    label: "Following Distance Warning Count"
    type: sum
    sql: ${distance_warning_events} ;;
    drill_fields: [operator_name,total_distance_warning_count_drill_down, total_distance_warning_points]
  }

  measure: total_distance_harsh_count {
    group_label: "Event Counts"
    label: "Following Distance Warning and Harsh Braking Count"
    type: sum
    sql: ${distance_harsh_events} ;;
    drill_fields: [operator_name,total_distance_harsh_count_drill_down, total_distance_harsh_points]
  }

  measure: total_collision_warning_count {
    group_label: "Event Counts"
    label: "Forward Collision Warning Count"
    type: sum
    sql: ${collision_warning_events} ;;
    drill_fields: [operator_name,total_collision_warning_count_drill_down, total_collision_warning_points]
  }

  measure: total_harsh_braking_count {
    group_label: "Event Counts"
    label: "Harsh Braking Count"
    type: sum
    sql: ${harsh_breaking_events} ;;
    drill_fields: [operator_name,total_harsh_braking_count_drill_down, total_harsh_braking_points]
  }

  measure: total_extreme_speeding_count {
    group_label: "Event Counts"
    label: "20+ MPH Over Speed Limit Count"
    type: sum
    sql: ${extreme_speeding_events} ;;
    drill_fields: [operator_name,total_extreme_speeding_count_drill_down, total_extreme_speeding_points]
  }

  measure: total_high_speeding_count {
    group_label: "Event Counts"
    label: "10-20 MPH Over Speed Limit Count"
    type: sum
    sql: ${high_speeding_events} ;;
    drill_fields: [operator_name,total_high_speeding_count_drill_down, total_high_speeding_points]
  }

  dimension: formatted_coaching_recommended {
    group_label: "HTML Formatted"
    label: "Coaching Recommended"
    type: yesno
    sql: ${TABLE}."COACHING_RECOMMENDED" ;;
    html:
    {% if value == 'Yes' %}
      <font color="#DA344D"><b>{{value}}</b> 🚩 </font>
      {% else %}

      {% endif %}
    ;;
  }

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Operator Name"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1668?Driver={{drivers.driver._filterable_value | url_encode}}&Exclude+%27No+Seatbelt%27+from+Totals={{daily_summary.exclude_seatbelt_clean._filterable_value | url_encode }}"target="_blank">
    {{rendered_value}} ➔</a></font>
    ;;
  }

  measure: total_seat_belt_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "No Seat Belt Count"
    type: sum
    sql: ${seat_belt_events} ;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_seat_belt_count_drill_down, daily_summary.total_seat_belt_points_drill_down]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_cell_phone_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Using Cell Phone Count"
    type: sum
    sql: ${cell_phone_events} ;;
    # drill_fields: [operator_name,total_cell_phone_count, total_cell_phone_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_cell_phone_count_drill_down, daily_summary.total_cell_phone_points_drill_down]
  }

  measure: total_camera_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Camera Covered Count"
    type: sum
    sql: ${camera_events} ;;
    # drill_fields: [operator_name,total_camera_count, total_camera_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_camera_count_drill_down, daily_summary.total_camera_points_drill_down]
  }

  measure: total_smoking_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Smoking Count"
    type: sum
    sql: ${smoking_events} ;;
    # drill_fields: [operator_name,total_smoking_count, total_smoking_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_smoking_count_drill_down, daily_summary.total_smoking_points_drill_down]
  }

  measure: total_distracted_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Driver Distracted Count"
    type: sum
    sql: ${distracted_events} ;;
    # drill_fields: [operator_name,total_distracted_count, total_distracted_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distracted_count_drill_down, daily_summary.total_distracted_points_drill_down]
  }

  measure: total_distance_warning_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Following Distance Warning Count"
    type: sum
    sql: ${distance_warning_events} ;;
    # drill_fields: [operator_name,total_distance_warning_count, total_distance_warning_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distance_warning_count_drill_down, daily_summary.total_distance_warning_points_drill_down]
  }

  measure: total_distance_harsh_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Following Distance Warning and Harsh Braking Count"
    type: sum
    sql: ${distance_harsh_events} ;;
    # drill_fields: [operator_name,total_distance_harsh_count, total_distance_harsh_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_distance_harsh_count_drill_down, daily_summary.total_distance_harsh_points_drill_down]
  }

  measure: total_collision_warning_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Forward Collision Warning Count"
    type: sum
    sql: ${collision_warning_events} ;;
    # drill_fields: [operator_name,total_collision_warning_count, total_collision_warning_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_collision_warning_count_drill_down, daily_summary.total_collision_warning_points_drill_down]
  }

  measure: total_harsh_braking_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "Harsh Braking Count"
    type: sum
    sql: ${harsh_breaking_events} ;;
    # drill_fields: [operator_name,total_harsh_braking_count, total_harsh_braking_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_harsh_braking_count_drill_down, daily_summary.total_harsh_braking_points_drill_down]
  }

  measure: total_extreme_speeding_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "20+ MPH Over Speed Limit Count"
    type: sum
    sql: ${extreme_speeding_events} ;;
    # drill_fields: [operator_name,total_extreme_speeding_count, total_extreme_speeding_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_extreme_speeding_count_drill_down, daily_summary.total_extreme_speeding_points_drill_down]
  }

  measure: total_high_speeding_count_drill_down {
    group_label: "Event Counts Drill Down"
    label: "10-20 MPH Over Speed Limit Count"
    type: sum
    sql: ${high_speeding_events} ;;
    # drill_fields: [operator_name,total_high_speeding_count, total_high_speeding_points]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [operator_name, daily_summary.formatted_day, daily_summary.total_high_speeding_count_drill_down, daily_summary.total_high_speeding_points_drill_down]
  }

######################################################################

  measure: high_speeding_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "High Speeding"
    type: number
    sql: SUM(${high_speeding_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: extreme_speeding_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Extreme Speeding"
    type: number
    sql: SUM(${extreme_speeding_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: camera_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Camera Covered"
    type: number
    sql: SUM(${camera_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: distracted_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Driver Distracted"
    type: number
    sql: SUM(${distracted_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: smoking_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Driver Smoking"
    type: number
    sql: SUM(${smoking_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: cell_phone_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Driver Using Cell Phone"
    type: number
    sql: SUM(${cell_phone_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: distance_warning_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Distance Warning Only"
    type: number
    sql: SUM(${distance_warning_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: distance_harsh_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Distance Warning and Harsh Breaking"
    type: number
    sql: SUM(${distance_harsh_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
  }

  measure: collision_warning_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Collission Warning"
    type: number
    sql: SUM(${collision_warning_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: harsh_breaking_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Harsh Breaking Only"
    type: number
    sql: SUM(${harsh_breaking_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: seat_belt_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "No Seat Belt"
    type: number
    sql: SUM(${seat_belt_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: policy_category_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Policy Category"
    type: number
    sql: SUM(${policy_category_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: safety_category_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Safety Category"
    type: number
    sql: SUM(${safety_category_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  measure: speeding_category_events_per_drive_time {
    group_label: "Events per Drive Time"
    label: "Speeding Category"
    type: number
    sql: SUM(${speeding_category_events}) / NULLIFZERO(SUM(${total_drive_time} - ${total_idle_time})/3600) ;;
    value_format: "0.###"
  }

  parameter: time_interval {
    type: string
    allowed_value: {value: "Weekly"}
    allowed_value: {value: "Monthly"}
  }

  dimension: primary_violation_is_speeding {
    group_label: "Category Primary Violation"
    type: yesno
    sql: (${primary_violation} = '10-20 MPH Over Speed Limit' OR ${primary_violation} = '20+ MPH Over Speed Limit') AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_policy {
    group_label: "Category Primary Violation"
    type: yesno
    sql: (${primary_violation} = 'No Seat Belt' OR ${primary_violation} = 'Driver Using Cell Phone' OR ${primary_violation} = 'Camera Covered' OR ${primary_violation} = 'Driver Smoking') AND ${coaching_recommended} = 'Yes';;
  }

  dimension: primary_violation_is_safety {
    group_label: "Category Primary Violation"
    type: yesno
    sql: (${primary_violation} = 'Driver Distracted' OR ${primary_violation} = 'Harsh Braking' OR ${primary_violation} = 'Following Distance Warning' OR ${primary_violation} = 'Forward Collision Warning' OR ${primary_violation} = 'Following Distance Warning and Harsh Braking') AND ${coaching_recommended} = 'Yes' ;;
  }

  measure: unique_primary_violation_count {
    type: count_distinct
    sql: ${operator_name} ;;
    drill_fields: [operator_name,total_policy_weekly_events,total_safety_weekly_events,total_speeding_weekly_events]
  }

  measure: total_policy_category_count {
    group_label: "Category Count"
    label: "Total Policy Count"
    type: sum
    sql: ${policy_category_events} ;;
    drill_fields: [policy_drill*]
  }

  measure: total_safety_category_count {
    group_label: "Category Count"
    label: "Total Safety Count"
    type: sum
    sql: ${safety_category_events} ;;
    drill_fields: [safety_drill*]
  }

  measure: total_speeding_category_count {
    group_label: "Category Count"
    label: "Total Speeding Count"
    type: sum
    sql: ${speeding_category_events} ;;
    drill_fields: [speeding_drill*]
  }

  dimension: primary_violation_is_high_speeding {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = '10-20 MPH Over Speed Limit' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_extreme_speeding {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = '20+ MPH Over Speed Limit' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_no_seat_belt {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'No Seat Belt' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_using_cell_phone {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Driver Using Cell Phone' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_camera_covered {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Camera Covered' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_driver_smoking {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Driver Smoking' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_driver_distracted {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Driver Distracted' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_harsh_braking {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Harsh Braking' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_distance_warning {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Following Distance Warning' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_collision_warning {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Forward Collision Warning' AND ${coaching_recommended} = 'Yes' ;;
  }

  dimension: primary_violation_is_distance_warning_harsh_braking {
    group_label: "Primary Violation Counts"
    type: yesno
    sql: ${primary_violation} = 'Following Distance Warning and Harsh Braking' AND ${coaching_recommended} = 'Yes' ;;
  }

  measure: primary_violation_is_high_speeding_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_high_speeding: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_extreme_speeding_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_extreme_speeding: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_no_seat_belt_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_no_seat_belt: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_using_cell_phone_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_using_cell_phone: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_camera_covered_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_camera_covered: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_driver_smoking_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_driver_smoking: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_driver_distracted_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_driver_distracted: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_harsh_braking_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_harsh_braking: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_distance_warning_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_distance_warning: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_collision_warning_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_collision_warning: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  measure: primary_violation_is_distance_warning_harsh_braking_count {
    group_label: "Primary Violation Counts"
    type: count_distinct
    sql: ${operator_name} ;;
    filters: [primary_violation_is_distance_warning_harsh_braking: "Yes"]
    drill_fields: [primary_violation_drills*]
  }

  dimension: operator_email {
    type: string
    sql: ${drivers.operator_email} ;;
  }

  set: policy_drill {
    fields: [
      operator_name,
      total_seat_belt_points,
      total_cell_phone_points,
      total_camera_points,
      total_smoking_points
    ]
  }

  set: safety_drill {
    fields: [
      operator_name,
      total_distracted_points,
      total_distance_warning_points,
      total_distance_harsh_points,
      total_collision_warning_points,
      total_harsh_braking_points
    ]
  }

  set: speeding_drill {
    fields: [
      operator_name,
      total_extreme_speeding_points,
      total_high_speeding_points
    ]
  }

  set: detail {
    fields: [
      week_start,
      operator_name_link,
      formatted_coaching_recommended,
      primary_violation,
      secondary_violation,
      total_weekly_points,
      total_weekly_events,
      total_weekly_drive_time,
      total_weekly_idle_time,
      total_weekly_drive_distance
    ]
  }

  set: primary_violation_drills {
    fields: [operator_name, operator_email, total_policy_weekly_events,total_safety_weekly_events,total_speeding_weekly_events]
  }
}
