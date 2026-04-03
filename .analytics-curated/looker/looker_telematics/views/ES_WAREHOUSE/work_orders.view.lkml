view: work_orders {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS"
    ;;
  drill_fields: [work_order_id]

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _work_order_id {
    type: number
    # sql: ${TABLE}."_WORK_ORDER_ID" ;; --Taking this out so there aren't duplicates in the explore UI. -Jack G 9/7/21
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: _work_order_status_id {
    type: number
    sql: ${TABLE}."_WORK_ORDER_STATUS_ID" ;;
  }

  dimension_group: archived {
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
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  dimension: customer_user_id {
    type: number
    sql: ${TABLE}."CUSTOMER_USER_ID" ;;
  }

  dimension_group: date_billed {
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
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }

  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }

  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [work_order_id, date_created_raw, date_completed_raw,urgency_level_id,_work_order_status_id,description,billing_notes,invoice_number,date_billed_raw,asset_id,branch_id, severity_level_id,work_order_type_id,
      billing_type_id,mileage_at_service, hours_at_service, work_order_payroll.start_date,work_order_payroll.end_date, work_order_payroll.payroll_hours, work_order_payroll.installer]
  }

  measure: last_completed_inspection {
    type: date
    sql: MAX(CASE WHEN ${work_order_type_id} = 2 and ${work_order_status_id} IN (3, 4) THEN ${date_completed_date} ELSE NULL END);;
  }

  dimension: branch_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/147" target="_blank">Branch</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: trackers_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/148" target="_blank">Trackers</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: wo_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/151" target="_blank">Work Orders</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: keypads_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/149" target="_blank">Keypads</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: ble_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/150" target="_blank">BLE</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: trackers_by_month_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/152" target="_blank">Trackers by Month</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: AR_link {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/138" target="_blank">Accounts Receivable</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: Work_Order_Time_Tracking {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/158" target="_blank">Work Order Time Tracking</a></font></u>   ;;
    sql: ${asset_id};;
  }
}
