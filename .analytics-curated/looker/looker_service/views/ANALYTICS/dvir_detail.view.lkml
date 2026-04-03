view: dvir_detail {
  sql_table_name: "PARTS_INVENTORY"."DVIR_DETAIL"
    ;;

  dimension: asset_defect_comment {
    type: string
    sql: ${TABLE}."ASSET_DEFECT_COMMENT" ;;
  }

  dimension_group: asset_defect_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_DEFECT_CREATED_DATE" ;;
  }

  dimension_group: asset_defect_resolution {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_DEFECT_RESOLUTION_DATE" ;;
  }

  dimension: asset_defect_severity {
    type: string
    sql: ${TABLE}."ASSET_DEFECT_SEVERITY" ;;
  }

  dimension: asset_defect_status {
    type: string
    sql: ${TABLE}."ASSET_DEFECT_STATUS" ;;
  }

  dimension: asset_defect_type {
    type: string
    sql: ${TABLE}."ASSET_DEFECT_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: driver_id {
    type: number
    sql: ${TABLE}."DRIVER_ID" ;;
  }

  dimension_group: dvir_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DVIR_CREATED_DATE" ;;
  }

  dimension: dvir_id {
    type: string
    sql: ${TABLE}."DVIR_ID" ;;
  }

  dimension: dvir_type {
    type: string
    sql: ${TABLE}."DVIR_TYPE" ;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: CAST(
    CONCAT(${TABLE}."DVIR_ID",${TABLE}."WORK_ORDER_ID")
    as VARCHAR);;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: open_wo_count {
    type: count_distinct
    drill_fields: [dvir_wo_detail*]
    sql: ${work_order_id};;
  }

  measure: times_defect_reported {
    type: count_distinct
    sql: ${dvir_id} ;;
  }

  measure: unresolved_defects{
    type: count_distinct
    filters: [asset_defect_resolution_date: "NULL"]
    sql: ${work_order_id} ;;
  }

  measure: open_dvir{
    type: yesno
    sql: ${unresolved_defects} > 0 ;;
  }

  set: dvir_wo_detail {
    fields: [
      times_defect_reported,
      asset_id,
      assets.year,
      assets.make,
      assets.model,
      company_purchase_order_line_items.license_plate,
      company_purchase_order_line_items.license_state_id,
      company_purchase_order_line_items.license_expiration_date,
      markets.name,
      asset_defect_type,
      asset_defect_severity,
      asset_defect_comment,
      work_order_id,
      work_orders.date_created_date,
      users.created_by,
      work_orders.2_days_old
      ]
  }
}

view: dvir_detail_aggregate {
  derived_table: {
    sql:
      SELECT ASSET_ID, COUNT(DISTINCT CASE WHEN ASSET_DEFECT_RESOLUTION_DATE IS NULL THEN WORK_ORDER_ID END) AS unresolved_defects
      FROM ${dvir_detail.SQL_TABLE_NAME} AS divir_detail
      GROUP BY ASSET_ID ;;
    }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: unresolved_defects {
      type: number
      sql: ${TABLE}."UNRESOLVED_DEFECTS" ;;
    }

    measure: open_dvir{
      type: yesno
      sql: ${unresolved_defects} > 0 ;;
      }
}


