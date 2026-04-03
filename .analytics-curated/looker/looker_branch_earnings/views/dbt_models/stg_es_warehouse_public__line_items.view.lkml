view: stg_es_warehouse_public__line_items {
  sql_table_name: "INTACCT_MODELS"."STG_ES_WAREHOUSE_PUBLIC__LINE_ITEMS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: cheapest_period {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }
  dimension: extended_data__delivery {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__DELIVERY" ;;
  }
  dimension: extended_data__delivery__asset_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__DELIVERY__ASSET_ID" ;;
  }
  dimension: extended_data__delivery__delivery_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__DELIVERY__DELIVERY_ID" ;;
  }
  dimension: extended_data__delivery__rental_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__DELIVERY__RENTAL_ID" ;;
  }
  dimension: extended_data__delivery__scheduled_date {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__DELIVERY__SCHEDULED_DATE" ;;
  }
  dimension: extended_data__part_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__PART_ID" ;;
  }
  dimension: extended_data__part_number {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__PART_NUMBER" ;;
  }
  dimension: extended_data__rental {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL" ;;
  }
  dimension: extended_data__rental__cheapest_period_day_count {
    type: number
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__CHEAPEST_PERIOD_DAY_COUNT" ;;
  }
  dimension: extended_data__rental__cheapest_period_four_week_count {
    type: number
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__CHEAPEST_PERIOD_FOUR_WEEK_COUNT" ;;
  }
  dimension: extended_data__rental__cheapest_period_hour_count {
    type: number
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__CHEAPEST_PERIOD_HOUR_COUNT" ;;
  }
  dimension: extended_data__rental__cheapest_period_month_count {
    type: number
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__CHEAPEST_PERIOD_MONTH_COUNT" ;;
  }
  dimension: extended_data__rental__cheapest_period_week_count {
    type: number
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__CHEAPEST_PERIOD_WEEK_COUNT" ;;
  }
  dimension: extended_data__rental__end_date {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__END_DATE" ;;
  }
  dimension: extended_data__rental__equipment_assignments {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__EQUIPMENT_ASSIGNMENTS" ;;
  }
  dimension: extended_data__rental__equipment_class_name {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: extended_data__rental__location {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION" ;;
  }
  dimension: extended_data__rental__location__city {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__CITY" ;;
  }
  dimension: extended_data__rental__location__nickname {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__NICKNAME" ;;
  }
  dimension: extended_data__rental__location__state {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__STATE" ;;
  }
  dimension: extended_data__rental__location__street_1 {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__STREET_1" ;;
  }
  dimension: extended_data__rental__location__street_2 {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__STREET_2" ;;
  }
  dimension: extended_data__rental__location__zip_code {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__LOCATION__ZIP_CODE" ;;
  }
  dimension: extended_data__rental__price_per_day {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__PRICE_PER_DAY" ;;
  }
  dimension: extended_data__rental__price_per_four_weeks {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__PRICE_PER_FOUR_WEEKS" ;;
  }
  dimension: extended_data__rental__price_per_hour {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__PRICE_PER_HOUR" ;;
  }
  dimension: extended_data__rental__price_per_month {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__PRICE_PER_MONTH" ;;
  }
  dimension: extended_data__rental__price_per_week {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__PRICE_PER_WEEK" ;;
  }
  dimension: extended_data__rental__rental_bill_type {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__RENTAL_BILL_TYPE" ;;
  }
  dimension: extended_data__rental__rental_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__RENTAL_ID" ;;
  }
  dimension: extended_data__rental__shift_info {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__SHIFT_INFO" ;;
  }
  dimension: extended_data__rental__shift_info__shift_type {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__SHIFT_INFO__SHIFT_TYPE" ;;
  }
  dimension: extended_data__rental__shift_info__shift_type_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__SHIFT_INFO__SHIFT_TYPE_ID" ;;
  }
  dimension: extended_data__rental__start_date {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__RENTAL__START_DATE" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }
  dimension: override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."OVERRIDE_MARKET_TAX_RATE" ;;
  }
  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: payouts_processed {
    type: yesno
    sql: ${TABLE}."PAYOUTS_PROCESSED" ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }
  dimension: quoted_rates {
    type: string
    sql: ${TABLE}."QUOTED_RATES" ;;
  }
  dimension: rental_billed_days {
    type: number
    sql: ${TABLE}."RENTAL_BILLED_DAYS" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }
  dimension: tax_rate_id {
    type: number
    sql: ${TABLE}."TAX_RATE_ID" ;;
  }
  dimension: tax_rate_percentage {
    type: number
    sql: ${TABLE}."TAX_RATE_PERCENTAGE" ;;
  }
  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }
  measure: amount_agg {
    label: "Total Line Item Amount"
    type: sum
    sql: ${amount} ;;
  }
  measure: number_of_units_agg {
    label: "Number of Units"
    type: sum
    sql: ${number_of_units} ;;
  }
  measure: price_per_unit_agg {
    label: "Price per Unit"
    type: sum
    sql: ${price_per_unit} ;;
  }
  measure: count {
    type: count
    drill_fields: [extended_data__rental__location__nickname, extended_data__rental__equipment_class_name]
  }
}
