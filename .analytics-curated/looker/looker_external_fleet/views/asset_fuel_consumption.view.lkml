view: asset_fuel_consumption {
  derived_table: {
    sql:
WITH temp_slider AS (
  SELECT 0.25 AS num
  UNION ALL
  SELECT num + 0.25 FROM temp_slider
  WHERE num + 0.25 <= 15
),
gas_price_slider AS (
  SELECT 1 AS dummy_join_param,
         CAST(num AS DECIMAL(15,2)) AS gas_price_data
  FROM temp_slider t
  WHERE {% condition gas_price_filter %} CAST(num AS DECIMAL(15,2)) {% endcondition %}
),
date_diff_cte AS (
  SELECT DATEDIFF('day', {% date_start date_filter %}, {% date_end date_filter %}) AS delta_days
),
date_range AS (
  SELECT DATEADD('day', seq4(), {% date_start date_filter %}) AS report_date
  FROM TABLE(GENERATOR(ROWCOUNT => 1000))
  WHERE DATEADD('day', seq4(), {% date_start date_filter %}) <= {% date_end date_filter %}
),
asset_data as (
  SELECT ai.*
  FROM
  BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
  JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai on ai.asset_id = cv.asset_id
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
),
asset_day_cross AS (
  SELECT
    dr.report_date,
    ad.*
  FROM date_range dr
  CROSS JOIN asset_data ad
),
afc_data AS (
  SELECT *
  FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_FUEL_CONSUMPTION
  where asset_id in (select distinct asset_id from asset_data)
)
SELECT DISTINCT
  -- General asset data
  adc.asset_id,
  adc.company_id,
  adc.asset,
  adc.asset_type,
  adc.custom_name,
  adc.category AS category_name,
  adc.branch AS market_name,
  adc.asset_class,
  adc.ownership,
  adc.report_date AS start_date,
  CAST(adc.report_date AS STRING) AS start_date_string,

  -- Previous period usage
  DATEADD('day', -1 * ddc.delta_days, adc.report_date) AS previous_period_start_date,
  CAST(DATEADD('day', -1 * ddc.delta_days, adc.report_date) AS STRING) AS previous_period_start_date_string,
  DATEADD('day', -1 * ddc.delta_days, comp.hau_start_date) AS previous_period_hau_start_date,
  DATEADD('day', -1 * ddc.delta_days, comp.hau_end_date) AS previous_period_hau_end_date,
  comp.gallons_used_per_day AS previous_period_gallons_used_per_day,
  comp.idle_gallons_per_day AS previous_period_idle_gallons_per_day,
  comp.on_time AS previous_period_on_time,
  comp.idle_time AS previous_period_idle_time,
  comp.miles_driven AS previous_period_miles_driven,

  -- Main period usage
  afc.job_id,
  afc.job_name,
  afc.phase_job_id,
  afc.phase_job_name,
  afc.hau_start_date,
  afc.hau_end_date,
  afc.gallons_used_per_day,
  afc.idle_gallons_per_day,
  afc.on_time,
  afc.idle_time,
  afc.miles_driven,
  iff('{% parameter suspect_trip_data_flag %}'= 'true', CAST('Yes' as boolean) ,afc.suspect_trip_data_flag) as suspect_trip_data_flag,
  afc.suspect_trip_table_flag,

  -- Gas slider and asset make/model
  sld.gas_price_data,
  adc.make,
  adc.model

FROM asset_day_cross adc
JOIN date_diff_cte ddc ON TRUE
LEFT JOIN afc_data afc
  ON afc.asset_id = adc.asset_id
  AND afc.start_date = adc.report_date
  AND afc.hau_start_date >= adc.report_date
  AND afc.hau_end_date <= adc.report_date
JOIN gas_price_slider sld
  ON IFNULL(afc.dummy_join_param, 1) = sld.dummy_join_param
LEFT JOIN afc_data comp
  ON comp.asset_id = adc.asset_id
  AND comp.start_date = DATEADD('day', -1 * ddc.delta_days, adc.report_date)
  AND comp.hau_start_date >= DATEADD('day', -1 * ddc.delta_days, adc.report_date)
  AND comp.hau_end_date <= DATEADD('day', -1 * ddc.delta_days, adc.report_date)
left join
  (select oax.asset_id, listagg(o.name,', ') as group_name
  from organization_asset_xref oax
  join organizations o on oax.organization_id = o.organization_id
  AND o.company_id = {{ _user_attributes['company_id'] }}
  where {% condition groups_filter %} o.name {% endcondition %}
  group by oax.asset_id) org on org.asset_id = afc.asset_id
WHERE
  adc.report_date >= {% date_start date_filter %}
  AND adc.report_date < {% date_end date_filter %}
  AND {% condition job_name_filter %} afc.job_name {% endcondition %}
  AND {% condition phase_job_name_filter %} afc.phase_job_name {% endcondition %}
  AND {% condition gas_price_filter %} CAST(sld.gas_price_data AS DECIMAL(15,2)) {% endcondition %}
  AND {% condition groups_filter %} org.group_name {% endcondition %}
      ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${previous_period_start_date_raw}) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: category_name {
    label: "Category"
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: market_name {
    label: "Branch"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension_group: start_date {
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: previous_period_start_date {
    type: time
    sql: ${TABLE}."PREVIOUS_PERIOD_START_DATE" ;;
  }

  dimension: gallons_used_per_day {
    type: number
    sql: ${TABLE}."GALLONS_USED_PER_DAY" ;;
  }

  dimension: idle_gallons_per_day {
    type: number
    sql: ${TABLE}."IDLE_GALLONS_PER_DAY" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: phase_job_id {
    type: number
    sql: ${TABLE}."PHASE_JOB_ID" ;;
  }

  dimension: phase_job_name {
    type: string
    sql: ${TABLE}."PHASE_JOB_NAME" ;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: gas_price_filter{
    type: number
  }

  filter: abnormal_data_filter{
    type: yesno
  }

  # dimension: comparison_flag {
  #   type: number
  #   sql: ${TABLE}."COMPARISON_FLAG" ;;
  # }

  dimension: gas_price_data {
    type: number
    value_format: "$ #,##0.00"
    sql: ${TABLE}."GAS_PRICE_DATA" ;;
  }

  dimension: previous_period_gallons_used_per_day {
    type: number
    sql: ${TABLE}."PREVIOUS_PERIOD_GALLONS_USED_PER_DAY" ;;
  }

  dimension: previous_period_idle_gallons_used_per_day {
    type: number
    sql: ${TABLE}."PREVIOUS_PERIOD_IDLE_GALLONS_USED_PER_DAY" ;;
  }

  dimension: suspect_trip_data_flag {
    type: yesno
    sql:${TABLE}."SUSPECT_TRIP_DATA_FLAG";;
  }

  dimension: suspect_trip_table_flag {
    type: yesno
    sql:     CASE
      WHEN ${TABLE}."SUSPECT_TRIP_TABLE_FLAG" = 'YES' THEN TRUE
      WHEN ${TABLE}."SUSPECT_TRIP_TABLE_FLAG" = 'NO' THEN FALSE
      ELSE NULL
    END ;;
  }

  measure: previous_period_total_gallons {
    type: sum
    sql: ${previous_period_gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} gal.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: previous_period_idle_gallons {
    type: sum
    sql: ${previous_period_idle_gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} gal.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_gallons_change_over_previous_period {
    type: number
    sql: coalesce((${total_gallons} - ${previous_period_total_gallons}) / nullif(${total_gallons},0),0) * 100;;
    html:
    {% if value > 0 %}
    <span style="color:#DA344D;"> {{ rendered_value }} % </span>
    {% elsif value < 0 %}
    <span style="color:#00CB86;"> {{ rendered_value }} % </span>
    {% else %}
    <span style="color:#FFB14E;">{{ rendered_value }} % </span>
    {% endif %}
    ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }

  dimension: previous_period_miles_driven {
    type: number
    sql: ${TABLE}."PREVIOUS_PERIOD_MILES_DRIVEN" ;;
  }

  measure: previous_period_total_miles_driven {
    type: sum
    sql: ${previous_period_miles_driven} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} Miles
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }


  measure: total_miles_driven_change_over_previous_period {
    type: number
    sql: coalesce((${total_miles_driven} - ${previous_period_total_miles_driven}) / nullif(${total_miles_driven},0),0) * 100;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} %
    </font>
    </a>
    ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }


  dimension: previous_period_on_time {
    type: number
    sql: ${TABLE}."PREVIOUS_PERIOD_ON_TIME" ;;
  }

  measure: previous_period_total_run_time {
    type: sum
    sql: coalesce(${previous_period_on_time}/3600,0) ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} hrs.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }


  measure: total_run_time_change_over_previous_period {
    type: number
    sql: coalesce((${total_run_time} - ${previous_period_total_run_time}) / nullif(${total_run_time},0),0) * 100;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} %
    </font>
    </a>
    ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }

  measure: gas_price_measure {
    label: "Selected Fuel Price"
    type: average
    sql: ${gas_price_data}  ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}}
    </font>
    </a>
    ;;
    value_format: "$ #,##0.00"
    drill_fields: [detail*]
  }

  measure: estimated_fuel_cost {
    type: sum
    sql: ${gas_price_data} * ${gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}}
    </font>
    </a>
    ;;
    value_format: "$ #,##0.00"
    drill_fields: [detail*]
  }

  measure: previous_estimated_fuel_cost {
    type: sum
    sql: ${gas_price_data} * ${previous_period_gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}}
    </font>
    </a>
    ;;
    value_format: "$ #,##0.00"
    drill_fields: [detail*]
  }

  measure: estimated_idle_fuel_cost {
    type: sum
    sql: ${gas_price_data} * ${idle_gallons_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}}
    </font>
    </a>
    ;;
    value_format: "$ #,##0.00"
    drill_fields: [detail*]
  }

  measure: previous_estimated_idle_fuel_cost {
    type: sum
    sql: ${gas_price_data} * ${previous_period_idle_gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}}
    </font>
    </a>
    ;;
    value_format: "$ #,##0.00"
    drill_fields: [detail*]
  }

  # measure: estimated_fuel_cost_change_over_previous_period {
  #   type: number
  #   sql: coalesce((${estimated_fuel_cost} - ${previous_estimated_fuel_cost}) / nullif(${estimated_fuel_cost},0),0) * 100;;
  #   html:
  #   <a href="#drillmenu" target="_self">
  #   <font color="#000000">
  #   {{rendered_value}} %
  #   </font>
  #   </a>
  #   ;;
  #   value_format_name: decimal_2
  #   drill_fields: [detail*]
  # }

  measure: estimated_fuel_cost_change_over_previous_period {
    type: number
    sql: coalesce((${estimated_fuel_cost} - ${previous_estimated_fuel_cost}) / nullif(${estimated_fuel_cost},0),0) * 100;;
    html:
    {% if value > 0 %}
    <span style="color:#DA344D;"> {{ rendered_value }} % </span>
    {% elsif value < 0 %}
    <span style="color:#00CB86;"> {{ rendered_value }} % </span>
    {% else %}
    <span style="color:#FFB14E;">{{ rendered_value }} % </span>
    {% endif %} ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }


  measure: total_miles_driven {
    type: sum
    sql: ${miles_driven} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} Miles
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: actual_miles_per_gallon_used_per_day {
    type: number
    sql: coalesce(${total_miles_driven} / nullif(${total_gallons},0),0) ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} MPG
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: gallons_per_hour_per_day {
    type: number
    sql: coalesce(${total_gallons} / nullif(${total_run_time},0),0) ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} gal.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: idle_gallon_percent {
    type: number
    sql: coalesce(${total_idle_gallons} / nullif(${total_gallons},0),0) * 100;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} %
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: idle_time_percent {
    type: number
    sql: coalesce(${total_idle_time} / nullif(${total_run_time},0),0) * 100;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} %
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }


  measure: total_gallons {
    type: sum
    sql: ${gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} gal.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_idle_gallons {
    type: sum
    sql: ${idle_gallons_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} gal.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_run_time {
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} hrs.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_idle_time {
    type: sum
    sql: coalesce(${idle_time}/3600,0) ;;
    html:
    <a href="#drillmenu" target="_self">
    <font color="#000000">
    {{rendered_value}} hrs.
    </font>
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_gallons_bar_chart {
    group_label: "Bar Chart"
    label: "Total Fuel Consumed"
    type: sum
    sql: ${gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    {{rendered_value}} gal.
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: previous_total_gallons_bar_chart {
    group_label: "Bar Chart"
    label: "Previous Total Fuel Consumed"
    type: sum
    sql: ${previous_period_gallons_used_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    {{rendered_value}} gal.
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_cost_bar_chart {
    group_label: "Bar Chart"
    label: "Estimated Fuel Cost"
    type: number
    sql: ${estimated_fuel_cost} ;;
    html:
    <a href="#drillmenu" target="_self">
    $ {{rendered_value}}
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: previous_total_cost_bar_chart {
    group_label: "Bar Chart"
    label: "Previous Estimated Fuel Cost"
    type: number
    sql: ${previous_estimated_fuel_cost} ;;
    html:
    <a href="#drillmenu" target="_self">
    $ {{rendered_value}}
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_idle_gallons_bar_chart {
    group_label: "Bar Chart"
    label: "Total Idle Fuel Consumed"
    type: sum
    sql: ${idle_gallons_per_day} ;;
    html:
    <a href="#drillmenu" target="_self">
    {{rendered_value}} gal.
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: total_run_time_bar_chart {
    group_label: "Bar Chart"
    label: "Total Run Time"
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    html:
    <a href="#drillmenu" target="_self">
    {{rendered_value}} hrs.
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: idle_percent_bar_chart {
    group_label: "Bar Chart"
    label: "Idle Percent"
    type: percent_of_total
    sql: ${total_idle_gallons} / ${total_gallons} ;;
    # html:
    # <a href="#drillmenu" target="_self">
    # {{rendered_value}} per.
    # </a>
    # ;;
    value_format_name: percent_2
    drill_fields: [detail*]
  }

  measure: total_idle_time_bar_chart {
    group_label: "Bar Chart"
    label: "Total Idle Time"
    type: sum
    sql: coalesce(${idle_time}/3600,0) ;;
    html:
    <a href="#drillmenu" target="_self">
    {{rendered_value}} hrs.
    </a>
    ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  parameter: timeframe_selection {
    type: string
    allowed_value: { value: "Daily"}
    allowed_value: { value: "Day of Week"}
    allowed_value: { value: "Monthly"}
  }

  dimension: start_date_string {
    type: string
    sql: ${TABLE}."START_DATE_STRING" ;;
  }

  dimension: previous_period_start_date_string {
    type: string
    sql: ${TABLE}."PREVIOUS_PERIOD_START_DATE_STRING" ;;
  }

  dimension: dynamic_timeframe {
    label: "Date"
    type: string
    sql:
    CASE
    WHEN {% parameter timeframe_selection %} = 'Daily' THEN ${start_date_string}
    WHEN {% parameter timeframe_selection %} = 'Day of Week' THEN ${start_date_day_of_week}
    WHEN {% parameter timeframe_selection %} = 'Monthly' THEN ${start_date_month}
    END ;;
    html: {% if timeframe_selection._parameter_value == "'Daily'" %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif timeframe_selection._parameter_value == "'Day of Week'" %}
          {{ rendered_value | date: "%A" }}
          {% elsif timeframe_selection._parameter_value == "'Monthly'" %}
          {{ rendered_value | date: "%B, %Y" }}
          {% endif %} ;;
  }

  dimension: previous_period_dynamic_timeframe {
    label: "Previous Period Date"
    type: string
    sql:
    CASE
    WHEN {% parameter timeframe_selection %} = 'Daily' THEN ${previous_period_start_date_string}
    WHEN {% parameter timeframe_selection %} = 'Day of Week' THEN ${previous_period_start_date_day_of_week}
    WHEN {% parameter timeframe_selection %} = 'Monthly' THEN ${previous_period_start_date_month}
    END ;;
    html: {% if timeframe_selection._parameter_value == "'Daily'" %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif timeframe_selection._parameter_value == "'Day of Week'" %}
          {{ rendered_value | date: "%A" }}
          {% elsif timeframe_selection._parameter_value == "'Monthly'" %}
          {{ rendered_value | date: "%B, %Y" }}
          {% endif %} ;;
  }

  dimension: day_sort {
    type: string
    sql: CASE
          WHEN {% parameter timeframe_selection %} = 'Daily' THEN ${start_date_string}
          WHEN {% parameter timeframe_selection %} = 'Day of Week' THEN
                (CASE
                WHEN ${start_date_day_of_week} = 'Sunday' then 'A'
                WHEN ${start_date_day_of_week} = 'Monday' then 'B'
                WHEN ${start_date_day_of_week} = 'Tuesday' then 'C'
                WHEN ${start_date_day_of_week} = 'Wednesday' then 'D'
                WHEN ${start_date_day_of_week} = 'Thursday' then 'E'
                WHEN ${start_date_day_of_week} = 'Friday' then 'F'
                WHEN ${start_date_day_of_week} = 'Saturday' then 'G'
                END
                )
          WHEN {% parameter timeframe_selection %} = 'Monthly' THEN ${start_date_month}
          END ;;
  }

  dimension: day_sort_fuel {
    type: string
    sql: CASE
          WHEN {% parameter timeframe_selection %} = 'Daily' THEN ${previous_period_start_date_string}
          WHEN {% parameter timeframe_selection %} = 'Day of Week' THEN
                (CASE
                WHEN ${start_date_day_of_week} = 'Sunday' then 'G'
                WHEN ${start_date_day_of_week} = 'Monday' then 'F'
                WHEN ${start_date_day_of_week} = 'Tuesday' then 'E'
                WHEN ${start_date_day_of_week} = 'Wednesday' then 'D'
                WHEN ${start_date_day_of_week} = 'Thursday' then 'C'
                WHEN ${start_date_day_of_week} = 'Friday' then 'B'
                WHEN ${start_date_day_of_week} = 'Saturday' then 'A'
                END
                )
          WHEN {% parameter timeframe_selection %} = 'Monthly' THEN ${start_date_month}
          END ;;
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
    suggest_dimension: asset_fuel_consumption.asset
  }

  filter: category_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.category_name
  }

  filter: branch_filter {
    suggest_explore: asset_fuel_consumption
    suggest_dimension: asset_fuel_consumption.market_name
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
  set: detail {
    fields: [
      asset,
      dynamic_timeframe,
      make,
      model,
      ownership,
      total_gallons,
      total_idle_gallons,
      total_run_time,
      total_idle_time
    ]
  }
}
