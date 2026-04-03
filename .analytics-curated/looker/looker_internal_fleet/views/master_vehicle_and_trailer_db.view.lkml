view: master_vehicle_and_trailer_db {
  sql_table_name: "PUBLIC"."MASTER_VEHICLE_AND_TRAILER_DB"
    ;;

  dimension: 2290_fhwt_if_applicable {
    type: string
    sql: ${TABLE}."2290_fhwt_if_applicable" ;;
  }

  dimension: asset_number {
    type: number
    sql: ${TABLE}."ASSET_NUMBER" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: curr_user {
    type: string
    sql: TRIM(${TABLE}."CURR_USER",' ') ;;
  }

  dimension: custom_upfit_options {
    type: string
    sql: ${TABLE}."custom_up-fit_options" ;;
  }

  dimension: d_o_t_cost_if_applicable {
    type: string
    sql: ${TABLE}."d.o.t_cost_if_applicable" ;;
  }

  dimension: dash_cam_installed {
    type: string
    sql: ${TABLE}."DASH_CAM_INSTALLED" ;;
  }

  dimension: date_received {
    type: string
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: dot_unit_ {
    type: string
    sql: ${TABLE}."dot_unit_#" ;;
  }

  dimension: due_date {
    type: string
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: es_order_reference_number {
    type: string
    sql: ${TABLE}."ES_ORDER_REFERENCE_NUMBER" ;;
  }

  dimension: estimated_availability {
    type: string
    sql: ${TABLE}."ESTIMATED_AVAILABILITY" ;;
  }

  dimension: expiration {
    type: string
    sql: ${TABLE}."EXPIRATION" ;;
  }

  dimension: extended_warranty {
    type: string
    sql: ${TABLE}."EXTENDED_WARRANTY" ;;
  }

  dimension: f_e_t__if_additional {
    type: string
    sql: ${TABLE}."f.e.t._if_additional" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: freight {
    type: string
    sql: ${TABLE}."FREIGHT" ;;
  }

  dimension: fuel_card {
    type: string
    sql: ${TABLE}."FUEL_CARD" ;;
  }

  dimension: initial_titleregistration_cost {
    type: string
    sql: ${TABLE}."INITIAL_TITLEREGISTRATION_COST" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_ship_date {
    type: string
    sql: ${TABLE}."INVOICE_SHIP_DATE" ;;
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: lender {
    type: string
    sql: ${TABLE}."LENDER" ;;
  }

  dimension: loan_reference_number {
    type: string
    sql: ${TABLE}."LOAN_REFERENCE_NUMBER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: monthly_payment {
    type: string
    sql: ${TABLE}."MONTHLY_PAYMENT" ;;
  }

  dimension: net_price {
    type: string
    sql: ${TABLE}."NET_PRICE" ;;
  }

  dimension: new_card_ {
    type: string
    sql: ${TABLE}."new_card_#" ;;
  }

  dimension: odometer_purchase {
    type: string
    sql: ${TABLE}."odometer@_purchase" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: plate {
    type: string
    sql: ${TABLE}."PLATE" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: purchase_date {
    type: string
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: release_date {
    type: string
    sql: ${TABLE}."RELEASE_DATE" ;;
  }

  dimension: standard_warranty {
    type: string
    sql: ${TABLE}."STANDARD_WARRANTY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: state__local_taxes {
    type: string
    sql: ${TABLE}."state_&_local_taxes" ;;
  }

  dimension: titled_owner {
    type: string
    sql: ${TABLE}."TITLED_OWNER" ;;
  }

  dimension: toll_transponder {
    type: string
    sql: ${TABLE}."TOLL_TRANSPONDER" ;;
  }

  dimension: total_vendor_cost {
    type: string
    sql: ${TABLE}."TOTAL_VENDOR_COST" ;;
  }

  dimension: tracker_installed {
    type: string
    sql: ${TABLE}."TRACKER_INSTALLED" ;;
  }

  dimension: unit_cost {
    type: string
    sql: ${TABLE}."UNIT_COST" ;;
  }

  dimension: vehicle_build_specifications {
    type: string
    sql: ${TABLE}."VEHICLE_BUILD_SPECIFICATIONS" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: vendor_order_reference_number {
    type: string
    sql: ${TABLE}."VENDOR_ORDER_REFERENCE_NUMBER" ;;
  }

  dimension: vin_serial {
    type: string
    sql: ${TABLE}."VIN_SERIAL" ;;
  }

  dimension: vin_serial_if_applicable {
    type: string
    sql: ${TABLE}."VIN_SERIAL_IF_APPLICABLE" ;;
  }

  dimension: wex_card {
    type: string
    sql: ${TABLE}."WEX_CARD" ;;
  }

  dimension: wrap_decals_or_custom_paint {
    type: string
    sql: ${TABLE}."WRAP_DECALS_OR_CUSTOM_PAINT" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

# ----- Set fields for drilling -----
set: detail {
  fields: [
    asset_number,
    class,
    curr_user,
    market,
    order_status,
    state
    ]
}
}
