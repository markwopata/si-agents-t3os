view: sync_log_po {
 derived_table: {
  sql: SELECT *,CONVERT_TIMEZONE('America/Chicago',DATE_SYNCED) as date_convert--,CAST(date_synced AS TIMESTAMP) AS timestamp_date_sync

FROM ANALYTICS.CONCUR.SYNC_LOG_PO;;
}

  dimension_group: date_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_SYNCED" ;;
  }
  dimension_group: date_convert {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CONVERT" ;;
  }

  # dimension: formatted_date_sync {
  #   type: string
  #   sql: ${TABLE}."DATE_SYNCED" ;;
  # }


  # dimension_group: date_synced {
  #   type: time
  #   timeframes: [raw, time, date, week, month, quarter, year]
  #   datatype: timestamp
  #   sql: ${formatted_date_sync} ;;
  # }

  # dimension_group: formatted_date_sync {
  #   type: time
  #   timeframes: [raw, time, date, week, month, quarter, year]
  #   convert_tz: yes
  #   value_format: "%Y-%m-%d %H:%M:%S.%f"  # Format to match your timestamp
  #   sql: CONVERT_TIMEZONE('UTC', ${TABLE}."DATE_SYNCED") ;;
  # }

  # dimension_group: order_date{
  # type: time
  # timeframes: [date, week, month, year]
  # datatype: date
  # sql: ${TABLE}.order_date;;

  # }



  # dimension_group: date_synced {
  #   type: time

  #   sql: ${TABLE}."DATE_SYNCED" ;;
  # }

  # dimension: timestamp_date_sync {
  #   type: time
  #   sql: ${TABLE}.date_sync ;;
  #   convert_tz: no
  #   timeframes: [hour, day, week, month, year]
  # }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
