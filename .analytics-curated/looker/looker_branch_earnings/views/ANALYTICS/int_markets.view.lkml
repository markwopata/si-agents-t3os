view: int_markets {
  sql_table_name: "INTACCT_MODELS"."INT_MARKETS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _id_dist {
    type: number
    value_format_name: id
    sql: ${TABLE}."_ID_DIST" ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: latest_plexi_period {
    type: date
    sql: (select max(${plexi_periods.date}) from "ANALYTICS"."GS"."PLEXI_PERIODS"
      where {% condition period_name %} DISPLAY {% endcondition %}) ;;
  }

  dimension: months_open {
    type: number
    sql: datediff('month', date_trunc('month',${branch_earnings_start_month_raw}::date), ${latest_plexi_period}::date)+1 ;;
  }

  dimension: months_open_greater_than_twelve {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }
  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }
  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: county {
    type: string
    sql: ${TABLE}."COUNTY" ;;
  }
  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
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
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: exclude_hard_down {
    label: "Exclude Hard Down?"
    type: yesno
    sql: ${market_name} not ilike '%hard down%';;
  }

  dimension: division_id {
    type: number
    sql: ${TABLE}."DIVISION_ID" ;;
  }
  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
  }
  dimension: full_address {
    type: string
    sql: ${TABLE}."FULL_ADDRESS" ;;
  }
  dimension: is_active {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE" ;;
  }
  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: is_market_data_active_market {
    type: yesno
    sql: ${TABLE}."IS_MARKET_DATA_ACTIVE_MARKET" ;;
  }
  dimension: is_market_es_owned {
    type: yesno
    sql: ${TABLE}."IS_MARKET_ES_OWNED" ;;
  }
  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }
  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }
  dimension: market_order {
    label: "Market Sort"
    type: number
    sql:     CASE
      WHEN ${market_name} ILIKE '%Core Solutions%' THEN 1
      WHEN ${market_name} ILIKE '%Advanced Solutions%' THEN 2
      WHEN ${market_name} ILIKE '%Tooling Solutions%' THEN 3
      WHEN ${market_name} ILIKE '%- Materials%' THEN 4
      ELSE 5
    END ;;
  }

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }
  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: location_nickname {
    type: string
    sql: ${TABLE}."LOCATION_NICKNAME" ;;
  }
  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: gps_coordinates {
    type:  location
    # adding slight jitter for overlapping locations
    sql_longitude: ${TABLE}."LONGITUDE" ;;
    sql_latitude: ${TABLE}."LATITUDE";;
  }

  dimension: gps_coordinates_jitter {
    type:  location
    # adding slight jitter for overlapping locations
    sql_longitude: ${TABLE}."LONGITUDE" ;;
    sql_latitude: ${TABLE}."LATITUDE" + (0.000001 * (${TABLE}."MARKET_ID" % 10));;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: market_type_id {
    type: number
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
  }
  dimension: parent_market_id {
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }
  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: state_name {
    type: string
    sql: ${TABLE}."STATE_NAME" ;;
  }
  dimension: street_1 {
    type: string
    sql: ${TABLE}."STREET_1" ;;
  }
  dimension: street_2 {
    type: string
    sql: ${TABLE}."STREET_2" ;;
  }
  dimension: url_google_maps {
    type: string
    sql: ${TABLE}."URL_GOOGLE_MAPS" ;;
  }
  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  division_name,
  parent_market_name,
  company_name,
  location_nickname,
  region_name,
  state_name,
  market_name
  ]
  }

}
