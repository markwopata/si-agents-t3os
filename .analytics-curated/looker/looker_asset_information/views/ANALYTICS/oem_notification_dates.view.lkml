view: oem_notification_dates {
  derived_table: {
    sql:
      SELECT oem
        , notification_date
        , back_stop_date
      FROM ANALYTICS.WARRANTIES.OEM_NOTIFICATION_DATES ;;
  }

  dimension: oem {
    type: string
    sql: ${TABLE}.oem ;;
  }

  dimension: notification_days {
    type: number
    sql: ${TABLE}.notification_date ;;
  }

  dimension: back_stop_days {
    type: number
    sql: ${TABLE}.back_stop_date ;;
  }
  }
