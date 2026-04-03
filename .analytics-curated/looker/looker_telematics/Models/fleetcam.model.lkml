connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/fleetcam_points.view.lkml"
include: "/Dashboards/Driver_Evaluation/views/*"

explore: weekly_summary {
  group_label: "Driver Evaluation"
  case_sensitive: no

  join: daily_summary {
    type: inner
    relationship: one_to_many
    sql_on: ${weekly_summary.week_start} = ${daily_summary.week_start} AND ${weekly_summary.operator_id} = ${daily_summary.operator_id} ;;
  }

  join: events_no_seat_belt {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_no_seat_belt.event_date_date} = ${daily_summary.day} AND ${events_no_seat_belt.operator_id} = ${daily_summary.operator_id} and ${events_no_seat_belt.event_type} = 'No Seat Belt' ;;
  }

  join: events_cell_phone {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_cell_phone.event_date_date} = ${daily_summary.day} AND ${events_cell_phone.operator_id} = ${daily_summary.operator_id} and ${events_cell_phone.event_type} = 'Driver Using Cell Phone' ;;
  }

  join: events_camera_covered {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_camera_covered.event_date_date} = ${daily_summary.day} AND ${events_camera_covered.operator_id} = ${daily_summary.operator_id} and ${events_camera_covered.event_type} = 'Camera Covered' ;;
  }

  join: events_smoking {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_smoking.event_date_date} = ${daily_summary.day} AND ${events_smoking.operator_id} = ${daily_summary.operator_id} and ${events_smoking.event_type} = 'Driver Smoking' ;;
  }

  join: events_driver_distracted {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_driver_distracted.event_date_date} = ${daily_summary.day} AND ${events_driver_distracted.operator_id} = ${daily_summary.operator_id} and ${events_driver_distracted.event_type} = 'Driver Distracted' ;;
  }

  join: events_collision_warning {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_collision_warning.event_date_date} = ${daily_summary.day} AND ${events_collision_warning.operator_id} = ${daily_summary.operator_id} and ${events_collision_warning.event_type} = 'Forward Collision Warning' ;;
  }

  join: events_distance_warning {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_distance_warning.event_date_date} = ${daily_summary.day} AND ${events_distance_warning.operator_id} = ${daily_summary.operator_id} and ${events_distance_warning.event_type} = 'Following Distance Warning' ;;
  }

  join: events_harsh_braking {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_harsh_braking.event_date_date} = ${daily_summary.day} AND ${events_harsh_braking.operator_id} = ${daily_summary.operator_id} and ${events_harsh_braking.event_type} = 'Harsh Braking' ;;
  }

  join: events_distance_and_harsh_warning {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_distance_and_harsh_warning.event_date_date} = ${daily_summary.day} AND ${events_distance_and_harsh_warning.operator_id} = ${daily_summary.operator_id} and ${events_distance_and_harsh_warning.event_type} = 'Following Distance Warning and Harsh Breaking' ;;
  }

  join: events_high_speeding {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_high_speeding.event_date_date} = ${daily_summary.day} AND ${events_high_speeding.operator_id} = ${daily_summary.operator_id} and ${events_high_speeding.event_type} = '10-20 MPH Over Speed Limit' ;;
  }

  join: events_extreme_speeding {
    from: events
    type: inner
    relationship: one_to_one
    sql_on: ${events_extreme_speeding.event_date_date} = ${daily_summary.day} AND ${events_extreme_speeding.operator_id} = ${daily_summary.operator_id} and ${events_extreme_speeding.event_type} = '20+ MPH Over Speed Limit' ;;
  }

  join: drivers {
    type: inner
    relationship: many_to_one
    sql_on: ${weekly_summary.operator_id} = ${drivers.operator_id} ;;
  }

  # Coaching only joined to avoid LookML error when joining drivers view, which has a dimension with a coaching reference
  join: coaching {
    type: left_outer
    relationship: one_to_many
    sql_on: ${coaching.user_id} = ${drivers.user_id} ;;
  }

  always_join: [drivers]
}

explore: driver_evaluation_dashboard_info {
  group_label: "Driver Evaluation"
  case_sensitive: no
}

explore: fleetcam_points {
  case_sensitive: no
}

explore: driver_assignments {
  group_label: "Driver Evaluation"
  case_sensitive: no

  join: drivers {
    type: inner
    relationship: many_to_one
    sql_on: ${driver_assignments.user_id} = ${drivers.user_id} ;;
  }

  # Coaching only joined to avoid LookML error when joining drivers view, which has a dimension with a coaching reference
  join: coaching {
    type: left_outer
    relationship: one_to_many
    sql_on: ${coaching.user_id} = ${drivers.user_id} ;;
  }

  always_join: [drivers]
}

explore: latest_asset_assignments {
  group_label: "Driver Evaluation"
  case_sensitive: no
  join: drivers_incl_out_of_program {
    type: left_outer
    relationship: many_to_one
    sql_on: ${latest_asset_assignments.driver_user_id} = ${drivers_incl_out_of_program.user_id} ;;
  }
}

explore: firmware_watch {
  group_label: "Driver Evaluation"
  case_sensitive: no
  description: "Seat Belt occurences by day for device_serial IN ('003F00B1A1',
                                                                  '003F0071B1',
                                                                  '003F007976',
                                                                  '003F006FEF',
                                                                  '003F007270',
                                                                  '003F00AD82',
                                                                  '003F0064D6',
                                                                  '003F00A861',
                                                                  '003F006D7D',
                                                                  '003F006EBC')"
}

explore: coaching {
  group_label: "Driver Evaluation"
  case_sensitive: no
  join: drivers {
    type: inner
    relationship: many_to_one
    sql_on: ${coaching.user_id} = ${drivers.user_id} ;;
  }
  always_join: [drivers]
}

explore: drivers {
  group_label: "Driver Evaluation"
  case_sensitive: no
  join: coaching {
    type: left_outer
    relationship: one_to_many
    sql_on: ${coaching.user_id} = ${drivers.user_id} ;;
  }
}

explore: coaching_fan_out {
  group_label: "Driver Evaluation"
  case_sensitive: no
  join: drivers {
    type: inner
    relationship: many_to_one
    sql_on: ${coaching_fan_out.user_id} = ${drivers.user_id} ;;
  }
  join: coaching {
    type: inner
    relationship: many_to_one
    sql_on: ${coaching.key} = ${coaching_fan_out.key} ;;
  }
  always_join: [drivers]
}

explore: events_after_coaching {
  group_label: "Driver Evaluation"
  case_sensitive: no
}

explore: coaching_eval_card {
  group_label: "Driver Evaluation"
  case_sensitive: no
}
