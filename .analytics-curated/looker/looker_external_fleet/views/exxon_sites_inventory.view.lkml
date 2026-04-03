view: exxon_sites_inventory {
  derived_table: {
    sql: select
        a.asset_id,
        a.custom_name as asset,
        m.name as branch,
        askv.status as asset_status,
        cat.name as category_name,
        a.asset_class,
        a.make,
        a.model,
        coalesce(a.serial_number,a.vin) as serial_number_or_vin
      from
        assets a
        join markets m on a.rental_branch_id = m.market_id
        left join (select asset_id, value as status from asset_status_key_values where name = 'asset_inventory_status') askv on askv.asset_id = a.asset_id
        left join categories cat on a.category_id = cat.category_id
      where
        m.market_id in (48698, 44834, 44836)
        and a.deleted = 'FALSE'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number_or_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_OR_VIN" ;;
  }

  set: detail {
    fields: [
      asset_id,
      asset,
      branch,
      asset_status,
      category_name,
      asset_class,
      make,
      model,
      serial_number_or_vin
    ]
  }
}
