view: fulfillment_parts_attributes {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."FULFILLMENT_PARTS_ATTRIBUTES" ;;

  dimension: abc_classification {
    type: string
    sql: ${TABLE}."ABC_CLASSIFICATION" ;;
  }
  dimension: aisle {
    type: string
    sql: ${TABLE}."AISLE" ;;
  }
  dimension: area {
    type: string
    sql: ${TABLE}."AREA" ;;
  }
  dimension: bay {
    type: string
    sql: ${TABLE}."BAY" ;;
  }
  dimension: bin {
    type: string
    sql: ${TABLE}."BIN" ;;
  }
  dimension: conveyable {
    type: yesno
    sql: ${TABLE}."CONVEYABLE" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: fc_stockable {
    type: string #changed from yesno to string since it was assuming null=false which is not the case HL 12.5.25
    sql: ${TABLE}."FC_STOCKABLE" ;;
  }

  dimension: kit_bom {
    type: string
    sql: ${TABLE}."KIT_BOM" ;;
  }
  dimension: level {
    type: string
    sql: ${TABLE}."LEVEL" ;;
  }
  dimension: location_code {
    type: string
    sql: ${TABLE}."LOCATION_CODE" ;;
  }
  dimension: palletization_number {
    type: number
    sql: ${TABLE}."PALLETIZATION_NUMBER" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_type {
    type: string
    sql: ${TABLE}."PART_TYPE" ;;
  }
  dimension: quality_inspected {
    type: yesno
    sql: ${TABLE}."QUALITY_INSPECTED" ;;
  }
  dimension: safety_stock {
    type: number
    sql: ${TABLE}."SAFETY_STOCK" ;;
  }
  dimension: sioc {
    type: yesno
    sql: ${TABLE}."SIOC" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: updated_email {
    type: string
    sql: ${TABLE}."UPDATED_EMAIL" ;;
  }
  dimension: updated_user_id {
    type: number
    sql: ${TABLE}."UPDATED_USER_ID" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: zone_number {
    type: string
    sql: ${TABLE}."ZONE_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
