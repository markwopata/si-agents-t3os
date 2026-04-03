view: sub_part_procurement_comparison {
  derived_table: {
    sql: with parts_ordered as (
select
    p.part_master_id,
    ven.vendor_id,
    ven.vendor_name,
    ven.mapped_vendor_name,
    sum(poli.quantity) as purchase_quantity
from procurement.public.purchase_orders po
join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
join es_warehouse.inventory.parts pa
    on poli.item_id = pa.item_id
JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
    on po.vendor_ID = e.entity_ID
join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
    on e.entity_ID = evs.entity_ID
join (  select
            tvm.vendorid as vendor_id,
            tvm.vendor_name,
            tvm.mapped_vendor_name,
            tm.vendorid
        from analytics.parts_inventory.top_vendor_mapping tvm
        left join analytics.parts_inventory.top_vendor_mapping tm
            using(mapped_vendor_name)
        where tvm.primary_vendor = 'YES') ven
    on evs.EXTERNAL_ERP_VENDOR_REF = ven.vendorid
left join (select part_id,sub_part_id,sub_provider_name from analytics.parts_inventory.part_substitutes) sp
    on ven.mapped_vendor_name ilike concat('%',sp.sub_provider_name,'%')
    and pa.part_id = sp.part_id
join platform.gold.v_parts p
    on coalesce(sp.sub_part_id,pa.part_id) = p.part_id
where  date(po.date_created) between {% date_start date_filter %} and {% date_end date_filter %}
and po.date_archived is null
and poli.date_archived is null
group by
    p.part_master_id,
    ven.vendor_id,
    ven.vendor_name,
    ven.mapped_vendor_name
)

,net_price_prep as (
select
    part_id,
    vendor_id,
    net_price,
    end_date,
    lag(net_price) over (partition by part_id,vendor_id order by end_date) as previous_net_price
from analytics.parts_inventory.net_price
)

,final as (
select
    p.part_master_id as part_id,
    p.part_number,
    p.part_name as part_description,
    p.part_provider_id,
    p.part_provider_name as provider_name,
    po.vendor_id,
    po.vendor_name,
    po.mapped_vendor_name,
    p.part_msrp as msrp,
    np.net_price,
    np.previous_net_price,
    p.part_id||po.vendor_id pkey,
    po.purchase_quantity
from platform.gold.v_parts p
left join parts_ordered po
    on p.part_id = po.part_master_id
left join net_price_prep np
    on p.part_master_id = np.part_id
    and np.end_date > current_date
    and po.vendor_id = np.vendor_id
)

select
    f.part_id,
    f.part_number,
    f.part_description,
    f.provider_name,
    f.vendor_name,
    case
        when f.mapped_vendor_name ilike concat('%',f.provider_name,'%') or f.provider_name ilike concat('%',f.mapped_vendor_name,'%') then true
        when f.vendor_name is null then true
        else false
    end as oem,
    f.net_price,
    f.previous_net_price,
    f.msrp,
    f.purchase_quantity,
    fm.part_id as sub_part_id,
    fm.part_number as sub_part_number,
    fm.part_description as sub_part_description,
    fm.provider_name as sub_provider_name,
    sp.substitution_type,
    fm.vendor_name as sub_vendor_name,
    fm.net_price as sub_net_price,
    fm.previous_net_price as sub_previous_net_price,
    fm.msrp as sub_msrp,
    fm.purchase_quantity as sub_purchase_quantity
from final f
left join analytics.parts_inventory.part_substitutes sp
    on f.part_id = sp.part_id
left join final fm
    on sp.sub_part_id = fm.part_id;;
  }
  filter: date_filter {
    type: date
  }
  dimension: oem {
    type: yesno
    sql: ${TABLE}."OEM" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_DESCRIPTION" ;;
  }
  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: previous_net_price {
    type: number
    sql: ${TABLE}."PREVIOUS_NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
    value_format_name: usd
  }
  dimension: purchase_quantity {
    type: number
    sql: ${TABLE}."PURCHASE_QUANTITY" ;;
  }
  dimension: sub_part_id {
    type: number
    sql: ${TABLE}."SUB_PART_ID" ;;
    value_format_name: id
  }
  dimension: sub_part_number {
    type: string
    sql: ${TABLE}."SUB_PART_NUMBER" ;;
  }
  dimension: sub_part_description {
    type: string
    sql: ${TABLE}."SUB_PART_DESCRIPTION" ;;
  }
  dimension: sub_provider {
    type: string
    sql: ${TABLE}."SUB_PROVIDER_NAME" ;;
  }
  dimension: substitution_type {
    type: string
    sql: ${TABLE}."SUBSTITUTION_TYPE" ;;
  }
  dimension: sub_vendor {
    type: string
    sql: ${TABLE}."SUB_VENDOR_NAME" ;;
  }
  dimension: sub_net_price {
    type: number
    sql: ${TABLE}."SUB_NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: sub_previous_net_price {
    type: number
    sql: ${TABLE}."SUB_PREVIOUS_NET_PRICE" ;;
    value_format_name: usd
  }
  dimension: sub_msrp {
    type: number
    sql: ${TABLE}."SUB_MSRP" ;;
    value_format_name: usd
  }
  dimension: sub_purchase_quantity {
    type: number
    sql: ${TABLE}."SUB_PURCHASE_QUANTITY" ;;
  }
}
