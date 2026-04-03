
  include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


  view: training_aggregate {
    derived_table: {
      sql:

WITH dim_date AS (
    SELECT DISTINCT DT_DATE::DATE AS date
    FROM operational_analytics.gold.oa_dim_dates
    WHERE DT_DATE <= CURRENT_DATE()
    AND DATE_TRUNC('month', DT_DATE)::DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE ()))
),
course_dates AS (
    -- Get the first moment a course appeared (earliest date) and completion date
    SELECT
        USER_USERID,
        COURSE_UIDCOURSE,
        COURSE_NAME,
        ENROLLMENT_DATE_FIRST_ACCESS,
        ENROLLMENT_DATE_BEGIN_VALIDITY,
        ENROLLMENT_DATE_INSCR,
        MIN(COALESCE(ENROLLMENT_DATE_FIRST_ACCESS, ENROLLMENT_DATE_BEGIN_VALIDITY, ENROLLMENT_DATE_INSCR, CURRENT_DATE())) AS first_moment_date,
        ENROLLMENT_DATE_COMPLETE,
        ENROLLMENT_STATUS
    FROM ANALYTICS.DOCEBO.ENROLLMENT_HISTORY
    GROUP BY 1,2,3,4,5,6,8,9
),

all_courses as (SELECT
    DISTINCT
    u.MARKET_ID AS branch_id,
    c.user_userid,
    employee_title,
--     COURSE_UIDCOURSE,
    DATE_TRUNC('month', d.date)::DATE AS month,
    c.first_moment_date,
    c.ENROLLMENT_DATE_COMPLETE,
    CASE WHEN DATE_TRUNC('month', d.date)::DATE = DATE_TRUNC('month', c.ENROLLMENT_DATE_COMPLETE)::DATE THEN 1 else 0 end as completed,
    1 as enrolled
    FROM course_dates c
    LEFT JOIN ANALYTICS.payroll.company_directory u
    ON TO_VARCHAR(u.employee_id) = TO_VARCHAR(c.user_userid)
    LEFT JOIN dim_date d
    ON d.date::DATE BETWEEN c.first_moment_date::DATE AND COALESCE(c.ENROLLMENT_DATE_COMPLETE::DATE, CURRENT_DATE ()) -- Ensures row for each month in range
    WHERE u.employee_title ILIKE ANY ('Field Technician%', 'Service Technician%', 'Shop Technician%', 'Yard Technician%', 'Service Manager%')
    AND DATE_TRUNC('month', d.date)::DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE ()))              -- Look back exactly 12 months
    AND DATE_TRUNC('month', d.date)::DATE < DATE_TRUNC('month', CURRENT_DATE ())                                      -- Exclude current month
    ),

quarterly_goals as (
    SELECT
        employee_title,
        DATE_TRUNC('quarter', month)::DATE as quarter,
        sum(completed)/ sum(enrolled) as quarterly_completion_percentage_goal
    from all_courses
    group by 1,2
    order by 1,2 desc),

