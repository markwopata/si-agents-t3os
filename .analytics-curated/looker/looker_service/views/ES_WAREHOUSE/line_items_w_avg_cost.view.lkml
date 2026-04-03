view: line_items_w_avg_cost {
 derived_table: {
   sql: with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
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
        and wp.weighted_average_cost <> 0.01
)

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
    where spc.cost <> 0 and spc.cost is not null
)


, line_items_2024_flag as ( --Line items for 2022+ with value. Flag for WAC eligible parts (2024+)
    select li.*
        , i.billing_approved_date
    from ANALYTICS.PUBLIC.V_LINE_ITEMS li
    join es_warehouse.public.invoices i
        on i.invoice_id = li.invoice_id
    where i.billing_approved_date >= '2022-01-01'
       and li.amount <> 0
        and i.billing_approved = TRUE
        and li.line_item_type_id in (49  --Parts Retail Sale
                                    ,25  --Damage Parts
                                    ,11  --Service Equipment Parts
                                    ,23) --Warranty Parts Revenue
)

 , credit as ( --Removing line items that were credited using V line items.
    select invoice_id
        , line_item_id
        , billing_approved_date
        , branch_id
        , p.master_part_id as part_id
        , number_of_units
        , sum(amount) part_rev_adj --Zero out credited line items
        , line_item_type_id
    from line_items_2024_flag
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on extended_data:part_id = p.part_id
    group by invoice_id
        , line_item_id
        , billing_approved_date
        , branch_id
        , p.master_part_id, p.PART_NUMBER
        , number_of_units
        , line_item_type_id
    having part_rev_adj>0 -- adding this as to not eliminate credits where the part itself was not credited, mostly tax
 )

, cost_incorporation_prep as (
    select li.invoice_id, li.BILLING_APPROVED_DATE
        , li.line_item_id
        , li.number_of_units
        , li.branch_id
        , li.part_id
        , coalesce(wm.weighted_average_cost, spc.cost) as the_cost
        , coalesce(wm.inventory_location_id, spc.INVENTORY_LOCATION_ID) as the_inventory_location_id
        , part_rev_adj
        , line_item_type_id
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
            and spc.branch_id = li.branch_id
)

, company_wide_avg_filler as (select part_id, date_trunc(month, BILLING_APPROVED_DATE) as match_date, avg(the_cost) as avg_cost
           from cost_incorporation_prep
           group by part_id, date_trunc(month, BILLING_APPROVED_DATE))

, cost_incorporation as (
    select cip.invoice_id, cip.billing_approved_date
         , cip.line_item_id
         , cip.NUMBER_OF_UNITS
         , cip.branch_id
         , cip.part_id
         , coalesce(avg(cip.the_cost), t.avg_cost) as avg_cost
         , cip.part_rev_adj
         , cip.LINE_ITEM_TYPE_ID
    from cost_incorporation_prep cip
    left join company_wide_avg_filler t on cip.part_id = t.part_id and date_trunc(month, cip.BILLING_APPROVED_DATE) = t.match_date
    group by cip.invoice_id, cip.BILLING_APPROVED_DATE
           , cip.line_item_id, cip.NUMBER_OF_UNITS, cip.branch_id, cip.part_id, t.avg_cost
           , cip.part_rev_adj, cip.LINE_ITEM_TYPE_ID
) --select * from cost_incorporation;


--Final Select
select lif.invoice_id
    , lif.line_item_id
    , lif.number_of_units
    , lif.branch_id
    , lif.part_id
    , part_rev_adj as amount
    , lif.line_item_type_id
    , lif.avg_cost as average_cost
    , average_cost * lif.number_of_units as cogs
    , lif.part_rev_adj - zeroifnull(cogs) as gross_profit
    , (lif.part_rev_adj / cogs) - 1 as gross_profit_margin
    , p.part_number
    , p.provider_id
    , lit.name as line_item_type
    , p.msrp --heidi adding msrp to get avg line item discounts
    , pl.amount list_price
from cost_incorporation lif
left join "ES_WAREHOUSE"."INVENTORY"."PARTS" p --Joining Back in to get Part info. Using Master Part ID
    on lif.part_id = p.part_id
left join PROCUREMENT.PUBLIC.PRICE_LIST_ENTRIES pl
on p.item_id=pl.item_id
join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit
    on lit.line_item_type_id = lif.line_item_type_id
