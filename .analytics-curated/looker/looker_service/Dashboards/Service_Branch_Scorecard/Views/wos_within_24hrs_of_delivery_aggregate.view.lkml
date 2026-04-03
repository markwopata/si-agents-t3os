
  view: wos_within_24hrs_of_delivery_aggregate {
    sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_BRANCH_SCORECARD_24_HR_BREAKDOWN"
    ;;
#     derived_table: {
#       sql:
# --all deliveries
# with deliveries as (
# select d.asset_id,
#                           d.DELIVERY_ID,
#                           d.RENTAL_ID,
#                           d.delivery_status_id,
#                           ds.name,
#                           d.completed_date as delivery_date,
#                           r.START_DATE     as rental_start,
#                           r.end_date       as rental_end
#                           ,li.BRANCH_ID
#                     from es_warehouse.public.deliveries d
#                             inner join es_warehouse.public.delivery_statuses ds
#                                         on d.delivery_status_id = ds.delivery_status_id
#                             left outer join es_warehouse.public.locations l
#                                             on d.ORIGIN_LOCATION_ID = l.LOCATION_ID
#                             left outer join es_warehouse.public.rentals r
#                                             on r.RENTAL_ID = d.RENTAL_ID
#                             left join (SELECT * FROM es_warehouse.public.LINE_ITEMS li qualify ROW_NUMBER() OVER(PARTITION BY RENTAL_ID ORDER BY BRANCH_ID desc) = 1)
#                                             li on li.RENTAL_ID = r.RENTAL_ID
#                     where
#                       d.asset_id is not null
#                       and l.COMPANY_ID = 1854
#                       and d.delivery_status_id = 3
#                     ),


# --all work orders
#     wos as (
#         select wo.DATE_CREATED        as wo_date,
#                 wo.WORK_ORDER_ID,
#                 wo.ASSET_ID,
#                 wo.WORK_ORDER_STATUS_NAME,
#                 wo.WORK_ORDER_TYPE_NAME,
#                 wo.ARCHIVED_DATE,
#                 wo.DESCRIPTION,
#                 wo.branch_id,
#                 LISTAGG(ct.name, ', ') as tags
#         from ES_WAREHOUSE.work_orders.work_orders wo
#                   left outer join es_warehouse.work_orders.WORK_ORDER_COMPANY_TAGS tag
#                                   on wo.WORK_ORDER_ID = tag.WORK_ORDER_ID
#                   left outer join es_warehouse.work_orders.company_tags ct
#                                   on tag.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
#                   left outer join es_warehouse.work_orders.WORK_ORDER_ORIGINATORS o
#                                     on wo.work_order_id = o.WORK_ORDER_ID
#         where wo.WORK_ORDER_TYPE_NAME <> 'Inspection'
#         and o.originator_type_id <> 3 -- Maintenance Group Interval, system created
#         and tag.company_tag_id not in (980, 888, 393, 486, 400, 401, 856, 1396, 1209)
#             -- take out Equipment Transfer and anything to do with trackers


#         group by wo.DATE_CREATED, wo.WORK_ORDER_ID, wo.ASSET_ID, wo.WORK_ORDER_STATUS_NAME, wo.WORK_ORDER_TYPE_NAME,
#                   wo.ARCHIVED_DATE, wo.DESCRIPTION, wo.BRANCH_ID
#     ),

# deliveries_with_work_orders as (
#     select d.asset_id,
#     --        wos_24.DESCRIPTION,
#     --        wos_24.TAGS,
#     --        d.DELIVERY_ID,
#     --        d.RENTAL_ID,
#           CASE WHEN wos_24.WORK_ORDER_ID is null then d.BRANCH_ID ELSE COALESCE(wos_last.BRANCH_ID, wos_24.BRANCH_ID, d.BRANCH_ID) end as BRANCH_ID,
#           DATE_TRUNC('month', COALESCE(wos_24.WO_DATE,d.DELIVERY_DATE))::DATE as month,
#           CASE WHEN wos_24.WORK_ORDER_ID is not null then 1 else 0 end as breakdown_24_hr,
#           1 as delivery
#     --        wos_24.WORK_ORDER_ID,
#     --        wos_24.WORK_ORDER_TYPE_NAME,
#     --        wos_24.WORK_ORDER_STATUS_NAME,
#     --        wos_last.WORK_ORDER_ID,
#     --        wos_last.WORK_ORDER_TYPE_NAME,
#     --        wos_last.WORK_ORDER_STATUS_NAME,
#     --        d.DELIVERY_DATE,
#     --        wos_24.WO_DATE,
# --         ,d.BRANCH_ID,
# --            wos_24.BRANCH_ID,
#     --        wos_last.WO_DATE,
# --            wos_last.BRANCH_ID
#     --        d.RENTAL_START,
#     --        d.RENTAL_END,
#     --        ROW_NUMBER() OVER(PARTITION BY d.ASSET_ID, wos_24.WORK_ORDER_ID ORDER BY wos_last.WO_DATE desc)
#     from deliveries d
#             left join wos as wos_24-- to get breakdowns within 24 hrs
#                         on d.ASSET_ID = wos_24.asset_id
#                             and wos_24.wo_date between d.delivery_date and dateadd('hours', 24, d.delivery_date)
#             left join wos as wos_last -- to get last WO before delivery
#                         on d.ASSET_ID = wos_last.asset_id
#                             and wos_last.wo_date <= d.delivery_date
#             inner join es_warehouse.PUBLIC.ASSETS_AGGREGATE aa
#                         on d.ASSET_ID = aa.ASSET_ID
#     where aa.COMPANY_ID = 1854
#       and aa.ASSET_TYPE_ID = 1
#       and aa.RENTAL_BRANCH_ID is not null
#       and d.delivery_date < d.rental_end
#     QUALIFY ROW_NUMBER() OVER(PARTITION BY d.ASSET_ID, wos_24.WORK_ORDER_ID ORDER BY wos_last.WO_DATE desc) = 1 -- qualifier to get the most recent wo before delivery
#     )


#     SELECT
#         branch_id,
#         month,
#         sum(breakdown_24_hr) as count_wos_within_24_hrs_delivery,
#         sum(delivery) as delivery_count,
#         sum(breakdown_24_hr) / sum(delivery) as percent_deliveries_with_wo_within_24_hrs,
#         COALESCE(LEAST(1-(sum(breakdown_24_hr) / sum(delivery)),1),1) as percent_to_goal,
#         percent_to_goal*.5 as score
#         FROM deliveries_with_work_orders
#         where DATE_TRUNC('month', month)::DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE ()))              -- Look back exactly 12 months
#         AND DATE_TRUNC('month', month)::DATE < DATE_TRUNC('month', CURRENT_DATE ())                                      -- Exclude current month
#     group by 1,2
#         ;;
#     }



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


    dimension: count_wos_within_24_hrs_delivery {
      type: number
      value_format: "#,##0"
      sql: COALESCE(${TABLE}.count_wos_within_24_hrs_delivery,0) ;;
    }


    dimension: delivery_count {
      type: number
      value_format: "#,##0"
      sql: COALESCE(${TABLE}.delivery_count,0) ;;
    }

    dimension: percent_deliveries_with_wo_within_24_hrs {
      type: number
      value_format: "0.0%"
      sql: COALESCE(${TABLE}.percent_deliveries_with_wo_within_24_hrs,0) ;;
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
        wos_within_24hrs_of_delivery_aggregate.count_wos_within_24_hrs_delivery,
        wos_within_24hrs_of_delivery_aggregate.delivery_count,
        wos_within_24hrs_of_delivery_aggregate.percent_deliveries_with_wo_within_24_hrs,
        wos_within_24hrs_of_delivery_aggregate.percent_to_goal,
        wos_within_24hrs_of_delivery_aggregate.score]
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
        label: "Service Dashboard"
        url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
      }
    }

      measure: avg_last_3_months_performance {
        type: average
        value_format: "#,##0"
        sql: CASE
                   WHEN ${service_branch_scorecard.is_last_3_months} THEN ${count_wos_within_24_hrs_delivery}
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
          label: "Service Dashboard"
          url: "https://equipmentshare.looker.com/dashboards-next/49?Market={{ _filters['service_branch_scorecard.market_name'] | url_encode }}&toggle=det"
        }
      }

    # measure:  drill_fields_sbs{
    #   hidden:  yes
    #   type:  sum
    #   sql:  0;;
    #   drill_fields: [rebate_amount_per_customer.parent_customer_name, customer_rebates.customer_name, customer_rebates.customer_id, markets.name, markets.market_id, v_line_items.rental_charges, v_line_items.rental_charges_eligible_for_rebate, rebate_amount_per_customer.rebate_percent_achieved, v_line_items.rebate_amount]
    # }

    # measure: rebates_per_market {
    #   type:  sum
    #   sql: ${rebate_amount_per_customer.total_rebate_amount};; # ${rebate_amount_per_customer.rebate_percent_achieved} * ${v_line_items.rental_charges_eligible_for_rebate};;
    #   value_format: "$#,##0"
    #   filters: [tier: "1"]
    #   link: {
    #     label: "Rebate Amount per Market"
    #     url: "{{ drill_fields_sbs._link}}"
    #   }
    # }



  }
