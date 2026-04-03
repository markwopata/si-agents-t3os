view: stargate_top_assets {
  derived_table: {
    sql:
      select
          iah.daily_timestamp,
          iah.asset_id,
          iah.market_name,
          iah.equipment_class,
          iah.make,
          iah.model,
          iah.year,
          ia.serial_number_or_vin,
          iah.category,
          ia.description,
          e.horsepower,
          e.weight_lbs,
          aes.engine_model_name,
          em.engine_make_name,
          aes.engine_serial_number,
          iah.oec
      from analytics.assets.int_asset_historical as iah
          inner join analytics.assets.int_assets as ia
              on iah.asset_id = ia.asset_id
          left join taxes.charges.equipment as e
              on ia.equipment_model_id = e.model_id
          left join
              analytics.intacct_models.stg_es_warehouse_public__asset_engine_specification as aes
              on ia.asset_id = aes.asset_id
          left join
              analytics.intacct_models.stg_es_warehouse_public__engine_makes as em
              on aes.engine_make_id = em.engine_make_id
      where iah.market_id in (
              -- Stargate Abilene
              155559, -- Tooling Onsite
              157050, -- Onsite Yard
              173521  -- Advanced Solutions Onsite
          )
    ;;
  }

  ############################
  ## Dimensions
  ############################

  dimension:  daily_timestamp {
    type:  date
    sql: ${TABLE}.daily_timestamp ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.equipment_class ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
    value_format: "0"
  }

  dimension: serial_number_or_vin {
    label: "Serial/VIN"
    type: string
    sql: ${TABLE}.serial_number_or_vin ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension:  horsepower {
    type:  number
    sql:  ${TABLE}.horsepower ;;
  }

  dimension: weight_lbs {
    type: number
    sql:  ${TABLE}.weight_lbs ;;
  }

  dimension: engine_model_name {
    type:  string
    sql:  ${TABLE}.engine_model_name ;;
  }

  dimension: engine_make_name {
    type:  string
    sql:  ${TABLE}.engine_make_name ;;
  }

  dimension: engine_serial_number {
    type:  string
    sql:  ${TABLE}.engine_serial_number ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}.oec ;;
    value_format: "$#,##0.00"
  }
  ############################
  ## Measures
  ############################

  measure: count {
    type: count
    drill_fields: [asset_id, description, market_name, equipment_class, make, model, year, serial_number_or_vin, category]
  }

  ############################
  ## Optional Ordering
  ############################

  set: default_drill {
    fields: [asset_id, description, market_name, equipment_class, make, model, year, serial_number_or_vin, category]
  }
}
