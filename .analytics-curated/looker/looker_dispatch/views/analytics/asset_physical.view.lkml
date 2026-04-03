view: asset_physical {
  sql_table_name: "ANALYTICS"."ASSET_DETAILS"."ASSET_PHYSICAL" ;;

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    label: "Owner"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: non_es_branch {
    label: "Non-ES Branch"
    type: yesno
    sql: ${rental_branch_company_id} <> 1854 and ${service_branch_company_id} <> 1854 and ${inventory_branch_company_id} <> 1854 ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: equip_class_name {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: has_tracker {
    type: yesno
    sql: ${TABLE}."HAS_TRACKER" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: inventory_branch_company_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_COMPANY_ID" ;;
  }

  dimension: is_floor_plan {
    type: yesno
    sql: ${TABLE}."IS_FLOOR_PLAN" ;;
  }

  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }

  dimension: is_rerent {
    type: yesno
    sql: ${TABLE}."IS_RERENT" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: purchase_order_status {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_STATUS" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: rental_branch {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH" ;;
  }

  dimension: rental_branch_company_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_COMPANY_ID" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: service_branch {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }

  dimension: service_branch_company_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_COMPANY_ID" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: sub_category_id {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_ID" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

  dimension_group: table_update {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TABLE_UPDATE_DATE" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: own_program {
    type: yesno
    sql: ${company_id} <> 1854 and ${rental_branch_company_id} = 1854 ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [asset_id, parent_category_name, sub_category_name, equip_class_name, make, rental_branch, company_name]
  }





}
