view: missed_savings {
  derived_table: {
    sql:
with part_subs as (select part_id, part_family_id
from analytics.parts_inventory.part_substitutes
where isactive
    union
select sub_part_id as part_id, part_family_id
from analytics.parts_inventory.part_substitutes
    where isactive)
    , po_base as (
     select
    po.purchase_order_id,
      po.purchase_order_number,
      po.requesting_branch_id,
      m.market_region,
      po.created_by_id,
      po.date_created,
      p.part_id,
      p.part_number,
      p.part_name,
      ps.part_family_id,
      evs.EXTERNAL_ERP_VENDOR_REF as vendor_id,
      pov.name as vendor,
      poli.price_per_unit,
      poli.quantity,
      poli.price_per_unit * poli.quantity as extended_cost,
      poli.total_accepted,
      poli.purchase_order_line_item_id
    from procurement.public.purchase_orders po
      join procurement.public.purchase_order_line_items poli
      on po.purchase_order_id=poli.purchase_order_id
      and poli.date_archived is null
      join fleet_optimization.gold.dim_parts_fleet_opt p
      using(item_id)
      left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
      on po.vendor_ID = e.entity_ID
      left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
      on e.entity_ID = evs.entity_ID
      left join analytics.intacct.vendor pov
      on evs.EXTERNAL_ERP_VENDOR_REF = pov.vendorid
      left join platform.gold.v_markets m
      on po.requesting_branch_id = m.market_id
      left join part_subs ps
        on p.part_id=ps.part_id
      where zeroifnull(po.AMOUNT_APPROVED)> 1
    ) --select * from po_base where purchase_order_number = 1839502 and part_id=42572;
    ,min_region_wide as (
      select distinct
      part_id
      ,part_family_id
      ,market_region
      ,MIN(price_per_unit) over (partition by part_id, market_region) min_region_price
      ,first_value(vendor_id) over (partition by part_id, market_region order by price_per_unit asc)  min_region_vendor_id
      ,iff(part_family_id is null, null,min(price_per_unit) over (partition by part_family_id, market_region)) as min_region_price_sub
      ,iff(part_family_id is null, null,first_value(part_id) over (partition by part_family_id, market_region order by price_per_unit asc)) as min_region_sub_part_id
      ,iff(part_family_id is null, null,first_value(vendor_id) over (partition by part_family_id, market_region order by price_per_unit asc)) min_region_vendor_id_sub
      from po_base
     where price_per_unit>.01
      and total_accepted>0
      and date_created>= dateadd(day,-90,current_date())
      ) --select * from min_region_wide where part_id=42572;
      select
      po.purchase_order_id,
      po.purchase_order_number,
      po.purchase_order_line_item_id,
      po.requesting_branch_id,
      po.market_region,
      po.created_by_id,
      po.date_created,
      po.part_id,
      po.part_number,
      po.part_name,
      po.vendor_id,
      po.vendor,
      po.price_per_unit,
      po.quantity,
      po.extended_cost,
      mv.min_net_price,
      mv.min_net_vendor_id,
      npv.name min_net_vendor_name,
      mv.min_net_price_sub,
      mv.min_net_vendor_id_sub,
      mv.min_net_sub_part_id,
      mrw.min_region_price,
      mrw.min_region_vendor_id,
      mrw.min_region_price_sub,
      mrw.min_region_sub_part_id,
      mrw.min_region_vendor_id_sub,
      least_ignore_nulls(mv.min_net_price,mv.min_net_price_sub,mrw.min_region_price,mrw.min_region_price_sub) min_price,
      case when min_price =mv.min_net_price then mv.min_net_vendor_id
      when min_price=mv.min_net_price_sub then mv.min_net_vendor_id_sub
      when min_price=mrw.min_region_price then mrw.min_region_vendor_id
      when min_price=mrw.min_region_price_sub then mrw.min_region_vendor_id_sub
      end min_vendor_id,
      minv.name min_vendor_name,
      case when min_price =mv.min_net_price then 'Active Net Price'
      when min_price=mv.min_net_price_sub then 'Active Sub Net Price'
      when min_price=mrw.min_region_price then 'PO in Region Last 90 Days'
      when min_price=mrw.min_region_price_sub then 'Sub PO in Region Last 90 Days'
      end price_type,
      po.quantity * min_price as min_extended_cost,
      extended_cost - min_extended_cost as missed_savings
      from po_base po
      left join analytics.parts_inventory.daily_min_net_price mv
      on po.part_id=mv.part_id
      and po.date_created::date=mv.dt_date
      left join min_region_wide mrw
      on po.part_id=mrw.part_id
      and po.market_region=mrw.market_region
      join analytics.intacct.vendor minv
      on min_vendor_id = minv.vendorid
      and min_vendor_id!=po.vendor_id
      left join analytics.intacct.vendor npv
      on mv.min_net_vendor_id = npv.vendorid
      where missed_savings>.01
      ;;
  }
  filter: po_date {
    type: date
  }
  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: purchase_order_line_item_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."REQUESTING_BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
    value_format_name: id
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_NAME" ;;
  }
  dimension: po_vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: po_vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: po_price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format_name: usd
  }
  dimension: po_quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: po_extended_cost {
    type: number
    sql: ${TABLE}."EXTENDED_COST" ;;
    value_format_name: usd
  }
  dimension: min_vendor_id {
    type: string
    sql: ${TABLE}."MIN_VENDOR_ID" ;;
  }
  dimension: min_vendor {
    type: string
    sql: ${TABLE}."MIN_VENDOR_NAME" ;;
  }
  dimension: min_price {
    type: number
    sql: ${TABLE}."MIN_PRICE" ;;
    value_format_name: usd
  }
  # dimension: net_vs_cw_flag {
  #   label: "Net vs Region Flag"
  #   type: string
  #   sql: ${TABLE}."NET_VS_REGION_FLAG" ;;
  # }
  dimension: price_type {
    type: string
    sql: ${TABLE}."PRICE_TYPE" ;;
  }

  dimension: min_extended_cost {
    type: number
    sql: ${TABLE}."MIN_EXTENDED_COST" ;;
    value_format_name: usd
  }
  dimension: missed_savings {
    type: number
    sql: ${TABLE}."MISSED_SAVINGS" ;;
    value_format_name: usd
  }
  dimension: min_net_price {
    type: number
    sql: ${TABLE}."MIN_NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: min_net_vendor_name {
    type: string
    sql: ${TABLE}."MIN_NET_VENDOR_NAME" ;;
  }
  # dimension: same_vendor { --moved to the sql
  #   type: yesno
  #   sql: iff(${po_vendor_id} = ${min_vendor_id},true,false) ;;
  # }
  measure: sum_missed_savings {
    type: sum
    sql: ${missed_savings} ;;
    value_format_name: usd
    link: {
      label: "PO Detail"
      url: "{{ detail._link }}"
    }
    link: {
      label: "Subcategory Summary"
      url: "{{ category._link }}"
    }
  }

  measure: detail {
    drill_fields: [purchase_order_id,
      purchase_order_number,
      v_markets.market_name,
      users.full_name,
      date_created_date,
      part_number,
      part_description,
      po_vendor,
      po_quantity,
      po_price_per_unit,
      po_extended_cost,
      min_vendor,
      min_price,
      min_extended_cost,
      price_type,
      missed_savings,
      part_categorization_structure.subcategory]
    hidden: yes
    sql: 1=1 ;;
  }

  measure: category {
    drill_fields: [part_categorization_structure.subcategory,
      sum_missed_savings]
    hidden: yes
    sql: 1=1 ;;
  }
}

