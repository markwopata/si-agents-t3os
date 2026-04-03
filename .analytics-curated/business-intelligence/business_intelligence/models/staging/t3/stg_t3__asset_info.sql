{{ config(
    materialized='table'
    , cluster_by=[ 'asset_id', 'company_id']
) }}

select distinct
          a.asset_id,
          'Owned' as ownership,
          a.company_id, 
          a.custom_name as asset,
          a.custom_name,
          a.equipment_class_id,
          a.asset_class,
          m.name as branch, 
          ms.name as service_branch,
          a.make,
          a.model,
          a.equipment_model_id,
          coalesce(a.serial_number,a.vin) as serial_number_vin,
          a.serial_number,
          a.vin,
          d.dot_number,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
          tm.tracker_grouping as tracker_grouping,
          tm.tracker_model,
          tm.serial_vin as tracker_device_serial,
          tm.tracker_id as tracker_tracker_id,
          tm.tracker_id as esdb_tracker_id,
          a.driver_name,
          a.license_plate_number, 
          a.license_plate_state,
          a.INVENTORY_BRANCH_ID,
          case when odo.name = 'odometer' then odo.value end as odometer,
          case when h.name = 'hours' then h.value end as hours,
          case when (datediff(hours,lc.last_location_timestamp,current_timestamp) <= 72) then 'Yes'
          else 'No' end as contact_in_72_hours,
          mg.name as maintenance_group_name
          , coalesce(cat.name, case when ast.name is not null then null else 'Bulk Items' end) as category
          , cat.category_id as category_id
          , coalesce(cp2.name, case when ast.name is not null then null else 'Bulk Items' end) as parent_category
          , cp2.category_id as parent_category_id
          , CURRENT_TIMESTAMP()::timestamp_ntz AS data_refresh_timestamp
          from {{ ref('platform', 'es_warehouse__public__assets') }} a
          left join {{ ref('platform', 'es_warehouse__public__asset_types') }} ast on ast.asset_type_id = a.asset_type_id
          left join {{ ref('platform', 'es_warehouse__public__categories') }} cat on cat.category_id = a.category_id
          left join {{ ref('platform', 'es_warehouse__public__markets') }} m on m.market_id = a.inventory_branch_id
          left join {{ ref('platform', 'es_warehouse__public__markets') }} ms on ms.market_id = a.service_branch_id
          left join business_intelligence.triage.stg_t3__telematics_health tm on tm.asset_id = a.asset_id
          left join (select asset_id, value as last_location_timestamp from {{ ref('platform', 'es_warehouse__public__asset_status_key_values') }} where name = 'last_location_timestamp') lc on lc.asset_id = a.asset_id
          left join es_warehouse.public.maintenance_groups mg on mg.maintenance_group_id = a.maintenance_group_id
          left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
          left join es_warehouse.public.equipment_classes_models_xref emx on emx.equipment_model_id = em.equipment_model_id
          left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = emx.equipment_class_id
          left join es_warehouse.public.asset_status_key_values odo on odo.asset_id = a.asset_id and odo.name = 'odometer'
          left join es_warehouse.public.asset_status_key_values h on h.asset_id = a.asset_id and h.name = 'hours'
          left join es_warehouse.public.categories cc on ec.category_id = cc.category_id AND cc.parent_category_id is not null
          left join es_warehouse.public.categories cp ON cc.parent_category_id = cp.category_id AND cc.category_id = ec.category_id AND cp.parent_category_id is null

           -- below es.p.categories joins are for missing categories / parent categories which are not caught in the above joins
           -- however the below structure is a worse solution overall, so instead we are using it with a coalesce
           -- previous asset ids with mismatched categories: (339099, 402207)
          left join es_warehouse.public.categories cc2 on a.category_id = cc2.category_id AND cc2.parent_category_id is not null
          left join es_warehouse.public.categories cp2 ON cc2.parent_category_id = cp2.category_id AND cc2.category_id = a.category_id AND cp2.parent_category_id is null
            
          left join es_warehouse.public.company_dot_numbers d on a.dot_number_id = d.dot_number_id
          where
          a.deleted = false
          --  and cc.date_deactivated is null
          and a.asset_id is not null
