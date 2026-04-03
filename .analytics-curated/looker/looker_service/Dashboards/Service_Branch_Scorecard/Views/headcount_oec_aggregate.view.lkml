include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


view: headcount_oec_aggregate {
  derived_table: {
    sql:

WITH historical_oec AS (
    SELECT
        ad.MARKET_ID AS branch_id,
        DATE_TRUNC('month', GL_DATE)::DATE AS month,
        SUM(aa.oec) AS total_oec
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    LEFT JOIN ANALYTICS.BRANCH_EARNINGS.ASSET_DETAIL ad ON ad.ASSET_ID = aa.asset_id
    GROUP BY 1, 2
),

dim_date AS (
    SELECT DISTINCT DATE_TRUNC('month', DT_DATE)::DATE AS month
    FROM operational_analytics.gold.oa_dim_dates
    WHERE DT_DATE <= CURRENT_DATE()
)
     ,

techs_with_weight AS (
    SELECT
        DATE_TRUNC('month', d.month) AS month,
        cd.MARKET_ID AS branch_id,
        cd.employee_id,
        cd.employee_title,
        CASE
            WHEN employee_title ILIKE '%Yard Technician%' THEN 15500000
            WHEN employee_title ILIKE '%Field Technician%' OR employee_title ILIKE '%Shop Technician%' THEN 5000000
            ELSE 0
        END AS oec_target
    FROM dim_date d
    JOIN analytics.payroll.company_directory cd
        ON cd.date_hired <= LAST_DAY(d.month)
        AND (cd.date_terminated IS NULL OR cd.date_terminated >= d.month)
    where employee_title ilike any ('%Field Technician%', '%Shop Technician%', '%Yard Technician%')

)
,

branch_month_summary AS (
    SELECT
        branch_id,
        month,
        COUNT(DISTINCT employee_id) AS active_employee_count,
        SUM(oec_target) AS total_target_oec
    FROM techs_with_weight
    GROUP BY 1, 2
)

SELECT
    bms.branch_id,
    bms.month,
    bms.active_employee_count,
    hoec.total_oec,
    bms.total_target_oec,
    CASE
        WHEN bms.total_target_oec IS NULL THEN NULL
        ELSE ROUND(bms.total_target_oec/ hoec.total_oec, 4)
    END AS headcount_to_oec_ratio,
    ROUND(LEAST(COALESCE(bms.total_target_oec/ hoec.total_oec, 0), 1),4) AS percent_to_goal,
    ROUND(percent_to_goal*.5,2) as score
FROM branch_month_summary bms
LEFT JOIN historical_oec hoec ON hoec.branch_id = bms.branch_id AND hoec.month = bms.month
ORDER BY bms.branch_id, bms.month


--WITH esown AS (
    -- Identifying owned assets
--    SELECT COMPANY_ID
--    FROM ES_WAREHOUSE.public.companies
--    WHERE (COMPANY_ID IN (
--            SELECT company_id
--            FROM ANALYTICS.PUBLIC.ES_COMPANIES
--            WHERE owned = TRUE)
--        OR COMPANY_ID IN (
--            SELECT DISTINCT AA.COMPANY_ID
--            FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
--            JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
--                ON VPP.ASSET_ID = AA.ASSET_ID
--            WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
--                AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))
--    )
--),

--with historical_oec as (SELECT
--    ad.MARKET_ID as branch_id,
--        DATE_TRUNC('month', GL_DATE)::DATE as month,
--    sum(aa.oec) as total_oec
--    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
--      left join ANALYTICS.BRANCH_EARNINGS.ASSET_DETAIL ad on ad.ASSET_ID = aa.asset_id
--group by 1,2),
--
--dim_date AS (
--    SELECT DISTINCT DATE_TRUNC('month', DT_DATE)::DATE AS month
--    FROM operational_analytics.gold.oa_dim_dates
--    where DT_DATE <= current_date()
--)
--
--SELECT
--    cd.MARKET_ID as branch_id,
--    d.month AS month,
--    COUNT(DISTINCT cd.employee_id) AS active_employee_count,
--    hoec.total_oec,
--    CASE WHEN active_employee_count = 0 THEN null ELSE round(hoec.total_oec/active_employee_count) END as headcount_to_oec_ratio,
--    LEAST(COALESCE(headcount_to_oec_ratio/15500000,0),1) as percent_to_goal,
--    ROUND(percent_to_goal*.5,2) as score
--FROM dim_date d
--LEFT JOIN analytics.payroll.company_directory cd
--    ON cd.date_hired <= LAST_DAY(d.month)  -- Employee was hired on or before the end of the month
--    AND (cd.date_terminated IS NULL OR cd.date_terminated >= d.month)  -- Employee was active in the month
--FULL OUTER JOIN historical_oec hoec on hoec.branch_id = cd.MARKET_ID and hoec.month = d.month
--where employee_title ilike any ('%Technician%') --,'%Service Manager%', '%Mechanic%')
--GROUP BY 1,2,4
        ;;
  }


  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;  # Ensure it exists in the extended view
  }

  # Month Start Date Dimension
  dimension: pkey {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(DATE_TRUNC('month', ${TABLE}.month), ${TABLE}.branch_id) ;;
  }



  # dimension_group: date_created {
  #   type: time
  #   timeframes: [
  #     month
  #   ]
  #   sql: DATE_TRUNC('month', ${TABLE}.date_created_month) ;;
  # }

  # Dimension for Month Start Date
  dimension: month {
    type: date
    sql: ${TABLE}.month ;;
  }


  dimension: active_employee_count {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.active_employee_count ;;
  }


  dimension: total_oec {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.total_oec ;;
  }

  dimension: total_target_oec {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.total_target_oec ;;
  }

  dimension: headcount_to_oec_ratio {
    value_format: "0.0%"
    type: number
    sql: ${TABLE}.headcount_to_oec_ratio ;;
  }


  dimension: percent_to_goal {
    type: number
    value_format: "0.0%"
    sql: LEAST(COALESCE(${TABLE}.percent_to_goal,0),1) ;;
  }

  dimension: score {
    type: number
    value_format: "0.00"
    sql: COALESCE(LEAST(${TABLE}.score,.5),.5) ;;
  }

  measure:  drill_fields_sbs{
    hidden:  yes
    type:  sum
    sql:  0;;
    drill_fields: [
      service_branch_scorecard.market_name,
      service_branch_scorecard.month,
      headcount_oec_aggregate.active_employee_count,
      headcount_oec_aggregate.total_oec,
      headcount_oec_aggregate.headcount_to_oec_ratio,
      headcount_oec_aggregate.percent_to_goal,
      headcount_oec_aggregate.score]
  }

  measure: avg_last_1_month {
    type: average
    value_format: "0.00"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_1_month} THEN ${score}
         ELSE NULL
       END ;;
    description: "Average of monthly metric for the past 1 month"
    html:
    {% assign rounded = value | times: 100 | round | divided_by: 100 %}
    {% assign int_part = rounded | floor %}
    {% assign decimal_part = rounded | minus: int_part | times: 100 | round %}
    {% assign formatted_value = int_part | append: "." | append: decimal_part | slice: 0, 5 %}

    {% if value < 0.40 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.4 and value <= 0.45 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    drill_fields: []  # optional, removes the three-dot menu
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
  }

  measure: avg_last_3_months {
    type: average
    value_format: "0.00"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${score}
         ELSE NULL
       END ;;
    description: "Average of monthly metric for the past 3 months"
    html:
    {% assign rounded = value | times: 100 | round | divided_by: 100 %}
    {% assign int_part = rounded | floor %}
    {% assign decimal_part = rounded | minus: int_part | times: 100 | round %}
    {% assign formatted_value = int_part | append: "." | append: decimal_part | slice: 0, 5 %}

    {% if value < 0.40 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.40 and value <= 0.45 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    drill_fields: []  # optional, removes the three-dot menu
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
  }

  measure: avg_last_12_months {
    type: average
    value_format: "0.00"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_12_months} THEN ${score}
         ELSE NULL
       END ;;
    description: "Average of monthly metric for the past 12 months"
    html:
    {% assign rounded = value | times: 100 | round | divided_by: 100 %}
    {% assign int_part = rounded | floor %}
    {% assign decimal_part = rounded | minus: int_part | times: 100 | round %}
    {% assign formatted_value = int_part | append: "." | append: decimal_part | slice: 0, 5 %}

    {% if value < 0.40 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.40 and value <= 0.45 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    drill_fields: []  # optional, removes the three-dot menu
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
  }


  measure: avg_last_3_months_performance {
    type: average
    value_format: "#,##0"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${active_employee_count}
         ELSE NULL
       END ;;
    description: "Average of monthly metric for the past 3 months"
    html:
    {% if avg_last_3_months._value < 0.10 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">{{ value | round }}</span>
    {% elsif avg_last_3_months._value >= 0.10 and avg_last_3_months._value <= 0.15 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">{{ value | round }}</span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">{{ value | round }}</span>
    {% endif %}
    ;;
    # drill_fields: []  # optional, removes the three-dot menu
    drill_fields: []  # optional, removes the three-dot menu
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
  }


}
