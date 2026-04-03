view: market_level_asset_metrics_daily {

  sql_table_name: analytics.assets.market_level_asset_metrics_daily ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: metric_definition_pdf_link {
    type: string
    sql: 1 ;;
    html:<font color="#0063f3 "><a href="https://drive.google.com/file/d/1PpVT4HdUy0xGq_NXOIAS8DkGf7Tr42H5/view?usp=sharing"target="_blank">
    Metric Definition PDF ➔</font> ;;
  }

  dimension: pk_market_daily_timestamp_id {
    type: string
    sql: ${TABLE}."PK_MARKET_DAILY_TIMESTAMP_ID" ;;
  }

  dimension_group: daily_timestamp {
    type: time
    sql: ${TABLE}."DAILY_TIMESTAMP" ;;
  }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${daily_timestamp_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month {
    group_label: "HTML Formatted Date"
    label: "Date as Month"
    type: date
    sql: ${daily_timestamp_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${daily_timestamp_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: month_end_date {
    type: date
    sql: ${TABLE}."MONTH_END_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }


  dimension: total_fleet_oec {
    description: "OEC of all assets in total fleet at market"
    group_label: "Total Fleet OEC"
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format_name: usd_0
  }

  measure: total_fleet_oec_sum {
    description: "Sum of OEC of all assets in total fleet (all rental and inventory assets)"
    group_label: "Total Fleet OEC"
    type: sum
    sql: ${total_fleet_oec} ;;
    value_format_name: usd_0
  }

  measure: total_fleet_oec_sum_cd {
    description: "Sum of OEC of all assets in total fleet (all rental and inventory assets) on the current day"
    group_label: "Total Fleet OEC"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_current_day} THEN ${total_fleet_oec} END;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    }

  measure: total_fleet_oec_sum_eom_pm {
    group_label: "Total Fleet OEC"
    description: "Sum of OEC of all assets in total fleet (all rental and inventory assets) on the last day of the prior month"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_last_day_of_month} AND ${v_dim_dates_bi.is_prior_month} THEN ${total_fleet_oec} END;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    }



  dimension: total_fleet_units {
    group_label: "Total Fleet Units"
    description: "Count of units in total fleet (all rental and inventory assets) for market"
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }

  measure: total_fleet_units_sum {
    group_label: "Total Fleet Units"
    description: "Total count of units in total fleet (all rental and inventory assets)"
    type: sum
    sql: ${total_fleet_units};;
  }

  dimension: rental_fleet_oec {
    description: "OEC of all assets in rental fleet at market"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum {
    description: "Sum of the OEC of all assets in rental fleet"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum_drill_districts {
    description: "Sum of the OEC of all assets in rental fleet, including drill fields by district"
    group_label: "Rental Fleet OEC Drilled by Districts"
    label: "Rental Fleet OEC"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format_name: usd_0
    drill_fields: [market_region_xwalk.district, oec_on_rent_sum, rental_fleet_oec_sum, oec_on_rent_perc]
  }

  measure: rental_fleet_oec_sum_cd {
    group_label: "Time Flagged OEC"
    label: "Rental Fleet OEC - Current Day"
    description: "Sum of the OEC of all assets in rental fleet on the current day (filtered on date)"
    type: sum
    sql: ${rental_fleet_oec};;
    filters: [v_dim_dates_bi.is_current_day: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_current_day {
    group_label: "Time Flagged OEC"
    label: "Rental Fleet OEC - Current Day"
    description: "Sum of the OEC of all assets in rental fleet on the current day (unfiltered on date)"
    type: sum
    sql:CASE WHEN ${v_dim_dates_bi.is_current_day} THEN ${rental_fleet_oec} END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_last_31 {
    label: "Rental Fleet OEC - Last 31 Days"
    type: sum
    description: "Sum of the OEC of all assets in rental fleet over the last 31 days"
    sql: ${rental_fleet_oec};;
    filters: [v_dim_dates_bi.is_last_31_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_last_30 {
    label: "Rental Fleet OEC - Last 30 Days"
    type: sum
    sql: ${rental_fleet_oec};;
    description: "Sum of the OEC of all assets in rental fleet over the last 30 days"
    filters: [v_dim_dates_bi.is_last_30_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_eom_pm {
    group_label: "Time Flagged OEC"
    label: "Rental Fleet OEC - End of Month in Prior Month"
    description: "Sum of OEC of all rental assets in fleet on the last day of the prior month"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_last_day_of_month} AND ${v_dim_dates_bi.is_prior_month} THEN ${rental_fleet_oec} END;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: rental_fleet_units {
    description: "Count of units in rental fleet for market"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
  }

  measure: rental_fleet_units_sum {
    label: "Rental Fleet Units"
    description: "Total units in rental fleet"
    type: sum
    sql: ${rental_fleet_units};;
  }

  measure: rental_fleet_units_sum_last_30 {
    group_label: "Time Flagged Units"
    label: "Rental Fleet Units - Last 30 Days"
    description: "Sum of each days rental fleet unit count over last 30 days."
    type: sum
    sql: ${rental_fleet_units};;
    filters: [v_dim_dates_bi.is_last_30_days: "yes"]
  }

  dimension: unavailable_oec {
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    description: "Sum of oec of assets in a market's rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    value_format_name: usd_0
  }

  measure: unavailable_oec_sum {
    label: "Unavailable OEC"
    type: sum
    sql: ${unavailable_oec} ;;
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_sum_cd {
    label: "Unavailable OEC - Current Day"
    type: sum
    sql: ${unavailable_oec} ;;
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down on the current day"
    filters: [v_dim_dates_bi.is_current_day: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_perc {
    label: "Unavailable OEC %"
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable"
    sql: DIV0NULL(${unavailable_oec_sum}, ${rental_fleet_oec_sum}) ;;
    value_format_name: percent_1
  }



  measure: unavailable_oec_perc_cd {
    group_label: "Time Flagged OEC"
    label: "Unavailable OEC % - Current Day"
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable on the current day. Drill field broken down by region."
    sql: DIV0NULL(${unavailable_oec_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [company_unavailable_oec_perc_cd_detail*]
  }


  measure: unavailable_oec_perc_cd_region {
    group_label: "Time Flagged OEC - Region"
    label: "Unavailable OEC % - Current Day"
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable on the current day. Drill field broken down by district."
    sql: DIV0NULL(${unavailable_oec_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [region_unavailable_oec_perc_cd_detail*]
  }

  measure: unavailable_oec_perc_cd_district {
    group_label: "Time Flagged OEC - District"
    label: "Unavailable OEC % - Current Day"
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable on the current day. Drill field broken down by market."
    sql: DIV0NULL(${unavailable_oec_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [district_unavailable_oec_perc_cd_detail*]
  }

  measure: unavailable_oec_perc_bar {
    type: number
    sql: 1 - ${unavailable_oec_perc_cd_district} ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_perc_cd_market {
    group_label: "Time Flagged OEC - Market"
    label: "Unavailable OEC % - Current Day"
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable on the current day. Drill field shows market."
    sql: DIV0NULL(${unavailable_oec_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [market_unavailable_oec_perc_cd_detail*]
  }


  dimension: unavailable_units {
    type: number
    description: "Total count of rental fleet assets in a market that have an inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }

  measure: unavailable_units_sum {
    label: "Unavailable Units"
    type: sum
    description: "Total count of rental fleet assets that have an inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    sql: ${unavailable_units};;
  }

  dimension: oec_on_rent {
    description: "Amount of OEC of assets in rental fleet for a market that are on rent."
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: oec_on_rent_sum {
    label: "OEC On Rent"
    type: sum
    description: "Total sum of OEC of assets in rental fleet that are on rent."
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }

  measure: oec_on_rent_sum_cd {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent Sum - Current Day"
    description: "Total sum of OEC of assets in rental fleet that are currently on rent on the current day"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [v_dim_dates_bi.is_current_day: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: oec_on_rent_sum_last_31 {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent Sum - Last 31 Days"
    description: "Total sum of the daily OEC of assets in rental fleet on rent over the last 31 days"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [v_dim_dates_bi.is_last_31_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: oec_on_rent_perc {
    label: "OEC On Rent %"
    type: number
    description: "Percentage of rental fleet OEC that is on rent"
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_perc_cd {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent % - Current Day"
    description: "Percentage of rental fleet OEC that is on rent for the current day with drill down by region"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [company_oec_on_rent_perc_drill*]
  }

  measure: oec_on_rent_perc_cd_region {
    group_label: "Time Flagged OEC - Region"
    label: "OEC On Rent % - Current Day"
    description: "Percentage of rental fleet OEC that is on rent for the current day with drill down by district"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [region_oec_on_rent_perc_drill*]
  }

  measure: oec_on_rent_perc_cd_district {
    group_label: "Time Flagged OEC - District"
    label: "OEC On Rent % - Current Day"
    description: "Percentage of rental fleet OEC that is on rent for the current day with drill down by market"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [district_oec_on_rent_perc_drill*]
  }

  measure: oec_on_rent_perc_cd_market {
    group_label: "Time Flagged OEC - Market"
    label: "OEC On Rent % - Current Day"
    description: "Percentage of rental fleet OEC that is on rent for the current day with drill down by market"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
    drill_fields: [market_oec_on_rent_perc_drill*]
  }

  measure: oec_on_rent_sum_eom {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent - End of Month"
    type: sum
    description: "Percentage of rental fleet OEC that is on rent on the last day of each month"
    sql: ${oec_on_rent} ;;
    filters: [v_dim_dates_bi.is_last_day_of_month: "yes"]
    value_format_name: usd_0
  }

  dimension: units_on_rent {
    description: "Total number of assets in the rental fleet that are on rent for a market"
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  measure: units_on_rent_sum_region {
    group_label: "Units On Rent"
    label: "Units On Rent - Region"
    description: "Total sum of the number of assets in the rental fleet that are on rent by region"
    type: sum
    sql: ${units_on_rent};;
    drill_fields: [region_units_on_rent_drill*]
  }

  measure: units_on_rent_sum {
    group_label: "Units On Rent"
    label: "Units On Rent"
    description: "Total sum of the number of assets in the rental fleet that are on rent"
    type: sum
    sql: ${units_on_rent};;
  }

  measure: units_on_rent_sum_district {
    group_label: "Units On Rent"

    label: "Units On Rent - District"
    description: "Total sum of the number of assets in the rental fleet that are on rent by district"
    type: sum
    sql: ${units_on_rent};;
    drill_fields: [district_units_on_rent_drill*]
  }

  measure: units_on_rent_sum_market {
    group_label: "Units On Rent"

    label: "Units On Rent - Market"
    description: "Total sum of the number of assets in the rental fleet that are on rent by market"
    type: sum
    sql: ${units_on_rent};;
    drill_fields: [market_units_on_rent_drill*]
  }

  measure: unit_utilization {
    description: "Units rented divided by available rental days"
    type: number
    sql: DIV0NULL(${units_on_rent_sum}, ${rental_fleet_units_sum}) ;;
    value_format_name: percent_1
  }


  measure: units_on_rent_sum_last_31 {
    group_label: "Time Flagged Units"
    label: "Units On Rent - Last 31 Days"
    description: "Sum of each days unit on rent count over last 31 days."
    type: sum
    sql: ${units_on_rent};;
    filters: [v_dim_dates_bi.is_last_31_days: "yes"]
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    description: "Total rental revenue generated for a market from assets in rental fleet only"
    value_format_name: usd_0
  }

  measure: rental_revenue_sum {
    label: "Rental Revenue"
    type: sum
    description: "Total rental revenue generated from assets in rental fleet only"
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: rental_revenue_sum_last_31 {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Last 31 Days"
    description: "Sum of all rental revenue from assets in rental fleet over the last 31 days"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [v_dim_dates_bi.is_last_31_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }


  measure: rental_revenue_sum_cm {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Current Month"
    description: "Sum of all rental revenue for the current month"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_current_month} = TRUE THEN ${rental_revenue} ELSE NULL END;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
    drill_fields: [company_revenue_detail*]
    }

  measure: rental_revenue_sum_cm_region {
    group_label: "Time Flagged Revenue - Region"
    label: "Rental Revenue - Current Month"
    description: "Sum of all rental revenue for the current month with drill fields fit to show region performance by district"
    type: sum
    sql:  CASE WHEN ${v_dim_dates_bi.is_current_month} = TRUE THEN ${rental_revenue} ELSE NULL END;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
    drill_fields: [region_revenue_detail*]
  }

  measure: rental_revenue_sum_cm_district {
    group_label: "Time Flagged Revenue - District"
    label: "Rental Revenue - Current Month"
    description: "Sum of all rental revenue for the current month with drill fields fit to show district performance by market"
    type: sum
    sql:  CASE WHEN ${v_dim_dates_bi.is_current_month} = TRUE THEN ${rental_revenue} ELSE NULL END;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
    drill_fields: [district_revenue_detail*]
  }

  measure: rental_revenue_sum_cm_market {
    group_label: "Time Flagged Revenue - Market"
    label: "Rental Revenue - Current Month"
    description: "Sum of all rental revenue for the current month with drill fields fit to show district performance by market"
    type: sum
    sql:  CASE WHEN ${v_dim_dates_bi.is_current_month} = TRUE THEN ${rental_revenue} ELSE NULL END;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
    drill_fields: [market_revenue_detail*]
  }

  measure: rental_revenue_running_total_cm {
    group_label: "Running Total Revenue"
    label: "Running Total - Current Month Rental Revenue"
    type: number
    sql:
    CASE WHEN ${daily_timestamp_day_of_month} > EXTRACT(DAY FROM CURRENT_DATE) THEN NULL
      ELSE SUM(${rental_revenue_sum_cm}) OVER (
        ORDER BY ${daily_timestamp_day_of_month}
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    END
  ;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
    }

  measure: rental_revenue_running_total_cm_cd {
    group_label: "Running Total Revenue"
    label: "Running Total - Current Month Rental Revenue for Current Date"
    type: number
    sql:CASE WHEN ${daily_timestamp_day_of_month} <> EXTRACT(DAY FROM CURRENT_DATE) THEN NULL
    WHEN ${daily_timestamp_day_of_month} = EXTRACT(DAY FROM CURRENT_DATE)
        THEN SUM(${rental_revenue_sum_cm}) OVER (ORDER BY ${daily_timestamp_day_of_month} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
      ELSE NULL END
  ;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
  }

  measure: rental_revenue_sum_pm {
    group_label: "Running Total Revenue"
    label: "Rental Revenue - Prior Month"
    type: sum
    description: "Sum of all rental revenue for the prior month"
    sql:  CASE WHEN ${v_dim_dates_bi.is_prior_month} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [company_revenue_detail*]
  }

  measure: rental_revenue_sum_pm_region {
    group_label: "Running Total Revenue - Region"
    label: "Rental Revenue - Prior Month"
    type: sum
    description: "Sum of all rental revenue for the prior month with drill fields fit to show region performance by district"
    sql:  CASE WHEN ${v_dim_dates_bi.is_prior_month} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region_revenue_detail*]
  }


  measure: rental_revenue_sum_pm_district {
    group_label: "Running Total Revenue - District"
    label: "Rental Revenue - Prior Month"
    type: sum
    description: "Sum of all rental revenue for the prior month with drill fields fit to show district performance by market"
    sql:  CASE WHEN ${v_dim_dates_bi.is_prior_month} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    filters: [v_dim_dates_bi.is_prior_month: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [district_revenue_detail*]
  }

  measure: rental_revenue_sum_pm_market {
    group_label: "Running Total Revenue - Market"
    label: "Rental Revenue - Prior Month"
    type: sum
    description: "Sum of all rental revenue for the prior month with drill fields fit to show district performance by market"
    sql:  CASE WHEN ${v_dim_dates_bi.is_prior_month} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    filters: [v_dim_dates_bi.is_prior_month: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [market_revenue_detail*]
  }

  measure: rental_revenue_running_total_pm {
    group_label: "Running Total Revenue"
    label: "Running Total - Prior Month Rental Revenue"
    type: number
    sql:SUM(${rental_revenue_sum_pm}) OVER (ORDER BY ${daily_timestamp_day_of_month} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
  ;;
    value_format: "[>=1000000000]\"$\"0.00,,,\"B\";[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";[<1000]\"$\"0"
  }

  measure: rental_revenue_sum_pmtd {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Prior Month to Date"
    description: "Sum of all rental revenue for the prior month to date"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_prior_month_to_date} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [company_revenue_detail*]
  }

  measure: rental_revenue_sum_pmtd_region {
    group_label: "Time Flagged Revenue - Region"
    label: "Rental Revenue - Prior Month to Date"
    description: "Sum of all rental revenue for the prior month to date with drill fields fit to show region performance by district"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_prior_month_to_date} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region_revenue_detail*]
  }

  measure: rental_revenue_sum_pmtd_district {
    group_label: "Time Flagged Revenue - District"
    label: "Rental Revenue - Prior Month to Date"
    description: "Sum of all rental revenue for the prior month to date with drill fields fit to show district performance by market"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_prior_month_to_date} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [district_revenue_detail*]
  }

  measure: rental_revenue_sum_pmtd_market {
    group_label: "Time Flagged Revenue - Market"
    label: "Rental Revenue - Prior Month to Date"
    description: "Sum of all rental revenue for the prior month to date with drill fields fit to show district performance by market"
    type: sum
    sql: CASE WHEN ${v_dim_dates_bi.is_prior_month_to_date} = TRUE THEN ${rental_revenue} ELSE NULL END ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [market_revenue_detail*]
  }

  measure: rental_revenue_sum_cm_vs_pm {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Current vs Prior Month"
    type: number
    description: "Difference between current and prior month rental revenue totals"
    sql:  COALESCE(SUM(CASE WHEN ${v_dim_dates_bi.is_current_month} = TRUE THEN ${rental_revenue} ELSE NULL END),0) -
          COALESCE(SUM(CASE WHEN ${v_dim_dates_bi.is_prior_month} = TRUE THEN ${rental_revenue} ELSE NULL END),0) ;;
    value_format_name: usd_0
  }


  measure: financial_utilization_last_31{
    label: "Financial Utilization - Last 31 Days"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset. Drill fields broken down by region."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum_last_31}), ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [company_financial_ute_last_31_detail*]
  }

  measure: financial_utilization_last_31_region{
    group_label: "Financial Utilization - Last 31 Days - Region"
    label: "Financial Utilization - Last 31 Days"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset. Drill fields broken down by district."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum_last_31}), ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [region_financial_ute_last_31_detail*]
  }

  measure: financial_utilization_last_31_district{
    group_label: "Financial Utilization - Last 31 Days - District"
    label: "Financial Utilization - Last 31 Days"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset. Drill fields broken down by market."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum_last_31}), ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [district_financial_ute_last_31_detail*]
  }

  measure: financial_utilization_last_31_market{
    group_label: "Financial Utilization - Last 31 Days - Market"
    label: "Financial Utilization - Last 31 Days"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset. Drill field shows market."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum_last_31}), ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [market_financial_ute_last_31_detail*]
  }

  measure: financial_utilization {
    label: "Financial Utilization"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum}), ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }


  measure: time_utilization_last_31 {
    label: "Time Utilization - Last 31 Days"
    description: "(Days on Rent in Last 31 Days * Asset OEC) / (Rental Fleet OEC * 31). Drill fields broken down by region"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_last_31}, ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [company_time_utilization_last_31*]
  }

  measure: time_utilization_last_31_region {
    group_label: "Time Utilization - Last 31 Days - Region"
    label: "Time Utilization - Last 31 Days"
    description: "(Days on Rent in Last 31 Days * Asset OEC) / (Rental Fleet OEC * 31). Drill fields broken down by district"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_last_31}, ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [region_time_utilization_last_31*]
  }

  measure: time_utilization_last_31_district {
    group_label: "Time Utilization - Last 31 Days - District"
    label: "Time Utilization - Last 31 Days"
    description: "(Days on Rent in Last 31 Days * Asset OEC) / (Rental Fleet OEC * 31). Drill fields broken down by market"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_last_31}, ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [district_time_utilization_last_31*]
  }

  measure: time_utilization_last_31_market {
    group_label: "Time Utilization - Last 31 Days - Market"
    label: "Time Utilization - Last 31 Days"
    description: "(Days on Rent in Last 31 Days * Asset OEC) / (Rental Fleet OEC * 31). Drill fields showing market"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_last_31}, ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
    drill_fields: [market_time_utilization_last_31*]
  }

  measure: time_utilization {
    label: "Time Utilization"
    description: "(Days on Rent In Time Period * Asset OEC) / (Rental Fleet OEC * Number of Days in Time Period)"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  dimension: pending_return_oec {
    description: "Total OEC of asset with Pending Return inventory status for a day"
    group_label: "Pending OEC"
    type: number
    sql: ${TABLE}."PENDING_RETURN_OEC" ;;
    value_format_name: usd_0
  }

  measure: pending_return_oec_sum {
    description: "Sum of OEC of assets with Pending Return inventory status"
    group_label: "Pending OEC"
    label: "Pending Return OEC"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: pending_return_oec_perc {
    description: "Percentage of pending return oec of all rental fleet oec"
    group_label: "Pending OEC"
    label: "Pending Return OEC %"
    type: number
    sql:  DIV0NULL(${pending_return_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
    drill_fields: [pending_return_oec_perc_detail*]
  }

  dimension: pending_return_units {
    group_label: "Pending OEC"
    type: number
    sql: ${TABLE}."PENDING_RETURN_UNITS" ;;
  }

  measure: pending_return_units_sum {
    group_label: "Pending OEC"
    label: "Pending Return Units"
    description: "Count of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_units} ;;
  }



  measure: converted_timestamp {
    group_label: "Timezone Testing"
    type: date_time
    sql: convert_timezone('America/Chicago',current_timestamp) ;;
  }

  measure: unconverted_timestamp {
    group_label: "Timezone Testing"
    type: date_time
    sql: current_timestamp ;;
  }

  set: company_revenue_detail {
    fields: [market_region_xwalk.region_name, rental_revenue_sum_cm_region, rental_revenue_sum_pmtd, rental_revenue_sum_pm_region]
  }
  set: region_revenue_detail {
    fields: [market_region_xwalk.district, rental_revenue_sum_cm_district, rental_revenue_sum_pmtd, rental_revenue_sum_pm_district]
  }
  set: district_revenue_detail {
    fields: [market_region_xwalk.market_name, rental_revenue_sum_cm, rental_revenue_sum_pmtd, rental_revenue_sum_pm]
  }
  set: market_revenue_detail {
    fields: [market_region_xwalk.market_name, rental_revenue_sum_cm, rental_revenue_sum_pmtd, rental_revenue_sum_pm]
  }

  set: company_oec_on_rent_perc_drill {
    fields: [market_region_xwalk.region_name, oec_on_rent_sum_cd, rental_fleet_oec_sum_cd, oec_on_rent_perc_cd]
  }
  set: region_oec_on_rent_perc_drill {
    fields: [market_region_xwalk.district_name, oec_on_rent_sum_cd, rental_fleet_oec_sum_cd, oec_on_rent_perc_cd]
  }
  set: district_oec_on_rent_perc_drill {
    fields: [market_region_xwalk.market_name, oec_on_rent_sum_cd, rental_fleet_oec_sum_cd, oec_on_rent_perc_cd]
  }
  set: market_oec_on_rent_perc_drill {
    fields: [market_region_xwalk.market_name, oec_on_rent_sum_cd, rental_fleet_oec_sum_cd, oec_on_rent_perc_cd]
  }

  set: region_units_on_rent_drill {
    fields: [market_region_xwalk.region_name, units_on_rent_sum, oec_on_rent_sum, rental_fleet_oec_sum, oec_on_rent_perc]
  }

  set: district_units_on_rent_drill {
    fields: [market_region_xwalk.district, units_on_rent_sum, oec_on_rent_sum, rental_fleet_oec_sum, oec_on_rent_perc]
  }

  set: market_units_on_rent_drill {
    fields: [market_region_xwalk.market_name, units_on_rent_sum, oec_on_rent_sum, rental_fleet_oec_sum, oec_on_rent_perc]
  }

  set: company_financial_ute_last_31_detail{
    fields: [market_region_xwalk.region_name, financial_utilization_last_31]
  }
  set: region_financial_ute_last_31_detail{
    fields: [market_region_xwalk.district_name, financial_utilization_last_31]
  }
  set: district_financial_ute_last_31_detail{
    fields: [market_region_xwalk.market_name, financial_utilization_last_31]
  }
  set: market_financial_ute_last_31_detail{
    fields: [market_region_xwalk.market_name, financial_utilization_last_31]
  }

  set: company_time_utilization_last_31 {
    fields: [market_region_xwalk.region_name, time_utilization_last_31]
  }
  set: region_time_utilization_last_31 {
    fields: [market_region_xwalk.district, time_utilization_last_31]
  }
  set: district_time_utilization_last_31 {
    fields: [market_region_xwalk.market_name, time_utilization_last_31]
  }
  set: market_time_utilization_last_31 {
    fields: [market_region_xwalk.market_name, time_utilization_last_31]
  }

  set: company_unavailable_oec_perc_cd_detail {
    fields: [market_region_xwalk.region_name, unavailable_oec_sum_cd, rental_fleet_oec_sum_cd, unavailable_oec_perc_cd]
  }
  set: region_unavailable_oec_perc_cd_detail {
    fields: [market_region_xwalk.district, unavailable_oec_sum_cd, rental_fleet_oec_sum_cd, unavailable_oec_perc_cd]
  }
  set: district_unavailable_oec_perc_cd_detail {
    fields: [market_region_xwalk.market_name, unavailable_oec_sum_cd, rental_fleet_oec_sum_cd, unavailable_oec_perc_cd]
  }
  set: market_unavailable_oec_perc_cd_detail {
    fields: [market_region_xwalk.market_name, unavailable_oec_sum_cd, rental_fleet_oec_sum_cd, unavailable_oec_perc_cd]
  }

  set: pending_return_oec_perc_detail {
    fields: [market_region_xwalk.market_name, pending_return_oec, rental_fleet_oec_sum, pending_return_oec_perc]
  }



  set: detail {
    fields: [
        pk_market_daily_timestamp_id,
  daily_timestamp_time,
  month_end_date,
  market_id,
  total_fleet_oec_sum,
  total_fleet_units_sum,
  rental_fleet_oec_sum,
  rental_fleet_units_sum,
  unavailable_oec_sum,
  unavailable_units_sum,
  oec_on_rent_sum,
  units_on_rent,
  rental_revenue_sum
    ]
  }
  }
