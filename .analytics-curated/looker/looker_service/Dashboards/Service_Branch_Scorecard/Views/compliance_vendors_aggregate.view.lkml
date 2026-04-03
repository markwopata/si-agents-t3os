  include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view"
#include: "/views/custom_sql/warranty_invoice_asset_info.view"


view: compliance_vendors_aggregate {
    derived_table: {
      sql:
--Compliance Vendors
with vendor_spend as (

select
--     po.purchase_order_number,
    DATE_TRUNC('month', po.date_created)::DATE as month,
--     po.vendor_id,
    COALESCE(vm.preferred, 'No') preferred_vendor,
    po.requesting_branch_id market_id,
    SUM(po.amount_approved) as vendor_spend--this is at the PO level, if needing line level details you will need to use poli.price_per_unit*poli.quantity
from procurement.public.purchase_orders po
join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
    left join ES_WAREHOUSE.INVENTORY.PARTS p
    on poli.item_id=p.item_id
left join (select
                v.name,
                evs.entity_id,
                v.vendorid
           from ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
            left join analytics.intacct.vendor v
                on evs.EXTERNAL_ERP_VENDOR_REF = v.vendorid
                ) v
    on po.vendor_id = v.entity_id
left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING vm
on v.vendorid=vm.vendorid
where po.company_id = 1854
and po.date_archived is null
and poli.date_archived is null
and (poli.item_id ='d6fd484c-da57-4e62-a2c5-9a2d0202ffdb' or p.item_id is not null) --this is service outside labor or parts POs
and amount_approved>0
group by 1,2,3

)

          SELECT
              market_id AS branch_id,
              month,
              round(sum(CASE WHEN preferred_vendor = 'Yes' then vendor_spend ELSE 0 END),0) AS preferred_vendor_spend,
              round(SUM(vendor_spend),0) AS total_vendor_spend,
              total_vendor_spend - preferred_vendor_spend as non_preferred_vendor_spend,
              CASE WHEN total_vendor_spend = 0 THEN null ELSE preferred_vendor_spend/total_vendor_spend END as percent_preferred_vendor_spend,
              CASE WHEN total_vendor_spend = 0 THEN 1 ELSE ROUND(LEAST((preferred_vendor_spend/total_vendor_spend)/.90,1),4) END as percent_to_goal,
              ROUND(percent_to_goal*1,2) as score
          FROM vendor_spend
          WHERE month >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))  -- Look back exactly 12 months
          AND month < DATE_TRUNC('month', CURRENT_DATE())  -- Exclude current month
          group by 1,2
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


  dimension: preferred_vendor_spend {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.preferred_vendor_spend ;;
  }


  dimension: total_vendor_spend {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.total_vendor_spend ;;
  }

  dimension: non_preferred_vendor_spend {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.non_preferred_vendor_spend ;;
  }

  dimension: percent_preferred_vendor_spend {
    type: number
    value_format: "0.0%"
    sql: ${TABLE}.percent_preferred_vendor_spend ;;
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
      compliance_vendors_aggregate.preferred_vendor_spend,
      compliance_vendors_aggregate.total_vendor_spend,
      compliance_vendors_aggregate.percent_preferred_vendor_spend,
      compliance_vendors_aggregate.percent_to_goal,
      compliance_vendors_aggregate.score]
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
  }


  measure: avg_last_3_months_performance {
    type: average
    value_format: "$#,##0"
    sql: CASE
         WHEN ${service_branch_scorecard.is_last_3_months} THEN ${non_preferred_vendor_spend}
         ELSE NULL
       END ;;
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
  }

}
