view: mlamd_district_highlighted {
  derived_table: {
    sql:
       with district_selection as (
        select
        distinct district
        from
        analytics.public.market_region_xwalk
        where
        {% condition district_name_filter %} district {% endcondition %}

        )

        , district_selection_count as (
        select
        count(district) as total_districts_selected
        from
        district_selection
        )

        , region_first_district AS (
            select min(district) as first_district, region_name
            from analytics.public.market_region_xwalk xw
            where {% condition region_name_filter %} region_name {% endcondition %}
            group by region_name
        )
        , assigned_district as (
            select
            iff(xw_district.district IS NULL, first_district, xw_district.district) as district
            from analytics.payroll.company_directory
            left join analytics.public.market_region_xwalk xw_district ON xw_district.district = split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',3)
                and {% condition region_name_filter %} xw_district.region_name {% endcondition %}
            join region_first_district rfd
            where lower(work_email) = '{{ _user_attributes['email'] }}'
            group by iff(xw_district.district IS NULL, first_district, xw_district.district)
        )


      select
      mlamd.*,
      xw.market_name,
      xw.market_type,
      xw.is_open_over_12_months,
      xw.branch_earnings_start_month as market_start_month,
      case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
            CASE WHEN xw.market_name ILIKE '%Landmark%' THEN 'Landmark'
        when xw.market_name ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN xw.market_name ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN xw.market_name ILIKE '%Containers%' then 'Container' ELSE xw.market_type END as special_locations_type,
      xw.district,
      xw.region_name,
      IFF(IFF(dsc.total_districts_selected = 1, ds.district ,ad.district) = xw.district,TRUE,FALSE) as is_selected_district


      from analytics.assets.market_level_asset_metrics_daily mlamd
      join analytics.public.market_region_xwalk xw on mlamd.market_id = xw.market_id

        cross join district_selection_count dsc
        left join district_selection ds on dsc.total_districts_selected = 1
        cross join assigned_district ad

        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
        and {% condition region_name_filter %} region_name {% endcondition %}

      ;;
  }

  filter: region_name_filter {
    type: string
  }

  filter: district_name_filter {
    type: string
  }

  dimension: is_selected_district {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_DISTRICT" ;;
  }

  dimension: selected_district {
    type: string
    sql: case when ${is_selected_district} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  dimension: current_date_flag {
    type: yesno
    sql: current_timestamp::DATE = ${daily_timestamp_date} ;;
  }

  dimension: month_end_date {
    type: date
    sql: ${TABLE}."MONTH_END_DATE" ;;
  }

  dimension: market_id {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: is_open_over_12_months {
    group_label: "Location Information"
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

  dimension: market_start_month {
    type: date
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }

  dimension: market_name {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    group_label: "Location Information"
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: special_locations_type {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }

  dimension: district {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }


  dimension: total_oec {
    description: "OEC of all assets in total fleet at market"
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format_name: usd_0
  }

  measure: total_oec_sum {
    description: "Sum of OEC of all assets in total fleet"
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd_0
  }

  dimension: total_units {
    description: "Count of units in total fleet for market"
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }

  measure: total_units_sum {
    description: "Total count of units in total fleet"
    type: sum
    sql: ${total_units};;
  }

  dimension: rental_fleet_oec {
    description: "OEC of all assets in rental fleet at market"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum {
    description: "Sum of the OEC of all assets in rental fleet"
    type: sum
    sql: ${rental_fleet_oec} ;;
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum_cd {
    group_label: "Time Flagged OEC"
    label: "Rental Fleet OEC Sum - Current Day"
    description: "Sum of the OEC of all assets in rental fleet on the current day"
    type: sum
    sql: ${rental_fleet_oec};;
    filters: [current_date_flag: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_last_31 {
    type: sum
    description: "Sum of the OEC of all assets in rental fleet over the last 31 days"
    sql: ${rental_fleet_oec};;
    filters: [v_dim_dates_bi.is_last_31_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_fleet_oec_sum_last_30 {
    type: sum
    sql: ${rental_fleet_oec};;
    description: "Sum of the OEC of all assets in rental fleet over the last 30 days"
    filters: [v_dim_dates_bi.is_last_30_days: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure:rental_fleet_oec_sum_selected {
    group_label: "Selected Metric"
    label: "Rental Fleet OEC"
    description: "Sum of all rental revenue from assets in rental fleet in selected location"
    type: sum
    sql: ${rental_fleet_oec};;
    filters: [is_selected_district: "yes"]
    value_format_name: usd_0
  }

  measure: rental_fleet_oec_sum_unselected {
    group_label: "Unselected Metric"
    label: "Rental Fleet OEC"
    description: "Sum of all rental revenue from assets in rental fleet NOT in selected location"
    type: sum
    sql: ${rental_fleet_oec} ;;
    filters: [is_selected_district: "no"]
    value_format_name: usd_0
  }

  dimension: rental_fleet_units {
    description: "Count of units in rental fleet for market"
    type: number
    sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
  }

  measure: rental_fleet_units_sum {
    description: "Total units in rental fleet"
    type: sum
    sql: ${rental_fleet_units};;
  }

  measure: rental_fleet_units_sum_last_30 {
    group_label: "Time Flagged Units"
    label: "Rental Fleet Units - Last 30 Days"
    description: "Sum of each days rental fleet unit count over last 30 days. For time ute."
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
    type: sum
    sql: ${unavailable_oec} ;;
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_sum_selected {
    group_label: "Selected Metric"
    label: "Unavailable OEC"
    type: sum
    sql: ${unavailable_oec} ;;
    filters: [is_selected_district: "yes"]
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down in selected district"
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_sum_unselected {
    group_label: "Unselected Metric"
    label: "Unavailable OEC"
    type: sum
    sql: ${unavailable_oec} ;;
    filters: [is_selected_district: "no"]
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down NOT in selected district"
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_sum_cd {
    type: sum
    sql: ${unavailable_oec} ;;
    description: "Sum of oec of assets in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down on the current day"
    filters: [current_date_flag: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: unavailable_oec_perc {
    type: number
    description: "Percentage of asset oec in rental fleet that is unavailable"
    sql: DIV0NULL(${unavailable_oec_sum}, ${rental_fleet_oec_sum}) ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_perc_cd {
    group_label: "Time Flagged OEC"
    type: number
    description: "Percentage of asset oec in rental fleet with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down on the current day"
    sql: DIV0NULL(${unavailable_oec_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_perc_selected {
    group_label: "Selected Metric"
    label: "Unavailable OEC %"
    description: "Percentage of in rental fleet assets with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down in selected location"
    type: number
    sql: nullifzero(DIV0NULL(${unavailable_oec_sum_selected}, ${rental_fleet_oec_sum_selected})) ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_perc_unselected {
    group_label: "Unselected Metric"
    label: "Unavailable OEC %"
    description: "Percentage of in rental fleet assets with inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down NOT in selected location"
    type: number
    sql: nullifzero(DIV0NULL(${unavailable_oec_sum_unselected}, ${rental_fleet_oec_sum_unselected})) ;;
    value_format_name: percent_1
  }

  measure: unavailable_oec_percent_bar {
    group_label: "Percent Bar Visual"
    type: number
    sql: ${percent_bar} - ${unavailable_oec_perc};;
    value_format_name: percent_1
  }


  dimension: unavailable_units {
    type: number
    description: "Total count of rental fleet assets in a market that have an inventory status of Make Ready, Needs Inspection, Soft Down, or Hard Down"
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }

  measure: unavailable_units_sum {
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
    filters: [current_date_flag: "yes"]
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
    type: number
    description: "Percentage of rental fleet OEC that is on rent"
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_perc_cd {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent % - Current Day"
    description: "Percentage of rental fleet OEC that is on rent for the current day"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_cd}, ${rental_fleet_oec_sum_cd}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_perc_selected {
    group_label: "Selected Metric"
    label: "OEC On Rent %"
    description: "Percentage of in rental fleet assets on rent in selected location"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_selected}, ${rental_fleet_oec_sum_selected}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_perc_unselected {
    group_label: "Unselected Metric"
    label: "OEC On Rent %"
    description: "Percentage of in rental fleet assets on rent NOT in selected location"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_unselected}, ${rental_fleet_oec_sum_unselected}) ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_percent_bar {
    group_label: "Percent Bar Visual"
    type: number
    sql: ${percent_bar} - ${oec_on_rent_perc};;
    value_format_name: percent_1
  }

  measure: oec_on_rent_sum_eom {
    group_label: "Time Flagged OEC"
    label: "OEC On Rent - End of Month*********** NEEDS TO BE UPDATED WITH WILLA'S NEW FIELD"
    type: sum
    description: "Percentage of rental fleet OEC that is on rent on the last day of each month"
    sql: ${oec_on_rent} ;;
    filters: [daily_timestamp_day_of_month: "20"]
    value_format_name: usd_0
  }

  measure: oec_on_rent_sum_selected {
    group_label: "Selected Metric"
    label: "OEC On Rent"
    description: "Sum of all oec on rent in rental fleet in selected location"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "yes"]
  }

  measure: oec_on_rent_sum_unselected {
    group_label: "Unselected Metric"
    label: "OEC On Rent"
    description: "Sum of all oec on rent in rental fleet NOT in selected location"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "no"]
  }

  dimension: units_on_rent {
    description: "Total number of assets in the rental fleet that are on rent for a market"
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  measure: units_on_rent_sum {
    description: "Total sum of the number of assets in the rental fleet that are on rent"
    type: sum
    sql: ${units_on_rent};;
  }

  measure: units_on_rent_sum_last_30 {
    group_label: "Time Flagged Units"
    label: "Units On Rent - Last 30 Days"
    description: "Sum of each days unit on rent count over last 30 days. For time ute."
    type: sum
    sql: ${units_on_rent};;
    filters: [v_dim_dates_bi.is_last_30_days: "yes"]
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    description: "Total rental revenue generated for a market from assets in rental fleet only"
    value_format_name: usd_0
  }

  measure: rental_revenue_sum {
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
    sql: ${rental_revenue} ;;
    filters: [v_dim_dates_bi.is_current_month: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_revenue_sum_pm {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Prior Month"
    type: sum
    description: "Sum of all rental revenue for the prior month"
    sql: ${rental_revenue} ;;
    filters: [v_dim_dates_bi.is_prior_month: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: rental_revenue_sum_pmtd {
    group_label: "Time Flagged Revenue"
    label: "Rental Revenue - Prior Month to Date"
    description: "Sum of all rental revenue for the prior month to date"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [v_dim_dates_bi.is_prior_month_to_date: "yes"]
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }


  measure: rental_revenue_sum_selected {
    group_label: "Selected Metric"
    label: "Rental Revenue"
    description: "Sum of all rental revenue from assets in rental fleet in selected location"
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "yes"]
  }

  measure: rental_revenue_sum_unselected {
    group_label: "Unselected Metric"
    label: "Rental Revenue"
    description: "Sum of all rental revenue from assets in rental fleet NOT in selected location"
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "no"]
  }

  measure: percent_bar {
    group_label: "Percent Bar Visual"
    type: number
    sql: 1 ;;
    value_format_name: percent_0
  }


  measure: financial_utilization_last_31{
    label: "Financial Utilization - Last 31 Days"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum_last_31}), ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
  }

  measure: financial_utilization {
    label: "Financial Utilization"
    description: "Revenue generated by assets in rental fleet divided by rental fleet OEC over the last 31 days. Rental revenue included must be either generated from assets in rental fleet or invoices not tied to an asset."
    type: number
    sql: DIV0NULL((365 * ${rental_revenue_sum}), ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  measure: financial_utilization_percentage_selected {
    group_label: "Selected Metric"
    label: "Financial Utilization"
    type: number
    sql:case
              when ${rental_revenue_sum_selected} = 0 OR ${rental_revenue_sum_selected} IS NULL then 0
              when ${rental_fleet_oec_sum_selected} = 0 OR ${rental_fleet_oec_sum_selected} IS NULL then 0
              else (${rental_revenue_sum_selected} * 365) / nullifzero(${rental_fleet_oec_sum_selected}) end;;
    value_format_name: percent_1
  }

  measure: financial_utilization_percentage_unselected {
    group_label: "Unselected Metric"
    label: "Financial Utilization"
    type: number
    sql:case
              when ${rental_revenue_sum_unselected} = 0 OR ${rental_revenue_sum_unselected} IS NULL then 0
              when ${rental_fleet_oec_sum_unselected} = 0 OR ${rental_fleet_oec_sum_unselected} IS NULL then 0
              else (${rental_revenue_sum_unselected} * 365) / nullifzero(${rental_fleet_oec_sum_unselected}) end;;
    value_format_name: percent_1
  }

  measure: fin_ute_percent_bar {
    group_label: "Percent Bar Visual"
    type: number
    sql: ${percent_bar} - ${financial_utilization};;
    value_format_name: percent_1
  }

  measure: time_utilization_last_31 {
    label: "Time Utilization - Last 31 Days"
    description: "(Days on Rent in Last 31 Days * Asset OEC) / (Rental Fleet OEC * 31)"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum_last_31}, ${rental_fleet_oec_sum_last_31});;
    value_format_name: percent_1
  }

  measure: time_utilization {
    label: "Time Utilization"
    description: "(Days on Rent In Time Period * Asset OEC) / (Rental Fleet OEC * Number of Days in Time Period)"
    type: number
    sql: DIV0NULL(${oec_on_rent_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  measure: time_utilization_percentage_selected {
    group_label: "Selected Metric"
    label: "Time Utilization"
    type: number
    sql:case
              when ${oec_on_rent_sum_selected} = 0 OR ${oec_on_rent_sum_selected} IS NULL then 0
              when ${rental_fleet_oec_sum_selected} = 0 OR ${rental_fleet_oec_sum_selected} IS NULL then 0
              else (${oec_on_rent_sum_selected}) / nullifzero(${rental_fleet_oec_sum_selected}) end;;
    value_format_name: percent_1
  }

  measure: time_utilization_percentage_unselected {
    group_label: "Unselected Metric"
    label: "Time Utilization"
    type: number
    sql:case
              when ${oec_on_rent_sum_unselected} = 0 OR ${oec_on_rent_sum_unselected} IS NULL then 0
              when ${rental_fleet_oec_sum_unselected} = 0 OR ${rental_fleet_oec_sum_unselected} IS NULL then 0
              else (${oec_on_rent_sum_unselected} ) / nullifzero(${rental_fleet_oec_sum_unselected}) end;;
    value_format_name: percent_1
  }

  measure: time_ute_percent_bar {
    group_label: "Percent Bar Visual"
    type: number
    sql: ${percent_bar} - ${time_utilization};;
    value_format_name: percent_1
  }




  dimension: pending_return_oec {
    description: "Total OEC of asset with Pending Return inventory status for a day"
    type: number
    sql: ${TABLE}."PENDING_RETURN_OEC" ;;
    value_format_name: usd_0
  }

  measure: pending_return_oec_sum {
    description: "Sum of OEC of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: pending_return_oec_sum_selected {
    group_label: "Selected Metric"
    label: "Pending Return OEC"
    description: "Sum of OEC of assets with Pending Return inventory status in selected location"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "yes"]
  }

  measure: pending_return_oec_sum_unselected {
    group_label: "Unselected Metric"
    label: "Pending Return OEC"
    description: "Sum of OEC of assets with Pending Return inventory status NOT in selected location"
    type: sum
    sql: ${pending_return_oec} ;;
    value_format_name: usd_0
    filters: [is_selected_district: "no"]
  }


  measure: pending_return_oec_perc {
    description: "Percentage of pending return oec of all rental fleet oec"
    type: number
    sql:  DIV0NULL(${pending_return_oec_sum}, ${rental_fleet_oec_sum});;
    value_format_name: percent_1
  }

  measure: pending_return_oec_perc_selected {
    group_label: "Selected Metric"
    label: "Pending Return OEC Perc"
    type: number
    sql:case
              when ${pending_return_oec_sum_selected} = 0 OR ${pending_return_oec_sum_selected} IS NULL then 0
              when ${rental_fleet_oec_sum_selected} = 0 OR ${rental_fleet_oec_sum_selected} IS NULL then 0
              else (${pending_return_oec_sum_selected}) / nullifzero(${rental_fleet_oec_sum_selected}) end;;
    value_format_name: percent_1
  }

  measure: pending_return_oec_perc_unselected {
    group_label: "Unselected Metric"
    label: "Pending Return OEC Perc"
    type: number
    sql:case
              when ${pending_return_oec_sum_unselected} = 0 OR ${pending_return_oec_sum_unselected} IS NULL then 0
              when ${rental_fleet_oec_sum_unselected} = 0 OR ${rental_fleet_oec_sum_unselected} IS NULL then 0
              else (${pending_return_oec_sum_unselected}) / nullifzero(${rental_fleet_oec_sum_unselected}) end;;
    value_format_name: percent_1
  }

  dimension: pending_return_units {
    type: number
    sql: ${TABLE}."PENDING_RETURN_UNITS" ;;
    value_format_name: usd_0
  }

  measure: pending_return_units_sum {
    description: "Count of assets with Pending Return inventory status"
    type: sum
    sql: ${pending_return_units } ;;
  }


  set: detail {
    fields: [
      pk_market_daily_timestamp_id,
      daily_timestamp_time,
      month_end_date,
      market_id,
      total_oec_sum,
      total_units_sum,
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
