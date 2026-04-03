view: parts_by_make_model {
  derived_table: {
    sql: with wac_prep as (
    select
        wacs.*
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    qualify row_number()
        over (partition by wacs.inventory_location_id, wacs.product_id, date_applied order by wacs.date_created desc) = 1
    and max(date_applied)
        over (partition by wacs.PRODUCT_ID, INVENTORY_LOCATION_ID order by wacs.date_applied desc) = date_applied
    order by
        wacs.product_id,
        wacs.INVENTORY_LOCATION_ID,
        wacs.date_applied desc
)

,wac_final as (
    select
        k.part_master_id,
        avg(wp.WEIGHTED_AVERAGE_COST) avg_cost_master_cw
    from wac_prep wp
    join platform.gold.v_parts k -- superceded loop logic
        on wp.PRODUCT_ID = k.PART_ID
    join ES_WAREHOUSE.INVENTORY.PARTS p
        on wp.PRODUCT_ID = p.PART_ID
    where wp.WEIGHTED_AVERAGE_COST not in (0, 0.01)
    group by
        k.part_master_id
)

,avg_cost_per_part as (
    select
        p.part_master_id,
        sum(tran.amount) / sum(tran.quantity) as avg_cost_snap
    from ANALYTICS.PUBLIC.AVERAGE_COST_TRANSACTIONS tran
    join platform.gold.v_parts p
        on tran.CURRENT_PART_ID = p.part_id
    where tran.contribute_to_avg_flag = true --only want transaction types that are considered valid
    and tran.cost > 0--no part costs nothing, suppressing data entry errors
    and tran.cost is not null--no part costs nothing, suppressing data entry errors
    and tran.quantity > 0--if there's no quantity, there shouldn't be a transaction; i cannot divide by zero
    group by
        p.part_master_id
)

,work_orders as (
select
    wo.work_order_id,
    woct.company_tags,
    case
        when woo.originator_type_id = 3 then mgi.name
        when woct.company_tags ilike any (
            '% 32 %',  -- PM Service
            '% 31 %',  -- ANSI
            '% 40 %',  -- Make Ready
            '% 53 %',  -- Inspection completed
            '% 617 %', -- Cancelled Rental - Make Back Ready
            '% 626 %', -- Tire Rotation
            '% 846 %' -- DOT Inspection
        ) then 'Inspection'
        else 'Repair'
    end as originator,
    wo.asset_id
from es_warehouse.work_orders.work_orders wo -- originator type
left join es_warehouse.work_orders.work_order_originators woo
    using(work_order_id)
left join es_warehouse.public.maintenance_group_intervals mgi
    on woo.originator_id = mgi.maintenance_group_interval_id
left join (
            select
                work_order_id,
                listagg(concat(' ',company_tag_id,' '),',') as company_tags
            from es_warehouse.work_orders.work_order_company_tags
            group by work_order_id
            ) woct
    using(work_order_id)
where wo.date_created >= {% parameter wo_date %}
and wo.date_completed is not null
and wo.archived_date is null
)

,asset_count as (
select
    a.asset_equipment_category_name,
    a.asset_equipment_subcategory_name,
    a.asset_equipment_class_name,
    a.asset_equipment_make,
    a.asset_equipment_model_name,
    a.asset_year,
    count(distinct a.asset_id) as assets
from platform.gold.v_assets a
group by
    a.asset_equipment_category_name,
    a.asset_equipment_subcategory_name,
    a.asset_equipment_class_name,
    a.asset_equipment_make,
    a.asset_equipment_model_name,
    a.asset_year
)

select
    a.asset_equipment_category_name as category,
    a.asset_equipment_subcategory_name as sub_category,
    a.asset_equipment_class_name as class,
    a.asset_equipment_make as make,
    a.asset_equipment_model_name as model,
    a.asset_year as year,
    wo.work_order_id,
    wo.originator,
    p.part_master_id,
    p.part_master_number,
    p.part_master_name,
    p.part_provider_name as provider,
    p.part_msrp,
    coalesce(wf.avg_cost_master_cw,acpp.avg_cost_snap) as weighted_average_cost,
    ca.assets,
    sum(0 - po.quantity) as used
    -- iff(p.part_description ilike any ('%decal%','%label%','%fire ext%'),false,true) as remove_flag,
from platform.gold.v_assets a
left join asset_count ca
    using(asset_equipment_category_name,
    asset_equipment_subcategory_name,
    asset_equipment_class_name,
    asset_equipment_make,
    asset_equipment_model_name,
    asset_year)
left join work_orders wo
    using(asset_id)
left join analytics.intacct_models.part_inventory_transactions po
    using(work_order_id)
left join platform.gold.v_parts p
    using(part_id)
left join wac_final wf
    using(part_master_id)
left join avg_cost_per_part acpp
    using(part_master_id)
where po.transaction_type_id in (7,9)
group by
    a.asset_equipment_category_name,
    a.asset_equipment_subcategory_name,
    a.asset_equipment_class_name,
    a.asset_equipment_make,
    a.asset_equipment_model_name,
    a.asset_year,
    ca.assets,
    wo.work_order_id,
    wo.originator,
    p.part_master_id,
    p.part_master_number,
    p.part_master_name,
    p.part_provider_name,
    p.part_msrp,
    wf.avg_cost_master_cw,
    acpp.avg_cost_snap
having used is not null ;;
  }
  parameter: wo_date {
    type: date
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_MASTER_ID" ;;
    value_format_name: id
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_MASTER_NUMBER" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_MASTER_NAME" ;;
  }
  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }
  dimension: msrp {
    type: number
    sql: ${TABLE}."PART_MSRP" ;;
    value_format_name: usd
  }
  dimension: weighted_average_cost {
    type: number
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
    value_format_name: usd
  }
  dimension: assets {
    type: number
    sql: ${TABLE}."ASSETS" ;;
  }
  dimension: used {
    type: number
    sql: ${TABLE}."USED" ;;
  }
  measure: sum_used {
    type: sum
    sql: ${used} ;;
  }
}
