
view: asset_status_key_values_aggregate {
  derived_table: {
    sql:
    select a.equipment_class_id,
           a.market_id,
           count(iff(kv.value = 'Pending Return' or kv.value = 'Make Ready' or
                     kv.value = 'Needs Inspection' or kv.value = 'Soft Down' or
                     kv.value = 'Hard Down', 1,
                     NULL))                                                      count1,         -- "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down"
           count(iff(kv.value = 'Ready To Rent', 1, NULL))                       ready_to_rent,  -- "Ready To Rent"
           count(iff(kv.value = 'Soft Down' or kv.value = 'Hard Down', 1, NULL)) soft_hard_down, -- "Soft Down, Hard Down"
           count(iff(kv.value = 'On Rent', 1, NULL))                             on_rent,        -- "On Rent"
           count(iff(kv.value = 'On RPO', 1, NULL))                              on_rpo,         -- "On RPO"
           count(iff(kv.value = 'Assigned', 1, NULL))                            assigned,       -- "Assigned"
           count(*)                                                              total_assets,
           count(iff(kv.value = 'Pre-Delivered', 1, NULL))                       predelivered    -- "Pre-Delivered"
    from es_warehouse.public.asset_status_key_values kv
             left join es_warehouse.public.assets a on a.asset_id = kv.asset_id
    where kv.name = 'asset_inventory_status'
      and kv.value is not null
      and a.equipment_class_id is not null
      and kv.value is not null
      --and a.equipment_class_id = 3111
      and a.company_id = 1854
    group by a.equipment_class_id, a.market_id
      ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension: total_unavailable_assets{
    type: number
    description: "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down"
    sql: ${TABLE}.count1 ;;
  }

  dimension: down_eq {
    type: number
    sql: ${TABLE}.soft_hard_down ;;
  }

  dimension: on_rent {
    type: number
    sql: ${TABLE}.on_rent ;;
  }

  dimension: on_rpo {
    type: number
    sql: ${TABLE}.on_rpo ;;
  }

  dimension: assigned {
    type: number
    sql: ${TABLE}.assigned ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}.total_assets ;;
  }

  dimension: predelivered {
    type: number
    sql: ${TABLE}.predelivered ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: ready_to_rent {
    type: number
    sql: ${TABLE}.ready_to_rent ;;
  }

}
