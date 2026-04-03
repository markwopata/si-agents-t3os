view: int_assets {
  sql_table_name: "ANALYTICS"."ASSETS"."INT_ASSETS" ;;

  ## ————— Drill Set —————

  set: detail_drill {
    fields: [asset_id, make, model, status, market_name]
  }

  ## ————— Primary Key —————

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    description: "Unique identifier for each asset"
    value_format_name: id
  }

  ## ————— String Dimensions —————

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
    description: "Current inventory status of the asset"
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
    description: "Type classification of the asset"
  }

  dimension: battery_voltage_type {
    type: string
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE" ;;
    description: "Battery voltage type for the asset"
  }

  dimension: business_segment_name {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
    description: "Name of the business segment the asset belongs to"
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
    description: "Equipment category name"
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
    description: "Custom display name assigned to the asset"
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    description: "Text description of the asset"
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
    description: "Equipment class classification"
  }

  dimension: inventory_branch_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
    description: "Name of the branch where the asset is inventoried"
  }

  dimension: inventory_transit_status {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSIT_STATUS" ;;
    description: "Transit status of the asset within inventory"
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    description: "Invoice number associated with the asset"
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
    description: "License plate number for the asset"
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
    description: "Manufacturer or make of the asset"
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    description: "Name of the market the asset is assigned to"
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
    description: "Model name of the asset"
  }

  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
    description: "Name of the company that owns the asset"
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
    description: "Parent category name for the asset classification"
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
    description: "Name of the payout program the asset is enrolled in"
  }

  dimension: payout_program_type {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE" ;;
    description: "Type of payout program for the asset"
  }

  dimension: rental_branch_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
    description: "Name of the branch handling the rental"
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
    description: "Serial number of the asset"
  }

  dimension: serial_number_or_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_OR_VIN" ;;
    description: "Serial number or VIN, whichever is available"
  }

  dimension: service_branch_name {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
    description: "Name of the branch responsible for servicing the asset"
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    description: "State where the asset is located"
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
    description: "Current status of the asset"
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
    description: "Sub-category name for the asset classification"
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
    description: "Admin URL link for the asset"
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    description: "T3 platform URL link for the asset"
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
    description: "Vehicle Identification Number"
  }

  ## ————— Number Dimensions —————

  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
    description: "ID of the company associated with the asset"
    value_format_name: id
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
    description: "Payout percentage for the asset"
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
    description: "ID for the asset type classification"
    value_format_name: id
  }

  dimension: battery_voltage_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
    description: "ID for the battery voltage type"
    value_format_name: id
  }

  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
    description: "ID of the business segment"
    value_format_name: id
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
    description: "ID for the equipment category"
    value_format_name: id
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    description: "ID for the equipment class"
    value_format_name: id
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
    description: "ID for the equipment manufacturer"
    value_format_name: id
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
    description: "ID for the equipment model"
    value_format_name: id
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
    description: "ID of the branch where the asset is inventoried"
    value_format_name: id
  }

  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
    description: "ID of the market company"
    value_format_name: id
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    description: "ID of the market the asset is assigned to"
    value_format_name: id
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    description: "Original Equipment Cost of the asset"
  }

  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
    description: "ID of the parent category"
    value_format_name: id
  }

  dimension: payout_program_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
    description: "ID of the payout program"
    value_format_name: id
  }

  dimension: payout_program_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
    description: "ID of the payout program type"
    value_format_name: id
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
    description: "ID of the branch handling the rental"
    value_format_name: id
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
    description: "ID of the branch responsible for servicing"
    value_format_name: id
  }

  dimension: sub_category_id {
    hidden: yes
    type: number
    sql: ${TABLE}."SUB_CATEGORY_ID" ;;
    description: "ID of the sub-category"
    value_format_name: id
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
    description: "ID of the tracker installed on the asset"
    value_format_name: id
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    description: "Model year of the asset"
  }

  ## ————— Boolean Dimensions —————

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
    description: "Whether the asset has been deleted"
  }

  dimension: is_es_owned_company {
    type: yesno
    sql: ${TABLE}."IS_ES_OWNED_COMPANY" ;;
    description: "Whether the asset belongs to an ES-owned company"
  }

  dimension: is_in_transit {
    type: yesno
    sql: ${TABLE}."IS_IN_TRANSIT" ;;
    description: "Whether the asset is currently in transit"
  }

  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
    description: "Whether the asset is managed by an ES-owned market"
  }

  dimension: is_own_program_asset {
    type: yesno
    sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
    description: "Whether the asset is part of the Own Program"
  }

  dimension: is_payout_program_enrolled {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_ENROLLED" ;;
    description: "Whether the asset is enrolled in a payout program"
  }

  dimension: is_payout_program_unpaid {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_UNPAID" ;;
    description: "Whether the payout program payment is unpaid"
  }

  dimension: is_rerent_asset {
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
    description: "Whether the asset is a re-rent asset"
  }

  ## ————— Dimension Groups (Timestamps) —————

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
    description: "Timestamp when the asset record was created"
  }

  dimension_group: date_deleted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_DELETED" ;;
    description: "Timestamp when the asset was deleted"
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
    description: "Timestamp when the asset record was last updated"
  }

  dimension_group: first_rental {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
    description: "Date of the first rental for this asset"
  }

  dimension_group: last_off_rent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_OFF_RENT_DATE" ;;
    description: "Date when the asset was last taken off rent"
  }

  dimension_group: last_rental {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_RENTAL_DATE" ;;
    description: "Date of the most recent rental for this asset"
  }

  dimension_group: latest_rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LATEST_RENTAL_START_DATE" ;;
    description: "Start date of the latest rental for this asset"
  }

  dimension_group: purchase {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."PURCHASE_DATE" ;;
    description: "Date the asset was purchased"
  }

  dimension_group: tracker_install {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."TRACKER_INSTALL_DATE" ;;
    description: "Date when a tracker was installed on the asset"
  }

  ## ————— Formatted Dates —————

  dimension: formatted_first_rental_date {
    group_label: "HTML Formatted Dates"
    label: "First Rental Date"
    type: date
    sql: ${first_rental_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    description: "Formatted date for First Rental Date displayed as month abbreviation, day, and year (e.g., Jan 15, 2026)"
  }

  dimension: formatted_last_off_rent_date {
    group_label: "HTML Formatted Dates"
    label: "Last Off Rent Date"
    type: date
    sql: ${last_off_rent_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    description: "Formatted date for Last Off Rent Date displayed as month abbreviation, day, and year (e.g., Jan 15, 2026)"
  }

  dimension: formatted_last_rental_date {
    group_label: "HTML Formatted Dates"
    label: "Last Rental Date"
    type: date
    sql: ${last_rental_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    description: "Formatted date for Last Rental Date displayed as month abbreviation, day, and year (e.g., Jan 15, 2026)"
  }

  dimension: formatted_latest_rental_start_date {
    group_label: "HTML Formatted Dates"
    label: "Latest Rental Start Date"
    type: date
    sql: ${latest_rental_start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    description: "Formatted date for Latest Rental Start Date displayed as month abbreviation, day, and year (e.g., Jan 15, 2026)"
  }

  ## ————— Measures —————

  measure: count {
    type: count
    description: "Total number of asset records"
    drill_fields: [detail_drill*]
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
    description: "Sum of Original Equipment Cost across all assets"
    drill_fields: [detail_drill*]
  }

  measure: average_oec {
    type: average
    sql: ${oec} ;;
    description: "Average Original Equipment Cost across all assets"
    drill_fields: [detail_drill*]
  }
}
