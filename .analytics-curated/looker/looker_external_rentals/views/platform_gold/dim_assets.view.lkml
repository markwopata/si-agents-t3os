view: dim_assets {
  sql_table_name: "PLATFORM"."GOLD"."V_ASSETS" ;;

  # PRIMARY KEY
  dimension: asset_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
    description: "Source system for asset data"
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    description: "Natural asset ID"
    value_format_name: id
    link: {
      label: "Asset Details"
      url: "/dashboards/asset_profile?asset_id={{ value }}"
    }
  }

  # ASSET IDENTIFICATION
  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    description: "Asset name"
  }

  dimension: asset_custom_name {
    type: string
    sql: ${TABLE}."ASSET_CUSTOM_NAME" ;;
    description: "Asset custom name"
  }

  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
    description: "Asset description"
  }

  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
    description: "Asset serial number"
  }

  # ASSET CLASSIFICATION
  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
    description: "Asset manufacturer"
    group_label: "Asset Classification"
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
    description: "Asset model"
    group_label: "Asset Classification"
  }

  dimension: asset_make_model {
    type: string
    sql: concat(${TABLE}."ASSET_EQUIPMENT_MAKE", ' ', ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME") ;;
    description: "Combined make and model"
    group_label: "Asset Classification"
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
    description: "Asset class"
    group_label: "Asset Classification"
  }

  dimension: asset_category {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
    description: "Asset category"
    group_label: "Asset Classification"
  }

  dimension: asset_parent_category {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_SUBCATEGORY_NAME" ;;
    description: "Asset subcategory"
    group_label: "Asset Classification"
  }

  # ASSET STATUS
  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
    description: "Asset is active"
  }

  # LOCATION FIELDS
  dimension: asset_last_location {
    type: string
    sql: ${TABLE}."ASSET_LAST_LOCATION" ;;
    description: "Asset last known location"
  }

  dimension: asset_last_city {
    type: string
    sql: ${TABLE}."ASSET_LAST_CITY" ;;
    description: "Asset last known city"
  }

  dimension: asset_last_street {
    type: string
    sql: ${TABLE}."ASSET_LAST_STREET" ;;
    description: "Asset last known street"
  }

  dimension: asset_last_address {
    type: string
    sql: ${TABLE}."ASSET_LAST_ADDRESS" ;;
    description: "Asset last known full address"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of assets"
    drill_fields: [asset_name, asset_make_model, asset_class]
  }

  measure: count_by_class {
    type: count_distinct
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
    description: "Number of distinct asset classes"
  }

  measure: count_by_category {
    type: count_distinct
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
    description: "Number of distinct asset categories"
  }

  # TIMESTAMP
  dimension_group: asset_recordtimestamp {
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
    sql: CAST(${TABLE}."ASSET_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this asset record was created"
  }
}
