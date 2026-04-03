  include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


  view: lost_revenue_aggregate {
    sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_BRANCH_SCORECARD_LOST_REVENUE"
    ;;
    # derived_table: {
    #   sql:
# with unavailable_history as (
#         select
#           to_date(i.generateddate) generated_date,
#           m.DISTRICT,
#           i.market_id,
#           i.class,
#           a.EQUIPMENT_CLASS_ID as EQUIPMENT_CLASS_ID,
#           sum(unavailablecount) as unavailablecount,
#           sum(unavailableoec) as unavailableoec,
#           sum(totalcount) as totalcount,
#           sum(totaloec) as totaloec
#         from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS i
#         left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE a on a.ASSET_ID = i.ASSET_ID
#         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m on m.MARKET_ID = i.MARKET_ID
#         where m.DISTRICT is not null
#         and a.EQUIPMENT_CLASS_ID is not null
#         group by 1,2,3,4,5
#           order by generated_date
#             ),

# time_ute as (Select
#             dt.START_DATE as date,
#             a.EQUIPMENT_CLASS_ID,
#             m.DISTRICT,
#             sum(r.revenue) as revenue_sum,
#             sum(h.rental_oec) as rental_oec_sum,
#             sum(h.in_fleet_oec) as in_fleet_oec_sum,
#             ifnull(round(rental_oec_sum/in_fleet_oec_sum,4),0) as time_utilization
#         FROM FLEET_OPTIMIZATION.GOLD.UTILIZATION_ASSET_MARKET_HISTORICAL h
#         left join FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC dt on dt.TF_KEY = h.TF_KEY
#         left join FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_REVENUE_ASSET_MARKET r on r.AGG_REV_CALCULATION_KEY = h.AGG_REV_CALCULATION_KEY and r.TF_KEY = h.TF_KEY
#         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m on m.MARKET_ID = h.MARKET_ID
#         left join ES_WAREHOUSE.PUBLIC.ASSETS a on a.ASSET_ID = h.ASSET_ID
#         WHERE dt.TIMEFRAME = 'monthly'
#         and EQUIPMENT_CLASS_ID is not null
#         and DISTRICT is not null
#         group by 1,2,3
#         order by 1
#         ),

# benchmark_rates as (select
#                         BRANCH_ID,
#                         EQUIPMENT_CLASS_ID,
#                         PRICE_PER_MONTH,
#                         DATE_CREATED,
#                         DATE_VOIDED,
#                         ACTIVE
#                     from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
#                     where RATE_TYPE_ID = 2),


# lost_revenue as (
# SELECT DATE_TRUNC('month', u.generated_date)::DATE                                as month,
#                         u.market_id                                                                as branch_id,
#                         u.EQUIPMENT_CLASS_ID,
#                         ROUND(sum(u.unavailableoec) / count(distinct u.generated_date))              as unavailable_oec,
#                         ROUND(sum(u.totaloec) / count(distinct u.generated_date))                    as total_oec,
#                         ROUND(case WHEN total_oec = 0 then null else unavailable_oec / total_oec end,4)   AS unavailable_oec_percent,
#                         t.time_utilization as time_ute_1_year_prior,
#                         b.PRICE_PER_MONTH,
#                         ROUND(sum(u.totalcount) / count(distinct u.generated_date))                    as total_asset_count,
#                         CASE WHEN t.time_utilization <= (1-unavailable_oec_percent) THEN 0
#                             ELSE t.time_utilization - (1-unavailable_oec_percent) END as Unavailble_oec_percent_ding,
#                         total_asset_count * Unavailble_oec_percent_ding * b.PRICE_PER_MONTH as lost_revenue
#                 FROM unavailable_history u
#                     left join time_ute t on t.date::DATE = DATEADD('month', -12, DATE_TRUNC('month', u.generated_date))::DATE
#                           and t.DISTRICT = u.DISTRICT
#                           and t.EQUIPMENT_CLASS_ID = u.EQUIPMENT_CLASS_ID
#                 left join benchmark_rates b on b.EQUIPMENT_CLASS_ID = u.EQUIPMENT_CLASS_ID
#                         and b.BRANCH_ID = u.market_id
#                 and DATE_TRUNC('month', u.generated_date) >= b.DATE_CREATED
#                 and DATE_TRUNC('month', u.generated_date) < coalesce(b.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
#                 and (b.DATE_VOIDED IS NOT NULL OR b.ACTIVE)
#                 WHERE u.generated_date >=
#                       DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE())) -- Look back exactly 12 months
#                   AND u.generated_date < DATE_TRUNC('month', CURRENT_DATE())       -- Exclude current month
#                 GROUP BY 1,2,3,7,8
#                     order by 2,1)



#         SELECT
#         branch_id,
#         month,
#         sum(lost_revenue) as total_lost_revenue,
#         COALESCE(GREATEST((1-ZEROIFNULL(ROUND(total_lost_revenue/10000,4))),0),1) as percent_to_goal,
#         ROUND(percent_to_goal*1.5,2) as score
#         FROM lost_revenue
#         GROUP BY 1,2
#         order by month
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

    # Dimension for Month Start Date
    dimension: month {
      type: date
      sql: ${TABLE}.month ;;
    }



    dimension: total_lost_revenue {
      type: number
      value_format: "$#,##0"
      sql: COALESCE(${TABLE}.total_lost_revenue,0) ;;
    }


    dimension: percent_to_goal {
      type: number
      value_format: "0.0%"
      sql: COALESCE(${TABLE}.percent_to_goal,1) ;;
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
        lost_revenue_aggregate.total_lost_revenue,
        lost_revenue_aggregate.percent_to_goal,
        lost_revenue_aggregate.score]
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

      {% if value < 0.17 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.17 and value <= 0.34 %}
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

      {% if value < 0.17 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.17 and value <= 0.34 %}
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

      {% if value < 0.17 %}
      <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">
      {{ formatted_value }}
      </span>
      {% elsif value >= 0.17 and value <= 0.34 %}
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
      value_format: "$#,##0"
      sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${total_lost_revenue}
         ELSE NULL
       END ;;
      description: "Average of monthly metric for the past 3 months"
      html:
    {% assign thousands = value | divided_by: 1000.0 | round %}

          {% if avg_last_3_months._value < 0.17 %}
          <span style="display: block; background-color: #EE7772; color: black; padding: 2px;">${{ thousands }}K</span>
          {% elsif avg_last_3_months._value >= 0.17 and avg_last_3_months._value <= 0.34 %}
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
      }
  }
