
view: asset_inventory_status_duration {
  derived_table: {
    sql: select
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_id,
          mrx.market_type,
          ao.asset_id,
          askv.value as inventory_status,
          askv.value_timestamp as inventory_status_value_change,
          datediff(day,askv.value_timestamp,current_date) as days_since_status_change,
          coalesce(aa.oec,aph.oec) as oec,
          ec.name as equipment_class
      from
          es_warehouse.public.asset_status_key_values askv
          join analytics.bi_ops.asset_ownership ao on askv.asset_id = ao.asset_id
          join analytics.public.market_region_xwalk mrx on mrx.market_id = ao.market_id
          left join es_warehouse.public.assets_aggregate aa on ao.asset_id = aa.asset_id
          left join es_warehouse.public.asset_purchase_history aph on ao.asset_id = aph.asset_id
          join es_warehouse.public.assets a on ao.asset_id = a.asset_id
          left join es_warehouse.public.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
      where
          askv.name = 'asset_inventory_status'
          AND ao.ownership in ('ES','OWN')
          AND ao.rentable = TRUE ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${region_name},${market_name},${asset_id}) ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3 "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id}}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension_group: inventory_status_value_change {
    label: "Last Inventory Status Value Change"
    type: time
    sql: ${TABLE}."INVENTORY_STATUS_VALUE_CHANGE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: days_since_status_change {
    type: number
    sql: ${TABLE}."DAYS_SINCE_STATUS_CHANGE" ;;
  }

  dimension: asset_inventory_status_date_over_30_days {
    type: yesno
    sql: ${days_since_status_change} > 30 ;;
  }

  dimension: asset_inventory_status_date_over_3_days {
    type: yesno
    sql: ${days_since_status_change} > 3 ;;
  }

  dimension: asset_inventory_status_date_over_5_days {
    type: yesno
    sql: ${days_since_status_change} > 5 ;;
  }

  dimension: asset_inventory_status_date_over_90_days {
    type: yesno
    sql: ${days_since_status_change} > 90 ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  measure: total_assets_in_severe_soft_down_status {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Soft Down", asset_inventory_status_date_over_30_days: "YES"]
    drill_fields: [detail*]
  }

  measure: total_assets_in_severe_hard_down_status {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Hard Down", asset_inventory_status_date_over_30_days: "YES"]
    drill_fields: [detail*]
  }

  measure: total_assets_in_severe_needs_inspection_status {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Needs Inspection", asset_inventory_status_date_over_3_days: "YES"]
    drill_fields: [detail*]
  }


  measure: total_assets_in_pending_return_status {
    label: "Pending Return"
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Pending Return"]
    drill_fields: [detail*]
  }

  measure: total_assets_in_pending_return_status_over_five_days {
    label: "Pending Return 5+ Days"
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Pending Return", asset_inventory_status_date_over_5_days: "YES"]
    drill_fields: [detail*]
  }

  measure: total_assets_in_ready_to_rent_status_over_90_days {
    label: "Ready To Rent 90+ Days"
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [inventory_status: "Ready to Rent", asset_inventory_status_date_over_90_days: "YES"]
    drill_fields: [detail*]
  }

  measure: oec_measure {
    label: "OEC"
    type: sum
    sql: ${oec} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      asset_id,
      equipment_class,
      market_name,
      inventory_status,
      days_since_status_change,
      inventory_status_value_change_date,
      oec_measure
    ]
  }
}
