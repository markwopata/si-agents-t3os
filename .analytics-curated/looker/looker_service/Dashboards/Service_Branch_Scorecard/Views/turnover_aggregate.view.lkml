include: "/Dashboards/Service_Branch_Scorecard/Views/ee_company_directory_12_month_aggregate.view"
include: "/Dashboards/Service_Branch_Scorecard/Views/termination_details.view"

  view: turnover_aggregate {
    sql_table_name: "PEOPLE_ANALYTICS"."OPERATIONAL_ANALYTICS"."SERVICE_BRANCH_SCORECARD_RETENTION"
    ;;
    # derived_table: {
    #   sql:

    # with terminations as (SELECT
    #         DATE_TRUNC('month',_es_update_timestamp)::DATE as month,
    #         market_id as branch_id,
    #         SUM(terminations) as termination_count
    #     FROM ${ee_company_directory_12_month_aggregate.SQL_TABLE_NAME}
    #     WHERE _es_update_timestamp >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
    #     AND _es_update_timestamp < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
    #     AND employee_title ilike any ('%Technician%','%Service Manager%', '%Mechanic%')
    #     and _es_update_timestamp is not null
    #     GROUP BY 1,2),

    #     headcount as (SELECT
    #         DATE_TRUNC('month',_es_update_timestamp)::DATE as month,
    #         market_id as branch_id,
    #         COUNT(DISTINCT EMPLOYEE_ID) as headcount
    #     FROM ${ee_company_directory_12_month_aggregate.SQL_TABLE_NAME}
    #     WHERE CASE
    #       WHEN DATE_REHIRED IS NOT NULL THEN DATE_REHIRED
    #       ELSE DATE_HIRED END  <= _es_update_timestamp
    #     AND employee_status ilike any ('Active', 'External Payroll', 'Leave with Pay', 'Leave withoutout Pay', 'Work Comp Leave')
    #     AND employee_title != 'Contractor'
    #     and employee_title ilike any ('%Technician%','%Service Manager%', '%Mechanic%')
    #     AND employee_id is not null
    #     AND _es_update_timestamp >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
    #     AND _es_update_timestamp < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
    #     and _es_update_timestamp is not null
    #     GROUP BY 1,2)

    #     SELECT COALESCE(t.month, h.month) as month,
    #     COALESCE(t.branch_id, h.branch_id) as branch_id,
    #     h.headcount,
    #     t.termination_count,
    #     CASE WHEN h.headcount = 0 THEN null ELSE COALESCE(1-(t.termination_count/h.headcount),1) END as retention_percent,
    #     CASE WHEN h.headcount = 0 THEN 1 ELSE LEAST(COALESCE(1-(t.termination_count/h.headcount),1),1) END as percent_to_goal,
    #     ROUND(percent_to_goal*.5,2) as score
    #     FROM terminations as t
    #     FULL OUTER JOIN headcount as h on h.month = t.month and h.branch_id = t.branch_id
    #     ;;
    # }




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


    dimension: termination_count {
      type: number
      value_format: "#,##0"
      sql: COALESCE(${TABLE}.termination_count,0) ;;
    }


    dimension: headcount {
      type: number
      value_format: "#,##0"
      sql: COALESCE(${TABLE}.headcount,0) ;;
    }

    dimension: retention_percent {
      type: number
      value_format: "0.0%"
      sql: COALESCE(${TABLE}.retention_percent,1) ;;
    }


    dimension: percent_to_goal {
      type: number
      value_format: "0.0%"
      sql: LEAST(COALESCE(${TABLE}.percent_to_goal,1),1) ;;
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
        turnover_aggregate.termination_count,
        turnover_aggregate.headcount,
        turnover_aggregate.retention_percent,
        turnover_aggregate.percent_to_goal,
        turnover_aggregate.score]
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
      link: {
        label: "Turnover Dashboard"
        url: "https://equipmentshare.looker.com/dashboards/1160"
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
      link: {
        label: "Turnover Dashboard"
        url: "https://equipmentshare.looker.com/dashboards/1160"
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
      link: {
        label: "Turnover Dashboard"
        url: "https://equipmentshare.looker.com/dashboards/1160"
      }
    }


    measure: avg_last_3_months_performance {
      type: average
      # value_format: "0.00%"
      sql: CASE
             WHEN ${service_branch_scorecard.is_last_3_months} THEN ${termination_count}
             ELSE NULL
           END ;;
      description: "Average of monthly metric for the past 3 months"
      html:
                                    {% if avg_last_3_months._value < 0.40 %}
                                    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">{{ value | round }}</span>
                                    {% elsif avg_last_3_months._value >= 0.40 and avg_last_3_months._value <= 0.45 %}
                                    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">{{ value | round }}</span>
                                    {% else %}
                                    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">{{ value | round }}</span>
                                    {% endif %}

                                      ;;
      drill_fields: []  # optional, removes the three-dot menu

      link: {
        label: "Additional Details"
        url: "{{drill_fields_sbs._link}}"
      }
      link: {
        label: "Turnover Dashboard"
        url: "https://equipmentshare.looker.com/dashboards/1160"
      }
    }


  }
