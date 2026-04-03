view: int_assets {
  sql_table_name: "ANALYTICS"."ASSETS"."INT_ASSETS" ;;

  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }
  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }
  dimension: business_segment_name {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
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
  dimension_group: date_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_DELETED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }
  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }
  dimension_group: first_rental {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FIRST_RENTAL_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }
  dimension: inventory_branch_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }
  dimension: is_es_owned_company {
    type: yesno
    sql: ${TABLE}."IS_ES_OWNED_COMPANY" ;;
  }
  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
  }
  dimension: is_own_program_asset {
    group_label: "Payout Program Info"
    type: yesno
    sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
  }
  dimension: is_payout_program_enrolled {
    group_label: "Payout Program Info"
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_ENROLLED" ;;
  }
  dimension: is_payout_program_unpaid {
    group_label: "Payout Program Info"
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_UNPAID" ;;
  }
  dimension: is_rerent_asset {
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
  }
  dimension_group: last_rental {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_RENTAL_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_name_link {
    type: string
    group_label: "Links"
    label: "Market"
    sql: ${market_name} ;;
    html:
    <a href="https://equipmentshare.looker.com/dashboards/342?Manager+Name=&amp;Work+Phone=&amp;Market+Name={{ value | prepend:'"' | append:'"' | url_encode }}&amp;Job+Title=&amp;Employee+Name=&amp;Work+Email=&amp;Sales+Front+Email=&amp;District=&amp;State=&amp;Market+Type=&amp;Cost+Centers=&amp;Region=&amp;Market+Zip+Code="
       target="_blank"
       style="color:#0063f3; text-decoration:underline;">
      {{ value }} ➔
    </a>;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: oec {
    label: "OEC"
    type: number
    sql: COALESCE(${TABLE}."OEC",0) ;;
    value_format_name: usd_0
  }
  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
  }
  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }
  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }
  dimension: payout_program_id {
    group_label: "Payout Program Info"
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }
  dimension: payout_program_name {
    group_label: "Payout Program Info"
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }
  dimension: payout_program_type {
    group_label: "Payout Program Info"
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE" ;;
  }
  dimension: payout_program_type_id {
    group_label: "Payout Program Info"
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
  }
  dimension_group: purchase {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  dimension: rental_branch_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: serial_number_or_vin {
    label: "Serial # or VIN"
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_OR_VIN" ;;
  }
  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }
  dimension: service_branch_name {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: sub_category_id {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_ID" ;;
  }
  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }
  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }
  dimension_group: tracker_install {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_INSTALL_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: url_admin {
    group_label: "Links"
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }
  dimension: url_t3 {
    group_label: "Links"
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension_group: latest_rental_start_date {
    type: time
    sql: ${TABLE}."LATEST_RENTAL_START_DATE" ;;
  }

  dimension_group: last_off_rent_date {
    type: time
    sql: ${TABLE}."LAST_OFF_RENT_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id_link_to_details {
    type: number
    value_format_name: id
    group_label: "Links"
    label: "Asset ID"
    sql: ${asset_id} ;;
    html: <a href='https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}' target='_blank' style='color:#0063f3; text-decoration:underline;'>{{ value }} ➔</a>;;
  }

  dimension: formatted_last_rental_date {
    group_label: "HTML Formatted Dates"
    label: "Last Rental Date"
    type: date
    sql: ${last_rental_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_latest_rental_start_date {
    group_label: "HTML Formatted Dates"
    label: "Last Rental Start Date"
    type: date
    sql: ${latest_rental_start_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_last_off_rent_date {
    group_label: "HTML Formatted Dates"
    label: "Last Off Rent Date"
    type: date
    sql: ${last_off_rent_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  owning_company_name,
  payout_program_name,
  rental_branch_name,
  market_name,
  sub_category_name,
  inventory_branch_name,
  custom_name,
  business_segment_name,
  description,
  service_branch_name,
  parent_category_name
  ]
  }

}
