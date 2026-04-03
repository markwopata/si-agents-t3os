view: asset_swaps {
    derived_table: {
      sql:
          SELECT
              *
          FROM analytics.assets.int_equipment_assignments iea;;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}.rental_id ;;
    }

    dimension: asset_id {
      type: string
      sql: ${TABLE}.asset_id ;;
    }

    dimension: asset_start_date {
      type: date
      sql: ${TABLE}.date_start ;;
    }

    dimension: asset_end_date {
      type: date
      sql: ${TABLE}.date_end ;;
    }

    dimension_group: asset_start_date_group {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: ${TABLE}.date_start ;;
    }

    dimension_group: asset_end_date_group {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: ${TABLE}.date_end ;;
    }

  dimension: asset_duration {
    label: "Asset Duration (Days)"
    type: number
    sql: CASE WHEN ${asset_end_date} = '9999-12-30'
          THEN DATEDIFF('hour', ${asset_start_date_group_time}, CURRENT_TIMESTAMP()) / 24.0
          ELSE DATEDIFF('hour', ${asset_start_date_group_time}, ${asset_end_date_group_time}) / 24.0
          END ;;
    value_format_name: "decimal_1"
  }

  dimension: asset_duration_html {
    label: "Asset Duration"
    type: string
    sql:
    CASE
      WHEN ABS(${asset_duration}) < 1
        THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hours'
      WHEN ABS(${asset_duration}) >= 1 AND ABS(${asset_duration}) < 2
        THEN TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' day'
      ELSE TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' days'
    END ;;
  }



  measure: count {
    type: count
  }



  }
