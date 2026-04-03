view: market_class_inventory_status_count {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with asset_info as (
      select
        m.market_id,
        ec.name,
        ec.category_id,
        ais.asset_inventory_status,
        sum(coalesce(aa.oec,0)) as oec,
        count(*) as assetcount
      from
        ES_WAREHOUSE.PUBLIC.assets a
        left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
        left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on a.asset_id = ais.asset_id
        left join ES_WAREHOUSE.PUBLIC.equipment_models em on em.equipment_model_id = a.equipment_model_id
        left join ES_WAREHOUSE.PUBLIC.equipment_classes_models_xref ecm on ecm.equipment_model_id  = em.equipment_model_id
        left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on ec.equipment_class_id = ecm.equipment_class_id
        left join ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
      where
        ais.current_flag = 1
        and a.asset_type_id = 1
        and a.deleted = false
        and m.company_id = 1854
        and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
        and a.rental_branch_id is not null
        and m.is_public_rsp = true
      group by
        m.market_id,
        ec.name,
        ec.category_id,
        ais.asset_inventory_status
      ),
      class_name as (
        select
          '1' as flag,
          name
        from ES_WAREHOUSE.PUBLIC.equipment_classes ec
      ),
      market_info as (
      select
        m.market_id,
        mrx.market_name,
        mrx.region_name,
        '1' as flag
      from
        ES_WAREHOUSE.PUBLIC.markets m
        join market_region_xwalk mrx on m.market_id = mrx.market_id
      ),
      market_asset_name as (
      select
        mi.market_id,
        mi.market_name,
        cn.name as class_name
      from
        market_info mi
        join class_name cn on cn.flag = mi.flag
      ),
      class_name_has_asset_assigned as (
      select
        ma.class_name,
        sum(assetcount) as ttl_assets_in_class
      from
        market_asset_name ma
        left join asset_info ai on ma.market_id = ai.market_id and ai.name = ma.class_name
      group by
        ma.class_name
      )
      select
        ma.market_id,
        ma.market_name,
        ma.class_name,
        ai.category_id,
        sum(case when ai.asset_inventory_status = 'On Rent' then assetcount else 0 end) as OnRentCount,
        sum(case when ai.asset_inventory_status = 'Ready To Rent' then assetcount else 0 end) as ReadyToRentCount,
        sum(case when ai.asset_inventory_status = 'Assigned' then assetcount else 0 end) as AssignedCount,
        sum(case when ai.asset_inventory_status = 'Hard Down' then assetcount else 0 end) as HardDownCount,
        sum(case when ai.asset_inventory_status = 'Make Ready' then assetcount else 0 end) as MakeReadyCount,
        sum(case when ai.asset_inventory_status = 'Needs Inspection' then assetcount else 0 end) as NeedsInspectionCount,
        sum(case when ai.asset_inventory_status = 'Pending Return' then assetcount else 0 end) as PendingReturnCount,
        sum(case when ai.asset_inventory_status = 'Pre-Delivered' then assetcount else 0 end) as PreDeliveredCount,
        sum(case when ai.asset_inventory_status = 'Soft Down' then assetcount else 0 end) as SoftDownCount,
        sum(case when ai.asset_inventory_status = 'On RPO' then assetcount else 0 end) as OnRPOCount,
        sum(case when ai.asset_inventory_status = 'On Rent' then oec else 0 end) as OnRentOEC,
        sum(case when ai.asset_inventory_status = 'Ready To Rent' then oec else 0 end) as ReadyToRentOEC,
        sum(case when ai.asset_inventory_status = 'Assigned' then oec else 0 end) as AssignedOEC,
        sum(case when ai.asset_inventory_status = 'Hard Down' then oec else 0 end) as HardDownOEC,
        sum(case when ai.asset_inventory_status = 'Make Ready' then oec else 0 end) as MakeReadyOEC,
        sum(case when ai.asset_inventory_status = 'Needs Inspection' then oec else 0 end) as NeedsInspectionOEC,
        sum(case when ai.asset_inventory_status = 'Pending Return' then oec else 0 end) as PendingReturnOEC,
        sum(case when ai.asset_inventory_status = 'Pre-Delivered' then oec else 0 end) as PreDeliveredOEC,
        sum(case when ai.asset_inventory_status = 'Soft Down' then oec else 0 end) as SoftDownOEC,
        sum(case when ai.asset_inventory_status = 'On RPO' then oec else 0 end) as OnRPOOEC
      from
        market_asset_name ma
        left join asset_info ai on ma.market_id = ai.market_id and ai.name = ma.class_name
        left join class_name_has_asset_assigned ca on ca.class_name = ma.class_name
      where
        ca.ttl_assets_in_class is not null
      group by
        ma.market_id,
        ma.market_name,
        ma.class_name,
        ai.category_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_class_pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${market_id}, '-', ${class_name}) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}."CLASS_NAME" ;;
  }

  dimension: category_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: onrentcount {
    type: number
    sql: ${TABLE}."ONRENTCOUNT" ;;
  }

  dimension: readytorentcount {
    type: number
    sql: ${TABLE}."READYTORENTCOUNT" ;;
  }

  dimension: assignedcount {
    type: number
    sql: ${TABLE}."ASSIGNEDCOUNT" ;;
  }

  dimension: harddowncount {
    type: number
    sql: ${TABLE}."HARDDOWNCOUNT" ;;
  }

  dimension: makereadycount {
    type: number
    sql: ${TABLE}."MAKEREADYCOUNT" ;;
  }

  dimension: needsinspectioncount {
    type: number
    sql: ${TABLE}."NEEDSINSPECTIONCOUNT" ;;
  }

  dimension: pendingreturncount {
    type: number
    sql: ${TABLE}."PENDINGRETURNCOUNT" ;;
  }

  dimension: predeliveredcount {
    type: number
    sql: ${TABLE}."PREDELIVEREDCOUNT" ;;
  }

  dimension: softdowncount {
    type: number
    sql: ${TABLE}."SOFTDOWNCOUNT" ;;
  }

  dimension: onrpocount {
    type: number
    sql: ${TABLE}."ONRPOCOUNT" ;;
  }

  dimension: onrentoec {
    type: number
    sql: ${TABLE}."ONRENTOEC" ;;
  }

  dimension: readytorentoec {
    type: number
    sql: ${TABLE}."READYTORENTOEC" ;;
  }

  dimension: assignedoec {
    type: number
    sql: ${TABLE}."ASSIGNEDOEC" ;;
  }

  dimension: harddownoec {
    type: number
    sql: ${TABLE}."HARDDOWNOEC" ;;
  }

  dimension: makereadyoec {
    type: number
    sql: ${TABLE}."MAKEREADYOEC" ;;
  }

  dimension: needsinspectionoec {
    type: number
    sql: ${TABLE}."NEEDSINSPECTIONOEC" ;;
  }

  dimension: pendingreturnoec {
    type: number
    sql: ${TABLE}."PENDINGRETURNOEC" ;;
  }

  dimension: predeliveredoec {
    type: number
    sql: ${TABLE}."PREDELIVEREDOEC" ;;
  }

  dimension: softdownoec {
    type: number
    sql: ${TABLE}."SOFTDOWNOEC" ;;
  }

  dimension: onrpooec {
    type: number
    sql: ${TABLE}."ONRPOOEC" ;;
  }

  measure: on_rent_count {
    type: sum
    sql: ${onrentcount} ;;
  }

  measure: ready_to_rent_count {
    type: sum
    sql: ${readytorentcount} ;;
  }

  measure: assigned_count {
    type: sum
    sql: ${assignedcount} ;;
  }

  measure: hard_down_count {
    type: sum
    sql: ${harddowncount} ;;
  }

  measure: make_ready_count {
    type: sum
    sql: ${makereadycount} ;;
  }

  measure: needs_inspection_count {
    type: sum
    sql: ${needsinspectioncount} ;;
  }

  measure: pending_return_count {
    type: sum
    sql: ${pendingreturncount} ;;
  }

  measure: pre_delivered_count {
    type: sum
    sql: ${predeliveredcount} ;;
  }

  measure: soft_down_count {
    type: sum
    sql: ${softdowncount} ;;
  }

  measure: on_rpo_count {
    type: sum
    sql: ${onrpocount} ;;
  }

  measure: total_asset_count {
    type: sum
    sql: ${onrentcount}+${readytorentcount}+${assignedcount}+${harddowncount}+${makereadycount}+${needsinspectioncount}+${pendingreturncount}+${predeliveredcount}+${softdowncount}+${onrpocount} ;;
  }

  measure: on_rent_oec {
    type: sum
    sql: ${onrentoec} ;;
    value_format_name: usd_0
  }

  measure: ready_to_rent_oec {
    type: sum
    sql: ${readytorentoec} ;;
    value_format_name: usd_0
  }

  measure: assigned_oec {
    type: sum
    sql: ${assignedoec} ;;
    value_format_name: usd_0
  }

  measure: hard_down_oec {
    type: sum
    sql: ${harddownoec} ;;
    value_format_name: usd_0
  }

  measure: make_ready_oec {
    type: sum
    sql: ${makereadyoec} ;;
    value_format_name: usd_0
  }

  measure: needs_inspection_oec {
    type: sum
    sql: ${needsinspectionoec} ;;
    value_format_name: usd_0
  }

  measure: pending_return_oec {
    type: sum
    sql: ${pendingreturnoec} ;;
    value_format_name: usd_0
  }

  measure: pre_delivered_oec {
    type: sum
    sql: ${predeliveredoec} ;;
    value_format_name: usd_0
  }

  measure: soft_down_oec {
    type: sum
    sql: ${softdownoec} ;;
    value_format_name: usd_0
  }

  measure: on_rpo_oec {
    type: sum
    sql: ${onrpooec} ;;
    value_format_name: usd_0
  }

  measure: total_asset_oec {
    type: sum
    sql: ${onrentoec}+${readytorentoec}+${assignedoec}+${harddownoec}+${makereadyoec}+${needsinspectionoec}+${pendingreturnoec}+${predeliveredoec}+${softdownoec}+${onrpooec} ;;
    value_format_name: usd_0
  }

  measure: assets_considered_on_rent {
    type: sum
    sql: ${onrentcount}+${onrpocount} ;;
  }

  measure: count_utilization {
    type: number
    sql: ${assets_considered_on_rent} / case when ${total_asset_count} = 0 then null else ${total_asset_count} end ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      class_name,
      category_id,
      onrentcount,
      readytorentcount,
      assignedcount,
      harddowncount,
      makereadycount,
      needsinspectioncount,
      pendingreturncount,
      predeliveredcount,
      softdowncount,
      onrpocount,
      onrentoec,
      readytorentoec,
      assignedoec,
      harddownoec,
      makereadyoec,
      needsinspectionoec,
      pendingreturnoec,
      predeliveredoec,
      softdownoec,
      onrpooec
    ]
  }
}
