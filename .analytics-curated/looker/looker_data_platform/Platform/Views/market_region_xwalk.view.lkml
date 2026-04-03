view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" ;;

  set: detail_drill {
    fields: [market_name, district, region_name]
  }

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    description: "Unique identifier for each market"
    value_format_name: id
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    description: "Name of the market"
  }

  dimension: market_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
    description: "ID for the market type classification"
    value_format_name: id
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
    description: "Classification type of the market"
  }

  dimension: parent_market_id {
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
    description: "ID of the parent market"
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
    description: "Name of the parent market"
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
    description: "Short abbreviation for the market"
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
    description: "Area code associated with the market"
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    description: "State where the market is located"
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    description: "District the market belongs to"
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
    description: "Region number for the market"
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    description: "Name of the region the market belongs to"
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
    description: "Combined region and district identifier"
  }

  dimension: division_id {
    type: number
    sql: ${TABLE}."DIVISION_ID" ;;
    description: "ID for the division"
    value_format_name: id
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
    description: "Name of the division"
  }

  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
    description: "Whether the market has been open for more than 12 months"
  }

  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
    description: "Whether the market is a dealership location"
  }

  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
    description: "Number of months the market has been open"
  }

  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    datatype: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
    description: "Date the market started tracking branch earnings"
  }

  dimension: formatted_branch_earnings_start_month_date {
    group_label: "HTML Formatted Dates"
    label: "Branch Earnings Start Month Date"
    type: date
    sql: ${branch_earnings_start_month_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    description: "Formatted date for Branch Earnings Start Month displayed as month abbreviation, day, and year (e.g., Jan 15, 2026)"
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    datatype: timestamp
    sql: ${TABLE}."DATE_UPDATED" ;;
    description: "Timestamp of the last update to this record"
  }

  dimension: id_dist {
    hidden: yes
    type: number
    sql: ${TABLE}."_ID_DIST" ;;
    description: "Distribution ID"
    value_format_name: id
  }

  measure: count {
    type: count
    description: "Total number of market records"
    drill_fields: [detail_drill*]
  }
}