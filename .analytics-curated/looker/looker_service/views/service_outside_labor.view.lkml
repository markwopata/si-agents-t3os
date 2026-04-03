view: service_outside_labor {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_OUTSIDE_LABOR" ;;
  # Note: this table has a market-quarter grain.

  # For year grain, the SQL table is not normal form and repeats those values for each quarter of the year.
  # I apologize for these questionable data practices ^ , but I couldn't figure out how to compute everything I wanted on the Looker side of things

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

  # Service Amount & Percent
  measure: rental_revenue {
    type: sum
    sql: ${TABLE}."RENTAL_REVENUE_AMOUNT" ;;
    value_format_name: usd
    drill_fields: [market_name, region_name, district, year, quarter, service_outside_labor.rental_revenue]
  }
  measure: service_amount {
    type: sum
    sql: ${TABLE}."SERVICE_AMOUNT" ;;
    value_format_name: usd
    drill_fields: [market_name, region_name, district, year, quarter, service_amount]
    link: {
      label: "Show PO-level Details"
      url: "https://equipmentshare.looker.com/explore/service_outside_labor_enhancement/purchase_order_line_items?qid=F1xV5szvSyM6BDSdSsMHf3&toggle=fil,vis"
      # url: "/explore/service_outside_labor/purchase_order_line_items?fields=purchase_order_line_items.purchase_order_line_id,&f[users.city]=&sorts=orders.count+desc&limit=500"
    }
  }

  # Service Percent
  measure: service_percent_quarter {
    type: max
    sql: ${TABLE}."SERVICE_PERCENT" ;;
  }
  measure: service_percent_year {
    type: average
    sql: ${TABLE}."SERVICE_PERCENT_YEAR" ;;
    value_format_name: percent_2
  }
  # measure: service_percent_calculated {
  #   type: number
  #   sql: ${service_amount} / NULLIFZERO(${rental_revenue}) ;;
  #   value_format_name: percent_2
  # }


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

  # measure: service_percent_rank_quarter {
  #   type: max
  #   sql: ${TABLE}."SERVICE_PERCENT_RANK_QUARTER" ;;
  #   value_format: "0.00"
  #   hidden: yes
  # }

  # dimension: service_percent_rank_quarter {
  #   hidden: yes
  #   type: number
  #   sql:
  #   CASE
  #     WHEN ${TABLE}."SERVICE_PERCENT" IS NULL THEN NULL
  #     ELSE PERCENT_RANK() OVER (
  #           PARTITION BY ${quarter_label}, ${dynamic_location}
  #           ORDER BY ${TABLE}."SERVICE_PERCENT"
  #         )
  #   END ;;
  #   value_format: "0.00"
  # }

  # dimension: service_percent_rank_quarter {
  #   hidden: yes
  #   type: number
  #   sql:
  #   CASE
  #     WHEN ${service_percent_quarter} IS NULL THEN NULL
  #     ELSE PERCENT_RANK() OVER (
  #           PARTITION BY ${quarter_label}
  #           ORDER BY ${service_percent_quarter}
  #         )
  #   END ;;
  #   value_format: "0.00"
  # }


  # measure: service_percent_quarter_calculated_color_coded {
  #   type: number
  #   sql: ${service_percent_quarter} ;;
  #   value_format_name: percent_2
  #   html:
  #   {% assign rank = service_percent_rank_quarter._value %}
  #     {% if rank != null %}
  #       {% if rank >= 0.9 %}
  #         <div style="background-color:lightcoral; display:block;">{{ rendered_value }}</div>
  #       {% elsif rank <= 0.1 %}
  #         <div style="background-color:lightgreen; display:block;">{{ rendered_value }}</div>
  #       {% else %}
  #         <div style="background-color:lightyellow; display:block;">{{ rendered_value }}</div>
  #       {% endif %}
  #   {% else %}
  #     {{ rendered_value }}
  #   {% endif %}
  #   ;;
  # }

  # dimension: service_percent_rank_year {
  #   type: number
  #   sql: CASE
  #     WHEN ${service_percent_year} IS NULL THEN NULL
  #     ELSE PERCENT_RANK() OVER (
  #           PARTITION BY ${year}
  #           ORDER BY ${service_percent_year}
  #         )
  #   END ;;
  #   hidden: yes
  # }
  # dimension: service_percent_rank_year {
  #   type: number
  #   sql: CASE
  #         WHEN ${TABLE}."SERVICE_PERCENT_YEAR" IS NULL THEN NULL
  #         ELSE PERCENT_RANK() OVER (
  #               PARTITION BY ${year}
  #               ORDER BY ${service_percent_year}
  #             )
  #       END ;;
  #   hidden: yes
  # }

  # measure: service_percent_year_calculated_color_coded {
  #   type: number
  #   # sql: ${service_amount} / NULLIFZERO(${rental_revenue}) ;;
  #   sql: ${service_percent_year} ;;
  #   value_format_name: percent_2
  #   html:
  #   {% assign rank = service_percent_rank_year._value %}
  #     {% if rank != null %}
  #   {% if rank >= 0.9 %}
  #     <div style="background-color:lightcoral; display:block;">{{ rendered_value }}</div>
  #   {% elsif rank <= 0.1 %}
  #     <div style="background-color:lightgreen; display:block;">{{ rendered_value }}</div>
  #   {% else %}
  #     <div style="background-color:lightyellow; display:block;">{{ rendered_value }}</div>
  #   {% endif %}
  #   {% else %}
  #     {{ rendered_value }}
  #   {% endif %}
  #   ;;
  # }

  # Unavailable
  measure: unavailable_oec_sum {
    type: sum
    sql: ${TABLE}.UNAVAILABLE_OEC ;;
  }
  measure: rental_fleet_oec_sum {
    type: sum
    sql: ${TABLE}.RENTAL_FLEET_OEC ;;
  }
  measure: unavailable_oec_pct_calculated {
    type: number
    sql: ${unavailable_oec_sum} / NULLIF(${rental_fleet_oec_sum}, 0) ;;
    value_format_name: percent_2
  }

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

  # measure: service_percent_dynamic {
  #   label: "Service Percent Dynamic"
  #   type: number
  #   sql:
  #   {% if time_grain._parameter_value == "Year" %}
  #     ${service_percent_year_calculated_color_coded}
  #   {% else %}
  #     ${service_percent_quarter_calculated_color_coded}
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
  #       <div style="background-color:lightyellow; display:block;">{{ rendered_value }}</div>
  #     {% endif %}
  #   {% else %}
  #     {{ rendered_value }}
  #   {% endif %} ;;
  # }
  measure: service_percent_dynamic {
    label: "Service Percent Dynamic"
    type: max
    sql:
    {% if time_grain._parameter_value == "Year" %}
      ${TABLE}."SERVICE_PERCENT_YEAR"
    {% else %}
      ${TABLE}."SERVICE_PERCENT"
    {% endif %} ;;
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
  measure: average_service_percent_year {
    type: average
    sql: ${TABLE}."SERVICE_PERCENT_YEAR" ;;
  }
  # measure: service_percent_rank_dynamic {
  #   label: "Service Percent Rank Dynamic"
  #   type: number
  #   sql:
  #     {% if time_grain._parameter_value == "Year" %}
  #       ${service_percent_rank_year}
  #     {% else %}
  #       ${service_percent_rank_quarter}
  #     {% endif %} ;;
  #   value_format: "0.00"
  # }
  # dimension: service_percent_rank_dynamic {
  #   label: "Service Percent Rank Dynamic"
  #   type: number
  #   sql:
  #   CASE
  #     {% if time_grain._parameter_value == "Year" %}
  #       WHEN ${TABLE}."SERVICE_PERCENT_YEAR" IS NULL THEN NULL
  #     {% else %}
  #       WHEN ${TABLE}."SERVICE_PERCENT" IS NULL THEN NULL
  #     {% endif %}
  #     ELSE PERCENT_RANK() OVER (
  #       PARTITION BY ${time_pivot}, ${dynamic_location}
  #       ORDER BY
  #         {% if time_grain._parameter_value == "Year" %}
  #           ${TABLE}."SERVICE_PERCENT_YEAR"
  #         {% else %}
  #           ${TABLE}."SERVICE_PERCENT"
  #         {% endif %}
  #     )
  #   END ;;
  #   value_format: "0.00"
  #   hidden: yes
  # }
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
        service_amount,
        rental_revenue,
        service_percent_year,
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
      service_amount,
      rental_revenue,
      service_percent_year,
      service_percent_year_increased,
    ]
  }
}
