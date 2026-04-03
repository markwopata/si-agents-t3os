view: fleet_qbr_historical_utilization {
 derived_table: {
  sql:
        Select
        asset_id,
        timeframe,
        start_date,
        end_date,
        timestamp_updated,
        days_in_period,
        asset_description,
        make,
        asset_class,
        equipment_class_id,
        equipment_model_id,
        equipment_class,
        category,
        sub_category,
        branch_name,
        own_status,
        company_id,
        asset_inventory_status,
        oec,
        days_on_rent,
        days_in_fleet,
        asset_count,
        revenue,
        rental_oec,
        in_fleet_oec,
        oec_adjusted
        from data_science_stage.fleet_testing.utilization_historical_working
          ;;
}

  dimension: p_key {
    type: string
    primary_key: yes
    hidden: no
    sql: CONCAT(${TABLE}."ASSET_ID", ${TABLE}."TIMEFRAME", ${TABLE}."START_DATE") ;;
  }

  dimension: asset_id {
    type:  number
    hidden:  yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: timeframe {
    type:  string
    hidden:  no
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: asset_description {
    type:  string
    hidden:  no
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }

  dimension: equipment_make {
    type:  string
    hidden:  no
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: equipment_class {
    type:  string
    hidden:  no
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type:  string
    hidden:  no
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: sub_category {
    type:  string
    hidden:  no
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: own_status {
    type:  string
    hidden:  no
    sql: ${TABLE}."OWN_STATUS" ;;
  }

  dimension: company_id {
    type:  string
    hidden:  no
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_inventory_status {
    type:  string
    hidden:  no
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: days_in_period {
    type:  number
    sql: ${TABLE}."DAYS_IN_PERIOD" ;;
  }

  dimension: original_equipment_cost  {
    type:  number
    value_format: "$#,###.00"
    sql: ${TABLE}."OEC" ;;
  }

  dimension: days_on_rent  {
    type:  number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: days_in_fleet  {
    type:  number
    sql: ${TABLE}."DAYS_IN_FLEET" ;;
  }

  dimension: asset_count  {
    type:  number
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  dimension: revenue  {
    type:  number
    value_format: "$#,###.00"
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: rental_oec  {
    type:  number
    value_format: "$#,###.00"
    sql: ${TABLE}."RENTAL_OEC" ;;
  }

  dimension: in_fleet_oec  {
    type:  number
    value_format: "$#,###.00"
    sql: ${TABLE}."IN_FLEET_OEC" ;;
  }

  dimension: oec_adjusted  {
    type:  number
    value_format: "$#,###.00"
    sql: ${TABLE}."OEC_ADJUSTED" ;;
  }
}
