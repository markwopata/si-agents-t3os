view: fuel_emissions_aggregate {

  derived_table: {
    sql:
    WITH BASE_DATA AS (
    select
            CAST(asset_id AS STRING) AS asset_id
            ,asset
            ,make
            ,model
            ,asset_class
            ,engine_power_type
            ,SUM(emissions_per_day) AS total_emissions
            ,SUM(gallons_used_per_day) AS total_gallons
            ,SUM(idle_emissions_per_day) AS total_idle_emissions
            ,SUM(idle_gallons_per_day) AS total_idle_gallons
            ,SUM(idle_emissions_per_day)/SUM(emissions_per_day) AS percent_idle_emissions
            ,SUM(emissions_per_day)/NULLIF(SUM(gallons_used_per_day),0) AS emission_intensity_asset
        FROM business_intelligence.triage.stg_t3__by_day_utilization bdu
        WHERE (rental_company_id = {{ _user_attributes['company_id'] }}::numeric
              or owner_company_id = {{ _user_attributes['company_id'] }}::numeric)
        {% if date_filter._is_filtered %}
        and date >= {% date_start date_filter %}
        and date <= {% date_end date_filter %}
        {% endif %}
        AND {% condition asset_filter %} bdu.asset {% endcondition %}
        AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
        AND {% condition make_filter %} bdu.make {% endcondition %}
        AND {% condition model_filter %} bdu.model {% endcondition %}
        AND {% condition engine_type_filter %} bdu.engine_power_type {% endcondition %}
        GROUP BY ALL
    )
    SELECT
    *,
    SUM(total_emissions) OVER (ORDER BY total_emissions DESC) / SUM(total_emissions) OVER () AS cumulative_pct
    FROM BASE_DATA
  ;;
  }



  # ---------------------
  # Dimensions
  # ---------------------

  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }
  dimension: asset { type: string sql: ${TABLE}.ASSET ;; }
  dimension: model { type: string sql: ${TABLE}.MODEL ;; }
  dimension: make { type: string sql: ${TABLE}.MAKE ;; }
  dimension: asset_class { type: string sql: ${TABLE}.ASSET_CLASS ;; }
  dimension: engine_power_type { type: string sql: ${TABLE}.ENGINE_POWER_TYPE ;; }

  dimension: total_emissions_asset { type: number sql: ${TABLE}.TOTAL_EMISSIONS ;; }
  dimension: total_gallons_asset { type: number sql: ${TABLE}.TOTAL_GALLONS ;; }
  dimension: total_idle_emissions_asset { type: number sql: ${TABLE}.TOTAL_IDLE_EMISSIONS ;; }
  dimension: total_idle_gallons_asset { type: number sql: ${TABLE}.TOTAL_IDLE_GALLONS ;; }
  dimension: percent_idle_emissions { type: number sql: ${TABLE}.PERCENT_IDLE_EMISSIONS ;; }
  dimension: emission_intensity_asset { type: number sql: ${TABLE}.EMISSION_INTENSITY_ASSET ;; }

  dimension: cumulative_pct { type: number sql: ${TABLE}.CUMULATIVE_PCT ;; }

  dimension: asset_hyperlink {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${TABLE}.ASSET ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }


  # ---------------------
  # Meaures
  # ---------------------
  measure: distinct_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    value_format_name: decimal_0
    drill_fields: [asset_hyperlink, make, model, asset_class, engine_power_type, total_emissions_asset, total_gallons_asset]
  }

  measure: distinct_emitting_assets {
    #type: number
    #sql: COUNT(DISTINCT CASE WHEN total_emissions > 0 THEN ${asset_id} END) ;;
    type: count_distinct
    sql: ${asset_id} ;;
    value_format_name: decimal_0
    drill_fields: [asset_hyperlink, make, model, asset_class, engine_power_type, total_emissions, total_fuel_gallons]
    filters: [total_emissions_asset: ">0"]
    order_by_field: total_emissions
  }

  measure: performing_assets {
    #type: number
    #sql: SUM(CASE WHEN cumulative_pct <= 0.80 THEN 1 ELSE 0 END) ;;
    type: count_distinct
    sql: ${asset_id} ;;
    value_format_name: decimal_0
    drill_fields: [asset_hyperlink, make, model, asset_class, engine_power_type, total_emissions, total_fuel_gallons]
    filters: [cumulative_pct: "<=0.80"]
    order_by_field: total_emissions
  }

  measure: total_emissions { type: sum sql: ${total_emissions_asset} ;; value_format_name: decimal_0 }
  measure: average_emissions { type: average sql: ${total_emissions_asset} ;; value_format_name: decimal_0 }
  measure: projected_emissions { type: number sql: COUNT(DISTINCT ${asset_id})*AVG(${total_emissions_asset}) ;; value_format_name: decimal_0 }
  measure: total_idle_emissions { type: sum sql: ${total_idle_emissions_asset} ;; value_format_name: decimal_0 }
  measure: total_fuel_gallons { type: sum sql: ${total_gallons_asset} ;; value_format_name: decimal_0 }
  measure: total_idle_fuel_gallons { type: sum sql: ${total_idle_gallons_asset} ;; value_format_name: decimal_0 }
  measure: emission_intensity { type: number sql: SUM(${total_emissions_asset}) / SUM(${total_gallons_asset})  ;; value_format_name: decimal_2 }
  measure: avg_emission_intensity { type: number sql: AVG(${emission_intensity_asset})  ;; value_format_name: decimal_2 }
  measure: emission_intensity_unweighted { type: number sql: AVG(${total_emissions_asset}) / AVG(${total_gallons_asset})  ;; value_format_name: decimal_2 }


  # ---------------------
  # Filters
  # ---------------------

  filter: date_filter {
    type: date_time
  }

  filter: asset_filter {
    type: string
  }

  filter: asset_class_filter {
    type: string
  }

  filter: make_filter {
    type: string
  }

  filter: model_filter {
    type: string
  }

  filter: engine_type_filter {
    type: string
  }


}
