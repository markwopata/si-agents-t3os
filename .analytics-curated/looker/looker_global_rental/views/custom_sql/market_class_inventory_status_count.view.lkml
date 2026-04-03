view: market_class_inventory_status_count {
  derived_table: {
    sql:
    with asset_info as (
      select
        m.market_id,
        coalesce(ec.category_id, -1) as category_id,
        coalesce(a.asset_class, 'No Class Available') as asset_class,
        ais.asset_inventory_status,
        sum(coalesce(aa.oec,0)) as oec,
        count(*) as assetcount
      from ES_WAREHOUSE.PUBLIC.assets a
        left join ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
        left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
        left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on a.asset_id = ais.asset_id
        left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
      where
        ais.current_flag = 1
   --     and a.asset_type_id = 1
        and a.deleted = false
        and m.company_id = {{ _user_attributes['company_id'] }}
        and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
     --   and m.is_public_rsp = true
      group by
        m.market_id,
        ec.category_id,
        a.asset_class,
        ais.asset_inventory_status
      ),
      class_name as (
        select distinct coalesce(a.asset_class, 'No Class Available') as asset_class,
          '1' as flag
        from ES_WAREHOUSE.PUBLIC.assets a
              left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
        and m.company_id = {{ _user_attributes['company_id'] }}
      ),
      market_info as (
      select distinct
        m.market_id,
        m.name as market_name,
        '1' as flag
      from
        ES_WAREHOUSE.PUBLIC.markets m
        join ES_WAREHOUSE.PUBLIC.assets a on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
      where m.company_id = {{ _user_attributes['company_id'] }}
      ),
      market_asset_name as (
      select
        mi.market_id,
        mi.market_name,
        cn.asset_class
      from
        market_info mi
        join class_name cn on cn.flag = mi.flag
      )
      , class_name_has_asset_assigned as (
      select
        ma.asset_class,
        sum(assetcount) as ttl_assets_in_class
      from
        market_asset_name ma
        left join asset_info ai on ma.market_id = ai.market_id and ai.asset_class = ma.asset_class
      group by
        ma.asset_class
      )
      select
        ma.market_id,
        ma.market_name,
        ai.category_id,
        ma.asset_class,
        sum(case when ai.asset_inventory_status = 'On Rent' then assetcount else 0 end) as OnRentCount,
        sum(case when ai.asset_inventory_status = 'Ready To Rent' then assetcount else 0 end) as ReadyToRentCount,
        sum(case when ai.asset_inventory_status = 'Assigned' then assetcount else 0 end) as AssignedCount,
        sum(case when ai.asset_inventory_status IS NULL then assetcount else 0 end) as UnassignedCount,
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
        sum(case when ai.asset_inventory_status IS NULL then oec else 0 end) as UnassignedOEC,
        sum(case when ai.asset_inventory_status = 'Hard Down' then oec else 0 end) as HardDownOEC,
        sum(case when ai.asset_inventory_status = 'Make Ready' then oec else 0 end) as MakeReadyOEC,
        sum(case when ai.asset_inventory_status = 'Needs Inspection' then oec else 0 end) as NeedsInspectionOEC,
        sum(case when ai.asset_inventory_status = 'Pending Return' then oec else 0 end) as PendingReturnOEC,
        sum(case when ai.asset_inventory_status = 'Pre-Delivered' then oec else 0 end) as PreDeliveredOEC,
        sum(case when ai.asset_inventory_status = 'Soft Down' then oec else 0 end) as SoftDownOEC,
        sum(case when ai.asset_inventory_status = 'On RPO' then oec else 0 end) as OnRPOOEC
      from
        market_asset_name ma
        left join asset_info ai on ma.market_id = ai.market_id and ai.asset_class = ma.asset_class
        left join class_name_has_asset_assigned ca on ca.asset_class = ma.asset_class
      where
        ca.ttl_assets_in_class is not null
      group by
        ma.market_id,
        ma.market_name,
        ai.category_id,
        ma.asset_class
  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_class_pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${market_id}, '-', ${asset_class}) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
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

  dimension: unassignedcount {
    type: number
    sql: ${TABLE}."UNASSIGNEDCOUNT" ;;
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
    label: "Needs Inspection"
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

  dimension: unassignedoec {
    type: number
    sql: ${TABLE}."UNASSIGNEDOEC" ;;
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
    label: "On Rent"
    type: sum
    sql: ${onrentcount} ;;
  }

  measure: ready_to_rent_count {
    label: "Ready to Rent"
    type: sum
    sql: ${readytorentcount} ;;
  }

  measure: assigned_count {
    label: "Assigned"
    type: sum
    sql: ${assignedcount} ;;
  }

  measure: unassigned_count {
    label: "Unassigned"
    type: sum
    sql: ${unassignedcount} ;;
  }

  measure: hard_down_count {
    label: "Hard Down"
    type: sum
    sql: ${harddowncount} ;;
  }

  measure: make_ready_count {
    label: "Make Ready"
    type: sum
    sql: ${makereadycount} ;;
  }

  measure: needs_inspection_count {
    label: "Needs Inspection"
    type: sum
    sql: ${needsinspectioncount} ;;
  }

  measure: pending_return_count {
    label: "Pending Return"
    type: sum
    sql: ${pendingreturncount} ;;
  }

  measure: pre_delivered_count {
    label: "Pre-Delivered"
    type: sum
    sql: ${predeliveredcount} ;;
  }

  measure: soft_down_count {
    label: "Soft Down"
    type: sum
    sql: ${softdowncount} ;;
  }

  measure: on_rpo_count {
    label: "On RPO"
    type: sum
    sql: ${onrpocount} ;;
  }

  measure: total_asset_count {
    label: "Total Assets"
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

  measure: unassigned_oec {
    type: sum
    sql: ${unassignedoec} ;;
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
      asset_class,
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
