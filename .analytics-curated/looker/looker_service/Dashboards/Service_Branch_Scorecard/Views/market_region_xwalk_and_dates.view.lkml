
  include: "/views/OPERATIONAL_ANALYTICS/oa_dim_dates.view"
 # include: "/views/ANALYTICS/market_region_xwalk.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


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

    -- Flag for past 12 months (excluding current month)
    CASE
        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
        THEN 1 ELSE 0
    END AS is_last_12_months,
    m.*
FROM ${oa_dim_dates.SQL_TABLE_NAME}
CROSS JOIN analytics.public.market_region_xwalk as m
inner join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE as mr on mr.market_id = m.market_id
--and mr.BRANCH_EARNINGS_START_MONTH <= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
WHERE DT_DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
AND DT_DATE < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
 ;;
    }

  # Month Start Date Dimension
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(DATE_TRUNC('month', ${TABLE}.month), ${TABLE}.market_id) ;;
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
    sql: (${district} in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id} in ({{ _user_attributes['market_id'] }})) ;;
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



  measure: total_percent_to_goal_avg_last_1_month {
    type: number
    value_format: "0.00"
    sql: COALESCE((LEAST(COALESCE(${warranty_aggregate.avg_last_1_month},0),1) +
        LEAST(COALESCE(${training_aggregate.avg_last_1_month},0),.5) +
        LEAST(COALESCE(${lost_revenue_aggregate.avg_last_1_month},0),1.5) +
        LEAST(COALESCE(${compliance_vendors_aggregate.avg_last_1_month},0),1) +
        LEAST(COALESCE(${aging_work_orders_aggregate.avg_last_1_month},0),1.5) +
        LEAST(COALESCE(${turnover_aggregate.avg_last_1_month},0),.5) +
        LEAST(COALESCE(${overdue_inspections_aggregate.avg_last_1_month},0),1) +
        LEAST(COALESCE(${headcount_oec_aggregate.avg_last_1_month},0),.5) +
        LEAST(COALESCE(${deadstock_ratio_aggregate.avg_last_1_month},0),.5) +
        LEAST(COALESCE(${unavailable_oec_aggregate.avg_last_1_month},0),1.5) +
        LEAST(COALESCE(${wos_within_7days_of_delivery_aggregate.avg_last_1_month},0),.5)
        ),0);;
    description: "Total sum of all percent_to_goal metrics from different views, divided by 100"
  }

  measure: total_percent_to_goal_avg_last_3_months {
    type: number
    value_format: "0.00"
    sql: COALESCE((LEAST(COALESCE(${warranty_aggregate.avg_last_3_months},0),1) +
        LEAST(COALESCE(${training_aggregate.avg_last_3_months},0),.5) +
        LEAST(COALESCE(${lost_revenue_aggregate.avg_last_3_months},0),1.5) +
        LEAST(COALESCE(${compliance_vendors_aggregate.avg_last_3_months},0),1) +
        LEAST(COALESCE(${aging_work_orders_aggregate.avg_last_3_months},0),1.5) +
        LEAST(COALESCE(${turnover_aggregate.avg_last_3_months},0),.5) +
        LEAST(COALESCE(${overdue_inspections_aggregate.avg_last_3_months},0),1) +
        LEAST(COALESCE(${headcount_oec_aggregate.avg_last_3_months},0),.5) +
        LEAST(COALESCE(${deadstock_ratio_aggregate.avg_last_3_months},0),.5) +
        LEAST(COALESCE(${unavailable_oec_aggregate.avg_last_3_months},0),1.5) +
        LEAST(COALESCE(${wos_within_7days_of_delivery_aggregate.avg_last_3_months},0),.5)
        ),0);;
    description: "Total sum of all percent_to_goal metrics from different views, divided by 100"
    html:
    {% assign rounded = value | times: 100 | round | divided_by: 100 %}
    {% assign int_part = rounded | floor %}
    {% assign decimal_part = rounded | minus: int_part | times: 100 | round %}
    {% assign formatted_value = int_part | append: "." | append: decimal_part | slice: 0, 5 %}

    {% if value < 4 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 4 and value <= 7.5 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
  }

  measure: total_percent_to_goal_avg_last_12_months {
    type: number
    value_format: "0.00"
    sql: COALESCE((LEAST(COALESCE(${warranty_aggregate.avg_last_12_months},0),1) +
        LEAST(COALESCE(${training_aggregate.avg_last_12_months},0),.5) +
        LEAST(COALESCE(${lost_revenue_aggregate.avg_last_12_months},0),1.5) +
        LEAST(COALESCE(${compliance_vendors_aggregate.avg_last_12_months},0),1) +
        LEAST(COALESCE(${aging_work_orders_aggregate.avg_last_12_months},0),1.5) +
        LEAST(COALESCE(${turnover_aggregate.avg_last_12_months},0),.5) +
        LEAST(COALESCE(${overdue_inspections_aggregate.avg_last_12_months},0),1) +
        LEAST(COALESCE(${headcount_oec_aggregate.avg_last_12_months},0),.5) +
        LEAST(COALESCE(${deadstock_ratio_aggregate.avg_last_12_months},0),.5) +
        LEAST(COALESCE(${unavailable_oec_aggregate.avg_last_12_months},0),1.5) +
        LEAST(COALESCE(${wos_within_7days_of_delivery_aggregate.avg_last_12_months},0),.5)
        ),0);;
    description: "Total sum of all percent_to_goal metrics from different views, divided by 100"
  }

#        COALESCE(${lost_revenue_aggregate.avg_last_1_month}, 0) +
#        COALESCE(${retention_aggregate.avg_last_1_month}, 0) +
#        COALESCE(${unavailable_oec_aggregate.avg_last_1_month}, 0)

}

# --SELECT DISTINCT
# --    DATE_TRUNC('month', DT_DATE)::DATE AS month,
# --    -- Flag for past 1 month
# --    CASE
# --        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -1, DATE_TRUNC('month', CURRENT_DATE()))
# --        THEN 1 ELSE 0
# --    END AS is_last_1_month,
# --
# --    -- Flag for past 3 months
# --    CASE
# --        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -3, DATE_TRUNC('month', CURRENT_DATE()))
# --        THEN 1 ELSE 0
# --    END AS is_last_3_months,
# --
# --    -- Flag for past 12 months
# --    CASE
# --        WHEN DATE_TRUNC('month', DT_DATE) >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
# --        THEN 1 ELSE 0
# --    END AS is_last_12_months,
# --    m.*
# --FROM ${oa_dim_dates.SQL_TABLE_NAME}
# --cross join ${market_region_xwalk.SQL_TABLE_NAME} as m
# --WHERE DT_DATE BETWEEN '2023-01-01' AND CURRENT_DATE()
# ----ORDER BY month DESC
