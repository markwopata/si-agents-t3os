view: dealership_parts_transactions {
  derived_table: {
    sql:
with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
    select *
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
        qualify
                row_number() over (
                    partition by wacs.inventory_location_id, wacs.product_id, date_applied
                    order by wacs.date_created desc)
                = 1
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

, wac as ( --Pulling the master part id and the branch id and configuring a date end for the WAC line
    select p.master_part_id as part_id
         , wp.weighted_average_cost
         , wp.date_applied as date_start
        , coalesce(lead(wp.DATE_APPLIED, 1) over (
            partition by wp.PRODUCT_ID, wp.INVENTORY_LOCATION_ID
            order by wp.DATE_APPLIED asc), '2099-12-31') as date_end
        , wp.inventory_location_id
        , il.branch_id
        , wp.is_current
    from wac_prep wp
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on il.inventory_location_id = wp.inventory_location_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on wp.product_id = p.part_id
    where wp.weighted_average_cost <> 0
        and wp.weighted_average_cost <> 0.01)

, prep_store_part_cost as ( --Store Part Costs with start and end dates
    select p.master_part_id as part_id
        , il.branch_id
        , il.inventory_location_id
        , spc.COST
        , coalesce(
            lag(spc.DATE_ARCHIVED::timestamp_ntz) over (partition by spc.STORE_PART_ID order by spc.date_archived, spc.STORE_PART_COST_ID),
            0::timestamp_ntz)::timestamp_ntz                           as date_start
        , coalesce(spc.DATE_ARCHIVED::timestamp_ntz, '2099-12-31'::timestamp_ntz) as date_end
    from ES_WAREHOUSE.INVENTORY.STORE_PART_COSTS spc
    join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
        on sp.store_part_id = spc.store_part_id
    join es_warehouse.inventory.inventory_locations il
        on il.inventory_location_id = sp.store_id
    join ANALYTICS.parts_inventory.parts p
        on p.part_id = sp.part_id
    where spc.cost <> 0 and spc.cost is not null)

, line_items_2024_flag as ( --Line items for 2022+ with value. Flag for WAC eligible parts (2024+)
    select li.*
         , i.billing_approved_date
         , i.company_id
    from ANALYTICS.PUBLIC.V_LINE_ITEMS li
             join es_warehouse.public.invoices i
                  on i.invoice_id = li.invoice_id
    where i.billing_approved_date >= '2024-01-01'
      and li.amount <> 0
      and i.billing_approved = TRUE
      and li.line_item_type_id in (49 --Parts Retail Sale
        , 25 --Damage Parts
        , 11 --Service Equipment Parts
        , 23) --Warranty Parts Revenue
)

 , credit as ( --Removing line items that were credited using V line items.
    select li.invoice_id
         , li.line_item_id
         , li.billing_approved_date
         , li.company_id
         , li.branch_id
         , p.master_part_id as part_id
         , li.number_of_units
         , sum(li.amount)         part_rev_adj --Zero out credited line items
         , li.line_item_type_id
         , li.description
    from line_items_2024_flag li
             join ANALYTICS.PARTS_INVENTORY.PARTS p
                  on li.extended_data:part_id = p.part_id
    group by li.invoice_id
           , li.line_item_id
           , li.billing_approved_date
           , li.company_id
           , li.branch_id
           , p.master_part_id, p.PART_NUMBER
           , li.number_of_units
           , li.line_item_type_id
           , li.description
    having part_rev_adj > 0 -- adding this as to not eliminate credits where the part itself was not credited, mostly tax
)

, cost_incorporation_prep as (
    select li.invoice_id, li.BILLING_APPROVED_DATE
        , li.line_item_id
        , li.number_of_units
        , li.branch_id
        , li.company_id
        , li.part_id
        , coalesce(wm.weighted_average_cost, spc.cost) as the_cost
        , coalesce(wm.inventory_location_id, spc.INVENTORY_LOCATION_ID) as the_inventory_location_id
        , part_rev_adj
        , line_item_type_id
        , li.description
    from credit li
    join es_warehouse.public.invoices i
        on i.invoice_id = li.invoice_id
    left join wac wm
        on i.billing_approved_date >= wm.date_start --WAC at a time
            and i.billing_approved_date < wm.date_end
            and wm.part_id = li.part_id --Joining on Master part id (aliased)
            and wm.branch_id = li.branch_id
    left join prep_store_part_cost spc
        on li.billing_approved_date >= spc.date_start --SPC at a time
            and li.billing_approved_date < spc.date_end
            and spc.part_id = li.part_id --Join on Master Part ID (aliased)
            and spc.branch_id = li.branch_id)

, company_wide_avg_filler as (select part_id, date_trunc(month, BILLING_APPROVED_DATE) as match_date, avg(the_cost) as avg_cost
           from cost_incorporation_prep
           group by part_id, date_trunc(month, BILLING_APPROVED_DATE))

, cost_incorporation as (
    select cip.invoice_id, cip.billing_approved_date
         , cip.line_item_id
         , cip.NUMBER_OF_UNITS
         , cip.branch_id
         , cip.company_id
         , cip.part_id
         , coalesce(avg(cip.the_cost), t.avg_cost) as avg_cost
         , cip.part_rev_adj
         , cip.LINE_ITEM_TYPE_ID
         , cip.description
    from cost_incorporation_prep cip
    left join company_wide_avg_filler t on cip.part_id = t.part_id and date_trunc(month, cip.BILLING_APPROVED_DATE) = t.match_date
    group by cip.invoice_id, cip.BILLING_APPROVED_DATE
           , cip.line_item_id, cip.NUMBER_OF_UNITS, cip.branch_id, cip.company_id, cip.part_id, t.avg_cost
           , cip.part_rev_adj, cip.LINE_ITEM_TYPE_ID, cip.description)

, parts_attributes as(
select distinct part_id, part_categorization_id
            from analytics.parts_inventory.parts_attributes
            where end_date::date = '2999-01-01' and part_categorization_id is not null)

select lif.invoice_id
    , lif.line_item_id
    , lif.billing_approved_date::date as gl_date
    , lif.number_of_units
    , lif.company_id
    , pc.name as customer
    , m.market_id
    , m.market_name as market
    , rm.retail_territory
    , m.region_name as region
    , m.district
    , lif.part_id
    , part_rev_adj as revenue
    , lif.line_item_type_id
    , lif.avg_cost as average_cost
    , average_cost * lif.number_of_units as cost
    , lif.part_rev_adj - zeroifnull(cost) as gross_profit
    , (lif.part_rev_adj / cost) - 1 as gross_profit_margin
    , p.part_number
    , lit.name as line_item_type
    , lif.description
    , p.msrp --heidi adding msrp to get avg line item discounts
    , pl.amount list_price
    , pa.part_categorization_id
    , pcs.category
    , pcs.subcategory
    , pro.name as brand
from cost_incorporation lif
left join es_warehouse.inventory.parts p on lif.part_id = p.part_id
left join es_warehouse.inventory.providers pro on p.provider_id = pro.provider_id
left join parts_attributes pa on p.part_id = pa.part_id
left join analytics.parts_inventory.part_categorization_structure pcs on pa.part_categorization_id = pcs.part_categorization_id
left join PROCUREMENT.PUBLIC.PRICE_LIST_ENTRIES pl on p.item_id = pl.item_id
join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit on lit.line_item_type_id = lif.line_item_type_id
join analytics.branch_earnings.market m on lif.branch_id = m.child_market_id
join analytics.dbt_seeds.seed_retail_market_map rm on m.child_market_id = rm.market_id
left join analytics.public.es_companies c on lif.company_id = c.company_id
left join es_warehouse.public.companies pc on lif.company_id = pc.company_id
where c.company_id is null
 and lif.company_id not in(420,62875,1854,1855,61036)
      ;;
  }

  dimension: invoice_id {
    label: "InvoiceID"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
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

  measure: number_of_units {
    label: "Quantity Sold"
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
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

  dimension: part_id {
    label: "PartID"
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: current_year_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" end;;
  }

  measure: cy_avg_monthly_revenue {
    label: "CY Avg Monthly Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: prior_year_revenue {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" end;;
  }

  measure: py_avg_monthly_revenue {
    label: "PY Avg Monthly Revenue"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  dimension: line_item_type_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  measure: average_cost {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."AVERAGE_COST" ;;
  }

  measure: cost  {
    label: "Parts Cost"
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."COST" ;;
  }

  measure: current_year_cost {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."COST" end;;
  }

  measure: prior_year_cost {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."COST" end;;
  }

  measure: gross_profit {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql:${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") ;;
  }

  measure: current_year_gross_profit {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end;;
  }

  measure: cy_avg_monthly_profit {
    label: "CY Avg Monthly Profit"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: prior_year_gross_profit {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end;;
  }

  measure: py_avg_monthly_profit {
    label: "PY Avg Monthly Profit"
    type: number
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) -1 then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end)
      / count(distinct case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then date_trunc(month,${TABLE}."GL_DATE") end) ;;
  }

  measure: profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST"))/nullifzero(sum(${TABLE}."REVENUE")) ;;
  }

  measure: current_year_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end)
         /nullifzero(sum(case when year(${TABLE}."GL_DATE") = year(current_date) then ${TABLE}."REVENUE" end));;
  }

  measure: prior_year_profit_margin {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" - zeroifnull(${TABLE}."COST") end)
      /nullifzero(sum(case when year(${TABLE}."GL_DATE") = year(current_date) - 1 then ${TABLE}."REVENUE" end));;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  measure: msrp  {
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."MSRP" ;;
  }

  measure: list_price {
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."LIST_PRICE" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}."SUBCATEGORY" ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
  }

  dimension: sold_below_cost {
    type: yesno
    sql: ${TABLE}."REVENUE" < ${TABLE}."COST";;
  }

  set: drill_fields {
    fields: [
      retail_territory,
      market,
      invoice_id,
      gl_date,
      line_item_type,
      description,
      revenue,
      cost,
      gross_profit,
      profit_margin,
      part_id,
      part_number,
      category,
      brand,
      customer
    ]
  }

}
