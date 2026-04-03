#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: es_owned_assets {
  derived_table: {
    sql: select
    cast(ap.ASSET_ID as string) as Asset_ID,
    coalesce(ap.SERIAL_NUMBER,ap.VIN) AS serial_vin,
    cast(ap.YEAR as string) as Year,
    ap.MAKE,
    ap.MODEL,
    cast(ap.COMPANY_ID as string) as Company_ID,
    ap.COMPANY_NAME,
    cast(ap.TRACKER_ID as string) as Tracker_ID,
    ap.INVENTORY_BRANCH,
    ap.SUB_CATEGORY_NAME as Category,
    ap.asset_inventory_status,
    cast(ka.KEYPAD_ID as string) as Keypad_ID
from ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap
    left join ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS ka
    on ka.ASSET_ID = ap.ASSET_ID
where ap.RENTAL_BRANCH_COMPANY_ID = 1854
  and ap.TRACKER_ID is not null
  and IS_PUBLIC_MSP = 'true';;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}."SERIAL_VIN" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: tracker_id {
    type: string
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: keypad_id {
    type: string
    sql: ${TABLE}."KEYPAD_ID" ;;
  }


  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  set: detail {
    fields: [
        asset_id,
  serial_vin,
  year,
  make,
  model,
  company_id,
  company_name,
  tracker_id,
  inventory_branch,
  category,
  keypad_id,
  asset_inventory_status
    ]
  }
}
