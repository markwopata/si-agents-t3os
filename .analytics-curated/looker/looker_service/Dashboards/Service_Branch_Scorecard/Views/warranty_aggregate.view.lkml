
include: "/views/custom_sql/warranty_invoices.view"
include: "/views/custom_sql/min_date_branch_warranty_oec.view"
include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


view: warranty_aggregate {
  derived_table: {
    sql:

with warranty_invoices as (
SELECT
    BRANCH_ID,
DATE_TRUNC('month', DATE_CREATED)::DATE AS date_created_month,
round(sum(TOTAL_AMT),0) as total_invoice_amount
FROM ${warranty_invoice_asset_info.SQL_TABLE_NAME}
group by 1,2),

warranty_oec as (
    SELECT
        branch_id,
        DATE_TRUNC('month', generated_date)::DATE AS date_created_month,
        DATEDIFF('day', DATE_TRUNC('month', generated_date), DATEADD('month', 1, DATE_TRUNC('month', generated_date))) AS days_in_month,
        ROUND(sum(TOTAL_OEC)) as total_oec
    FROM ${min_date_branch_warranty_oec.SQL_TABLE_NAME}
    group by 1,2,3
    )


      SELECT
        w.branch_id,
        w.date_created_month as month,
        w.days_in_month,
        wi.total_invoice_amount,
        w.total_oec as warranty_oec,
        round(365 / NULLIF(w.days_in_month, 0) * wi.total_invoice_amount) as annualized_claim_total,
        ROUND((365 / NULLIF(w.days_in_month, 0) * wi.total_invoice_amount)/nullifzero(w.total_oec),4) as Annualized_Claims_divided_by_Warranty_OEC,
        LEAST(COALESCE(round(Annualized_Claims_divided_by_Warranty_OEC/.02,4),0),1) as percent_to_goal,
        ROUND(percent_to_goal*1,2) as score
      FROM warranty_oec w
      left outer join WARRANTY_INVOICES wi on wi.BRANCH_ID = w.branch_id and wi.date_created_month = w.date_created_month
        WHERE w.date_created_month >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
        AND w.date_created_month < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
--         where w.branch_id =36763
      GROUP BY 1, 2,3,4,5
--order by date_created_month desc
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

  # Dimension for Month Start Date
  dimension: month {
    type: date
    sql: ${TABLE}.month ;;
  }

  dimension: days_in_month {
    type: number
    sql: ${TABLE}.days_in_month ;;
  }


  dimension: total_invoice_amount {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.total_invoice_amount ;;
  }

  dimension: annualized_claim_total {
    type: number
    value_format: "$#,##0"
    sql: COALESCE(${TABLE}.annualized_claim_total,0) ;;
  }

  dimension: warranty_oec {
    type: number
    value_format: "$#,##0"
    sql: COALESCE(${TABLE}.warranty_oec,0) ;;
  }

  dimension: annualized_claims_divided_by_warranty_oec {
    type: number
    value_format: "0.0%"
    sql: COALESCE(${TABLE}.annualized_claims_divided_by_warranty_oec,0) ;;
  }


  dimension: percent_to_goal {
    type: number
    value_format: "0.0%"
    sql: LEAST(COALESCE(${TABLE}.percent_to_goal,0),1) ;;
  }


  dimension: score {
    type: number
    value_format: "0.00"
    sql: COALESCE(LEAST(${TABLE}.score,1),0) ;;
  }


  measure:  drill_fields_sbs{
    hidden:  yes
    type:  sum
    sql:  0;;
    drill_fields: [
      service_branch_scorecard.market_name,
      service_branch_scorecard.month,
      warranty_aggregate.annualized_claim_total,
      warranty_aggregate.warranty_oec,
      warranty_aggregate.annualized_claims_divided_by_warranty_oec,
      warranty_aggregate.percent_to_goal,
      warranty_aggregate.score]
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

    {% if value < 0.33 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.33 and value <= 0.66 %}
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
    link: {
      label: "Warranty Overview Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1288?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
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

    {% if value < 0.33 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.33 and value <= 0.66 %}
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
    link: {
      label: "Warranty Overview Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1288?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
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

    {% if value < 0.33 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 0.33 and value <= 0.66 %}
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
    link: {
      label: "Warranty Overview Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1288?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
    }
  }

    measure: avg_last_3_months_performance {
      type: average
      value_format: "$#,##0"
      sql: CASE
                   WHEN ${service_branch_scorecard.is_last_3_months} THEN ${annualized_claim_total}
                   ELSE NULL
                 END ;;
      description: "Average of monthly metric for the past 3 months"
      html:
            {% assign thousands = value | divided_by: 1000.0 | round %}

                            {% if avg_last_3_months._value < 0.33 %}
                            <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">${{ thousands }}K</span>
                            {% elsif avg_last_3_months._value >= 0.33 and avg_last_3_months._value <= 0.66 %}
                            <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">${{ thousands }}K</span>
                            {% else %}
                            <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">${{ thousands }}K</span>
                            {% endif %}
                              ;;
      drill_fields: []  # optional, removes the three-dot menu

      link: {
        label: "Additional Details"
        url: "{{drill_fields_sbs._link}}"
      }
      link: {
        label: "Warranty Overview Dashboard"
        url: "https://equipmentshare.looker.com/dashboards/1288?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
      }
    }



  }