view: missed_savings_by_part_number {
  derived_table: {
    sql: with min_vendor as (
        SELECT
            np.part_id,
            p.part_number,
            MIN(np.net_price) AS min_net_price,
            MIN_BY(np.vendor_id, np.net_price) AS min_net_vendor_id,
            min_by(v.vendor_name, np.net_price) as min_net_vendor_name
        FROM ANALYTICS.PARTS_INVENTORY.NET_PRICE np
                 LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
                           ON np.part_id = p.part_id
                 LEFT JOIN analytics.PARTS_INVENTORY.TOP_VENDOR_MAPPING v
                            ON np.VENDOR_ID = v.VENDORID
        WHERE DATE(np.end_date) = '2999-01-01'
        GROUP BY
            np.part_id,
            p.part_number
          )

      ,min_region_wide as (
      select
      p.part_number,
      p.part_id,
      m.market_region,
      m.market_region_name,
      min_by(evs.EXTERNAL_ERP_VENDOR_REF,poli.price_per_unit) as min_cw_vendor_id,
      min_by(e.name,poli.price_per_unit) as min_cw_vendor_name,
      min(poli.price_per_unit) as min_cw_price,
      min_by(po.purchase_order_number,poli.price_per_unit) as po_no
      from procurement.public.purchase_orders po
      join procurement.public.purchase_order_line_items poli
      using(purchase_order_id)
      join es_warehouse.inventory.parts p
      using(item_id)
      left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
      on po.vendor_ID = e.entity_ID
      left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
      on e.entity_ID = evs.entity_ID
      left join platform.gold.v_markets m
      on po.requesting_branch_id = m.market_id
      where
      po.date_created>= dateadd(day,-90,current_date()) and
      zeroifnull(po.AMOUNT_APPROVED)> 1
      and poli.date_archived is null
      group by
      p.part_number, p.part_id,
      m.market_region, m.market_region_name
      )

      , min_company_wide as (
      select
      mrw.part_number,
      mrw.part_id,
      min_by(mrw.min_cw_vendor_id,mrw.min_cw_price) as min_cw_vendor_id,
      min_by(mrw.min_cw_vendor_name,mrw.min_cw_price) as min_cw_vendor_name,
      min(mrw.min_cw_price) as min_cw_price
      from min_region_wide mrw
      group by
      1,2)

      , min_company_wide_2 as (
      select cw.part_id
      , m.MARKET_REGION
      , iff(reg.MARKET_REGION is null, true, false) as company_wide_due_to_no_regional_purchase
      , coalesce(reg.min_cw_price, cw.min_cw_price) as min_price
      , coalesce(reg.min_cw_vendor_id, cw.min_cw_vendor_id) as min_vendor_id
      , coalesce(reg.min_cw_vendor_name, cw.min_cw_vendor_name) as min_vendor_name
      from min_company_wide cw
      join (select distinct market_region from PLATFORM.GOLD.DIM_MARKETS) m
      left join min_region_wide reg
      on cw.PART_ID = reg.PART_ID and m.MARKET_REGION = reg.MARKET_REGION)


      select p.part_id
      , v.min_net_price
      , v.min_net_vendor_id
      , v.min_net_vendor_name
      , cw.MARKET_REGION
      , cw.min_price
      , cw.min_vendor_id
      , cw.min_vendor_name
      , cw.company_wide_due_to_no_regional_purchase
      from es_warehouse.inventory.parts p
      left join min_vendor v using(part_id)
      left join min_company_wide_2 cw using(part_id)

      ;;
  }
  filter: po_date {
    type: date
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: min_net_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.min_net_price ;;
  }

  dimension: min_net_vendor_id {
    type: string
    sql: ${TABLE}.min_net_vendor_id ;;
  }

  dimension: min_net_vendor_name {
    type: string
    sql: ${TABLE}.min_net_vendor_name ;;
  }

  dimension: market_region {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_region ;;
  }

  dimension: default_market_region_flag {
    type: yesno
    sql: ${TABLE}.market_region = 0 ;;
  }

  dimension: min_po_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.min_price ;;
  }

  dimension: min_po_vendor_id {
    type: string
    sql: ${TABLE}.min_vendor_id ;;
  }

  dimension: min_po_vendor_name {
    type: string
    sql: ${TABLE}.min_vendor_name ;;
  }

}

