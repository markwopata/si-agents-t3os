view: fact_rental_metrics {
  sql_table_name: "PLATFORM"."GOLD"."V_RENTAL_METRICS" ;;

  # PRIMARY KEY
  dimension: fact_rental_metrics_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."FACT_RENTAL_METRICS_KEY" ;;
    hidden: yes
  }

  # FOREIGN KEYS (Hidden - used for joins)
  dimension: rental_key {
    type: string
    sql: ${TABLE}."RENTAL_KEY" ;;
    description: "Foreign key to dim_rentals"
  }

  dimension: rental_status_key {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_KEY" ;;
    hidden: yes
  }

  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
    description: "Foreign key to dim_assets"
  }

  dimension: user_key {
    type: string
    sql: ${TABLE}."USER_KEY" ;;
    hidden: yes
  }

  dimension: customer_company_key {
    type: string
    sql: ${TABLE}."CUSTOMER_COMPANY_KEY" ;;
    description: "Foreign key to dim_companies"
  }

  dimension: market_company_key {
    type: string
    sql: ${TABLE}."MARKET_COMPANY_KEY" ;;
    description: "Foreign key to dim_companies (market company)"
  }

  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
    description: "Foreign key to dim_markets"
  }

  dimension: purchase_order_key {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_KEY" ;;
    description: "Foreign key to dim_purchase_orders"
  }

  dimension: order_key {
    type: string
    sql: ${TABLE}."ORDER_KEY" ;;
    hidden: yes
  }

  dimension: job_key {
    type: string
    sql: ${TABLE}."JOB_KEY" ;;
    description: "Foreign key to dim_jobs"
  }

  dimension: location_key {
    type: string
    sql: ${TABLE}."LOCATION_KEY" ;;
    description: "Foreign key to dim_locations"
  }

  dimension: geofence_key {
    type: string
    sql: ${TABLE}."GEOFENCE_KEY" ;;
    hidden: yes
  }

  dimension: part_key {
    type: string
    sql: ${TABLE}."PART_KEY" ;;
    description: "Foreign key to dim_parts (for bulk orders)"
    hidden: yes
  }

  dimension: primary_salesperson_user_key {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_USER_KEY" ;;
    description: "Foreign key to dim_users (primary salesperson)"
    hidden: yes
  }

  dimension: sub_renter_key {
    type: string
    sql: ${TABLE}."SUB_RENTER_KEY" ;;
    description: "Foreign key to dim_sub_renters (sub-contractor)"
    hidden: yes
  }

  dimension: tracker_key {
    type: string
    sql: ${TABLE}."TRACKER_KEY" ;;
    hidden: yes
  }

  # DATE KEYS (Hidden - used for joins)
  dimension: rental_start_date_key {
    type: string
    sql: ${TABLE}."RENTAL_START_DATE_KEY" ;;
    hidden: yes
  }

  dimension: rental_end_date_key {
    type: string
    sql: ${TABLE}."RENTAL_END_DATE_KEY" ;;
    hidden: yes
  }

  dimension: next_cycle_date_key {
    type: string
    sql: ${TABLE}."NEXT_CYCLE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: scheduled_drop_off_delivery_date_key {
    type: string
    sql: ${TABLE}."SCHEDULED_DROP_OFF_DELIVERY_DATE_KEY" ;;
    hidden: yes
  }

  # RENTAL METRICS (Dimensions for individual records)
  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
    description: "Days on rent for this rental"
    value_format_name: decimal_0
    group_label: "Rental Metrics"
  }

  dimension: weekdays_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_WEEKDAYS_ON_RENT" ;;
    description: "Weekdays on rent for this rental"
    value_format_name: decimal_0
    group_label: "Rental Metrics"
  }

  # RENTAL METRICS (Aggregated measures)
  measure: total_days_on_rent {
    type: sum
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
    description: "Total days equipment has been on rent"
    value_format_name: decimal_0
  }

  measure: total_weekdays_on_rent {
    type: sum
    sql: ${TABLE}."TOTAL_WEEKDAYS_ON_RENT" ;;
    description: "Total weekdays equipment has been on rent"
    value_format_name: decimal_0
  }

  measure: avg_days_on_rent {
    type: average
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
    description: "Average days on rent per rental"
    value_format_name: decimal_1
  }

  dimension: billing_days_left {
    type: number
    sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
    description: "Days remaining in current billing cycle"
  }

  dimension: current_cycle {
    type: number
    sql: ${TABLE}."CURRENT_CYCLE" ;;
    description: "Current billing cycle number"
  }

  dimension: cycles_next_seven_days {
    type: number
    sql: ${TABLE}."CYCLES_NEXT_SEVEN_DAYS" ;;
    description: "Number of billing cycles in next 7 days"
  }

  # FINANCIAL METRICS (Dimensions for individual records)
  dimension: invoiced_amount {
    type: number
    sql: ${TABLE}."TOTAL_INVOICED_AMOUNT" ;;
    description: "Invoiced amount for this rental"
    value_format_name: usd
    group_label: "Financial Metrics"
  }

  # FINANCIAL METRICS (Aggregated measures)
  measure: total_invoiced_amount {
    type: sum
    sql: ${TABLE}."TOTAL_INVOICED_AMOUNT" ;;
    description: "Total amount invoiced for rentals"
    value_format_name: usd
  }

  measure: avg_invoiced_amount {
    type: average
    sql: ${TABLE}."TOTAL_INVOICED_AMOUNT" ;;
    description: "Average invoiced amount per rental"
    value_format_name: usd
  }

  measure: line_item_count {
    type: sum
    sql: ${TABLE}."LINE_ITEM_COUNT" ;;
    description: "Total number of line items"
    value_format_name: decimal_0
  }

  # PRICING METRICS
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    description: "Daily rental rate"
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    description: "Weekly rental rate"
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    description: "Monthly rental rate"
    value_format_name: usd
  }

  # DATE CALCULATIONS
  dimension: days_until_rental_end_date {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_RENTAL_END_DATE" ;;
    description: "Days until rental is scheduled to end"
  }

  # UTILIZATION METRICS (Timezone-Aware)
  dimension: rental_period_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_WST"
        ELSE ${TABLE}."RENTAL_PERIOD_UTILIZATION_EST"
      END ;;
    description: "Total utilization for rental period (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: run_time_hours {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."RUN_TIME_HOURS_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."RUN_TIME_HOURS_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."RUN_TIME_HOURS_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."RUN_TIME_HOURS_WST"
        ELSE ${TABLE}."RUN_TIME_HOURS_EST"
      END ;;
    description: "Total runtime hours (timezone-aware)"
    value_format_name: decimal_1
  }

  # DAILY UTILIZATION METRICS (Timezone-Aware)
  dimension: previous_day_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."PREVIOUS_DAY_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."PREVIOUS_DAY_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."PREVIOUS_DAY_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."PREVIOUS_DAY_UTILIZATION_WST"
        ELSE ${TABLE}."PREVIOUS_DAY_UTILIZATION_EST"
      END ;;
    description: "Previous day utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: two_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."TWO_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."TWO_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."TWO_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."TWO_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."TWO_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Two days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: three_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."THREE_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."THREE_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."THREE_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."THREE_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."THREE_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Three days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: four_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."FOUR_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."FOUR_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."FOUR_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."FOUR_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."FOUR_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Four days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: five_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."FIVE_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."FIVE_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."FIVE_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."FIVE_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."FIVE_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Five days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: six_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."SIX_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."SIX_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."SIX_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."SIX_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."SIX_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Six days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  dimension: seven_days_ago_utilization {
    type: number
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."SEVEN_DAYS_AGO_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."SEVEN_DAYS_AGO_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."SEVEN_DAYS_AGO_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."SEVEN_DAYS_AGO_UTILIZATION_WST"
        ELSE ${TABLE}."SEVEN_DAYS_AGO_UTILIZATION_EST"
      END ;;
    description: "Seven days ago utilization (timezone-aware)"
    value_format_name: percent_1
  }

  # BENCHMARK METRICS
  dimension: benchmarked_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_ASSET_COUNT" ;;
    description: "Number of assets used for class benchmarking"
  }

  dimension: utilization_30_day_class_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CLASS_BENCHMARK" ;;
    description: "30-day utilization benchmark for asset class"
    value_format_name: percent_1
  }

  dimension: benchmarked_category_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_CATEGORY_ASSET_COUNT" ;;
    description: "Number of assets used for category benchmarking"
  }

  dimension: utilization_30_day_category_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CATEGORY_BENCHMARK" ;;
    description: "30-day utilization benchmark for category"
    value_format_name: percent_1
  }

  dimension: benchmarked_parent_category_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_PARENT_CATEGORY_ASSET_COUNT" ;;
    description: "Number of assets used for parent category benchmarking"
  }

  dimension: utilization_30_day_parent_category_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK" ;;
    description: "30-day utilization benchmark for parent category"
    value_format_name: percent_1
  }

  # RENTAL ANALYSIS
  dimension: rental_period_percent {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_PERCENT" ;;
    description: "Percentage of rental period completed"
    value_format_name: percent_1
  }

  # FLOOR RATE ANALYSIS
  dimension: floor_day_rate {
    type: number
    sql: ${TABLE}."FLOOR_DAY_RATE" ;;
    description: "Floor daily rate for asset class"
    value_format_name: usd
  }

  dimension: floor_week_rate {
    type: number
    sql: ${TABLE}."FLOOR_WEEK_RATE" ;;
    description: "Floor weekly rate for asset class"
    value_format_name: usd
  }

  dimension: floor_month_rate {
    type: number
    sql: ${TABLE}."FLOOR_MONTH_RATE" ;;
    description: "Floor monthly rate for asset class"
    value_format_name: usd
  }

  # AGGREGATED MEASURES
  measure: count {
    type: count
    description: "Number of rental records"
    drill_fields: [fact_rental_metrics_key]
  }

  measure: rental_count {
    type: count_distinct
    sql: ${rental_key} ;;
    description: "Number of distinct rentals"
    label: "Rental Count"
  }

  measure: avg_utilization_period {
    type: average
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."RENTAL_PERIOD_UTILIZATION_WST"
        ELSE ${TABLE}."RENTAL_PERIOD_UTILIZATION_EST"
      END ;;
    description: "Average utilization across rental period"
    value_format_name: percent_1
  }

  measure: avg_run_time_hours {
    type: average
    sql:
      CASE
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'UTC' THEN ${TABLE}."RUN_TIME_HOURS_UTC"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' THEN ${TABLE}."RUN_TIME_HOURS_CST"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' THEN ${TABLE}."RUN_TIME_HOURS_MNT"
        WHEN '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' THEN ${TABLE}."RUN_TIME_HOURS_WST"
        ELSE ${TABLE}."RUN_TIME_HOURS_EST"
      END ;;
    description: "Average runtime hours across rentals"
    value_format_name: decimal_1
  }

  # TIMESTAMP
  dimension_group: fact_rental_metrics_recordtimestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FACT_RENTAL_METRICS_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this fact record was created"
  }

  # CONCATENATED DIMENSIONS - Simple Newline Approach

  # Asset Information (concatenated with newlines)
  dimension: asset_info {
    group_label: "Asset Info"
    type: string
    sql: concat(
      case when cast(${dim_assets.asset_id} as varchar) = '-1' then 'Asset to be assigned'
           else coalesce(${dim_assets.asset_custom_name}, cast(${dim_assets.asset_id} as varchar))
      end, '|',
      cast(${dim_assets.asset_id} as varchar), '|',
      case when cast(${dim_assets.asset_id} as varchar) = '-1' then concat('Bulk Item - ', cast(${dim_parts.part_id} as varchar)) else coalesce(${dim_assets.asset_make_model}, 'N/A') end, '|',
      coalesce(${dim_assets.asset_class}, ${dim_parts.part_type_description}, 'N/A'), '|',
      coalesce(${dim_locations.location_nickname}, 'N/A'), '|',
      coalesce(${dim_purchase_orders.purchase_order_name}, 'N/A'), '|',
      coalesce(${dim_assets.asset_last_address}, 'N/A')
    ) ;;
    html: <table style="border-collapse: collapse; width: 100%;">
      <tr><td style="text-align: left; padding: 2px;"><b>Asset:</b></td><td style="text-align: left; padding: 2px;"><font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ value | split: '|' | slice: 1, 1 }}/history?selectedDate={{ current_date._value }}" target="_blank">{{ value | split: '|' | first }}</a></u></font></td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Make/Model:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 2, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Class:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 3, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Jobsite:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 4, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>PO:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 5, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Current Asset Location:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 6, 1 }}</td></tr>
    </table> ;;
  }

  # Rental Information (concatenated with newlines)
  dimension: rental_info {
    group_label: "Rental Info"
    type: string
    sql: concat(
      coalesce(${dim_companies.company_name}, 'N/A'), '|',
      coalesce(${dim_users.user_full_name}, 'N/A'), '|',
      coalesce(cast(${rental_start_date.dt_date} as varchar), 'N/A'), '|',
      coalesce(cast(${rental_end_date.dt_date} as varchar), 'N/A')
    ) ;;
    html: <table style="border-collapse: collapse; width: 100%;">
      <tr><td style="text-align: left; padding: 2px;"><b>Vendor:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | first }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Ordered By:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 1, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Rental Start Date:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 2, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Scheduled Off Rent Date:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 3, 1 }}</td></tr>
    </table> ;;
  }

  # Spend Information (concatenated with newlines)
  dimension: spend_info {
    group_label: "Spend Info"
    type: string
    sql: concat(
      coalesce(cast(${price_per_day} as varchar), '0'), '|',
      coalesce(cast(${price_per_week} as varchar), '0'), '|',
      coalesce(cast(${price_per_month} as varchar), '0'), '|',
      coalesce(cast(${invoiced_amount} as varchar), '0'), '|',
      coalesce(cast(${days_on_rent} as varchar), '0'), '|',
      coalesce(cast(${weekdays_on_rent} as varchar), '0')
    ) ;;
    html: <table style="border-collapse: collapse; width: 100%;">
      <tr><td style="text-align: left; padding: 2px;"><b>Day Rate:</b></td><td style="text-align: left; padding: 2px;">${{ value | split: '|' | first }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Week Rate:</b></td><td style="text-align: left; padding: 2px;">${{ value | split: '|' | slice: 1, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Month Rate:</b></td><td style="text-align: left; padding: 2px;">${{ value | split: '|' | slice: 2, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Total Invoiced Amount:</b></td><td style="text-align: left; padding: 2px;">${{ value | split: '|' | slice: 3, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Days On Rent:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 4, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px;"><b>Weekdays On Rent:</b></td><td style="text-align: left; padding: 2px;">{{ value | split: '|' | slice: 5, 1 }}</td></tr>
    </table> ;;
  }

  # Billing Information (concatenated with newlines)
  dimension: billing_info {
    group_label: "Billing Info"
    type: string
    sql: concat(
      case when ${next_cycle_date} = '0001-01-01' then 'NULL'
           else coalesce(cast(${next_cycle_date} as varchar), 'N/A')
      end, '|',
      coalesce(cast(${days_on_rent} as varchar), '0'), '|',
      coalesce(cast(${billing_days_left} as varchar), '0'), '|',
      coalesce(cast(${current_cycle} as varchar), '0')
    ) ;;
    html: <table style="border-collapse: collapse; width: 100%; table-layout: fixed;">
      <tr><td style="text-align: left; padding: 2px; width: 60%;"><b>Next Cycle Date:</b></td><td style="text-align: left; padding: 2px; width: 40%;">{{ value | split: '|' | first }}</td></tr>
      <tr><td style="text-align: left; padding: 2px; width: 60%;"><b>Total Days On Rent:</b></td><td style="text-align: left; padding: 2px; width: 40%;">{{ value | split: '|' | slice: 1, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px; width: 60%;"><b>Billing Days Left:</b></td><td style="text-align: left; padding: 2px; width: 40%;">{{ value | split: '|' | slice: 2, 1 }}</td></tr>
      <tr><td style="text-align: left; padding: 2px; width: 60%;"><b>Rental Billing Cycle:</b></td><td style="text-align: left; padding: 2px; width: 40%;">{{ value | split: '|' | slice: 3, 1 }}</td></tr>
    </table> ;;
  }

  # Utilization Information (concatenated with newlines, filtered to rental period only)
  dimension: utilization_info {
    group_label: "Utilization Info"
    type: string
    sql: concat(
      case when ${rental_start_date} <= ${previous_day_date} then
        concat(coalesce(cast(${previous_day_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${previous_day_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${two_days_ago_date} then
        concat(coalesce(cast(${two_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${two_days_ago_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${three_days_ago_date} then
        concat(coalesce(cast(${three_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${three_days_ago_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${four_days_ago_date} then
        concat(coalesce(cast(${four_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${four_days_ago_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${five_days_ago_date} then
        concat(coalesce(cast(${five_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${five_days_ago_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${six_days_ago_date} then
        concat(coalesce(cast(${six_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${six_days_ago_utilization} as varchar), '0'), char(10))
      else '' end,
      case when ${rental_start_date} <= ${seven_days_ago_date} then
        concat(coalesce(cast(${seven_days_ago_date} as varchar), 'N/A'), ' Run Time Hrs.: ', coalesce(cast(${seven_days_ago_utilization} as varchar), '0'))
      else '' end
    ) ;;
    html: <div style="white-space: pre">{{ value | replace: ' Run Time Hrs.: ', '<b> Run Time Hrs.:</b> ' }}</div> ;;
  }

  # Display dimensions for easy access
  dimension: rental_id {
    type: string
    sql: ${dim_rentals.rental_id} ;;
    description: "Rental ID"
    value_format_name: id
  }

  dimension: asset_id {
    type: string
    sql: ${dim_assets.asset_id} ;;
    description: "Asset ID"
    value_format_name: id
  }

  # Asset ID with clickable link
  dimension: asset_id_link {
    type: string
    sql: ${dim_assets.asset_id} ;;
    description: "Asset ID with link to asset details"
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ value }}/history?selectedDate={{ current_date._value }}" target="_blank">{{ value }}</a></u></font> ;;
  }

  dimension: asset_name {
    type: string
    sql: ${dim_assets.asset_custom_name} ;;
    description: "Asset custom name"
  }

  dimension: company_name {
    type: string
    sql: ${dim_companies.company_name} ;;
    description: "Customer company name"
  }

  # Rental Start Date as separate field
  dimension: rental_start_date {
    type: date
    sql: ${rental_start_date.dt_date} ;;
    description: "Rental Start Date"
  }

  # Rental End Date as separate field
  dimension: rental_end_date {
    type: date
    sql: ${rental_end_date.dt_date} ;;
    description: "Rental End Date"
  }

  # Next Cycle Date (for billing cycle information) - using date dimension join
  dimension: next_cycle_date {
    type: date
    sql: ${next_cycle_date.dt_date} ;;
    description: "Next billing cycle date"
    group_label: "Billing Info"
  }

  # Scheduled Drop Off Delivery Date - using date dimension join
  dimension: scheduled_drop_off_delivery_date {
    type: date
    sql: ${scheduled_drop_off_delivery_date.dt_date} ;;
    description: "Scheduled drop off delivery date"
  }

  # Date dimensions for utilization
  dimension: previous_day_date {
    type: date
    sql: CURRENT_DATE - 1 ;;
    description: "Previous day date"
  }

  dimension: two_days_ago_date {
    type: date
    sql: CURRENT_DATE - 2 ;;
    description: "Two days ago date"
  }

  dimension: three_days_ago_date {
    type: date
    sql: CURRENT_DATE - 3 ;;
    description: "Three days ago date"
  }

  dimension: four_days_ago_date {
    type: date
    sql: CURRENT_DATE - 4 ;;
    description: "Four days ago date"
  }

  dimension: five_days_ago_date {
    type: date
    sql: CURRENT_DATE - 5 ;;
    description: "Five days ago date"
  }

  dimension: six_days_ago_date {
    type: date
    sql: CURRENT_DATE - 6 ;;
    description: "Six days ago date"
  }

  dimension: seven_days_ago_date {
    type: date
    sql: CURRENT_DATE - 7 ;;
    description: "Seven days ago date"
  }

  # Current date for dynamic URL parameters
  dimension: current_date {
    type: date
    sql: CURRENT_DATE ;;
    description: "Current date (used for dynamic links)"
  }

  # Utilization Status (determines if utilization should be shown)
  dimension: utilization_status {
    type: string
    sql: CASE
      WHEN ${previous_day_utilization} IS NULL AND ${two_days_ago_utilization} IS NULL
           AND ${three_days_ago_utilization} IS NULL AND ${four_days_ago_utilization} IS NULL
           AND ${five_days_ago_utilization} IS NULL AND ${six_days_ago_utilization} IS NULL
           AND ${seven_days_ago_utilization} IS NULL
      THEN 'No utilization data available'
      ELSE 'show utilization'
    END ;;
    description: "Status indicating whether utilization data should be displayed"
  }
}
