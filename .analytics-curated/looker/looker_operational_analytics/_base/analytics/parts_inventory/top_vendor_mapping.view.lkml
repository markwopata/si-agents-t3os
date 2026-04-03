view: top_vendor_mapping {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: active_ {
    type: yesno
    sql: ${TABLE}."ACTIVE_" ;;
  }
  dimension: avoidance_ {
    type: number
    sql: ${TABLE}."AVOIDANCE_" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: dealership_ {
    type: yesno
    sql: ${TABLE}."DEALERSHIP_" ;;
  }
  dimension: mapped_name {
    type: string
    sql: ${TABLE}."MAPPED_NAME" ;;
  }
  dimension: mapped_primary_vendor_pricing {
    type: string
    sql: ${TABLE}."MAPPED_PRIMARY_VENDOR_PRICING" ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: preferred {
    type: yesno
    sql: iff(${TABLE}."PREFERRED"='YES',true,false) ;;
  }
  dimension: primary_vendor {
    type: yesno
    sql: iff(${TABLE}."PRIMARY_VENDOR"='YES',true,false) ;;
  }
  dimension: primary_vendor_pricing {
    type: string
    sql: ${TABLE}."PRIMARY_VENDOR_PRICING" ;;
  }
  dimension: responsible_ssm {
    type: string
    sql: ${TABLE}."RESPONSIBLE_SSM" ;;
  }
  dimension: savings_ {
    type: number
    sql: ${TABLE}."SAVINGS_" ;;
  }
  dimension: tier {
    type: string
    sql: ${TABLE}."TIER" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }
  dimension: vendor_type_2 {
    type: string
    sql: ${TABLE}."VENDOR_TYPE_2" ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }
  measure: count {
    type: count
    drill_fields: [mapped_name, mapped_vendor_name, vendor_name]
  }
}
