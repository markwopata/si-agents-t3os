view: ap_fleet_paid {
  sql_table_name: "FLEET"."AP_FLEET_PAID" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}.pending_schedule ;;
  }
  dimension: _row {
    primary_key: yes
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."BOOK_OF_BUSINESS" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: core_designation {
    type: string
    sql: ${TABLE}."CORE_DESIGNATION" ;;
  }
  dimension: customer_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_PAID" ;;
  }
  dimension_group: date_of_workflow_update {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_OF_WORKFLOW_UPDATE" ;;
  }
  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }
  dimension: finance_designation {
    type: string
    sql: ${TABLE}."FINANCE_DESIGNATION" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension_group: month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }
  dimension_group: payment {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS" ;;
  }
  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: week {
    type: string
    sql: ${TABLE}."WEEK" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: sum_total_oec {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format: "#,##0"
    drill_fields: [
      _row,
      asset_id,
      book_of_business,
      class,
      core_designation,
      customer_paid,
      factory_build_specs,
      finance_designation,
      invoice_number,
      invoice_date,
      make,
      market,
      market_id,
      model,
      order_number,
      serial_number,
      title_status,
      total_oec,
      vendor_name,
      week,
      month_raw,
      year]
  }
  measure: count {
    type: count
    drill_fields: [ _row,
                    asset_id,
                    book_of_business,
                    class,
                    core_designation,
                    customer_paid,
                    factory_build_specs,
                    finance_designation,
                    invoice_number,
                    make,
                    market,
                    market_id,
                    model,
                    order_number,
                    serial_number,
                    title_status,
                    total_oec,
                    vendor_name,
                    week,
                    month_raw,
                    year]
  }
}
