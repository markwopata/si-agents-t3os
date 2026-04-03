
view: top_vendor_mapping {
 sql_table_name: analytics.parts_inventory.top_vendor_mapping ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}."TIER" ;;
  }

  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }

  dimension: primary_vendor {
    type: string
    sql: ${TABLE}."PRIMARY_VENDOR" ;;
  }

  dimension: preferred {
    type: string
    sql:COALESCE(${TABLE}."PREFERRED", 'No') ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: primary_vendor_pricing {
    type: string
    sql: ${TABLE}."PRIMARY_VENDOR_PRICING" ;;
  }

  set: detail {
    fields: [
        vendorid,
  vendor_name,
  _fivetran_synced_time,
  _row,
  tier,
  mapped_vendor_name,
  primary_vendor,
  preferred,
  vendor_type,
  vendor_id,
  primary_vendor_pricing
    ]
  }
}