order by lif.invoice_id desc;;
 }
  dimension: line_item_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: per_unit_sale_price {
    type: number
    value_format_name: usd
    sql: ${amount}/nullifzero(${number_of_units}) ;;
  }
  dimension: list_price {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LIST_PRICE" ;;
  }
  dimension: list_amount {
    type: number
    value_format_name: usd_0
    sql: ${list_price}*${number_of_units} ;;
  }
  measure: total_list {
    type: sum
    value_format_name: usd_0
    sql: ${list_amount} ;;
  }
  dimension: list_potential_rev{
    type: number
    value_format_name: usd_0
    sql: case when zeroifnull(${list_price})>${per_unit_sale_price} then ${list_amount} else ${amount}  end  ;;
  }
  measure: total_list_potential {
    type: sum
    value_format_name: usd_0
    sql: ${list_potential_rev} ;;
  }
  measure: list_addition_rev_potential {
    type: number
    value_format_name: percent_1
    sql: (${total_list_potential}/nullifzero(${total_value_of_transaction}))-1;;
  }
  dimension: msrp { #per unit
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."MSRP" ;;
  }

  dimension: msrp_amount { #msrp * number of units
    type:number
    value_format_name: usd
    sql: ${msrp}*${number_of_units} ;;
    }

    measure: total_msrp {
      type: sum
      value_format_name: usd_0
      sql: ${msrp_amount} ;;
    }
   measure: achieved_markup {
     type: number
    value_format_name: percent_2
    sql: (${total_value_of_transaction}/nullifzero(${total_msrp}))-1 ;;
    drill_fields: [market_region_xwalk.market_name, companies.customer_name,invoice_id_with_link_to_invoice , line_item_type, part_id, part_number, per_unit_sale_price, msrp, msrp_markup, number_of_units, amount, msrp_missed_opportunity]
   }
  dimension: msrp_markup {
    type: number
    value_format_name: percent_2
    sql: (${per_unit_sale_price}/nullifzero(${msrp}))-1 ;;
  }
  measure: avg_markup {
    type: average
    value_format_name: percent_2
    sql: ${msrp_markup} ;;
    drill_fields: [market_region_xwalk.market_name, companies.customer_name, invoice_id_with_link_to_invoice , line_item_type, part_id, part_number, per_unit_sale_price, msrp, msrp_markup, number_of_units, amount, msrp_missed_opportunity]
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  # dimension: extended_data {
  #   type: string
  #   sql: ${TABLE}."EXTENDED_DATA" ;;
  # }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AVERAGE_COST" ;;
  }

  dimension: cogs {
    type: number
    value_format_name: usd
    sql: ${TABLE}."COGS" ;;
  }

  dimension: gross_profit {
    type: number
    value_format_name: usd
    sql: ${TABLE}.gross_profit ;;
  }

  dimension: gross_profit_margin {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."GROSS_PROFIT_MARGIN" ;;
  }

  dimension: provider_id  {
    type: string
    sql: ${TABLE}."PROVIDER_ID";;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: invoice_id_with_link_to_invoice {
    label: "Invoice ID"
    type: string
    sql: ${invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_drill*]
  }

  measure: total_cost_of_parts {
    type: sum
    value_format_name: usd_0
    sql: ${cogs} ;;
    drill_fields: [market_drill*]
  }

  measure: total_cost_of_parts_drill {
    type: sum
    value_format_name: usd_0
    sql: ${cogs} ;;
    drill_fields: [invoice_drill*]
  }

  measure: total_value_of_transaction {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    drill_fields: [market_drill*]
  }

  measure: total_value_of_transaction_drill {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    drill_fields: [invoice_drill*]
  }
dimension: msrp_potential_rev{
  type: number
  value_format_name: usd_0
  sql: case when ${msrp_amount}>${amount} then ${msrp_amount} else ${amount} end  ;;
}
measure: total_msrp_potential {
  type: sum
  value_format_name: usd_0
  sql: ${msrp_potential_rev} ;;
}
dimension: msrp_missed_opportunity {
  type: number
  value_format_name: usd_0
  sql: case when ${msrp_amount}>${amount} then ${msrp_amount}-${amount} else 0 end  ;;
}
measure: total_msrp_opportunity {
  type: sum
  value_format_name: usd_0
  sql: ${msrp_missed_opportunity}  ;;
  drill_fields: [market_region_xwalk.market_name, companies.customer_name, invoice_id_with_link_to_invoice , line_item_type, part_id, part_number, parts.part_name,providers.name, per_unit_sale_price, msrp, msrp_markup, number_of_units, amount, msrp_missed_opportunity]
}
measure: msrp_additional_rev_potential {
  type: number
  value_format_name: percent_1
  sql: (${total_msrp_potential}/nullifzero(${total_value_of_transaction}))-1 ;;
}
  measure: total_quantity_ordered {
    type:  sum
    sql: ${number_of_units};;
    drill_fields: [invoice_drill*]
  }

  measure: total_gross_profit {
    type:  sum
    sql: ${gross_profit};;
    value_format_name: usd_0
    drill_fields: [invoice_drill*]
  }

  measure: average_gross_profit_margin {
    type: number
    value_format_name: percent_1
    sql: (${total_value_of_transaction}/ nullifzero(${total_cost_of_parts})) - 1 ;;
    drill_fields: [invoice_drill*]
  }

  set: invoice_drill {
    fields: [market_region_xwalk.market_name
      , invoice_id_with_link_to_invoice
      , line_item_id
      , line_item_type
      , invoices.billing_approved_date
      , parts.part_number
      , part_types.description
      , number_of_units
      , amount
      , cogs
      , gross_profit
      , gross_profit_margin
      , approved_invoice_salespersons_itl.primary_salesperson_name
      , approved_invoice_salespersons_itl.secondary_salesperson_names
      , companies.customer_name
    ]
  }

  set: market_drill {
    fields: [market_region_xwalk.market_name
      , market_region_xwalk.dealership_y_n
      , total_cost_of_parts_drill
      , total_value_of_transaction_drill
      , total_gross_profit
    ]
  }
}

