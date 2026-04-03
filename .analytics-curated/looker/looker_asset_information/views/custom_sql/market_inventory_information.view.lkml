view: market_inventory_information {
  derived_table: {
    # datagroup_trigger: Every_5_Min_Update
    sql:
    with inventory_info as(
    select
          m.market_id,
          v.value as asset_inventory_status,
          count(a.ASSET_ID) as total_units,
          sum(a.oec) as oec
        from
          ES_WAREHOUSE.PUBLIC.assets_aggregate a
          left join ES_WAREHOUSE.PUBLIC.assets aa on aa.asset_id = a.asset_id
          left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(aa.rental_branch_id, aa.inventory_branch_id) = m.market_id
          left join es_warehouse.public.asset_status_key_values v on a.asset_id = v.asset_id and v.name = 'asset_inventory_status'
          left join market_region_xwalk mr on m.market_id = mr.market_id
          left join ES_WAREHOUSE.PUBLIC.asset_purchase_history aph on a.asset_id = aph.asset_id
        where
          m.company_id = 1854
          and (LEFT(a.serial_number, 2) <> 'RR' and LEFT(a.custom_name, 2) <> 'RR' and a.company_id <> 11606)
          and m.is_public_rsp = true
          and aa.deleted = false
          --and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
       group by
          m.market_id,
          v.value),
    market_info as (
        select
          mr.region,
          mr.region_name,
          mr.district,
          mr.region_district,
          m.name as market_name,
          m.market_id,
          '1' as flag
      from
        ES_WAREHOUSE.PUBLIC.markets m
        join market_region_xwalk mr on m.market_id = mr.market_id
      )
      select
          m.region,
          m.region_name,
          m.district,
          m.region_district,
          m.market_name,
          m.market_id,
          i.asset_inventory_status,
          sum(i.total_units) as total_units,
          sum(i.oec) as oec
      from inventory_info i
      left join market_info m on m.MARKET_ID = i.MARKET_ID
      group by m.region, m.region_name, m.district, m.region_district, m.market_name, m.market_id, i.asset_inventory_status

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: total_units {
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  measure: total_number_of_units {
    type: sum
    sql: ${total_units} ;;
    # link: {
    #   label: "View Inventory Information Dashboard"
    #   url: "https://equipmentshare.looker.com/dashboards/27?Equipment%20Category=&Equipment%20Class=&Inventory%20Status={{ asset_inventory_status._value | url_encode }}&Market={{ _filters['market_name'] | url_encode }}&Region={{ _filters['market_inventory_information.region_name'] | url_encode }}&District={{ _filters['market_inventory_information.district'] | url_encode }}&"
    # }
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
    link: {
      label: "View Inventory Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/27?Equipment%20Category=&Equipment%20Class=&Inventory%20Status={{ asset_inventory_status._value | url_encode }}&Market={{ _filters['market_name'] | url_encode }}&Region={{ _filters['market_inventory_information.region_name'] | url_encode }}&District={{ _filters['market_inventory_information.district'] | url_encode }}&"
    }
  }

  measure: total_oec_no_link {
    type: sum
    sql: ${oec} ;;
  }

  measure: total_oec_on_Rent {
    type: sum
    filters: [asset_inventory_status: "On Rent"]
    sql: ${oec} ;;

  }

  set: detail {
    fields: [
      region,
      region_name,
      district,
      market_name,
      market_id,
      asset_inventory_status,
      total_units,
      oec
    ]
  }
}
