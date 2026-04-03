  include: "/views/ANALYTICS/overdue_inspections_12_mo.view"
  include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"


  view: overdue_inspections_aggregate {
    derived_table: {
      sql:
              SELECT
              MARKET_ID AS branch_id,
              DATE_TRUNC('month', date_of)::DATE as month,
              COUNT(DISTINCT CASE WHEN OVERDUE_FLAG = 1 THEN concat(asset_id,maintenance_group_interval_id) ELSE NULL END) AS overdue_inspections_count,
              COUNT(DISTINCT concat(asset_id,maintenance_group_interval_id)) AS inspections_count,
              CASE WHEN inspections_count = 0 THEN null ELSE ROUND(overdue_inspections_count/inspections_count,2) END as overdue_inspections_percent,
              COALESCE((1-overdue_inspections_percent),1) as percent_to_goal,
              ROUND(percent_to_goal*1,2) as score
          FROM ${overdue_inspections_12_mo.SQL_TABLE_NAME}
          WHERE date_of::DATE = LAST_DAY(date_of)
          AND DATE_TRUNC('month', date_of)::DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
          AND DATE_TRUNC('month', date_of)::DATE < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
          AND company_id = '1854'
          group by 1,2
          --order by month desc
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


    dimension: overdue_inspections_count {
      type: number
      value_format: "#,##0"
      sql: ${TABLE}.overdue_inspections_count ;;
    }


    dimension: inspections_count {
      type: number
      value_format: "#,##0"
      sql: ${TABLE}.inspections_count ;;
    }

    dimension: overdue_inspections_percent {
      type: number
      value_format: "0.0%"
      sql: ${TABLE}.overdue_inspections_percent ;;
    }


    dimension: percent_to_goal {
      type: number
      value_format: "0.0%"
      sql: LEAST(COALESCE(${TABLE}.percent_to_goal,1),1) ;;
    }

    dimension: score {
      type: number
      value_format: "0.00"
      sql: COALESCE(LEAST(${TABLE}.score,1),1) ;;
    }

    measure:  drill_fields_sbs{
      hidden:  yes
      type:  sum
      sql:  0;;
      drill_fields: [
        service_branch_scorecard.market_name,
        service_branch_scorecard.month,
        overdue_inspections_aggregate.overdue_inspections_count,
        overdue_inspections_aggregate.inspections_count,
        overdue_inspections_aggregate.overdue_inspections_percent,
        overdue_inspections_aggregate.percent_to_goal,
        overdue_inspections_aggregate.score]
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

      {% if value < 0.95 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.95 and value <= 0.98 %}
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

      {% if value < 0.95 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.95 and value <= 0.98 %}
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

      {% if value < 0.95 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.95 and value <= 0.98 %}
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
        label: "Service Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
      }
    }

    measure: avg_last_3_months_performance {
      type: average
      value_format: "#,##0"
      sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${overdue_inspections_count}
         ELSE NULL
       END ;;
      description: "Average of monthly metric for the past 3 months"
      html:
          {% if avg_last_3_months._value < 0.95 %}
          <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">{{ value | round }}</span>
          {% elsif avg_last_3_months._value >= 0.95 and avg_last_3_months._value <= 0.98 %}
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
