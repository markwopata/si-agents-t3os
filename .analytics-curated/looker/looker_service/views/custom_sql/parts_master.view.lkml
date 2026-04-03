view: parts_master_vw {
  sql_table_name: analytics.parts_inventory.parts_master_vw ;;

  dimension: part_id {
    type: string
    sql: ${TABLE}.PART_ID ;;
    primary_key: yes
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.PART_NUMBER ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.ITEM_ID ;;
  }

  dimension: upc {
    type: string
    sql: ${TABLE}.UPC ;;
  }

  dimension: provider_id {
    type: string
    sql: ${TABLE}.PROVIDER_ID ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}.PROVIDER_NAME ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.PART_NAME ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: msrp {
    type: number
    sql: ${TABLE}.MSRP ;;
  }

  dimension: net_price {
    type: number
    sql: ${TABLE}.NET_PRICE ;;
  }

  dimension: list_price {
    type: number
    sql: ${TABLE}.LIST_PRICE ;;
  }

  dimension: price_start_date {
    type: date
    sql: ${TABLE}.PRICE_START_DATE ;;
  }

  dimension: purchase_qty {
    type: number
    sql: ${TABLE}.PURCHASE_QTY ;;
  }

  dimension: purchase_uom {
    type: string
    sql: ${TABLE}.PURCHASE_UOM ;;
  }

  dimension: weight {
    type: number
    sql: ${TABLE}.WEIGHT ;;
  }

  dimension: weight_uom {
    type: string
    sql: ${TABLE}.WEIGHT_UOM ;;
  }

  dimension: package_length {
    type: number
    sql: ${TABLE}.PACKAGE_LENGTH ;;
  }

  dimension: package_width {
    type: number
    sql: ${TABLE}.PACKAGE_WIDTH ;;
  }

  dimension: package_height {
    type: number
    sql: ${TABLE}.PACKAGE_HEIGHT ;;
  }

  dimension: package_uom {
    type: string
    sql: ${TABLE}.PACKAGE_UOM ;;
  }

  dimension: product_length {
    type: number
    sql: ${TABLE}.PRODUCT_LENGTH ;;
  }

  dimension: product_width {
    type: number
    sql: ${TABLE}.PRODUCT_WIDTH ;;
  }

  dimension: product_height {
    type: number
    sql: ${TABLE}.PRODUCT_HEIGHT ;;
  }

  dimension: product_uom {
    type: string
    sql: ${TABLE}.PRODUCT_UOM ;;
  }

  dimension: freight_class {
    type: string
    sql: ${TABLE}.FREIGHT_CLASS ;;
  }

  dimension: hazardous_material_code {
    type: string
    sql: ${TABLE}.HAZARDOUS_MATERIAL_CODE ;;
  }

  dimension: hts_code {
    type: string
    sql: ${TABLE}.HTS_CODE ;;
  }

  dimension: nmfc {
    type: string
    sql: ${TABLE}.NMFC ;;
  }

  dimension: schedule_b {
    type: string
    sql: ${TABLE}.SCHEDULE_B ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.COUNTRY_CODE ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.CATEGORY ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}.SUBCATEGORY ;;
  }

  dimension: part_containers {
    type: string
    sql: ${TABLE}.PART_CONTAINERS ;;
  }

  dimension: category_confidence {
    type: number
    sql: ${TABLE}.CATEGORY_CONFIDENCE ;;
  }

  dimension: fc_part_type {
    type: string
    sql: ${TABLE}.FC_PART_TYPE ;;
  }

  dimension: area {
    type: string
    sql: ${TABLE}.AREA ;;
  }

  dimension: zone_number {
    type: string
    sql: ${TABLE}.ZONE_NUMBER ;;
  }

  dimension: aisle {
    type: string
    sql: ${TABLE}.AISLE ;;
  }

  dimension: bay {
    type: string
    sql: ${TABLE}.BAY ;;
  }

  dimension: level {
    type: string
    sql: ${TABLE}.LEVEL ;;
  }

  dimension: bin {
    type: string
    sql: ${TABLE}.BIN ;;
  }

  dimension: location_code {
    type: string
    sql: ${TABLE}.LOCATION_CODE ;;
  }

  dimension: palletization_number {
    type: number
    sql: ${TABLE}.PALLETIZATION_NUMBER ;;
  }

  dimension: abc_classification {
    type: string
    sql: ${TABLE}.ABC_CLASSIFICATION ;;
  }

  dimension: kit_bom {
    type: string
    sql: ${TABLE}.KIT_BOM ;;
  }

  dimension: sioc {
    type: yesno
    sql: ${TABLE}.SIOC ;;
  }

  dimension: conveyable {
    type: yesno
    sql: ${TABLE}.CONVEYABLE ;;
  }

  dimension: quality_inspected {
    type: yesno
    sql: ${TABLE}.QUALITY_INSPECTED ;;
  }

  dimension: safety_stock {
    type: number
    sql: ${TABLE}.SAFETY_STOCK ;;
  }

  dimension: fc_stockable {
    type: yesno
    sql: ${TABLE}.fc_stockable ;;
  }


  dimension: part_creation_date {
    type: date
    sql: ${TABLE}.PART_CREATION_DATE ;;
  }

  dimension: updated_date {
    type: date
    sql: ${TABLE}.UPDATED_DATE ;;
  }

  dimension: available_inventory {
    type: number
    sql: ${TABLE}.AVAILABLE_INVENTORY ;;
  }

  dimension: yearly_demand {
    type: number
    sql: ${TABLE}.YEARLY_DEMAND ;;
  }

}
