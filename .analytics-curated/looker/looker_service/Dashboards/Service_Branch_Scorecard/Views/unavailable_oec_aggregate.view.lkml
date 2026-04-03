    include: "//service/views/ANALYTICS/ASSETS/int_asset_historical.view"

    view: unavailable_oec_aggregate {
      derived_table: {
        sql:
      SELECT
          DATE_TRUNC('month', daily_timestamp)::DATE as month,
          market_id as branch_id,
          --sum(unavailablecount) as unavailablecount,
          ROUND(sum(unavailable_oec)/count(distinct daily_timestamp)) as avg_daily_unavailable_oec,
          --sum(totalcount) as totalcount,
          ROUND(sum(total_oec)/count(distinct daily_timestamp)) as avg_daily_total_oec,
          case WHEN avg_daily_total_oec = 0 then null else avg_daily_unavailable_oec/avg_daily_total_oec end AS unavailable_oec_percent,
          CASE WHEN avg_daily_total_oec = 0 THEN 1 ELSE ROUND(LEAST((1 - avg_daily_unavailable_oec/avg_daily_total_oec)/.92,1),4) END as percent_to_goal,
          ROUND(percent_to_goal*1.5,2) as score
      FROM ${int_asset_historical.SQL_TABLE_NAME}
      WHERE daily_timestamp >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
      AND daily_timestamp < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
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


    dimension: unavailable_oec {
      type: number
      value_format: "$#,##0"
      sql: COALESCE(${TABLE}.avg_daily_unavailable_oec,0) ;;
    }


    dimension: total_oec {
      type: number
      value_format: "$#,##0"
      sql: COALESCE(${TABLE}.avg_daily_total_oec,0) ;;
    }

    dimension: unavailable_oec_percent {
      type: number
      value_format: "0.0%"
      sql: COALESCE(${TABLE}.unavailable_oec_percent,0) ;;
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
        unavailable_oec_aggregate.unavailable_oec,
        unavailable_oec_aggregate.total_oec,
        unavailable_oec_aggregate.unavailable_oec_percent,
        unavailable_oec_aggregate.percent_to_goal,
        unavailable_oec_aggregate.score]
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

      {% if value < 1.35 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 1.35 and value <= 1.40 %}
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

      {% if value < 1.35 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 1.35 and value <= 1.40 %}
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

      {% if value < 1.35 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 1.35 and value <= 1.40 %}
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
        value_format: "$#,##0"
        sql: CASE
                   WHEN ${service_branch_scorecard.is_last_3_months} THEN ${unavailable_oec}
                   ELSE NULL
                 END ;;
        description: "Average of monthly metric for the past 3 months"
        html:
            {% assign millions = value | divided_by: 1000000.0 | round %}

                    {% if avg_last_3_months._value < 1.35 %}
                    <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">${{ millions }}M</span>
                    {% elsif avg_last_3_months._value >= 1.35 and avg_last_3_months._value <= 1.40 %}
                    <span style="display: block; background-color: #ffed6f; color: black; padding: 2px;">${{ millions }}M</span>
                    {% else %}
                    <span style="display: block; background-color: #7FCDAE; color: black; padding: 2px;">${{ millions }}M</span>
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