completion_by_tech_title as (SELECT
    branch_id,
    month,
    g.employee_title,
    USER_USERID,
    quarterly_completion_percentage_goal,
    sum(completed)/sum(enrolled) as completion_percentage,
    COALESCE(LEAST((sum(completed)/sum(enrolled)) /nullifzero(quarterly_completion_percentage_goal),1),1) as percent_to_goal_user_level
    FROM all_courses a
left join quarterly_goals g on g.quarter = DATE_TRUNC('quarter', a.month)::DATE and g.employee_title = a.employee_title
group by 1,2,3,4,5)


    SELECT
        branch_id,
        month,
        avg(completion_percentage) as avg_course_completion_percentage,
        COALESCE(AVG(percent_to_goal_user_level),1) as percent_to_goal,
        percent_to_goal*.5 as score
        FROM completion_by_tech_title
    group by 1,2
        ;;
    }



    dimension: branch_id {
      type: number
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

    dimension: avg_course_completion_percentage {
      type: number
      value_format: "0.0%"
      sql: LEAST(COALESCE(${TABLE}.avg_course_completion_percentage,0),1) ;;
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
        training_aggregate.avg_course_completion_percentage,
        training_aggregate.percent_to_goal,
        training_aggregate.score]
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

      {% if value < 0.20 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.20 and value <= 0.25 %}
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
        label: "ES University Statistics Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/571"
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

      {% if value < 0.20 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.20 and value <= 0.25 %}
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
        label: "ES University Statistics Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/571"
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

      {% if value < 0.20 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.20 and value <= 0.25 %}
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
        label: "ES University Statistics Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/571"
      }
    }

      measure: avg_last_3_months_performance {
      type: average
      # value_format: "0.00%"
      sql: CASE
             WHEN ${service_branch_scorecard.is_last_3_months} THEN ${avg_course_completion_percentage}
             ELSE NULL
           END ;;
      description: "Average of monthly metric for the past 3 months"
      html:
            {% assign percent = value | times: 100.0 | round %}

                            {% if avg_last_3_months._value < 0.20 %}
                            <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">{{ percent }}%</span>
                            {% elsif avg_last_3_months._value >= 0.20 and avg_last_3_months._value <= 0.25 %}
                            <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">{{ percent }}%</span>
                            {% else %}
                            <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">{{ percent }}%</span>
                            {% endif %}
                              ;;
      drill_fields: []  # optional, removes the three-dot menu

      link: {
        label: "Additional Details"
        url: "{{drill_fields_sbs._link}}"
      }
      link: {
        label: "ES University Statistics Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/571"
      }
    }



#   # Days in Month Calculation
#   dimension: days_in_month {
#     type: number
#     sql: DATEDIFF('day', ${date_created_month}, DATEADD('month', 1, ${date_created_month})) ;;
#   }

#   # Total Invoice Amount (Recreated in This View)
#   measure: total_invoice_amount {
#     type: sum
#     sql: ${warranty_invoice_asset_info.total_amt_requested} ;;
#   }


#   # Final Monthly Calculation: Normalized Invoice Amount
#   measure: normalized_invoice_amount {
#     type: number
#     sql: 365 / NULLIF(${days_in_month}, 0) * SUM(${warranty_invoice_asset_info.total_amt_requested}) ;;
#   }

#   # Flags for 1, 3, and 12-Month Periods
#   dimension: is_last_1_month {
#     type: yesno
#     sql:${date_created_month} >= DATEADD('month', -1, DATE_TRUNC('month', CURRENT_DATE())) ;;
#   }

#   dimension: is_last_3_months {
#     type: yesno
#     sql: ${date_created_month} >= DATEADD('month', -3, DATE_TRUNC('month', CURRENT_DATE())) ;;
#   }

#   dimension: is_last_12_months {
#     type: yesno
#     sql: ${date_created_month} >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE())) ;;
#   }



# # Measures for Aggregated Averages Over Time
#   measure: avg_last_1_month {
#     type: average
#     sql: CASE
#         WHEN ${is_last_1_month}
#         THEN (365 / NULLIF(${days_in_month}, 0) * SUM(${warranty_invoice_asset_info.total_amt_requested}))
#         ELSE NULL
#       END ;;
#   }

#   measure: avg_last_3_months {
#     type: average
#     sql: CASE
#         WHEN ${is_last_3_months}
#         THEN (365 / NULLIF(${days_in_month}, 0) * SUM(${warranty_invoice_asset_info.total_amt_requested}))
#         ELSE NULL
#       END ;;
#   }

#   measure: avg_last_12_months {
#     type: average
#     sql: CASE
#         WHEN ${is_last_12_months}
#         THEN (365 / NULLIF(${days_in_month}, 0) * SUM(${warranty_invoice_asset_info.total_amt_requested}))
#         ELSE NULL
#       END ;;
#   }

  }
