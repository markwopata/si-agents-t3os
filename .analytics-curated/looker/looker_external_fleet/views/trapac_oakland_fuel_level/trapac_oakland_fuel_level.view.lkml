view: trapac_oakland_fuel_level {
  derived_table: {
    sql: with asset_list as (
      select asset_id
      from table(assetlist(29167::numeric))
      union
      select asset_id
      from table(rental_asset_list(29167::numeric,
      convert_timezone('UTC', 'America/Los_Angeles', current_timestamp::date::timestamp_ntz),
      convert_timezone('UTC', 'America/Los_Angeles',  current_timestamp::date::timestamp_ntz),
      'America/Los_Angeles'))
      )
      select
        a.custom_name as asset,
        value as fuel_level
      from
        asset_list al
        inner join asset_status_key_values akv on al.asset_id = akv.asset_id
        join assets a on al.asset_id = a.asset_id
      where
        akv.name = 'fuel_level'
        and akv.value is not null
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: fuel_level {
    type: string
    sql: ${TABLE}."FUEL_LEVEL" ;;
    html: {{rendered_value}}% ;;
  }

  set: detail {
    fields: [asset, fuel_level]
  }
}
