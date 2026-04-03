view: parts_attributes {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PARTS_ATTRIBUTES" ;;

  dimension: category_confidence {
    type: number
    sql: ${TABLE}."CATEGORY_CONFIDENCE" ;;
  }
  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: freight_class {
    type: string
    sql: ${TABLE}."FREIGHT_CLASS" ;;
  }
  dimension: has_reman_option {
    type: yesno
    sql: ${TABLE}."HAS_REMAN_OPTION" ;;
  }
  dimension: hazardous_material_code {
    type: string
    sql: ${TABLE}."HAZARDOUS_MATERIAL_CODE" ;;
  }
  dimension: hts_code {
    type: string
    sql: ${TABLE}."HTS_CODE" ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${end_date} = '2999-01-01' ;;
  }
  dimension: nmfc {
    type: string
    sql: ${TABLE}."NMFC" ;;
  }
  dimension: oem_part_number {
    type: string
    sql: ${TABLE}."OEM_PART_NUMBER" ;;
  }
  dimension: oem_provider_id {
    type: number
    sql: ${TABLE}."OEM_PROVIDER_ID" ;;
  }
  dimension: package_height {
    type: number
    sql: ${TABLE}."PACKAGE_HEIGHT" ;;
  }
  dimension: package_length {
    type: number
    sql: ${TABLE}."PACKAGE_LENGTH" ;;
  }
  dimension: package_uom {
    type: string
    sql: ${TABLE}."PACKAGE_UOM" ;;
  }
  dimension: package_width {
    type: number
    sql: ${TABLE}."PACKAGE_WIDTH" ;;
  }
  dimension: part_categorization_id {
    type: number
    sql: ${TABLE}."PART_CATEGORIZATION_ID" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: product_height {
    type: number
    sql: ${TABLE}."PRODUCT_HEIGHT" ;;
  }
  dimension: product_length {
    type: number
    sql: ${TABLE}."PRODUCT_LENGTH" ;;
  }
  dimension: product_uom {
    type: string
    sql: ${TABLE}."PRODUCT_UOM" ;;
  }
  dimension: product_width {
    type: number
    sql: ${TABLE}."PRODUCT_WIDTH" ;;
  }
  dimension: purchase_qty {
    type: number
    sql: ${TABLE}."PURCHASE_QTY" ;;
  }
  dimension: purchase_uom {
    type: string
    sql: ${TABLE}."PURCHASE_UOM" ;;
  }
  dimension: schedule_b {
    type: string
    sql: ${TABLE}."SCHEDULE_B" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: unique_key {
    primary_key: yes
    type: number
    sql: ${vendor_id}||' - '||${part_id}||' - '||${end_date} ;;
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
  dimension: vendor_part_categorization_id {
    type: number
    sql: ${TABLE}."VENDOR_PART_CATEGORIZATION_ID" ;;
  }
  dimension: weight {
    type: number
    sql: ${TABLE}."WEIGHT" ;;
  }
  dimension: weight_uom {
    type: string
    sql: ${TABLE}."WEIGHT_UOM" ;;
  }
  measure: count {
    type: count
  }
}

view: parts_attributes_part_id_level {
  derived_table: {
    sql:
      select distinct part_id
           , part_categorization_id
      from ${parts_attributes.SQL_TABLE_NAME} AS parts_attributes
      where END_DATE::date = '2999-01-01'
        and part_categorization_id is not null
      ;;
  }
    dimension: part_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."PART_ID" ;;
    }
  dimension: part_categorization_id {
    type: number
    sql: ${TABLE}."PART_CATEGORIZATION_ID" ;;
  }
}
