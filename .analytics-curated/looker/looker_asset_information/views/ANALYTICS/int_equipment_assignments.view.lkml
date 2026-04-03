view: int_equipment_assignments {
  sql_table_name: "ANALYTICS"."ASSETS"."INT_EQUIPMENT_ASSIGNMENTS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_start {
    type: date
    sql: ${TABLE}.date_start ;;
  }
  dimension: asset_end {
    type: date
    sql: ${TABLE}.date_end ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_start_formatted {
    group_label: "Formatted Dates"
    label: "Asset Start"
    type: date_time
    datatype: datetime
    sql: ${date_start_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }
  dimension: asset_end_formatted {
    group_label: "Formatted Dates"
    label: "Asset End"
    type: date_time
    datatype: datetime
    sql: ${date_end_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }
  dimension: equipment_assignment_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }
  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }
  dimension: is_last_assignment_on_day {
    type: yesno
    sql: ${TABLE}."IS_LAST_ASSIGNMENT_ON_DAY" ;;
  }
  dimension_group: next_date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEXT_DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: rental_duration {
    type: number
    sql: ${TABLE}."RENTAL_DURATION" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension: asset_id_html {
    group_label: "Asset ID HTML"
    label: "Asset ID"
    sql: ${asset_id} ;;
    html:
    <a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id._value}}" style='color: blue;'
    target="_blank"><b>{{asset_id._value}}</b> ➔</a>
    ;;
  }

    dimension_group: delivery {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${deliveries.completed_raw} ;;
    }

  dimension: delivery_formatted {
    group_label: "Formatted Dates"
    label: "Delivery Date"
    type: date_time
    datatype: datetime
    sql: ${delivery_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }

    dimension: asset_duration {
      label: "Asset Duration (Days)"
      type: number
      sql: CASE WHEN ${asset_end} = '9999-12-30'
        THEN DATEDIFF('hour', ${delivery_time}, CURRENT_TIMESTAMP()) / 24.0
        ELSE DATEDIFF('hour', ${delivery_time}, ${date_end_time}) / 24.0
        END ;;
      value_format_name: "decimal_1"
    }

    dimension: asset_duration_html {
      label: "Asset Duration"
      type: string
      sql:
        CASE
          WHEN ABS(${asset_duration}) < 1 AND ROUND(ABS(${asset_duration} * 24), 0) = 1
            THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hour'
          WHEN ABS(${asset_duration}) < 1
            THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hours'
          WHEN ABS(${asset_duration}) >= 1 AND round(ABS(${asset_duration}),0) < 2
            THEN TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' day'
          ELSE TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' days'
        END ;;
    }

  measure: count {
    type: count
  }
}
