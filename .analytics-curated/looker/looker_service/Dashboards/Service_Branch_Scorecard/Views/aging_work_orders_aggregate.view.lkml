  include: "/views/custom_sql/ytd_open_work_orders.view"

view: aging_work_orders_aggregate {
    derived_table: {
      sql:
        SELECT
            DATE_TRUNC('month', date_of)::DATE as month,
            BRANCH_ID,
            -- Flag for work orders open for 3+ months
            COUNT(DISTINCT CASE WHEN DATEADD('month', 3, DATE_TRUNC('month', date_created)) <= date_of THEN work_order_id ELSE null END) AS work_order_count_open_3_months_or_more,
            COUNT(DISTINCT work_order_id) AS open_work_order_count,
            (work_order_count_open_3_months_or_more/open_work_order_count) as percent_of_work_orders_open_3_months_or_more,
            ROUND((1 - (work_order_count_open_3_months_or_more/open_work_order_count)),4) as percent_to_goal,
            ROUND(percent_to_goal*1.5,2) as score
        FROM ${ytd_open_work_orders.SQL_TABLE_NAME}
        WHERE date_of::DATE = DATE_TRUNC('month', date_of)
        AND date_of >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
        AND date_of < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
        GROUP BY 1,2
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


  dimension: work_order_count_open_3_months_or_more {
    type: number
    sql: ${TABLE}.work_order_count_open_3_months_or_more ;;
  }


  dimension: open_work_order_count {
    type: number
    sql: ${TABLE}.open_work_order_count ;;
  }

  dimension: percent_of_work_orders_open_3_months_or_more {
    type: number
    value_format: "0.0%"
    sql: ${TABLE}.percent_of_work_orders_open_3_months_or_more ;;
  }


  dimension: percent_to_goal {
    type: number
    value_format: "0.0%"
    sql: LEAST(COALESCE(${TABLE}.percent_to_goal,1),1) ;;
  }

  dimension: score {
    type: number
    value_format: "0.00"
    sql: COALESCE(LEAST(${TABLE}.score,1.5),1.5) ;;
  }

  measure:  drill_fields_sbs{
    hidden:  yes
    type:  sum
    sql:  0;;
    drill_fields: [
      service_branch_scorecard.market_name,
      service_branch_scorecard.month,
      aging_work_orders_aggregate.work_order_count_open_3_months_or_more,
      aging_work_orders_aggregate.open_work_order_count,
      aging_work_orders_aggregate.percent_of_work_orders_open_3_months_or_more,
      aging_work_orders_aggregate.percent_to_goal,
      aging_work_orders_aggregate.score]
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

    {% if value < 1 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 1 and value <= 1.25 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
    link: {
      label: "Service Dashboard"
      url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
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

    {% if value < 1 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 1 and value <= 1.25 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    link: {
      label: "Additional Details"
      url: "{{drill_fields_sbs._link}}"
    }
    link: {
      label: "Service Dashboard"
      url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
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

    {% if value < 1 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% elsif value >= 1 and value <= 1.25 %}
    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% else %}
    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">
    {{ formatted_value }}
    </span>
    {% endif %}
    ;;
    link: {
          label: "Additional Details"
          url: "{{drill_fields_sbs._link}}"
        }
    link: {
      label: "Service Dashboard"
      url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
    }
  }


  measure: avg_last_3_months_performance {
    type: average
    value_format: "#,##0"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${work_order_count_open_3_months_or_more}
         ELSE NULL
       END ;;
    html:

    {% if avg_last_3_months._value < 1 %}
    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">{{ value | round }}</span>
    {% elsif avg_last_3_months._value >= 1 and avg_last_3_months._value <= 1.25 %}
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
      label: "Service Dashboard"
      url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
    }
  }

}
