view: lease_accelerator_bu_asset {
  sql_table_name: "LEASE_ACCELERATOR"."LEASE_ACCELERATOR_BU_ASSET" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: first_rental_date {
    type: string
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }
  dimension: admin_asset_id {
    type: string
    sql: ${TABLE}."ADMIN_ASSET_ID" ;;
  }
  dimension: allocated_cost_local {
    type: string
    sql: ${TABLE}."ALLOCATED_COST_LOCAL" ;;
  }
  dimension: allocated_cost_reporting_currency {
    type: string
    sql: ${TABLE}."ALLOCATED_COST_REPORTING_CURRENCY" ;;
  }
  dimension: allocated_rent_local {
    type: string
    sql: ${TABLE}."ALLOCATED_RENT_LOCAL" ;;
  }
  dimension: allocated_rent_reporting_currency {
    type: string
    sql: ${TABLE}."ALLOCATED_RENT_REPORTING_CURRENCY" ;;
  }
  dimension: asset_cost_local {
    type: string
    sql: ${TABLE}."ASSET_COST_LOCAL" ;;
  }
  dimension: asset_cost_reporting_currency {
    type: string
    sql: ${TABLE}."ASSET_COST_REPORTING_CURRENCY" ;;
  }
  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER" ;;
  }
  dimension: asset_reference_number {
    type: string
    sql: ${TABLE}."ASSET_REFERENCE_NUMBER" ;;
  }
  dimension: asset_rent_local {
    type: string
    sql: ${TABLE}."ASSET_RENT_LOCAL" ;;
  }
  dimension: asset_rent_reporting_currency {
    type: string
    sql: ${TABLE}."ASSET_RENT_REPORTING_CURRENCY" ;;
  }
  dimension: asset_tag {
    type: string
    sql: ${TABLE}."ASSET_TAG" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: asset_type_2 {
    type: string
    sql: ${TABLE}."ASSET_TYPE_2" ;;
  }
  dimension_group: booking_ledger {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."BOOKING_LEDGER_DATE" ;;
  }
  dimension: business_unit {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT" ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension_group: commencement {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMMENCEMENT_DATE" ;;
  }
  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }
  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }
  dimension: current_foreign_exchange_rate {
    type: string
    sql: ${TABLE}."CURRENT_FOREIGN_EXCHANGE_RATE" ;;
  }
  dimension_group: date_entered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_ENTERED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension_group: effective_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EFFECTIVE_END_DATE" ;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }
  dimension: foreign_exchange_rate_at_lsd {
    type: string
    sql: ${TABLE}."FOREIGN_EXCHANGE_RATE_AT_LSD" ;;
  }
  dimension: funder {
    type: string
    sql: ${TABLE}."FUNDER" ;;
  }
  dimension: las_asset_id {
    type: string
    sql: ${TABLE}."LAS_ASSET_ID" ;;
  }
  dimension_group: last_renewal {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_RENEWAL" ;;
  }
  dimension: lease {
    type: string
    sql: ${TABLE}."LEASE" ;;
  }
  dimension: lease_genre {
    type: string
    sql: ${TABLE}."LEASE_GENRE" ;;
  }
  dimension: lease_type {
    type: string
    sql: ${TABLE}."LEASE_TYPE" ;;
  }
  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
  }
  dimension: months_remaining {
    type: string
    sql: ${TABLE}."MONTHS_REMAINING" ;;
  }
  dimension_group: original_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ORIGINAL_END_DATE" ;;
  }
  dimension: original_lease_rate_factor {
    type: string
    sql: ${TABLE}."ORIGINAL_LEASE_RATE_FACTOR" ;;
  }
  dimension: payment_schedule {
    type: string
    sql: ${TABLE}."PAYMENT_SCHEDULE" ;;
  }
  dimension: postal {
    type: string
    sql: ${TABLE}."POSTAL" ;;
  }
  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }
  dimension: renewal_term {
    type: string
    sql: ${TABLE}."RENEWAL_TERM" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: most_recent_run {
    type: string
    sql: ${TABLE}."MOST_RECENT_RUN" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: term {
    type: string
    sql: ${TABLE}."TERM" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension_group: time_of_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIME_OF_RUN" ;;
  }
  measure: count {
    type: count
  }
}