view: part_min_net_price {
  derived_table: {
    sql:
WITH recent_part_prices AS (
    SELECT
        pit.part_id,
        evs.external_erp_vendor_ref AS vendor_id,
        pit.cost_per_item AS price_paid,
        pit.date_completed AS received_date,
        ROW_NUMBER() OVER (
            PARTITION BY pit.part_id, evs.external_erp_vendor_ref
            ORDER BY pit.date_completed DESC
            ) AS rn
    FROM analytics.intacct_models.part_inventory_transactions pit
             JOIN procurement.public.purchase_orders po
                  ON po.purchase_order_id = pit.purchase_order_id
             LEFT JOIN es_warehouse.purchases.entity_vendor_settings evs
                       ON po.vendor_id = evs.entity_id
    WHERE pit.transaction_type_id IN (21, 23)
      AND pit.date_cancelled IS NULL
      AND pit.quantity > 0
      AND po.status != 'ARCHIVED'
      AND po.date_archived IS NULL
),
     most_recent_vendor_price_paid AS (
         SELECT
             part_id,
             vendor_id,
             price_paid AS most_recent_price_paid,
             received_date AS most_recent_received_date
         FROM recent_part_prices
         WHERE rn = 1
     )
SELECT
    np.part_id,
    p.part_number,
    MIN(np.net_price) AS min_net_price,
    MIN_BY(np.vendor_id, np.net_price) AS min_net_vendor_id,
    MIN_BY(v.vendor_name, np.net_price) AS min_net_vendor_name,
    mv.most_recent_price_paid AS last_paid_price,
    mv.most_recent_received_date AS last_received_date
FROM analytics.parts_inventory.net_price np
         LEFT JOIN fleet_optimization.gold.dim_parts_fleet_opt p
                   ON np.part_id = p.part_id
         LEFT JOIN analytics.parts_inventory.top_vendor_mapping v
                   ON np.vendor_id = v.vendorid
         LEFT JOIN most_recent_vendor_price_paid mv
                   ON np.part_id = mv.part_id
                       AND np.vendor_id = mv.vendor_id
WHERE DATE(np.end_date) = '2999-01-01'
  AND v.vendor_name IS NOT NULL
  AND np.vendor_id IS NOT NULL
  AND np.net_price IS NOT NULL
GROUP BY
    np.part_id,
    p.part_number,
    mv.most_recent_price_paid,
    mv.most_recent_received_date
ORDER BY np.part_id;;
  }

  dimension: part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.part_id ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: min_net_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.min_net_price ;;
  }

  dimension: min_net_vendor_id {
    type: string
    sql: ${TABLE}.min_net_vendor_id ;;
  }

  dimension: min_net_vendor_name {
    type: string
    sql: ${TABLE}.min_net_vendor_name ;;
  }

  dimension: last_price_paid_from_min_vendor{
    type: number
    value_format_name: usd
    sql: ${TABLE}.last_paid_price ;;
  }

  dimension: most_recent_received_date_from_min_vendor {
    type: date
    sql: ${TABLE}.most_recent_received_date ;;
  }
}
