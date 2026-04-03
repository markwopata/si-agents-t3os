include: "/views/OPERATIONAL_ANALYTICS/oa_dim_dates.view"
include: "//service/views/ANALYTICS/market_region_xwalk.view.lkml"

view: market_region_xwalk_and_dates {
  derived_table: {
    sql:
    SELECT DISTINCT
        DATE_TRUNC('month', DT_DATE)::DATE AS month,
      -- Flag for past 1 month (excluding current month)
      CASE
        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -1, DATE_TRUNC('month', CURRENT_DATE()))
        THEN 1 ELSE 0
        END AS is_last_1_month,
      -- Flag for past 3 months (excluding current month)
      CASE
        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -3, DATE_TRUNC('month', CURRENT_DATE()))
        THEN 1 ELSE 0
        END AS is_last_3_months,
      -- Flag for past 6 months (excluding current month)
      CASE
        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -6, DATE_TRUNC('month', CURRENT_DATE()))
        THEN 1 ELSE 0
        END AS is_last_6_months,
      -- Flag for past 12 months (excluding current month)
      CASE
        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
        THEN 1 ELSE 0
        END AS is_last_12_months,
      datediff(months,mr.BRANCH_EARNINGS_START_MONTH,date_trunc(month,current_date()))  as months_open,
      m.*
    FROM ${oa_dim_dates.SQL_TABLE_NAME}
    CROSS JOIN ${market_region_xwalk.SQL_TABLE_NAME} as m
