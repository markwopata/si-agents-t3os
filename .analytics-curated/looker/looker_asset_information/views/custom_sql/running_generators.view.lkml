
view: running_generators {
  derived_table: {
    sql: with all_generators as (
      select ap.ASSET_ID,
             ap.ASSET_INVENTORY_STATUS,
             ll.ADDRESS,
             ll.LAST_CHECKIN_TIMESTAMP
      from ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap
          left join ES_WAREHOUSE.PUBLIC.ASSET_LAST_LOCATION ll
          on ap.ASSET_ID = ll.ASSET_ID
      where MODEL like '%QAS%'
      ),
      currently_running_assets as (
      select
          ASSET_ID
      from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
      where NAME like 'engine_active' and VALUE like 'true'
      ),
      generator_kw_assets as (
      select ASSET_ID,
             VALUE as generator_kw_value
      from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
      where NAME like 'generator_total_percent_kw'
      ),
      diesel_exhaust_fluid_assets as (
      select ASSET_ID,
             VALUE as diesel_exhaust_value
      from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
      where NAME like 'diesel_exhaust_fluid_level'
      ),
      fuel_level_assets as (
      select ASSET_ID,
             VALUE as fuel_level_value
      from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
      where NAME like 'fuel_level'
      )
      select ag.asset_id,
             ag.address,
             ag.last_checkin_timestamp,
             case when gka.generator_kw_value is null then 'No Value' else cast(round(gka.generator_kw_value,0)as varchar) end as generator_kw_value_test,
             case when defa.diesel_exhaust_value is null then 'No Value' else cast(round(defa.diesel_exhaust_value,0)as varchar) end as diesel_exhaust_value,
             case when fla.fuel_level_value is null then 'No Value' else cast(round(fla.fuel_level_value,0)as varchar) end as fuel_level_value
      from all_generators ag
          left join currently_running_assets cra
          on ag.ASSET_ID = cra.ASSET_ID
          left join generator_kw_assets gka
          on cra.ASSET_ID = gka.ASSET_ID
          left join diesel_exhaust_fluid_assets defa
          on cra.ASSET_ID = defa.ASSET_ID
          left join fuel_level_assets fla
          on cra.ASSET_ID = fla.ASSET_ID
      where cra.ASSET_ID is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: address {
    type: string
    label: "Location"
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    label: "Last Checkin"
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: generator_kw_value_unformatted {
    type: string
    sql: ${TABLE}."GENERATOR_KW_VALUE_TEST";;
  }

  dimension: generator_kw_value {
    type: string
    label: "Gernerator Total KW"
    sql: ${generator_kw_value_unformatted} ;;
    html: {% if generator_kw_value_unformatted._value == 'No Value' %}
          {{generator_kw_value_unformatted._value}}
          {% else %}
          {{generator_kw_value_unformatted._value}}%
          {% endif %};;
  }

  dimension: diesel_exhaust_value_unformatted {
    type: string
    sql: ${TABLE}."DIESEL_EXHAUST_VALUE" ;;
  }

  dimension: diesel_exhaust_value {
    type: string
    label: "DEF Level"
    sql: ${diesel_exhaust_value_unformatted} ;;
    html: {% if diesel_exhaust_value_unformatted._value == 'No Value' %}
          {{diesel_exhaust_value_unformatted._value}}
          {% else %}
          {{diesel_exhaust_value_unformatted._value}}%
          {% endif %};;
  }

  dimension: fuel_level_value_unformatted {
    type: number
    sql: ${TABLE}."FUEL_LEVEL_VALUE" ;;
  }

  dimension: fuel_level_value {
    type: string
    label: "Fuel Level"
    sql: ${fuel_level_value_unformatted} ;;
    html: {% if fuel_level_value_unformatted._value == 'No Value' %}
          {{fuel_level_value_unformatted._value}}
          {% else %}
          {{fuel_level_value_unformatted._value}}%
          {% endif %};;
  }

  set: detail {
    fields: [
        asset_id,
  address,
  last_checkin_timestamp_time,
  generator_kw_value,
  diesel_exhaust_value,
  fuel_level_value
    ]
  }
}
