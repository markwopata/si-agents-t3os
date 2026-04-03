{{ config(
    materialized='table'
    , cluster_by=['po_date_created']
) }}

with po_items as (select
        po.purchase_order_number,
        po.purchase_order_id,
        case
          when it.item_type = 'INVENTORY' then 'A1301 - Equipment Parts Inventory'
          when it.item_type = 'NON_INVENTORY'then nit.name
        end as item_service,
        count(*) as item_service_count
      from
        {{ ref("platform", "procurement_purchase_orders") }} po
        left join {{ ref("platform", "purchase_order_line_items") }} li on po.purchase_order_id = li.purchase_order_id
        left join {{ ref("platform", "items") }} it on it.item_id = li.item_id
        left join {{ ref("platform", "non_inventory_items") }} nit on nit.item_id = li.item_id
       where
          po.date_archived is null
          AND li.date_archived is null
      group by
        1,2,3
      order by po.purchase_order_number desc
       )
      , market_open_date as (
      select
          child_market_id as market_id
        , branch_earnings_start_month
        , ifnull(datediff(months, branch_earnings_start_month, DATEADD('day', -29, CURRENT_DATE())::timestamp_ntz),0) as month_since_open
        , iff(month_since_open >= 12, true, false) as open_more_than_12_months
        from {{ ref("platform","analytics__branch_earnings__market")}}
      )
      ,
    po_spend_info as (
      select
          po.purchase_order_number,
          po.reference,
          du.user_full_name as created_by,
          e.name as vendor,
          coalesce(tvm.PREFERRED, 'No') as PREFERRED,
          po.date_created::date as po_date_created,
          dm.market_name as cost_center,
          dm.market_region_name as region_name,
          dm.market_district as district,
          dm.market_type,
          po.purchase_order_id,
          sum(li.quantity*li.price_per_unit) as total_po_cost,
          MAX(r.date_received) as date_received,
          max(li.description) as line_item_description
      from
          {{ ref("platform", "procurement_purchase_orders") }} po
          left join {{ ref("platform", "purchase_order_line_items") }} li on po.purchase_order_id = li.purchase_order_id
          left join {{ ref("platform", "dim_markets") }} dm on dm.market_id = po.requesting_branch_id
          left join {{ ref("platform", "dim_users") }} du on du.user_id = po.created_by_id
          left join {{ ref("platform", "entities") }} e on po.vendor_id = e.entity_id
          left join {{ ref("platform", "entity_vendor_settings") }} vend on po.vendor_id = vend.entity_id
          left join {{ ref("platform", "top_vendor_mapping") }} tvm on tvm.vendorid = vend.external_erp_vendor_ref
          left join market_open_date mod on mod.market_id = dm.market_id
          left join {{ ref("platform", "items") }} it on it.item_id = li.item_id
          left join {{ ref("platform", "non_inventory_items") }} nit on nit.item_id = li.item_id
          left join {{ ref("platform", "purchase_order_receiver_items") }} ri on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
          left join {{ ref("platform", "purchase_order_receivers") }} r on r.purchase_order_receiver_id = ri.purchase_order_receiver_id
      where
          po.date_archived is null
          AND li.date_archived is null
          AND dm.market_company_id = 1854
      group by
          po.purchase_order_number,
          po.reference,
          du.user_full_name,
          e.name,
          coalesce(tvm.PREFERRED, 'No'),
          po.date_created::date,
          dm.market_name,
          dm.market_region_name,
          dm.market_district,
          dm.market_type,
          po.purchase_order_id
      having sum(li.quantity*li.price_per_unit) >= 5000
      )
      select
          psi.purchase_order_number,
          psi.reference,
          psi.created_by,
          psi.vendor,
          psi.PREFERRED,
          psi.po_date_created,
          psi.cost_center,
          psi.purchase_order_id,
          psi.total_po_cost,
          pi.item_service,
          pi.item_service_count,
          psi.date_received,
          psi.line_item_description,
          psi.market_type,
          psi.region_name,
          psi.district
      from
          po_spend_info psi
      inner join po_items pi on pi.purchase_order_id = psi.purchase_order_id
