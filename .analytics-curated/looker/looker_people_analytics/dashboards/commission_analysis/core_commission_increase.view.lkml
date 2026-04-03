view: core_commission_increase {
  sql_table_name: ANALYTICS.COMMISSION.CORE_COMMISSION_INCREASE_TABLE ;;

  dimension_group: commission_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.COMMISSION_MONTH ;;  # If it's already a date/datetime
  }

  dimension: commission_quarter_year {
    type: string
    sql: CONCAT('Q', QUARTER(${TABLE}.COMMISSION_MONTH), ' - ', YEAR(${TABLE}.COMMISSION_MONTH)) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: parent_market_id {
    type: number
    sql: ${TABLE}.PARENT_MARKET_ID ;;
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}.PARENT_MARKET_NAME ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.REGION ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: invoice_asset_make {
    type: string
    sql: ${TABLE}.INVOICE_ASSET_MAKE ;;
  }

  dimension: invoice_class_id {
    type: number
    sql: ${TABLE}.INVOICE_CLASS_ID ;;
  }

  dimension: invoice_class {
    type: string
    sql: ${TABLE}.INVOICE_CLASS ;;
  }

  dimension: rental_class_id_from_rental {
    type: number
    sql: ${TABLE}.RENTAL_CLASS_ID_FROM_RENTAL ;;
  }

  measure: commission_rate {
    type: average
    sql: ${TABLE}.COMMISSION_RATE ;;
  }

  dimension: business_segment_id {
    type: number
    sql: ${TABLE}.BUSINESS_SEGMENT_ID ;;
  }

  dimension: rate_tier_id {
    type: number
    sql: ${TABLE}.RATE_TIER_ID ;;
  }

  dimension: rate_tier_name {
    type: string
    sql: ${TABLE}.RATE_TIER_NAME ;;
  }

  dimension: customer_geographic_rental_segment {
    type: string
    sql: ${TABLE}.CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT ;;
  }

  dimension: finance_segment_quarterly_name {
    type: string
    sql: ${TABLE}.FINANCE_SEGMENT_QUARTERLY_NAME ;;
  }

  dimension: finance_segment_annual_name {
    type: string
    sql: ${TABLE}.FINANCE_SEGMENT_ANNUAL_NAME ;;
  }

  measure: line_item_amount {
    type: sum
    value_format_name:  decimal_2
    sql: (${TABLE}.LINE_ITEM_AMOUNT) ;;
    drill_fields: [customer_geographic_rental_segment,finance_segment_quarterly_name,line_item_amount]

  }

  measure: commission_amount {
    type: sum
    value_format_name:  decimal_2
    sql: (${TABLE}.COMMISSION_AMOUNT) ;;
  }

  measure: net_commission_amount {
    type: number
    sql: ${commission_amount} * -0.375 ;;
  }

  dimension: is_commission_rate_08 {
    type: yesno
    sql: ${TABLE}.COMMISSION_RATE = 0.08 ;;
  }

  measure: rental_count {
    type: sum
    sql: (${TABLE}.RENTAL_COUNT) ;;
  }


  parameter: period_selection {
    type: string
    allowed_value:
    { label: "Monthly" value: "month" }
    allowed_value:
    { label: "Quarterly" value: "quarter" }
    default_value: "month"
  }

  dimension: commission_period {
    type: date # Or type: string for quarter number as string
    sql:
    CASE
      WHEN {% parameter period_selection %} = 'month' THEN DATE_TRUNC('MONTH', ${commission_month_date})
      WHEN {% parameter period_selection %} = 'quarter' THEN DATE_TRUNC('QUARTER', ${commission_month_date})
    END ;;
    # CASE
    #   WHEN {% parameter period_selection %} = 'month' THEN ${TABLE}.COMMISSION_MONTH.month
    #   WHEN {% parameter period_selection %} = 'quarter' THEN ${TABLE}.COMMISSION_MONTH.quarter_start
    # END ;;
  }


}
