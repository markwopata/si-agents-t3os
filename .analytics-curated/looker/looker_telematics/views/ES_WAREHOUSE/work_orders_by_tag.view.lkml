view: work_orders_by_tag {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG"
    ;;

  dimension: company_tag_id {
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
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

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${first_name} || ' '|| ${last_name} ;;
  }

  dimension: name {
    label: "WO Tag"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: user_assignment_end {
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
    sql: CAST(${TABLE}."USER_ASSIGNMENT_END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: user_assignment_start {
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
    sql: CAST(${TABLE}."USER_ASSIGNMENT_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_order_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  measure: work_order_count {
    type: count_distinct
    drill_fields: [name, first_name, last_name, work_order_id]
    sql: ${work_order_id}  ;;
  }

  dimension:  dated_last_year_month{
    type: yesno
    sql: extract(day from ${date_completed_raw}) <= extract(day from (date_trunc('day', current_date)))
          and extract(month from ${date_completed_raw})  = extract(month from (date_trunc('month', dateadd(month,-1,current_date))))
          and extract(year from ${date_completed_raw}) = extract(year from (date_trunc('year', current_date))) ;;
  }

  dimension: current_year_month {
    type: yesno
    sql: extract(month from ${date_completed_raw})  = extract(month from (date_trunc('month', current_date)))
      and extract(year from ${date_completed_raw})  = extract(year from  (date_trunc('year', current_date))) ;;

  }

  measure: month_to_date_work_order_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    #new filter to find the current mon and year
    filters: {
      field: current_year_month
      value: "Yes"
    }
    # link: {
    #   label: "Month To Date Revenue by Day"
    #   url: "/looks/8?&f[users.Full_Name]={{ _filters['users.Full_Name'] | url_encode }}"
    drill_fields: [name, first_name, last_name]
  }

  measure: last_mtd_work_order_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: {
      field:dated_last_year_month
      value: "Yes"
    }
    drill_fields: [name, first_name, last_name]
  }

  dimension:  current_ytd_by_work_order_count {
    type: yesno
    sql: (extract(day from ${date_created_raw}) <= extract(day from (date_trunc('day', current_date))))
          and extract(month from ${date_created_raw})  = extract(month from (date_trunc('month', current_date)))
          and extract(year from ${date_created_raw}) = extract(year from (date_trunc('year', current_date)))
          OR
          (extract(month from ${date_created_raw})  < extract(month from (date_trunc('month', current_date))))
          and extract(year from ${date_created_raw}) = extract(year from (date_trunc('year', current_date))) ;;
  }

  dimension:  last_ytd_by_work_order_count{
    type: yesno
    sql: (extract(day from ${date_created_raw}) <= extract(day from (date_trunc('day', current_date))))
          and extract(month from ${date_created_raw})  = extract(month from (date_trunc('month', current_date)))
          and extract(year from ${date_created_raw}) = extract(year from (date_trunc('year', dateadd(year,-1,current_date))))
          OR
          (extract(month from ${date_created_raw})  < extract(month from (date_trunc('month', current_date))))
          and extract(year from ${date_created_raw}) = extract(year from (date_trunc('year', dateadd(year,-1,current_date)))) ;;
  }

  measure: year_to_date_work_order_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    #new filter to find the current mon and year
    filters: {
      field: current_ytd_by_work_order_count
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: last_year_to_date_work_order_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: {
      field:last_ytd_by_work_order_count
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  dimension: wo_tag_is_replace_tracker {
    type: yesno
    sql: ${name} = 'Replace Tracker' ;;
  }

  measure: replace_tracker_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_replace_tracker: "Yes"]
  }

  dimension: wo_tag_is_new_tracker {
    type: yesno
    sql: ${name} = 'New Tracker' ;;
  }

  measure: new_tracker_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_new_tracker: "Yes"]
  }

  dimension: wo_tag_is_new_keypad {
    type: yesno
    sql: ${name} = 'New Keypad' ;;
  }

  measure: new_keypad_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_new_keypad: "Yes"]
  }

  dimension: wo_tag_is_replace_keypad {
    type: yesno
    sql: ${name} = 'Replace Keypad' ;;
  }

  measure: replace_keypad_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_replace_keypad: "Yes"]
  }

  dimension: wo_tag_is_tracker_repair {
    type: yesno
    sql: upper(${name}) like upper('Tracker repair%') ;;
  }

  measure: tracker_repair_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_tracker_repair: "Yes"]
  }

  dimension: wo_tag_is_telematics_check {
    type: yesno
    sql: ${name} = 'Telematics Check' ;;
  }

  measure: telematics_check_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_telematics_check: "Yes"]
  }

  dimension: wo_tag_is_replace_ble_device {
    type: yesno
    sql: ${company_tag_id} = 721 ;;
  }

  measure: replace_BLE_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_replace_ble_device: "Yes"]
  }

  dimension: wo_tag_is_new_BLE_device {
    type: yesno
    sql: ${company_tag_id} = 720 ;;
  }

  measure: new_BLE_device_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_new_BLE_device: "Yes"]
  }

  dimension: wo_tag_is_camera_install {
    type: yesno
    sql: ${name} = 'Camera Install' ;;
  }

  measure: camera_install_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_camera_install: "Yes"]
  }

  dimension: wo_tag_is_keypad_removed {
    type: yesno
    sql: ${company_tag_id} = 2664 ;;
  }

  measure: keypad_removed_count {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
    filters: [wo_tag_is_keypad_removed: "Yes"]
    }

  dimension: wo_tag_is_keypad_firmware_update {
      type: yesno
      sql: ${company_tag_id} = 1143 ;;
  }

  measure: keypad_firmware_count {
      type: count_distinct
      sql: ${work_order_id} ;;
      drill_fields: [detail*]
      filters: [wo_tag_is_keypad_firmware_update: "Yes"]
  }

  dimension: wo_tag_is_tracker_firmware_update {
        type: yesno
        sql: ${company_tag_id} = 2122 ;;
  }

  measure: tracker_firmware_count {
        type: count_distinct
        sql: ${work_order_id} ;;
        drill_fields: [detail*]
        filters: [wo_tag_is_tracker_firmware_update: "Yes"]
  }

  set: detail {
    fields: [markets.name, work_order_id_with_link_to_work_order, work_orders.asset_id, assets.make, assets.model, name, date_completed_date]
  }
}
