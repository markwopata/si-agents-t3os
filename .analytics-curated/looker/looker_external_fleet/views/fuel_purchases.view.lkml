view: fuel_purchases {
  derived_table: {
    sql:

    with asset_data as (
  SELECT DISTINCT ai.*
  FROM
  BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
  JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai on ai.asset_id = cv.asset_id
  left join es_warehouse.public.organization_asset_xref oax on ai.asset_id = oax.asset_id
  left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
  WHERE
     (cv.owner_company_id = {{ _user_attributes['company_id'] }}
    or
    cv.rental_company_id = {{ _user_attributes['company_id'] }}
    )
    AND {% condition asset_names_filter %} ai.asset_type {% endcondition %}
    AND {% condition custom_name_filter %} ai.asset {% endcondition %}
    AND {% condition category_filter %} ai.category {% endcondition %}
    AND {% condition branch_filter %} ai.branch {% endcondition %}
    AND {% condition asset_class_filter %} ai.asset_class {% endcondition %}
    AND {% condition asset_make_filter %} ai.make {% endcondition %}
    AND {% condition asset_model_filter %} ai.model {% endcondition %}

    AND {% condition groups_filter %} o.name {% endcondition %}
    )

    SELECT
      a.ASSET_ID,
      a.CUSTOM_NAME AS ASSET,
      a.COMPANY_ID,
      a.MAKE,
      a.MODEL,
      f.PURCHASE_DATE::DATE AS FUEL_PURCHASE_DATE,
      f.CARD_HOLDER,
      CONCAT(TRIM(f.ADDRESS), ', ', TRIM(f.CITY), ', ', TRIM(s.NAME)) AS FUEL_PURCHASE_ADDRESS,
      w.DESCRIPTION AS FUEL_PURCHASE_DESCRIPTION,
      f.GALLONS_PURCHASED,
      f.COST_PER_GALLON,
      f.PURCHASE_PRICE
    FROM ES_WAREHOUSE.PUBLIC.FUEL_PURCHASES f
    INNER JOIN asset_data a USING(ASSET_ID)
    LEFT JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_FUEL_CONSUMPTION AFC on
    afc.asset_id = f.asset_id and
    afc.company_id = f.company_id and
    afc.start_date = f.PURCHASE_DATE::DATE
    LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES s USING(STATE_ID)
    LEFT JOIN ES_WAREHOUSE.PUBLIC.WEX_PURCHASE_CODES w USING(PURCHASE_CODE_ID)
    WHERE
          f.purchase_date >= {% date_start date_filter %}
      AND f.purchase_date <= {% date_end date_filter %}
    GROUP BY ALL ;;
  }


  ## Dimensions:

  dimension: asset_id {
    type: string
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}.ASSET ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension_group: fuel_purchase_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.FUEL_PURCHASE_DATE ;;
  }

  dimension: card_holder {
    type: string
    sql: ${TABLE}.CARD_HOLDER ;;
  }

  dimension: fuel_purchase_address {
    type: string
    sql: ${TABLE}.FUEL_PURCHASE_ADDRESS ;;
  }

  dimension: fuel_purchase_description {
    type: string
    sql: ${TABLE}.FUEL_PURCHASE_DESCRIPTION ;;
  }

  dimension: gallons_purchased {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.GALLONS_PURCHASED ;;
  }

  dimension: cost_per_gallon {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.COST_PER_GALLON ;;
  }

  dimension: purchase_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.PURCHASE_PRICE ;;
  }


   ## Measures:

  measure: total_fuel_gallons {
    type: sum
    value_format_name: decimal_0
    sql:  ${TABLE}.GALLONS_PURCHASED ;;
  }

  measure: total_fuel_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.PURCHASE_PRICE ;;
  }

  measure: total_distinct_assets {
    type: count_distinct
    sql: ${TABLE}.ASSET_ID ;;
  }

  measure: avg_cost_per_gallon {
    type: average
    value_format: "$#,##0.00"
    sql:  COST_PER_GALLON ;;
  }

  ## Filters:

  # filter: date_filter {
  #   type: date_time
  # }

  # filter: asset_make_filter {
  #   type: string
  #   suggest_explore: fuel_purchases
  #   suggest_dimension: fuel_purchases.make
  # }

  # filter: asset_model_filter {
  #   type: string
  #   suggest_explore: fuel_purchases
  #   suggest_dimension: fuel_purchases.model
  # }

  filter: date_filter {
    type: date_time
  }

  filter: asset_class_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.asset_class
  }

  filter: asset_make_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.make
  }

  filter: asset_model_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.model
  }

  filter: asset_names_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.asset_type
  }

  filter: custom_name_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.custom_name
  }

  filter: category_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.category
  }

  filter: branch_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.branch
  }

  filter: groups_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: organizations.groups
  }

  filter: job_name_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.job_name
  }

  filter: phase_job_name_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.phase_job_name
  }
}
