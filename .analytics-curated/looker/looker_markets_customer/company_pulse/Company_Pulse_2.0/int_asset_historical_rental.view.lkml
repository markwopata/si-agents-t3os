
view: int_asset_historical_rental {
  sql_table_name: analytics.assets.int_asset_historical ;;

  dimension_group: daily_timestamp {
    type: time
    sql: ${TABLE}."DAILY_TIMESTAMP" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${daily_timestamp_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month {
    group_label: "HTML Formatted Date"
    label: "Date as Month"
    type: date
    sql: ${daily_timestamp_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${daily_timestamp_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: asset_id {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  dimension: asset_type_id {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: asset_type {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension_group: first_rental_date {
    group_label: "Asset Information"
    type: time
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }

  dimension: make {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: make_model {
    group_label: "Asset Information"
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  dimension: year {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: category_id {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: category {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: equipment_class_id {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: is_own_program_asset {
    group_label: "Asset Information"
    type: yesno
    sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
  }

  dimension: is_most_recent {
    type:  yesno
    sql: ${daily_timestamp_date} = current_date;;
  }

  dimension: is_last_day_of_month {
    type:  yesno
    sql: CASE WHEN ${v_dim_dates_bi.is_last_day_of_month} OR ${is_most_recent} THEN TRUE ELSE FALSE END ;;
  }

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  measure: units_on_rent_sum {
    type: sum
    sql:${units_on_rent} ;;
  }

  dimension: in_total_fleet {
    group_label: "Asset Information"
    type: yesno
    sql: ${TABLE}."IN_TOTAL_FLEET" ;;
  }

  dimension: total_oec {
    type: number
    description: "OEC of assets where in_total_fleet = TRUE"
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format_name: usd_0
  }

  measure: total_oec_sum {
    type: sum
    sql: ${total_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: in_rental_fleet {
    type: yesno
    sql: ${TABLE}."IN_RENTAL_FLEET" ;;
  }

  dimension: rental_fleet_oec {
    description: "OEC of asset where in_rental_fleet = TRUE"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: rental_fleet_oec_sum {
    description: "Sum of OEC of assets in_rental_fleet"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_percent_of_total {
    label: "Rental Fleet OEC % of Total"
    type: number
    sql: ${rental_fleet_oec_sum} / NULLIF(SUM(${rental_fleet_oec_sum}) OVER (), 0);;
    value_format_name: percent_1
  }

  dimension: rental_fleet_units {
    type: number
    sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
  }

  measure: rental_fleet_units_sum {
    description: "Total units in the rental fleet"
    type: sum
    sql: ${rental_fleet_units} ;;
  }

  dimension: rental_branch_id {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: rental_branch_name {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }

  dimension: service_branch_id {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: service_branch_name {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
  }

  dimension: inventory_branch_id {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: inventory_branch_name {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }

  dimension: market_id {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: is_rerent_asset {
    group_label: "Asset Information"
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
  }

  dimension: asset_company_id {
    group_label: "Asset Information"
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension:  is_managed_by_es_owned_market {
    group_label: "Market Information"
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
  }

  dimension: market_company_id {
    group_label: "Market Information"
    type: string
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }

  dimension: oec {
    group_label: "Asset Information"
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
  }

  measure: oec_sum {
    type: sum
    sql: ${oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: is_on_rent {
    type: yesno
    sql: ${TABLE}."IS_ON_RENT" ;;
  }

  dimension: is_last_rental_in_day {
    type: yesno
    sql: ${TABLE}."IS_LAST_RENTAL_IN_DAY" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: oec_on_rent {
    description: "OEC of asset on rent after considering asset swaps"
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: oec_on_rent_sum {
    description: "Total OEC of assets on rent after considering asset swaps"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: oec_on_rent_perc {
    description: "Percentage of oec on rent of all rental fleet oec"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: is_asset_unavailable {
    group_label: "Asset Inventory Status Info"
    type: yesno
    sql: ${TABLE}."IS_ASSET_UNAVAILABLE" ;;
  }

  dimension: unavailable_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    value_format_name: usd_0
  }

  measure: unavailable_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    type: sum
    sql: ${unavailable_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_perc {
    description: "Percentage of unavailable oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${unavailable_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: unavailable_units {
    type: number
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }

  measure: unavailable_units_sum {
    description: "Count of all unavailable assets"
    type: sum
    sql: ${unavailable_units} ;;
  }


  dimension: pending_return_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with Pending Return inventory status"
    type: number
    sql: ${TABLE}."PENDING_RETURN_OEC" ;;
    value_format_name: usd_0
  }

  measure: pending_return_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: pending_return_oec_perc {
    description: "Percentage of pending return oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${pending_return_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: pending_return_units {
    group_label: "Asset Inventory Status Info"
    type: number
    sql: ${TABLE}."PENDING_RETURN_UNITS" ;;
    value_format_name: usd_0
  }

  measure: pending_return_units_sum {
    group_label: "Asset Inventory Status Info"
    description: "Count of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_units } ;;
  }

  dimension: needs_inspection_oec {
    group_label: "Asset Inventory Status Info"
    description: "OEC of asset with Needs Inspection inventory status"
    type: number
    sql: CASE WHEN ${asset_inventory_status} ILIKE 'Needs Inspection' THEN ${TABLE}."TOTAL_OEC" ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: needs_inspection_oec_sum {
    group_label: "Asset Inventory Status Info"
    description: "Sum of OEC of assets with Needs Inspection inventory status"
    type: sum
    sql: ${needs_inspection_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: needs_inspection_oec_perc {
    description: "Percentage of Needs Inspection oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${needs_inspection_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: needs_inspection_units {
    group_label: "Asset Inventory Status Info"
    type: number
    sql: CASE WHEN ${asset_inventory_status} ILIKE 'Needs Inspection' THEN ${TABLE}."TOTAL_UNITS" ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: needs_inspection_units_sum {
    group_label: "Asset Inventory Status Info"
    description: "Count of assets with Needs Inspection inventory status"
    type: sum
    sql: ${needs_inspection_units} ;;
  }

  dimension: days_in_status {
    type: number
    sql: ${TABLE}."DAYS_IN_STATUS" ;;
  }



  set: pending_detail {
    fields: [daily_timestamp_date, asset_id, rental_branch_id, rental_branch_name, rental_id, asset_inventory_status, oec]
  }

  set: detail {
    fields: [
      asset_id,
      daily_timestamp_time,
      rental_branch_id,
      service_branch_id,
      inventory_branch_id,
      market_id,
      asset_company_id,
      asset_inventory_status,
      is_rerent_asset,
      market_company_id,
      oec,
      asset_type_id,
      asset_type,
      first_rental_date_time,
      make,
      model,
      year,
      category_id,
      category,
      equipment_class_id,
      equipment_class,
      is_on_rent,
      rental_id
    ]
  }
}
