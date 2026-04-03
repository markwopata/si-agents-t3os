#
# The purpose of this view is to pull customer lists by revenue with more customizable date filtering
# with better load time. It is very specific to the marketing program beginning May 2023 and should not be
# used elsewhere.
# Requiremetns are per marketing as of 2023.04.01.
#
# Related Story:
#   [https://app.shortcut.com/businessanalytics/story/246873/customer-revenue-dashboard-for-marketing-mikah-simpson]
#
#
# Britt Shanklin | Built 2023-04-05
view: company_revenue_by_date {
    derived_table: {
      sql: with invoices_info as (
        SELECT
          i.company_id,
          c.name,
          c.billing_location_id,
          ais.PRIMARY_SALESPERSON_ID as salesperson_user_id,
          concat(u2.first_name,' ',u2.last_name) as salesperson_name,
          li.branch_id,
          sum(li.amount) as total_spend,
          max(i.start_date::DATE) as latest_invoice_date
        FROM
          ES_WAREHOUSE.PUBLIC.INVOICES i
          join ES_WAREHOUSE.PUBLIC.companies c on i.company_id = c.company_id
          join ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS ais on i.INVOICE_ID = ais.INVOICE_ID
          join ES_WAREHOUSE.PUBLIC.users u2 on ais.PRIMARY_SALESPERSON_ID = u2.user_id
          join ANALYTICS.PUBLIC.V_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        WHERE
          i.BILLING_APPROVED_DATE > (current_date - INTERVAL '1 Year') AND
          {% condition date_filter %} i.BILLING_APPROVED_DATE {% endcondition %}
          AND li.line_item_type_id in {% if company_revenue_by_date.spend_type._parameter_value == 'rental' %} (6, 8, 108, 109)
                                      {% elsif company_revenue_by_date.spend_type._parameter_value == 'retail' %} (24, 80, 50, 81)
                                      {% else %} -1
                                      {% endif %}
          AND li.amount > 0
          AND {% condition market_region_xwalk.market_id %} li.branch_id {% endcondition %}
        GROUP BY
          i.company_id,
          li.branch_id,
          c.name,
          c.billing_location_id,
          ais.PRIMARY_SALESPERSON_ID,
          concat(u2.first_name,' ',u2.last_name)
          ),
        rank_total_spend as (
        select
          *,
          rank ()
          over (
          partition by
            company_id
          order by
            total_spend desc
          ) spend_rank_number
        from
          invoices_info
        where
          total_spend > 0
        order by
          company_id
        ),
        sales_rep_rank_one as (
        select
          company_id,
          case when spend_rank_number = 1 then salesperson_name end as sales_rep_rank_one,
          case when spend_rank_number = 1 then salesperson_user_id end as sales_rep_rank_one_id
        from
          rank_total_spend
        where
            spend_rank_number = 1
        ),
        sales_rep_rank_two as (
        select
          company_id,
          case when spend_rank_number = 2 then salesperson_name end as sales_rep_rank_two,
          case when spend_rank_number = 2 then salesperson_user_id end as sales_rep_rank_two_id
        from
          rank_total_spend
        where
            spend_rank_number = 2
        ),
        sales_rep_rank_three as (
        select
          company_id,
          case when spend_rank_number = 3 then salesperson_name end as sales_rep_rank_three,
          case when spend_rank_number = 3 then salesperson_user_id end as sales_rep_rank_three_id
        from
          rank_total_spend
        where
            spend_rank_number = 3
        ),
        company_sales_rep_spend_rank as (
        select
          r1.company_id,
          r1.sales_rep_rank_one,
          r1.sales_rep_rank_one_id,
          r2.sales_rep_rank_two,
          r2.sales_rep_rank_two_id,
          r3.sales_rep_rank_three,
          r3.sales_rep_rank_three_id
        from
          sales_rep_rank_one r1
          left join sales_rep_rank_two r2 on r1.company_id = r2.company_id
          left join sales_rep_rank_three r3 on r1.company_id = r3.company_id),
        company_totals as (
        select
          r.company_id,
          sum(r.total_spend) as total_company_spend
          from
            invoices_info r
          group by r.company_id)
        select
          r.*,
          c.sales_rep_rank_one,
          c.sales_rep_rank_one_id,
          c.sales_rep_rank_two,
          c.sales_rep_rank_two_id,
          c.sales_rep_rank_three,
          c.sales_rep_rank_three_id
        from company_totals t
        join invoices_info r on t.company_id = r.company_id
        left join company_sales_rep_spend_rank c on c.company_id = r.company_id
        where t.total_company_spend > 100000
      ;;
     }

    parameter: spend_type {
      type: unquoted
      allowed_value: {
        label: "Rental"
        # value: "'6','8','108','109'"
        value: "rental"
      }
      allowed_value: {
        label: "Retail"
        # value: "'24','80','50','81'"
        value: "retail"
      }
      default_value: "Rental"
    }

    filter: date_filter {
      type: date
      suggest_dimension: current_date
    }

    dimension: current_date {
      type: date
      sql: current_date ;;
    }

    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
      value_format_name: id
    }

    dimension: company_name {
      type: string
      sql: ${TABLE}."NAME" ;;
    }

  # dimension: salesperson_user_id {
  #   type: number
  #   sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  # }

  # dimension: salesperson_name {
  #   type: string
  #   sql: ${TABLE}."SALESPERSON_NAME" ;;
  # }

  dimension: total_spend {
    type: number
    sql: ${TABLE}."TOTAL_SPEND" ;;
  }

  # dimension: latest_invoice_date {
  #   type: date
  #   sql: ${TABLE}."LATEST_INVOICE_DATE" ;;
  # }

  dimension: billing_location_id {
    type: number
    sql: ${TABLE}."BILLING_LOCATION_ID" ;;
  }

  # dimension: rank_number {
  #   type: number
  #   sql: ${TABLE}."RANK_NUMBER" ;;
  # }

  # dimension: full_name_with_id {
  #   type: string
  #   sql: concat(${salesperson_name}, ' - ',${salesperson_user_id})  ;;
  # }


  #These are sales reps ranked according to invoice amount, not latest invoice date
  dimension: sales_rep_rank_one {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_ONE" ;;
  }

  dimension: sales_rep_rank_one_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_ONE_ID" ;;
  }

  dimension: sales_rep_rank_two {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_TWO" ;;
  }

  dimension: sales_rep_rank_two_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_TWO_ID" ;;
  }

  dimension: sales_rep_rank_three {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_THREE" ;;
  }

  dimension: sales_rep_rank_three_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_THREE_ID" ;;
  }

  # dimension: sales_rep_id_link_to_salesperson_dashboard {
  #   type: string
  #   sql: ${full_name_with_id} ;;

  #   link: {
  #     label: "View Salesperson Dashboard"
  #     url: "https://equipmentshare.looker.com/dashboards/5?Sales%20Rep={{ value | url_encode }}"
  #     #8&Market=&District=&Region=&Customer%20Terms%20(AR%20Past%20Due)=&National%20Sales%20Rep=&Do%20Not%20Rent%20Customers=
  #   }
  #   description: "This links out to the Salesperson dashboard"
  # }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  measure: total_amt {
    type: sum
    value_format_name: "usd"
    sql: ${TABLE}."TOTAL_SPEND";;
  }

}
