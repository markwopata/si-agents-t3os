#
# The purpose of this view is to capture revenue metrics.
# Revenue is defined as the total spend based on v_line_items for a given type.This was switched to
# use approved_invoice_salesperson to match revenue used for commissions.Includes primary (1) and secondary (2).
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/278895/salesperson-overview-section-refresh]
#
# Britt Shanklin | Built 2023-08-15 | Modified 2023-09-06
view: revenue {
    derived_table: {
      sql: with primary_rep_revenue as (
        SELECT
          ais.primary_salesperson_id as user_id,
          li.branch_id as market_id,
          'Primary' as salesperson_type,
          ais.billing_approved_date as invoice_date,
          i.paid as paid_status,
          case when i.outstanding >= 121 then 120
               when i.outstanding >= 91 then 90
               when i.outstanding >= 61 then 60
               when i.outstanding >= 31 then 30
               else 0
          end as outstanding_range,
          case when li.line_item_type_id in (6, 8, 108, 109) then 'Rental'
               when li.line_item_type_id in (44) then 'Bulk'
               when li.line_item_type_id in (5) then 'Delivery'
          end as revenue_type,
          count(i.invoice_id) as invoice_count,
          sum(i.owed_amount) as total_owed,
          sum(li.amount) as total_spend
        FROM ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS ais
        join ES_WAREHOUSE.PUBLIC.INVOICES i on ais.INVOICE_ID = i.INVOICE_ID
        join ANALYTICS.PUBLIC.V_LINE_ITEMS li on ais.INVOICE_ID = li.INVOICE_ID

        WHERE
          user_id = try_to_number(split_part({{ _filters['salesperson_revenue.full_name_with_id'] | sql_quote }}, '-', 2)) AND
          {% condition date_filter %} ais.BILLING_APPROVED_DATE {% endcondition %} AND
          ais.BILLING_APPROVED_DATE > (current_date - INTERVAL '6 Month') AND
          (li.line_item_type_id in (6, 8, 108, 109, 44) or (li.line_item_type_id = 5 and li.amount > 125))

        GROUP BY
            user_id,
            market_id,
            ais.billing_approved_date,
            salesperson_type,
            paid,
            outstanding_range,
            revenue_type
          ),
          secondary_rep_revenue as (
        SELECT
          flat.secondary_salesperson_id as user_id,
          li.branch_id as market_id,
          'Secondary' as salesperson_type,
          ais.billing_approved_date as invoice_date,
          i.paid as paid_status,
          case when i.outstanding >= 121 then 120
               when i.outstanding >= 91 then 90
               when i.outstanding >= 61 then 60
               when i.outstanding >= 31 then 30
               else 0
          end as outstanding_range,
          case when li.line_item_type_id in (6, 8, 108, 109) then 'Rental'
               when li.line_item_type_id in (44) then 'Bulk'
               when li.line_item_type_id in (5) then 'Delivery'
          end as revenue_type,
          count(i.invoice_id) as invoice_count,
          sum(i.owed_amount) as total_owed,
          sum(li.amount) as total_spend
        FROM ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS ais
        join (SELECT invoice_id,
                          value              AS secondary_salesperson_id
                  FROM es_warehouse.public.approved_invoice_salespersons, TABLE ( FLATTEN(secondary_salesperson_ids) )
                  WHERE secondary_salesperson_ids <> '[]'
                        and value = try_to_number(split_part({{ _filters['salesperson_revenue.full_name_with_id'] | sql_quote }}, '-', 2))
                        and {% condition date_filter %} BILLING_APPROVED_DATE {% endcondition %}
                        and  BILLING_APPROVED_DATE > (current_date - INTERVAL '6 Month')
                  group by invoice_id, value) flat on ais.invoice_id = flat.invoice_id
        join ANALYTICS.PUBLIC.V_LINE_ITEMS li on flat.INVOICE_ID = li.INVOICE_ID
        join ES_WAREHOUSE.PUBLIC.INVOICES i on flat.INVOICE_ID = i.INVOICE_ID
        WHERE
          user_id = try_to_number(split_part({{ _filters['salesperson_revenue.full_name_with_id'] | sql_quote }}, '-', 2)) AND
          {% condition date_filter %} ais.BILLING_APPROVED_DATE {% endcondition %} AND
          ais.BILLING_APPROVED_DATE > (current_date - INTERVAL '6 Month') AND
          (li.line_item_type_id in (6, 8, 108, 109, 44) or (li.line_item_type_id = 5 and li.amount > 125))
        GROUP BY
            user_id,
            market_id,
            ais.billing_approved_date,
            salesperson_type,
            paid,
            outstanding_range,
            revenue_type)
        select * from primary_rep_revenue
            UNION
        select * from secondary_rep_revenue
      ;;
}

    parameter: spend_type {
      type: unquoted
      allowed_value: {
        label: "Rental"
        value: "rental"
      }
      allowed_value: {
        label: "Retail"
        value: "retail"
      }
      allowed_value: {
        label: "Ancillary"
        value: "ancillary"
      }
      default_value: "Rental"
    }

    parameter: date_type {
      type: string
      allowed_value: {
        label: "Month"
        value: "month"
      }
      allowed_value: {
        label: "Quarter"
        value: "quarter"
      }
      default_value: "Month"
    }

    filter: date_filter {
      type: date
      suggest_dimension: current_date
    }

    dimension: current_date {
      type: date
      sql: current_date ;;
    }

    # parameter: user_id {
    #   type: string
    #   suggest_explore: salesperson_revenue
    #   suggest_dimension: salesperson_revenue.full_name_with_id
    #   suggest_persist_for: "24 hours"
    # }

    # dimension: user_id_filter {
    #   type: string
    #   sql: split_part(${user_id}, '-', 1);;
    # }

    # dimension: filtered_user {
    #   hidden: yes
    #   type: yesno
    #   sql: ${salesperson_user_id} = ${user_id_filter};;
    # }

    dimension_group: billing_approved_date {
      type: time
      timeframes: [
        raw,
        date,
        month,
        quarter
      ]
      sql: ${TABLE}."INVOICE_DATE" ;;
    }


    dimension: salesperson_user_id {
      type: string
      sql: ${TABLE}."USER_ID" ;;
    }

    dimension: full_name {
      type: string
      sql: ${TABLE}."FULL_NAME" ;;
    }

    dimension: full_name_with_id {
      type: string
      sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
    }

    dimension: salesperson_type {
      type: string
      sql: ${TABLE}."SALESPERSON_TYPE" ;;
    }

    dimension: revenue_type {
      type: string
      sql: ${TABLE}."REVENUE_TYPE" ;;
    }

    dimension: outstanding_range {
      type: number
      hidden: yes
      sql: ${TABLE}."OUTSTANDING_RANGE" ;;
    }

    dimension: oustanding_range_label {
      type: string
      sql: case when ${outstanding_range} = 120 then 'Clawback Eligible'
                when ${outstanding_range} = 90 then 'Clawback Eliglble Next 30 Days'
                else 'Oustanding'
          end ;;
    }

    dimension: paid_invoice {
      type: yesno
      sql: ${TABLE}."PAID_STATUS" ;;
    }

    dimension: total_owed_amount {
      type: number
      hidden: yes
      sql: ${TABLE}."TOTAL_OWED" ;;
    }

    dimension: total_spend {
      type: number
      hidden: yes
      sql: ${TABLE}."TOTAL_SPEND" ;;
    }

    dimension: market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: is_home_market{
      type: yesno
      sql: ${salesperson_revenue.home_market} = ${market_id} ;;
    }

    dimension: home_market_status{
      type: string
      sql: CASE WHEN ${is_home_market} THEN 'In Home Market'
           ELSE 'Outside Home Market' END ;;
    }

    dimension: amount {
      type: number
      sql: ${TABLE}."TOTAL_SPEND" ;;
    }

    measure: total_amt {
      type: sum
      value_format_name: usd
      sql: ${amount};;
    }


  dimension: is_current_period{
    type: yesno
    sql:{% if revenue.date_type._parameter_value == "'month'" %}
      date_trunc('month', ${billing_approved_date_raw}) = date_trunc('month', current_date)
    {% elsif revenue.date_type._parameter_value == "'quarter'" %}
      date_trunc('quarter', ${billing_approved_date_raw}) = date_trunc('quarter', current_date)
    {% else %}
      NULL
    {% endif %} ;;
    }

  dimension: is_prior_period{
    type: yesno
    sql:{% if revenue.date_type._parameter_value == "'month'" %}
      date_trunc('month', ${billing_approved_date_raw}) = (date_trunc('month', current_date) - interval '1 Month')
    {% elsif revenue.date_type._parameter_value == "'quarter'" %}
      date_trunc('quarter', ${billing_approved_date_raw}) = (date_trunc('quarter', current_date) - interval '1 Quarter')
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: current_period_amt {
    type: sum
    filters: [is_current_period: "Yes"]
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: prior_period_amt {
    type: sum
    filters: [is_prior_period: "Yes"]
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: total_owed_amt {
    type: sum
    sql: ${total_owed_amount} ;;
    value_format_name: usd
  }



  }
