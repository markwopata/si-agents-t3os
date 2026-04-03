view: asset_physical {
  sql_table_name: "ANALYTICS"."ASSET_DETAILS"."ASSET_PHYSICAL" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  dimension: rental_branch {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH" ;;
  }
  dimension: rental_branch_company_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_COMPANY_ID" ;;
  }
  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }
  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }
  dimension: service_branch {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }
  dimension: service_branch_company_id {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_COMPANY_ID" ;;
  }
  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }
  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }
  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }
  dimension: inventory_branch_company_id {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_COMPANY_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: purchase_order_status {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_STATUS" ;;
  }
  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."NUMBER" ;;
  }
  dimension: date_created {
    type: date_raw
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }
  dimension: has_tracker {
    type: yesno
    sql: ${TABLE}."HAS_TRACKER" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: equip_class_name {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }
  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }
  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }
  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }
  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }
  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }
  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }
  dimension: is_rerent {
    type: yesno
    sql: ${TABLE}."IS_RERENT" ;;
  }
  dimension: is_floor_plan {
    type: yesno
    sql: ${TABLE}."IS_FLOOR_PLAN" ;;
  }
  dimension: table_update {
    type: date_raw
    sql: ${TABLE}."TABLE_UPDATE_DATE" ;;
  }
}