--    INNER JOIN ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE as mr
--      on mr.market_id = m.market_id and
--         mr.BRANCH_EARNINGS_START_MONTH <= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
    LEFT JOIN ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE                                as mr
      on m.market_id = mr.market_id
    WHERE DT_DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
      AND DT_DATE < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
      ;;
  }
  dimension: months_open {
    type: number
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }
  # Dimension for Month Start Date
  dimension: month {
    type: date
    sql: ${TABLE}.month ;;
  }
  # Flag Dimensions for Time Periods
  dimension: is_last_1_month {
    type: yesno
    sql: CASE WHEN ${TABLE}.is_last_1_month = 1 THEN TRUE ELSE FALSE END ;;
  }
  dimension: is_last_3_months {
    type: yesno
    sql: CASE WHEN ${TABLE}.is_last_3_months = 1 THEN TRUE ELSE FALSE END ;;
  }
  dimension: is_last_6_months {
    type: yesno
    sql: CASE WHEN ${TABLE}.is_last_6_months = 1 THEN TRUE ELSE FALSE END ;;
  }
  dimension: is_last_12_months {
    type: yesno
    sql: CASE WHEN ${TABLE}.is_last_12_months = 1 THEN TRUE ELSE FALSE END ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ::text ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: dealership_y_n {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: fulfillment_center_branch { ## branch using fc as of 10/2/2024
    type: yesno
    sql: iff(${market_id} in (100084,123279,121364,118741,118304,118928,119548,117658,116480,
          116676,115005,111298,113822,110132,107531,111615,113364,109003,99181,105670,104585,106045,
          104651,105742,104466,103038,103114,103045,102440,100031,49771,96278,84007,40686,40692,95857,
          90850,87996,78646,15963,20553,13576,85154,63125,44501,11007,80549,3,40685,24081,24080,61102,
          18703,7672,7670,45106,40698,16835,73712,40524,36764,15965,83551,80605,80607,6,8606,10525,61106,
          1,7329,74090,2,17140,10313,61872,11812,8135,55507,15969,15984,13575,8,43290,77191,36769,8631,
          17138,15977,23627,13574,4,18702,25923,33165,92194,92193,123054),true,false) ;;
  }
  dimension: market_type_desc {
    type: string
    sql: case when ${market_type} = 'Pum' then 'Pump & Power'
              when ${market_type} = 'ITL' then 'Industrial'
              when ${market_type} = 'OPS' then 'Rental Yard'
              else ${market_type} --updated this from 'Other' since the types are changing
              END;;
  }
  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}.district in ({{ _user_attributes['district'] }}) OR ${TABLE}.region_name in ({{ _user_attributes['region'] }}) OR ${TABLE}.market_id in ({{ _user_attributes['market_id'] }}) ;;
  }
  parameter: drop_down_selection {
    type: string
    allowed_value: {value: "Company"}
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
  }
  dimension: dynamic_location {
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
  dimension: selected_hierarchy_dimension {
    type: string
    link: {label:"Service Dashboard"
      url:"https://equipmentshare.looker.com/dashboards/49?Market=&Region=&District=&Market+Type="}
    sql:   {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
      {% elsif market_name._in_query %}
           ${market_name}
         {% elsif district._in_query %}
           ${market_name}
         {% elsif region_name._in_query %}
           ${district}
         {% else %}
           ${region_name}
         {% endif %};;
  }
  measure: count {
    type: count
    drill_fields: [market_name]
  }
  dimension: pilot_study_market {
    type: yesno
    sql: iff(${market_id} in (3, 15966, 74090, 10313, 11812, 8631), TRUE, FALSE) ;;
  }
  dimension: market_name_and_id {
    type: string
    sql: concat(${market_id},' - ',${market_name}) ;;
  }
  dimension: light_weight {
    hidden: yes
    type: number
    sql: '.5' ;;
  }
  dimension: moderate_weight {
    hidden: yes
    type: number
    sql: '1.5' ;;
  }
  dimension: heavy_weight {
    hidden: yes
    type: number
    sql: '2.5' ;;
  }

  measure: total_score_avg_last_1_month {
    type: number
    value_format: "0.00"
    sql:COALESCE((LEAST(COALESCE(${bin_locations_aggregate.score_avg_last_1_month},0),{% parameter bin_locations_aggregate.weight %}) +
        LEAST(COALESCE(${deadstock_aggregate.score_avg_last_1_month},0),{% parameter deadstock_aggregate.weight %}) +
        LEAST(COALESCE(${min_max_use_aggregate.score_avg_last_1_month},0),{% parameter min_max_use_aggregate.weight %}) +
        LEAST(COALESCE(${parts_needed_wo_aggregate.score_avg_last_1_month},0),{% parameter parts_needed_wo_aggregate.weight %}) +
        LEAST(COALESCE(${purchase_order_aggregate.score_avg_last_1_month},0),{% parameter purchase_order_aggregate.weight %}) +
        LEAST(COALESCE(${warranty_denials_aggregate.score_avg_last_1_month},0),{% parameter warranty_denials_aggregate.weight %})
        ),0);;
    description: "Total sum of all score metrics from different views"
  }
  measure: total_score_avg_last_3_months {
    type: number
    value_format: "0.00"
    sql:COALESCE((LEAST(COALESCE(${bin_locations_aggregate.score_avg_last_3_months},0),{% parameter bin_locations_aggregate.weight %}) +
        LEAST(COALESCE(${deadstock_aggregate.score_avg_last_3_months},0),{% parameter deadstock_aggregate.weight %}) +
        LEAST(COALESCE(${min_max_use_aggregate.score_avg_last_3_months},0),{% parameter min_max_use_aggregate.weight %}) +
        LEAST(COALESCE(${parts_needed_wo_aggregate.score_avg_last_3_months},0),{% parameter parts_needed_wo_aggregate.weight %}) +
        LEAST(COALESCE(${purchase_order_aggregate.score_avg_last_3_months},0),{% parameter purchase_order_aggregate.weight %}) +
        LEAST(COALESCE(${warranty_denials_aggregate.score_avg_last_3_months},0),{% parameter warranty_denials_aggregate.weight %})
        ),0);;
    description: "Total sum of all score metrics from different views"
  }
  measure: total_score_avg_last_6_months {
    type: number
    value_format: "0.00"
    sql:COALESCE((LEAST(COALESCE(${bin_locations_aggregate.score_avg_last_6_months},0),{% parameter bin_locations_aggregate.weight %}) +
        LEAST(COALESCE(${deadstock_aggregate.score_avg_last_6_months},0),{% parameter deadstock_aggregate.weight %}) +
        LEAST(COALESCE(${min_max_use_aggregate.score_avg_last_6_months},0),{% parameter min_max_use_aggregate.weight %}) +
        LEAST(COALESCE(${parts_needed_wo_aggregate.score_avg_last_6_months},0),{% parameter parts_needed_wo_aggregate.weight %}) +
        LEAST(COALESCE(${purchase_order_aggregate.score_avg_last_6_months},0),{% parameter purchase_order_aggregate.weight %}) +
        LEAST(COALESCE(${warranty_denials_aggregate.score_avg_last_6_months},0),{% parameter warranty_denials_aggregate.weight %})
        ),0);;
    description: "Total sum of all score metrics from different views"
  }
  measure: total_score_avg_last_12_months {
    type: number
    value_format: "0.00"
    sql:COALESCE((LEAST(COALESCE(${bin_locations_aggregate.score_avg_last_12_months},0),{% parameter bin_locations_aggregate.weight %}) +
        LEAST(COALESCE(${deadstock_aggregate.score_avg_last_12_months},0),{% parameter deadstock_aggregate.weight %}) +
        LEAST(COALESCE(${min_max_use_aggregate.score_avg_last_12_months},0),{% parameter min_max_use_aggregate.weight %}) +
        LEAST(COALESCE(${parts_needed_wo_aggregate.score_avg_last_12_months},0),{% parameter parts_needed_wo_aggregate.weight %}) +
        LEAST(COALESCE(${purchase_order_aggregate.score_avg_last_12_months},0),{% parameter purchase_order_aggregate.weight %}) +
        LEAST(COALESCE(${warranty_denials_aggregate.score_avg_last_12_months},0),{% parameter warranty_denials_aggregate.weight %})
        ),0);;
    description: "Total sum of all score metrics from different views"
  }

}
