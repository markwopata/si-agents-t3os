  view: t3_inactive_platform {
    derived_table: {
      sql:
      SELECT
        m.MARKET_ID,
        d.TITLE,
        d._ES_UPDATE_TIMESTAMP,
        d.T3_PLATFORM_INACTIVE,
        m.active,
        d.DEPARTMENTID
      FROM analytics.intacct.department d
      LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m
        ON m.MARKET_ID = d.DEPARTMENTID
      WHERE
        d.T3_PLATFORM_INACTIVE = TRUE
        AND m.active = TRUE
    ;;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}.MARKET_ID ;;
    }

    dimension: title {
      type: string
      sql: ${TABLE}.TITLE ;;
    }

    dimension: department_id {
      type: string
      sql: ${TABLE}.DEPARTMENTID ;;
    }

    dimension: t3_platform_inactive {
      type: yesno
      sql: ${TABLE}.T3_PLATFORM_INACTIVE ;;
    }

    dimension: is_active_T3 {
      type: yesno
      sql: ${TABLE}.active ;;
    }

    dimension_group: update_time {
      type: time
      label: "ES_UPDATE_TIMESTAMP"
      timeframes: [time, date, week, month, raw]
      sql: ${TABLE}._ES_UPDATE_TIMESTAMP ;;
    }

    measure: new_addition_count {
      type: count
      label: "New T3 Inactive Admin Active Count"
      description: "Count of new rows where T3 platform is inactive and market is active"
    }
  }
