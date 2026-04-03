view: fleetcam_points {
    derived_table: {
      sql: Select * from analytics.bi_ops.fleetcam_testing ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: driver_name {
      type: string
      sql: ${TABLE}."DRIVER_NAME" ;;
    }

    dimension: driver_source {
      type: string
      sql: ${TABLE}."DRIVER_SOURCE" ;;
    }

    dimension: week_of_year {
      type: number
      sql: ${TABLE}."WEEK_OF_YEAR" ;;
    }

  dimension: coaching_required {
    type: string
    sql: case when ${TABLE}."SEAT_BELT_POINTS" > 0
                  or ${TABLE}."POINTS_PER_HOUR_DRIVEN" >= 2.5
                  or ${TABLE}."TOTAL_POINTS" > 1000
                  THEN 'YES'
                  ELSE 'NO'
                  END;;
  }

    measure: total_points {
      type: sum
      sql: ${TABLE}."TOTAL_POINTS" ;;
    }

    measure: policy_points {
      type: sum
      sql: ${TABLE}."POLICY_POINTS" ;;
    }

    measure: safety_points {
      type: sum
      sql: ${TABLE}."SAFETY_POINTS" ;;
    }

    measure: distracted_count {
      type: sum
      sql: ${TABLE}."DISTRACTED_COUNT" ;;
    }

    measure: smoking_count {
      type: sum
      sql: ${TABLE}."SMOKING_COUNT" ;;
    }

    measure: cell_phone_count {
      type: sum
      sql: ${TABLE}."CELL_PHONE_COUNT" ;;
    }

    measure: collision_count {
      type: sum
      sql: ${TABLE}."COLLISION_COUNT" ;;
    }

    measure: seat_belt_count {
      type: sum
      sql: ${TABLE}."SEAT_BELT_COUNT" ;;
    }

    measure: camera_count {
      type: sum
      sql: ${TABLE}."CAMERA_COUNT" ;;
    }

    measure: distance_harsh_count {
      type: sum
      sql: ${TABLE}."DISTANCE_HARSH_COUNT" ;;
    }

    measure: distance_warning_count {
      type: sum
      sql: ${TABLE}."DISTANCE_WARNING_COUNT" ;;
    }

    measure: harsh_braking_count {
      type: sum
      sql: ${TABLE}."HARSH_BRAKING_COUNT" ;;
    }

    measure: distracted_points {
      type: sum
      sql: ${TABLE}."DISTRACTED_POINTS" ;;
    }

    measure: smoking_points {
      type: sum
      sql: ${TABLE}."SMOKING_POINTS" ;;
    }

    measure: cell_phone_points {
      type: sum
      sql: ${TABLE}."CELL_PHONE_POINTS" ;;
    }

    measure: collision_points {
      type: sum
      sql: ${TABLE}."COLLISION_POINTS" ;;
    }

    measure: seat_belt_points {
      type: sum
      sql: ${TABLE}."SEAT_BELT_POINTS" ;;
    }

    measure: camera_points {
      type: sum
      sql: ${TABLE}."CAMERA_POINTS" ;;
    }

    measure: distance_harsh_points {
      type: sum
      sql: ${TABLE}."DISTANCE_HARSH_POINTS" ;;
    }

    measure: distance_warning_points {
      type: sum
      sql: ${TABLE}."DISTANCE_WARNING_POINTS" ;;
    }

    measure: harsh_braking_points {
      type: sum
      sql: ${TABLE}."HARSH_BRAKING_POINTS" ;;
    }

    measure: total_drive_time {
      type: sum
      sql: ${TABLE}."TOTAL_DRIVE_TIME" ;;
    }

    measure: points_per_hour_driven {
      type: sum
      sql: ${TABLE}."POINTS_PER_HOUR_DRIVEN" ;;
    }

    dimension: recommendation {
      type: string
      sql: ${TABLE}."RECOMMENDATION" ;;
    }

    dimension: primary_violation {
      type: string
      sql: ${TABLE}."PRIMARY_VIOLATION" ;;
    }

    dimension: secondary_violation {
      type: string
      sql: ${TABLE}."SECONDARY_VIOLATION" ;;
    }

    set: detail {
      fields: [
        driver_name,
        driver_source,
        week_of_year,
        total_points,
        policy_points,
        safety_points,
        distracted_count,
        smoking_count,
        cell_phone_count,
        collision_count,
        seat_belt_count,
        camera_count,
        distance_harsh_count,
        distance_warning_count,
        harsh_braking_count,
        distracted_points,
        smoking_points,
        cell_phone_points,
        collision_points,
        seat_belt_points,
        camera_points,
        distance_harsh_points,
        distance_warning_points,
        harsh_braking_points,
        total_drive_time,
        points_per_hour_driven,
        recommendation,
        primary_violation,
        secondary_violation
      ]
    }
  }
