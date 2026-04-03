view: top_50_customers_by_revenue {
  derived_table: {
    sql:
    with REV_CTE as
         (
             select i.ship_from:branch_id as branch_id,
                    sum(LI.AMOUNT) as REVENUE,
                    I.COMPANY_ID
             from ES_WAREHOUSE.PUBLIC.INVOICES I
                      join ANALYTICS.PUBLIC.V_LINE_ITEMS LI
                           on I.INVOICE_ID = LI.INVOICE_ID
             where LI.GL_BILLING_APPROVED_DATE > dateadd(day, -365, current_date)
             group by i.ship_from:branch_id, I.COMPANY_ID
         ),
     RANK_CTE as (
         select *,
                rank() over (partition by BRANCH_ID order by REVENUE desc) as RANK_
         from REV_CTE
         where COMPANY_ID not in (6954, 1854)
     )
    select
    branch_id
    ,revenue
    ,company_id
    ,rank_
    from RANK_CTE
    where RANK_ <= 50;;

  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}."RANK_" ;;
  }

  measure: total_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${revenue} ;;
    drill_fields: [top_50_drill*]
  }

  set: top_50_drill {
    fields: [rank, companies.company_name_with_id, owners.Full_Name_with_ID, owners.phone_number, owners.email_address, revenue]
  }

  measure: revenue_total {
    type: sum
    value_format_name: usd_0
    sql: ${revenue} ;;
    drill_fields: [market_region_xwalk.market_name, companies.company_name_with_id, owners.Full_Name_with_ID, owners.phone_number, owners.email_address, revenue]
  }

  measure: total_revenue_new_drill {
    type: sum
    value_format_name: usd_0
    sql: ${revenue} ;;
    drill_fields: [market_region_xwalk.selected_hierarchy_dimension, companies.company_name_with_id, owners.Full_Name_with_ID, owners.phone_number, owners.email_address, revenue_total]
  }

  }
