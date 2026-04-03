view: dealership_service_revenue {
    derived_table: {
      sql:
with worked_hours as(
select wo.invoice_id
     , sum(tt.regular_hours + tt.overtime_hours) as hours
 from analytics.intacct_models.stg_es_warehouse_time_tracking__time_entries tt
 join analytics.intacct_models.stg_es_warehouse_work_orders__work_orders wo on tt.work_order_id = wo.work_order_id
 where tt.event_type_id = 1
 group by all)

select rm.retail_territory
     , m.region
     , m.district
     , m.market_id
     , m.market_name as market
     , li.invoice_id
     , li.invoice_number
     , li.gl_date::date as gl_date
     , li.company_id
     , li.customer_name as customer
     , li.line_item_id
     , li.line_item_type_id
     , li.line_item_type_name as line_item_type
     , li.line_item_description
     , li.asset_id
     , li.amount as revenue
     , sum(li.amount) over (partition by li.invoice_id, li.line_item_type_id, li.gl_date) as total_revenue
     , coalesce((li.amount/nullifzero(total_revenue)) * coalesce(wh.hours,ia.number_of_units),0) as labor_hours
     , (case
         when year(li.gl_date::date) = 2024 then 74.33 * labor_hours
         when year(li.gl_date::date) = 2025 then 64.4 * labor_hours
         else 64.4 * labor_hours
        end) as labor_cost
     , (case
         when li.line_item_type_id in(13,26) then li.amount - labor_cost
         else 0
        end) as labor_profit
 from analytics.intacct_models.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL li
 join analytics.branch_earnings.market m on li.market_id = m.child_market_id
 join analytics.dbt_seeds.seed_retail_market_map rm on m.market_id = rm.market_id
 left join worked_hours wh on li.invoice_id = wh.invoice_id and li.line_item_type_id in(13,26)
 left join analytics.intacct_models.int_admin_invoice_line_detail ia on li.line_item_id = ia.line_item_id and li.line_item_type_id in(13,26)
 left join analytics.public.es_companies ec on li.company_id = ec.company_id
 where date_trunc(month,li.gl_date::date) >= '2024-01-01'
  and li.line_item_type_id in(11,13,25,26)
  and ec.company_id is null
  and li.company_id not in(420,62875,1854,1855,61036)
  and li.amount <> 0
        ;;
    }

  dimension: retail_territory {
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: invoice_id {
    label: "InvoiceID"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year, month_name]
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: service_revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: total_revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: labor_revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end ;;
  }

  measure: parts_revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then ${TABLE}."REVENUE" end ;;
  }

  measure: labor_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."LABOR_HOURS" ;;
  }

  measure: labor_cost {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."LABOR_COST" ;;
  }

  measure: labor_profit {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."LABOR_PROFIT" ;;
  }

  measure: labor_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(${TABLE}."LABOR_PROFIT")/nullifzero(sum(case when ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)) ;;
  }

  measure: service_cost {
    type: number
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${labor_cost} + ${dealership_parts_transactions.cost} ;;
  }

  measure: service_profit {
    type: number
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${service_revenue} - ${labor_cost} - ${dealership_parts_transactions.cost} ;;
  }

  measure: service_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: (${service_revenue} - ${labor_cost} - ${dealership_parts_transactions.cost})/nullifzero(${service_revenue}) ;;
  }

  measure: current_year_service_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" end;;
  }

  measure: cy_avg_monthly_service_revenue {
    label: "CY Avg Monthly Service Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" end)
         / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: prior_year_service_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" end;;
  }

  measure: py_avg_monthly_service_revenue {
    label: "PY Avg Monthly Service Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: current_year_labor_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date)
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end;;
  }

  measure: cy_avg_monthly_labor_revenue {
    label: "CY Avg Monthly Labor Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: cy_avg_monthly_labor_revenue_month_ct {
    label: "CY Avg Monthly Labor Revenue Month Ct"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: prior_year_labor_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end;;
  }

  measure: py_avg_monthly_labor_revenue {
    label: "PY Avg Monthly Labor Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) - 1 and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: current_year_labor_cost {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."LABOR_COST" end;;
  }

  measure: prior_year_labor_cost {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."LABOR_COST" end;;
  }

  measure: current_year_labor_profit {
    type: sum
    value_format_name: decimal_0
    sql: (case when year(${TABLE}."GL_DATE") = year(current_date)
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
           - (case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."LABOR_COST" end);;
  }

  measure: prior_year_labor_profit {
    type: sum
    value_format_name: decimal_0
    sql: (case when year(${TABLE}."GL_DATE") = year(current_date) - 1
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
           - (case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."LABOR_COST" end);;
  }

  measure: current_year_labor_profit_margin {
    type: number
    value_format_name: percent_2
    sql: sum((case when year(${TABLE}."GL_DATE") = year(current_date)
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
           - (case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."LABOR_COST" end))
          /nullifzero(sum(case when year(${TABLE}."GL_DATE") = year(current_date)
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end));;
  }

  measure: prior_year_labor_profit_margin {
    type: number
    value_format_name: percent_2
    sql: sum((case when year(${TABLE}."GL_DATE") = year(current_date) - 1
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end)
           - (case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."LABOR_COST" end))
          /nullifzero(sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1
          and ${TABLE}."LINE_ITEM_TYPE_ID" in(13,26) then ${TABLE}."REVENUE" end));;
  }

  measure: current_year_service_profit {
    type: number
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${current_year_service_revenue} - ${current_year_labor_cost} - ${dealership_parts_transactions.current_year_cost};;
  }

  measure: prior_year_service_profit {
    type: number
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${prior_year_service_revenue} - ${prior_year_labor_cost} - ${dealership_parts_transactions.prior_year_cost};;
  }

  measure: current_year_service_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: (${current_year_service_revenue} - ${current_year_labor_cost} - ${dealership_parts_transactions.current_year_cost})
          /${current_year_service_revenue};;
  }

  measure: prior_year_service_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: (${prior_year_service_revenue} - ${prior_year_labor_cost} - ${dealership_parts_transactions.prior_year_cost})
      /${prior_year_service_revenue};;
  }

  measure: current_year_parts_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date)
      and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then ${TABLE}."REVENUE" end;;
  }

  measure: cy_avg_monthly_parts_revenue {
    label: "CY Avg Monthly Parts Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: prior_year_parts_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1
      and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then ${TABLE}."REVENUE" end;;
  }

  measure: py_avg_monthly_parts_revenue {
    label: "PY Avg Monthly Parts Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) - 1 and ${TABLE}."LINE_ITEM_TYPE_ID" in(11,25) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }


    set: drill_fields {
      fields: [
        retail_territory,
        market,
        invoice_id,
        gl_date,
        line_item_type,
        description,
        customer,
        service_revenue,
        labor_cost,
        dealership_parts_transactions.cost
      ]
    }

  }
