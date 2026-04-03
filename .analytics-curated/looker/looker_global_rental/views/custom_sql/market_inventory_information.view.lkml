view: market_inventory_information {
  derived_table: {
    sql:  select a.asset_id, initcap(aty.name) as asset_type, a.asset_class, c.name as asset_owner,
            m.name as market_name,
            coalesce(a.rental_branch_id, a.inventory_branch_id) as branch_id,
            ais.asset_inventory_status,
            coalesce(aph.oec, aph.purchase_price) as oec
          from ES_WAREHOUSE.PUBLIC.assets a
            left join ES_WAREHOUSE.PUBLIC.markets m on a.rental_branch_id = m.market_id
            left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on a.asset_id = ais.asset_id
            left join ES_WAREHOUSE.PUBLIC.asset_purchase_history aph on a.asset_id = aph.asset_id
            left join ES_WAREHOUSE.PUBLIC.companies c on a.company_id = c.company_id
            left join ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
          where
            ais.current_flag = 1
    --        and a.asset_type_id = 1
            and a.deleted = false
            and m.company_id = {{ _user_attributes['company_id'] }}
            and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
            and a.available_for_rent = true
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }

  measure: total_number_of_units {
    type: count
    drill_fields: [detail*]
    # link: {
    #   label: "View Inventory Information Dashboard"
    #   url: "https://equipmentshare.looker.com/dashboards/27?Equipment%20Category=&Equipment%20Class=&Inventory%20Status={{ asset_inventory_status._value | url_encode }}&Market={{ _filters['market_name'] | url_encode }}&Region={{ _filters['market_inventory_information.region_name'] | url_encode }}&District={{ _filters['market_inventory_information.district'] | url_encode }}&"
    # }
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
    drill_fields: [detail*]

    # link: {
    #   label: "View Inventory Information Dashboard"
    #   url: "https://equipmentshare.looker.com/dashboards/27?Equipment%20Category=&Equipment%20Class=&Inventory%20Status={{ asset_inventory_status._value | url_encode }}&Market={{ _filters['market_name'] | url_encode }}&Region={{ _filters['market_inventory_information.region_name'] | url_encode }}&District={{ _filters['market_inventory_information.district'] | url_encode }}&"
    # }
  }

  set: detail {
    fields: [
      asset_id,
      asset_class,
      asset_owner,
      market_name,
      asset_inventory_status,
      oec
    ]
  }
}