view: line_items_w_avg_cost_calculations {
  derived_table: {
    sql:
      select *
      from ${line_items_w_avg_cost.SQL_TABLE_NAME} AS line_items_w_avg_cost;;
  }

  dimension: line_item_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_amount_this_period {
    type: number
    value_format_name: usd
    sql: iff(${invoices.timeframes} = 'Period', ${amount}, 0) ;;
  }

  dimension: line_item_amount_previous_period {
    type: number
    value_format_name: usd
    sql: iff(${invoices.timeframes} = 'Previous Period', ${amount}, 0) ;;
  }

  dimension: line_item_number_of_units_this_period {
    type: number
    sql: iff(${invoices.timeframes} = 'Period', ${number_of_units}, 0) ;;
  }

  dimension: line_item_number_of_units_previous_period {
    type: number
    sql: iff(${invoices.timeframes} = 'Previous Period', ${number_of_units}, 0) ;;
  }

  measure: total_line_item_amount_this_period {
    type: sum
    value_format_name: usd
    sql: ${line_item_amount_this_period} ;;
  }

  measure: total_line_item_amount_previous_period {
    type: sum
    value_format_name: usd
    sql: ${line_item_amount_previous_period} ;;
  }

  measure: total_quantity_ordered_this_period {
    type:  sum
    sql: ${line_item_number_of_units_this_period};;
  }

  measure: total_quantity_ordered_previous_period {
    type:  sum
    sql: ${line_item_number_of_units_previous_period};;
  }

  measure: total_change_between_periods {
    type: number
    value_format_name: usd_0
    sql: ${total_line_item_amount_previous_period} - ${total_line_item_amount_this_period} ;;
    link: {
      label: "Parts Detail"
      url: "{{ parts._link }}"
    }
    link: {
      label: "Customer Detail"
      url: "{{ customer._link }}"
    }
  }

  measure: percent_change_between_periods {
    value_format_name: percent_2
    sql: iff(${total_change_between_periods} <=0, 0, (${total_line_item_amount_previous_period} - ${total_line_item_amount_this_period}) / ${total_line_item_amount_previous_period}) ;;
  }

  measure: parts {
    drill_fields: [providers.name
      , parts.part_number
      , parts.part_name
      , total_line_item_amount_previous_period
      , total_quantity_ordered_previous_period
      , total_line_item_amount_this_period
      , total_quantity_ordered_this_period
      , total_change_between_periods]
    hidden: yes
    sql: 1=1 ;;
  }

  measure: customer {
    drill_fields: [companies.name
      , total_line_item_amount_previous_period
      , total_line_item_amount_this_period
      , total_change_between_periods]
    hidden: yes
    sql: 1=1 ;;
  }

}
