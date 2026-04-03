view: service_outside_labor_enhancement {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_OUTSIDE_LABOR_ENHANCEMENT" ;;

  # Note: this table has 2 parts, unioned together: ROLLUP rows + PO_LINE rows
  # Use row_type to choose between rollup or drill contexts.

  # Row Type
  dimension: row_type {
    type: string
    sql: ${TABLE}."ROW_TYPE" ;;
    hidden: yes
    description: "ROW_TYPE is 'ROLLUP' for canonical market-quarter rows and 'PO_LINE' for PO line detail rows."
  }

  # PO-line Grain
  dimension: purchase_order_id {
    type: string
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."PURCHASE_ORDER_ID" ELSE NULL END ;;
  }
  dimension: purchase_order_line_item_id {
    type: string
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ELSE NULL END ;;
  }
  dimension: po_line_created_at {
    label: "PO Created Date"
    type: date
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."PO_CREATED_AT" ELSE NULL END ;;
  }
  dimension: po_line_vendor_name {
    label: "Vendor Name"
    type: string
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."VENDOR_NAME" ELSE NULL END ;;
  }
  dimension: po_line_quantity {
    type: number
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."QUANTITY" ELSE NULL END ;;
  }
  dimension: po_line_price_per_unit {
    type: number
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."PRICE_PER_UNIT" ELSE NULL END ;;
  }
  dimension: service_line_amount {
    type: number
    sql: CASE WHEN ${row_type} = 'PO_LINE' THEN ${TABLE}."SERVICE_AMOUNT_LINE" ELSE NULL END ;;
  }
  measure: sum_service_line_amount {
    type: sum
    sql: ${TABLE}."SERVICE_AMOUNT_LINE" ;;
    filters: [row_type: "PO_LINE"]
    value_format_name: usd
  }


  # Asset Age
  measure: avg_asset_age_quarter_avg {
    type: max
    sql: ${TABLE}."AVG_ASSET_AGE_QUARTER" ;;
    value_format: "0.0"
    label: "Average Asset Age (Quarter)"
  }
  measure: avg_asset_age_year_avg {
    type: max
    sql: ${TABLE}."AVG_ASSET_AGE_YEAR" ;;
    value_format: "0.0"
    label: "Average Asset Age (Year)"
  }
  measure: avg_asset_age_dynamic {
    label: "Average Asset Age Dynamic"
    type: number
    sql:
    {% if time_grain._parameter_value == "Year" %}
      ${avg_asset_age_year_avg}
    {% else %}
      ${avg_asset_age_quarter_avg}
    {% endif %} ;;
    value_format: "0.0"
  }

  # Location
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  # Gen Market Data
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: current_number_months_open {
    type: number
    sql: ${TABLE}."CURRENT_NUMBER_MONTHS_OPEN" ;;
  }
  dimension: market_open_greater_than_12_months {
    type: yesno
    sql: ${TABLE}."MARKET_OPEN_GREATER_THAN_12_MONTHS" ;;
  }


  # Time
  dimension: quarter {
    type: number
    sql: ${TABLE}."QUARTER" ;;
  }
  dimension: quarter_label {
    type: string
    sql: ${TABLE}."QUARTER_LABEL" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format: "####"
  }

  ########################
  # Existing (contextual) measures - kept as-is so current UX/liquid stays unchanged
  # These measures are useful for drill/context rows; they return the repeated column value (max).
  ########################

  # measure: rental_revenue {
  #   type: max
  #   sql: ${TABLE}."RENTAL_REVENUE_AMOUNT" ;;
  #   value_format_name: usd
  #   drill_fields: [market_name, region_name, district, year, quarter, service_outside_labor.rental_revenue]
  # }

  # measure: service_amount {
  #   type: max
  #   sql: ${TABLE}."SERVICE_AMOUNT_QTR" ;;
  #   value_format_name: usd
  #   drill_fields: [market_name, region_name, district, year, quarter, service_amount]
  # }

  # measure: service_percent_quarter {
  #   type: max
  #   sql: ${TABLE}."SERVICE_PERCENT" ;;
  # }
  # measure: service_percent_year {
  #   type: average
  #   sql: ${TABLE}."SERVICE_PERCENT_YEAR" ;;
  #   value_format_name: percent_2
  # }

    ########################
  # Rollup-safe measures (new) — use these in tiles/aggregates
  # These SUM only the canonical ROLLUP rows (no duplicate inflation)
  ########################
  # Rental revenue summed only on ROLLUP rows (safe to SUM across markets/districts/years)
  measure: rental_revenue_rollup_sum {
    label: "Rental Revenue (Rollup: sum of rollup rows)"
    type: sum
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."RENTAL_REVENUE_AMOUNT" ELSE NULL END ;;
    value_format_name: usd
  }

  # Service amount (quarter) summed only on ROLLUP rows
  measure: service_amount_qtr_rollup_sum {
    label: "Service Amount Qtr (Rollup: sum of rollup rows)"
    type: sum
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."SERVICE_AMOUNT_QTR" ELSE NULL END ;;
    value_format_name: usd
    drill_fields: [region_name, district, market_id, market_name,  purchase_order_id, po_line_created_at, po_line_vendor_name, po_line_price_per_unit, po_line_quantity, service_line_amount]
  }

  # measure: sum_service_line_amount {
  #   type: sum
  #   hidden: yes
  #   sql: ${TABLE}."SERVICE_LINE_AMOUNT" ;;
  # }

  measure: service_percent_rollup {
    label: "Service Percent (Rollup: ratio of sums)"
    type: number
    sql: ${service_amount_qtr_rollup_sum} / NULLIFZERO(${rental_revenue_rollup_sum}) ;;
    value_format_name: percent_2
    # Hidden so the color-coded one can be used without confusion; this one is just for reference
    hidden: yes
  }

# EXPERIMENT -- TRULY DYNAMIC RANKING
# measure: dynamic_percent_ranking {
#   type: number
#   sql:  PERCENT_RANK() OVER (PARTITION BY view_by.parameter_selection ORDER BY ${service_percent_rollup}) ;;
# }



  ########################
  # Unavailable / rental fleet OEC (rollup-safe)
  ########################

  # Sum only rollup rows (prevents multiplication when PO_LINE rows exist)
  measure: unavailable_oec_rollup_sum {
    label: "Unavailable OEC (Rollup sum)"
    type: sum
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."UNAVAILABLE_OEC" ELSE NULL END ;;
  }

  measure: rental_fleet_oec_rollup_sum {
    label: "Rental Fleet OEC (Rollup sum)"
    type: sum
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."RENTAL_FLEET_OEC" ELSE NULL END ;;
  }

  measure: unavailable_oec_pct_rollup {
    label: "Unavailable OEC % (Rollup)"
    type: number
    sql:
      CASE WHEN NULLIF(${rental_fleet_oec_rollup_sum}, 0) IS NULL THEN NULL
           ELSE ${unavailable_oec_rollup_sum} / NULLIF(${rental_fleet_oec_rollup_sum}, 0)
      END ;;
    value_format_name: percent_2
  }


  # Rankings, coloring, formatting for Service Percent
  dimension: rank_qtr_market {
    type: number
    sql: ${TABLE}."RANK_QTR_MARKET" ;;
    value_format: "0.00"
    hidden: yes
  }
  dimension: rank_qtr_district {
    type: number
    sql: ${TABLE}."RANK_QTR_DISTRICT" ;;
    value_format: "0.00"
    hidden: yes
  }
  dimension: rank_qtr_region {
    type: number
    sql: ${TABLE}."RANK_QTR_REGION" ;;
    value_format: "0.00"
    hidden: yes
  }
  dimension: rank_year_market {
    type: number
    sql: ${TABLE}."RANK_YEAR_MARKET" ;;
    value_format: "0.00"
    hidden: yes
  }
  dimension: rank_year_district {
    type: number
    sql: ${TABLE}."RANK_YEAR_DISTRICT" ;;
    value_format: "0.00"
    hidden: yes
  }
  dimension: rank_year_region {
    type: number
    sql: ${TABLE}."RANK_YEAR_REGION" ;;
    value_format: "0.00"
    hidden: yes
  }



  # Count
  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }


  # DYNAMIC LOCATION GRAIN
  parameter: drop_down_selection {
    type: string
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
  }

  dimension: dynamic_location {
    description: "Allows user to pick between Company, Region, District, and Market Axis."
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
    {% else %}
      NULL
    {% endif %} ;;
  }

# Use only these in tiles with dynamic location
  dimension: market_id_dynamic {
    label: "Market ID Dynamic"
    sql: {% if drop_down_selection._parameter_value == "'Market'" %}
            ${market_id}
          {% else %}
              NULL
          {% endif %} ;;
  }
  dimension: mature_branch_dynamic {
    label: "Mature Branch Dynamic"
    type: yesno
    sql: {% if drop_down_selection._parameter_value == "'Market'" %}
            ${market_open_greater_than_12_months}
          {% else %}
            NULL
          {% endif %} ;;
  }
  dimension: market_type_dynamic {
    label: "Market Type Dynamic"
    sql: {% if drop_down_selection._parameter_value == "'Market'" %}
            ${market_type}
          {% else %}
            NULL
          {% endif %} ;;
  }
  dimension: market_number_months_open_dynamic {
    label: "Market Number Months Open Dynamic"
    sql: {% if drop_down_selection._parameter_value == "'Market'" %}
            ${current_number_months_open}
          {% else %}
            NULL
          {% endif %} ;;
  }

  # DYNAMIC TIME GRAIN
  parameter: time_grain {
    label: "View By"
    type: unquoted
    default_value: "Year"
    allowed_value: { label: "Year"    value: "Year" }
    allowed_value: { label: "Quarter" value: "Quarter" }
  }
  dimension: time_pivot {
    label_from_parameter: time_grain
    type: string
    sql:
    {% if time_grain._parameter_value == "Year" %}
      -- CAST(${year} AS STRING)
      ${year}
    {% else %}
      ${quarter_label}
    {% endif %} ;;
  }

  # measure: average_service_percent_year {
  #   type: average
  #   sql: ${TABLE}."SERVICE_PERCENT_YEAR" ;;
  # }

  # OLD APPROACH
  # measure: service_percent_dynamic {
  #   label: "Service Percent Dynamic"
  #   type: max
  #   sql:
  #   {% if time_grain._parameter_value == "Year" %}
  #     ${TABLE}."SERVICE_PERCENT_YEAR"
  #   {% else %}
  #     ${TABLE}."SERVICE_PERCENT"
  #   {% endif %} ;;
  #   value_format_name: percent_2
  #   html:
  #   {% assign rank = service_percent_rank_dynamic._value %}
  #   {% if rank != null %}
  #     {% if rank >= 0.9 %}
  #       <div style="background-color:lightcoral; display:block;">{{ rendered_value }}</div>
  #     {% elsif rank <= 0.1 %}
  #       <div style="background-color:lightgreen; display:block;">{{ rendered_value }}</div>
  #     {% else %}
  #       {{rendered_value}}
  #     {% endif %}
  #   {% else %}
  #     {{rendered_value}}
  #   {% endif %} ;;
  # }

  # NEW TEST APPROACH
  measure: service_percent_dynamic {
    label: "Service Percent Dynamic"
    type: number
    sql:
      ${service_amount_qtr_rollup_sum} / NULLIFZERO(${rental_revenue_rollup_sum}) ;;
    value_format_name: percent_2
    html:
    {% assign rank = service_percent_rank_dynamic._value %}
    {% if rank != null %}
      {% if rank >= 0.9 %}
        <div style="background-color:lightcoral; display:block;">{{ rendered_value }}</div>
      {% elsif rank <= 0.1 %}
        <div style="background-color:lightgreen; display:block;">{{ rendered_value }}</div>
      {% else %}
        {{rendered_value}}
      {% endif %}
    {% else %}
      {{rendered_value}}
    {% endif %} ;;
  }

  measure: service_percent_rank_dynamic {
    label: "Service Percent Rank Dynamic"
    type: max
    hidden: yes
    sql:
    {% if time_grain._parameter_value == "Year" %}
      -- Year grain
      {% if drop_down_selection._parameter_value == "'Market'" %}
        ${TABLE}."RANK_YEAR_MARKET"
      {% elsif drop_down_selection._parameter_value == "'District'" %}
        ${TABLE}."RANK_YEAR_DISTRICT"
      {% elsif drop_down_selection._parameter_value == "'Region'" %}
        ${TABLE}."RANK_YEAR_REGION"
      {% else %}
        NULL
      {% endif %}
    {% else %}
      -- Quarter grain
      {% if drop_down_selection._parameter_value == "'Market'" %}
        ${TABLE}."RANK_QTR_MARKET"
      {% elsif drop_down_selection._parameter_value == "'District'" %}
        ${TABLE}."RANK_QTR_DISTRICT"
      {% elsif drop_down_selection._parameter_value == "'Region'" %}
        ${TABLE}."RANK_QTR_REGION"
      {% else %}
        NULL
      {% endif %}
    {% endif %} ;;
    value_format: "0.00"
  }

  measure: service_percent_year {
    type: average
    value_format_name: percent_2
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."SERVICE_PERCENT_YEAR" ELSE NULL END ;;
  }
  measure: average_service_percent_year {
    type: average
    value_format_name: percent_2
    sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."SERVICE_PERCENT_YEAR" ELSE NULL END ;;
    filters: [market_id: "-85607"]
  }
  # measure: average_service_percent_qtr {
  #   type: average
  #   sql: CASE WHEN ${row_type} = 'ROLLUP' THEN ${TABLE}."SERVICE_PERCENT" ELSE NULL END ;;
  # }

  # Show Yearly Trends
  dimension: service_percent_year_increased {
    type: yesno
    sql: ${TABLE}."SERVICE_PERCENT_YEAR_INCREASED" ;;
  }
  measure: count_markets_service_increased_yoy {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [service_percent_year_increased: "yes"]
    drill_fields: [
      market_name,
      market_id,
      region_name,
      district,
      year,
      # service_amount,
      # rental_revenue,
      # service_percent_year,
      service_percent_year_increased,
    ]
  }
  measure: count_markets_service_decreased_yoy {
    type: count_distinct
    sql: ${market_id} ;;
    filters: [service_percent_year_increased: "no"]
    drill_fields: [
      market_name,
      market_id,
      region_name,
      district,
      year,
      service_amount_qtr_rollup_sum,
      rental_revenue_rollup_sum,
      service_percent_rollup,
      service_percent_year_increased,
    ]
  }
}
